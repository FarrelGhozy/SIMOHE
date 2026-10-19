import { eq } from 'drizzle-orm'
import { db } from '../../src/db/client'
import { batches, type Device, latestState } from '../../src/db/schema'
import { apiRequest, appHeaders, readJson, resetDatabase, seedDevice } from '../integration/helpers'

export interface LiveView {
  device: { online: boolean; last_seen_at: string | null }
  state: { valve_open: boolean; heater_on: boolean }
  maturity: { mature: boolean; progress: number; streak_sec: number }
}

export interface EventView {
  type: string
  severity: string
  payload: Record<string, unknown>
}

export async function seedTestDevice(): Promise<Device> {
  await resetDatabase()
  return seedDevice()
}

export async function setSettings(patch: Record<string, unknown>): Promise<void> {
  const response = await apiRequest('/api/settings', {
    method: 'PUT',
    headers: appHeaders(),
    body: JSON.stringify(patch),
  })
  if (response.status !== 200) {
    throw new Error(`gagal set settings: ${response.status} ${await response.text()}`)
  }
}

export async function getLive(): Promise<LiveView> {
  const response = await apiRequest('/api/live', { headers: appHeaders() })
  return readJson(response)
}

export async function listEvents(): Promise<EventView[]> {
  const response = await apiRequest('/api/events?limit=100', { headers: appHeaders() })
  const body = (await readJson(response)) as { items: EventView[] }
  return body.items
}

export async function getLatest(deviceId: number) {
  const [row] = await db
    .select()
    .from(latestState)
    .where(eq(latestState.deviceId, deviceId))
    .limit(1)
  return row
}

export async function backdateState(deviceId: number, seconds: number): Promise<void> {
  await db
    .update(latestState)
    .set({ updatedAt: new Date(Date.now() - seconds * 1000) })
    .where(eq(latestState.deviceId, deviceId))
}

export async function getBatch(deviceId: number) {
  const [row] = await db.select().from(batches).where(eq(batches.deviceId, deviceId)).limit(1)
  return row
}
