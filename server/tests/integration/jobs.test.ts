import { beforeAll, describe, expect, test } from 'bun:test'
import { eq } from 'drizzle-orm'
import { db } from '../../src/db/client'
import {
  commands,
  devices,
  events,
  latestState,
  sensorReadings,
  settings,
  telemetryRaw,
} from '../../src/db/schema'
import { runCommandExpiry } from '../../src/jobs/command-expiry'
import { runOfflineDetector } from '../../src/jobs/offline-detector'
import { runRetention } from '../../src/jobs/retention'
import { runSampling } from '../../src/jobs/sampling'
import { resetDatabase, seedDevice } from './helpers'

let deviceId: number

beforeAll(async () => {
  await resetDatabase()
  const device = await seedDevice()
  deviceId = device.id
})

describe('job sampling', () => {
  test('menyalin latest_state ke sensor_readings', async () => {
    await db
      .update(latestState)
      .set({ tempC: 33.5, nh3Ppm: 12.25, heaterOn: 1, status: 'heating' })
      .where(eq(latestState.deviceId, deviceId))

    const inserted = await runSampling(new Date())
    expect(inserted).toBe(1)

    const rows = await db.select().from(sensorReadings).where(eq(sensorReadings.deviceId, deviceId))
    expect(rows.length).toBe(1)
    expect(rows[0]?.tempC).toBe(33.5)
    expect(rows[0]?.status).toBe('heating')
  })

  test('tidak menyimpan sebelum interval terlewati', async () => {
    const inserted = await runSampling(new Date())
    expect(inserted).toBe(0)
  })

  test('menyimpan lagi setelah interval terlewati', async () => {
    await db.update(settings).set({ historyIntervalMin: 1 }).where(eq(settings.deviceId, deviceId))
    const inserted = await runSampling(new Date(Date.now() + 61_000))
    expect(inserted).toBe(1)
  })
})

describe('job offline-detector', () => {
  test('menandai offline + event sekali per transisi', async () => {
    await db
      .update(devices)
      .set({ isOnline: 1, lastSeenAt: new Date(Date.now() - 5 * 60_000) })
      .where(eq(devices.id, deviceId))

    const marked = await runOfflineDetector(new Date())
    expect(marked).toBe(1)

    const [device] = await db.select().from(devices).where(eq(devices.id, deviceId))
    expect(device?.isOnline).toBe(0)

    const all = await db.select().from(events).where(eq(events.deviceId, deviceId))
    expect(all.filter((event) => event.type === 'device_offline').length).toBe(1)

    const again = await runOfflineDetector(new Date())
    expect(again).toBe(0)
  })
})

describe('job command-expiry', () => {
  test('menandai pending lewat TTL sebagai expired', async () => {
    await db.insert(commands).values({
      id: crypto.randomUUID(),
      deviceId,
      action: 'valve_open',
      status: 'pending',
      expiresAt: new Date(Date.now() - 1000),
    })
    await db.insert(commands).values({
      id: crypto.randomUUID(),
      deviceId,
      action: 'valve_close',
      status: 'pending',
      expiresAt: new Date(Date.now() + 60_000),
    })

    const count = await runCommandExpiry(new Date())
    expect(count).toBe(1)

    const rows = await db.select().from(commands).where(eq(commands.deviceId, deviceId))
    expect(rows.filter((row) => row.status === 'expired').length).toBe(1)
    expect(rows.filter((row) => row.status === 'pending').length).toBe(1)
  })
})

describe('job retention', () => {
  test('menghapus telemetry_raw lebih tua dari retensi', async () => {
    await db.update(settings).set({ rawRetentionDays: 1 }).where(eq(settings.deviceId, deviceId))

    await db.insert(telemetryRaw).values({
      deviceId,
      tempC: 30,
      nh3Ppm: 5,
      recordedAt: new Date(Date.now() - 3 * 86_400_000),
    })
    await db.insert(telemetryRaw).values({
      deviceId,
      tempC: 31,
      nh3Ppm: 6,
      recordedAt: new Date(),
    })

    const deleted = await runRetention(new Date())
    expect(deleted).toBe(1)

    const rows = await db.select().from(telemetryRaw).where(eq(telemetryRaw.deviceId, deviceId))
    expect(rows.length).toBe(1)
  })
})
