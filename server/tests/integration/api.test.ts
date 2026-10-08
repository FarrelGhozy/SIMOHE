import { afterAll, beforeAll, describe, expect, test } from 'bun:test'
import { pool } from '../../src/db/client'
import {
  apiRequest,
  appHeaders,
  deviceHeaders,
  ingest,
  readJson,
  resetDatabase,
  seedDevice,
} from './helpers'

beforeAll(async () => {
  await resetDatabase()
  await seedDevice()
})

afterAll(async () => {
  await pool.end()
})

describe('GET /api/health', () => {
  test('mengembalikan status ok', async () => {
    const response = await apiRequest('/api/health')
    expect(response.status).toBe(200)
    const body = await readJson(response)
    expect(body.status).toBe('ok')
    expect(body.db).toBe('up')
  })
})

describe('autentikasi', () => {
  test('endpoint app tanpa token -> 401', async () => {
    const response = await apiRequest('/api/live')
    expect(response.status).toBe(401)
  })

  test('token app salah -> 401', async () => {
    const response = await apiRequest('/api/live', {
      headers: { authorization: 'Bearer salah' },
    })
    expect(response.status).toBe(401)
  })

  test('device key salah -> 401', async () => {
    const response = await ingest(
      { telemetry: { temp_c: 30 } },
      { 'content-type': 'application/json', 'x-device-key': 'salah' },
    )
    expect(response.status).toBe(401)
  })
})

describe('POST /api/iot/ingest', () => {
  test('memperbarui latest_state dan mengembalikan config', async () => {
    const response = await ingest({
      seq: 1,
      firmware: '0.2.0',
      telemetry: { temp_c: 33, nh3_ppm: 10, heater: false, valve: false, mode: 'AUTO' },
    })
    expect(response.status).toBe(200)

    const body = await readJson(response)
    expect(body.config.ingest_interval_sec).toBe(10)
    expect(body.server_time).toBeString()

    const liveResponse = await apiRequest('/api/live', { headers: appHeaders() })
    const live = await readJson(liveResponse)
    expect(live.state.temp_c).toBe(33)
    expect(live.device.online).toBe(true)
    expect(live.device.firmware).toBe('0.2.0')
  })

  test('suhu di bawah minimum membuat event temp_low', async () => {
    await ingest({ telemetry: { temp_c: 27, nh3_ppm: 5, heater: true } })
    const response = await apiRequest('/api/events', { headers: appHeaders() })
    const body = await readJson(response)
    expect(body.items.some((item: { type: string }) => item.type === 'temp_low')).toBe(true)
  })

  test('payload tidak valid -> 400', async () => {
    const response = await ingest({ telemetry: { nh3_ppm: 5000 } })
    expect(response.status).toBe(400)
    const body = await readJson(response)
    expect(body.error.code).toBe('VALIDATION_ERROR')
  })
})

describe('alur perintah', () => {
  test('pending -> sent -> acked', async () => {
    const createResponse = await apiRequest('/api/commands', {
      method: 'POST',
      headers: appHeaders(),
      body: JSON.stringify({ action: 'valve_open' }),
    })
    expect(createResponse.status).toBe(201)
    const created = await readJson(createResponse)
    expect(created.status).toBe('pending')

    const ingestResponse = await ingest({
      telemetry: { temp_c: 33, nh3_ppm: 5, valve: false },
    })
    const ingestBody = await readJson(ingestResponse)
    expect(ingestBody.commands.map((command: { id: string }) => command.id)).toContain(created.id)

    await ingest({
      telemetry: { temp_c: 33, nh3_ppm: 5, valve: true },
      acks: [{ id: created.id, ok: true }],
    })

    const listResponse = await apiRequest('/api/commands', { headers: appHeaders() })
    const list = await readJson(listResponse)
    const command = list.find((item: { id: string }) => item.id === created.id)
    expect(command.status).toBe('acked')
    expect(command.acked_at).toBeString()
  })

  test('membatalkan perintah pending', async () => {
    const createResponse = await apiRequest('/api/commands', {
      method: 'POST',
      headers: appHeaders(),
      body: JSON.stringify({ action: 'heater_off' }),
    })
    const created = await readJson(createResponse)

    const cancelResponse = await apiRequest(`/api/commands/${created.id}/cancel`, {
      method: 'POST',
      headers: appHeaders(),
    })
    expect(cancelResponse.status).toBe(200)
    const body = await readJson(cancelResponse)
    expect(body.status).toBe('expired')
  })

  test('aksi tidak dikenal -> 400', async () => {
    const response = await apiRequest('/api/commands', {
      method: 'POST',
      headers: appHeaders(),
      body: JSON.stringify({ action: 'reboot' }),
    })
    expect(response.status).toBe(400)
  })
})

describe('GET/PUT /api/settings', () => {
  test('mengubah ambang suhu minimum', async () => {
    const response = await apiRequest('/api/settings', {
      method: 'PUT',
      headers: appHeaders(),
      body: JSON.stringify({ temp_min_c: 28 }),
    })
    expect(response.status).toBe(200)
    const body = await readJson(response)
    expect(body.temp_min_c).toBe(28)
  })

  test('nilai di luar rentang -> 400', async () => {
    const response = await apiRequest('/api/settings', {
      method: 'PUT',
      headers: appHeaders(),
      body: JSON.stringify({ history_interval_min: 0 }),
    })
    expect(response.status).toBe(400)
  })
})

describe('events', () => {
  test('tandai semua dibaca', async () => {
    await apiRequest('/api/iot/ingest', {
      method: 'POST',
      headers: deviceHeaders(),
      body: JSON.stringify({ telemetry: { temp_c: 27, nh3_ppm: 5, heater: true } }),
    })

    const readAll = await apiRequest('/api/events/read-all', {
      method: 'POST',
      headers: appHeaders(),
    })
    expect(readAll.status).toBe(200)

    const response = await apiRequest('/api/events?unread=true', { headers: appHeaders() })
    const body = await readJson(response)
    expect(body.unread_count).toBe(0)
  })
})

describe('batches', () => {
  test('menandai panen', async () => {
    const listResponse = await apiRequest('/api/batches', { headers: appHeaders() })
    const list = await readJson(listResponse)
    const batchId = list[0].id

    const harvest = await apiRequest(`/api/batches/${batchId}/harvest`, {
      method: 'POST',
      headers: appHeaders(),
    })
    expect(harvest.status).toBe(200)
    const body = await readJson(harvest)
    expect(body.status).toBe('harvested')
  })
})
