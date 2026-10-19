import { desc, eq } from 'drizzle-orm'
import { db } from '../db/client'
import { listDevicesWithSettings } from '../db/queries/devices'
import { latestState, sensorReadings } from '../db/schema'
import type { ScheduledJob } from '../lib/scheduler'
import { elapsedSeconds } from '../lib/time'
import { logger } from '../logger'

export const SAMPLING_TICK_MS = 30_000

export async function runSampling(now: Date = new Date()): Promise<number> {
  const devicesWithSettings = await listDevicesWithSettings()
  let inserted = 0

  for (const { device, settings } of devicesWithSettings) {
    const intervalSec = settings.historyIntervalMin * 60

    const [last] = await db
      .select({ sampledAt: sensorReadings.sampledAt })
      .from(sensorReadings)
      .where(eq(sensorReadings.deviceId, device.id))
      .orderBy(desc(sensorReadings.sampledAt))
      .limit(1)

    if (last && elapsedSeconds(now, last.sampledAt) < intervalSec) {
      continue
    }

    const [state] = await db
      .select()
      .from(latestState)
      .where(eq(latestState.deviceId, device.id))
      .limit(1)
    if (!state) continue

    await db.insert(sensorReadings).values({
      deviceId: device.id,
      tempC: state.tempC,
      nh3Ppm: state.nh3Ppm,
      heaterOn: state.heaterOn,
      valveOpen: state.valveOpen,
      status: state.status,
      sampledAt: now,
    })
    inserted += 1
  }

  return inserted
}

export const samplingJob: ScheduledJob = {
  name: 'sampling',
  intervalMs: SAMPLING_TICK_MS,
  run: async () => {
    const count = await runSampling()
    if (count > 0) {
      logger.info({ count }, 'sampling menyimpan histori')
    }
  },
}
