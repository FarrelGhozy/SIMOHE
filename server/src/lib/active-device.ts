import { asc } from 'drizzle-orm'
import { db } from '../db/client'
import { type Device, devices } from '../db/schema'
import { AppError } from './app-error'

export async function getActiveDevice(): Promise<Device> {
  const [device] = await db.select().from(devices).orderBy(asc(devices.id)).limit(1)
  if (!device) {
    throw new AppError(404, 'DEVICE_NOT_FOUND', 'Belum ada device terdaftar')
  }
  return device
}
