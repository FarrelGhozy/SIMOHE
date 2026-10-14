import { eq } from 'drizzle-orm'
import { db } from '../db/client'
import { listDevicesWithSettings } from '../db/queries/devices'
import { devices, events } from '../db/schema'
import type { ScheduledJob } from '../lib/scheduler'
import { elapsedSeconds } from '../lib/time'
import { logger } from '../logger'
import { deviceOfflineEvent } from '../services/event'

export const OFFLINE_DETECT_TICK_MS = 30_000

export async function runOfflineDetector(now: Date = new Date()): Promise<number> {
  const devicesWithSettings = await listDevicesWithSettings()
  let marked = 0

  for (const { device, settings } of devicesWithSettings) {
    if (device.isOnline !== 1 || !device.lastSeenAt) continue

    const thresholdSec = settings.ingestIntervalSec * 3
    if (elapsedSeconds(now, device.lastSeenAt) <= thresholdSec) continue

    await db.update(devices).set({ isOnline: 0 }).where(eq(devices.id, device.id))
    await db.insert(events).values(deviceOfflineEvent(device.id, device.lastSeenAt))
    marked += 1
    logger.warn({ deviceId: device.id }, 'perangkat ditandai offline')
  }

  return marked
}

export const offlineDetectorJob: ScheduledJob = {
  name: 'offline-detector',
  intervalMs: OFFLINE_DETECT_TICK_MS,
  runOnStart: true,
  run: async () => {
    await runOfflineDetector()
  },
}
