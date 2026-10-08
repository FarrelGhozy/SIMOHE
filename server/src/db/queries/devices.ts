import { asc, eq } from 'drizzle-orm'
import { db } from '../client'
import { type Device, devices, type Settings, settings } from '../schema'

export interface DeviceWithSettings {
  device: Device
  settings: Settings
}

export async function listDevicesWithSettings(): Promise<DeviceWithSettings[]> {
  const rows = await db
    .select({ device: devices, settings })
    .from(devices)
    .leftJoin(settings, eq(settings.deviceId, devices.id))
    .orderBy(asc(devices.id))

  const result: DeviceWithSettings[] = []
  for (const row of rows) {
    if (row.settings) {
      result.push({ device: row.device, settings: row.settings })
      continue
    }

    await db.insert(settings).values({ deviceId: row.device.id })
    const [created] = await db
      .select()
      .from(settings)
      .where(eq(settings.deviceId, row.device.id))
      .limit(1)
    if (created) {
      result.push({ device: row.device, settings: created })
    }
  }
  return result
}
