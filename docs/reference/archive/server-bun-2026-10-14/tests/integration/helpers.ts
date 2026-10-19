import { eq, sql } from 'drizzle-orm'
import { app } from '../../src/app'
import { db } from '../../src/db/client'
import { batches, devices, latestState, settings } from '../../src/db/schema'
import { hashDeviceKey } from '../../src/lib/hash'

export const TEST_DEVICE_KEY = 'test-device-key'
export const TEST_APP_TOKEN = 'test-app-token'

const tables = [
  'events',
  'commands',
  'telemetry_raw',
  'sensor_readings',
  'batches',
  'latest_state',
  'settings',
  'devices',
]

export async function resetDatabase(): Promise<void> {
  await db.execute(sql`SET FOREIGN_KEY_CHECKS = 0`)
  for (const table of tables) {
    await db.execute(sql.raw(`TRUNCATE TABLE \`${table}\``))
  }
  await db.execute(sql`SET FOREIGN_KEY_CHECKS = 1`)
}

export async function seedDevice() {
  const keyHash = hashDeviceKey(TEST_DEVICE_KEY)
  await db.insert(devices).values({ name: 'Test Reaktor', deviceKey: keyHash, isOnline: 0 })

  const [device] = await db.select().from(devices).where(eq(devices.deviceKey, keyHash)).limit(1)
  if (!device) throw new Error('gagal seed device')

  await db.insert(settings).values({ deviceId: device.id })
  await db.insert(latestState).values({ deviceId: device.id })
  await db.insert(batches).values({ deviceId: device.id, startedAt: new Date() })
  return device
}

export function apiRequest(path: string, init?: RequestInit): Promise<Response> {
  return app.handle(new Request(`http://localhost${path}`, init))
}

export async function readJson(response: Response) {
  return JSON.parse(await response.text())
}

export function jsonHeaders(extra: Record<string, string> = {}): Record<string, string> {
  return { 'content-type': 'application/json', ...extra }
}

export function deviceHeaders(): Record<string, string> {
  return jsonHeaders({ 'x-device-key': TEST_DEVICE_KEY })
}

export function appHeaders(): Record<string, string> {
  return jsonHeaders({ authorization: `Bearer ${TEST_APP_TOKEN}` })
}

export function ingest(body: unknown, headers: Record<string, string> = deviceHeaders()) {
  return apiRequest('/api/iot/ingest', {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  })
}
