import { beforeEach, expect, test } from 'bun:test'
import { runCommandExpiry } from '../../src/jobs/command-expiry'
import { runOfflineDetector } from '../../src/jobs/offline-detector'
import {
  applyCommand,
  computeHeater,
  createDeviceState,
  enforceValveSafety,
} from '../../tools/simulator/device-state'
import { apiRequest, appHeaders, ingest, readJson } from '../integration/helpers'
import {
  backdateState,
  getBatch,
  getLatest,
  getLive,
  listEvents,
  seedTestDevice,
  setSettings,
} from './support'

const THRESHOLDS = { tempMinC: 30, tempMaxC: 45, hysteresisC: 2 }

let device: Awaited<ReturnType<typeof seedTestDevice>>
let seq = 0

async function send(
  telemetry: Record<string, unknown>,
  extra: Record<string, unknown> = {},
): Promise<{ status: number; body: Record<string, unknown> }> {
  seq += 1
  const response = await ingest({
    seq,
    firmware: 'sim-e2e',
    ts: new Date().toISOString(),
    telemetry,
    ...extra,
  })
  return { status: response.status, body: await readJson(response) }
}

async function createCommand(action: string) {
  const response = await apiRequest('/api/commands', {
    method: 'POST',
    headers: appHeaders(),
    body: JSON.stringify({ action }),
  })
  expect(response.status).toBe(201)
  return (await readJson(response)) as { id: string; status: string }
}

async function listCommands() {
  const response = await apiRequest('/api/commands?limit=20', { headers: appHeaders() })
  return (await readJson(response)) as Array<{ id: string; status: string }>
}

function commandIds(body: Record<string, unknown>): string[] {
  const commands = (body.commands as Array<{ id: string }> | undefined) ?? []
  return commands.map((command) => command.id)
}

beforeEach(async () => {
  seq = 0
  device = await seedTestDevice()
  await setSettings({
    history_interval_min: 1,
    mature_hold_min: 1,
    nh3_mature_ppm: 25,
    command_ttl_sec: 5,
    valve_max_open_min: 1,
    ingest_interval_sec: 10,
  })
})

test('T1 suhu 27°C -> heater ON + event temp_low', async () => {
  const simulator = createDeviceState()
  const heater = computeHeater(simulator, 27, THRESHOLDS, Date.now())
  expect(heater).toBe(true)

  const result = await send({
    temp_c: 27,
    nh3_ppm: 10,
    temp_ok: true,
    heater,
    valve: false,
    mode: simulator.mode,
  })
  expect(result.status).toBe(200)

  const events = await listEvents()
  expect(events.some((event) => event.type === 'temp_low')).toBe(true)
  expect((await getLatest(device.id))?.heaterOn).toBe(1)
})

test('T2 suhu 36°C -> heater OFF + event heater_off', async () => {
  const simulator = createDeviceState()

  const on = computeHeater(simulator, 27, THRESHOLDS, Date.now())
  expect(on).toBe(true)
  await send({
    temp_c: 27,
    nh3_ppm: 10,
    temp_ok: true,
    heater: on,
    valve: false,
    mode: simulator.mode,
  })

  const off = computeHeater(simulator, 36, THRESHOLDS, Date.now())
  expect(off).toBe(false)
  await send({
    temp_c: 36,
    nh3_ppm: 10,
    temp_ok: true,
    heater: off,
    valve: false,
    mode: simulator.mode,
  })

  const events = await listEvents()
  expect(events.some((event) => event.type === 'heater_off')).toBe(true)
  expect((await getLatest(device.id))?.heaterOn).toBe(0)
})

test('T3 suhu 46°C -> heater OFF + event temp_high & safety_cutoff', async () => {
  const simulator = createDeviceState()
  const heater = computeHeater(simulator, 46, THRESHOLDS, Date.now())
  expect(heater).toBe(false)
  expect(simulator.mode).toBe('AUTO')

  await send(
    { temp_c: 46, nh3_ppm: 15, temp_ok: true, heater, valve: false, mode: simulator.mode },
    { events: [{ code: 'SAFETY_CUTOFF', detail: 'temp_high', ts: new Date().toISOString() }] },
  )

  const events = await listEvents()
  const tempHigh = events.find((event) => event.type === 'temp_high')
  expect(tempHigh).toBeDefined()
  expect(tempHigh?.severity).toBe('critical')
  expect(events.some((event) => event.type === 'safety_cutoff')).toBe(true)
})

test('T4/T5 kematangan: belum matang lalu event mature tanpa buka katup', async () => {
  const payload = {
    temp_c: 34,
    nh3_ppm: 26,
    temp_ok: true,
    heater: false,
    valve: false,
    mode: 'AUTO',
  }

  await send(payload)
  await backdateState(device.id, 20)
  await send(payload)
  await backdateState(device.id, 20)
  await send(payload)

  let live = await getLive()
  expect(live.maturity.mature).toBe(false)
  expect(live.maturity.progress).toBeGreaterThan(0.3)
  expect(live.maturity.progress).toBeLessThan(0.9)

  await backdateState(device.id, 20)
  await send(payload)

  const events = await listEvents()
  expect(events.some((event) => event.type === 'mature')).toBe(true)

  live = await getLive()
  expect(live.maturity.mature).toBe(true)
  expect(live.state.valve_open).toBe(false)
  expect((await getBatch(device.id))?.status).toBe('mature')
})

test('T6 valve_open -> pending -> sent -> acked', async () => {
  const created = await createCommand('valve_open')
  expect(created.status).toBe('pending')

  const sent = await send({
    temp_c: 30,
    nh3_ppm: 10,
    temp_ok: true,
    heater: false,
    valve: false,
    mode: 'AUTO',
  })
  expect(commandIds(sent.body)).toContain(created.id)

  await send(
    { temp_c: 30, nh3_ppm: 10, temp_ok: true, heater: false, valve: true, mode: 'AUTO' },
    { acks: [{ id: created.id, ok: true }] },
  )

  const commands = await listCommands()
  expect(commands.find((command) => command.id === created.id)?.status).toBe('acked')
  expect((await listEvents()).some((event) => event.type === 'valve_open')).toBe(true)
})

test('T7 command lewat TTL -> expired & tidak dieksekusi', async () => {
  const created = await createCommand('valve_open')

  await runCommandExpiry(new Date(Date.now() + 6_000))

  const commands = await listCommands()
  expect(commands.find((command) => command.id === created.id)?.status).toBe('expired')

  const result = await send({
    temp_c: 31,
    nh3_ppm: 10,
    temp_ok: true,
    heater: false,
    valve: false,
    mode: 'AUTO',
  })
  expect(commandIds(result.body)).not.toContain(created.id)
})

test('T8 katup buka > max_open -> auto-close + safety_cutoff', async () => {
  const simulator = createDeviceState()
  const openedAt = Date.now()
  applyCommand(
    simulator,
    { id: 'cmd-1', action: 'valve_open', args: {}, expires_at: null },
    openedAt,
  )

  const closed = enforceValveSafety(simulator, openedAt + 60_000, 1)
  expect(closed).toBe(true)
  expect(simulator.valve).toBe(false)

  await send(
    { temp_c: 33, nh3_ppm: 10, temp_ok: true, heater: false, valve: false, mode: 'AUTO' },
    { events: [{ code: 'SAFETY_CUTOFF', detail: 'valve_max_open', ts: new Date().toISOString() }] },
  )

  const events = await listEvents()
  expect(events.some((event) => event.type === 'safety_cutoff')).toBe(true)
  expect((await getLatest(device.id))?.valveOpen).toBe(0)
})

test('T9/T10 device offline lalu online kembali', async () => {
  await send({ temp_c: 34, nh3_ppm: 10, temp_ok: true, heater: false, valve: false, mode: 'AUTO' })
  expect((await getLive()).device.online).toBe(true)

  await runOfflineDetector(new Date(Date.now() + 31_000))
  expect((await getLive()).device.online).toBe(false)
  expect((await listEvents()).some((event) => event.type === 'device_offline')).toBe(true)

  await send({ temp_c: 34, nh3_ppm: 10, temp_ok: true, heater: false, valve: false, mode: 'AUTO' })
  expect((await getLive()).device.online).toBe(true)
  expect((await listEvents()).some((event) => event.type === 'device_online')).toBe(true)
})
