import { eq } from 'drizzle-orm'
import { Elysia } from 'elysia'
import { db } from '../db/client'
import { type Device, devices } from '../db/schema'
import { AppError } from '../lib/app-error'
import { hashDeviceKey } from '../lib/hash'

export async function findDeviceByKey(rawKey: string | undefined): Promise<Device> {
  const key = rawKey?.trim()
  if (!key) {
    throw new AppError(401, 'UNAUTHORIZED', 'Header X-Device-Key wajib diisi')
  }

  const [device] = await db
    .select()
    .from(devices)
    .where(eq(devices.deviceKey, hashDeviceKey(key)))
    .limit(1)

  if (!device) {
    throw new AppError(401, 'UNAUTHORIZED', 'Device key tidak valid')
  }

  return device
}

export const authDevice = new Elysia({ name: 'auth-device' }).macro({
  device: {
    async resolve({ headers }) {
      const device = await findDeviceByKey(headers['x-device-key'])
      return { device }
    },
  },
})
