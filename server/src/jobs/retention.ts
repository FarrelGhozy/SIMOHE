import { and, eq, inArray, lt } from 'drizzle-orm'
import { db } from '../db/client'
import { listDevicesWithSettings } from '../db/queries/devices'
import { telemetryRaw } from '../db/schema'
import type { ScheduledJob } from '../lib/scheduler'
import { logger } from '../logger'

export const RETENTION_TICK_MS = 24 * 60 * 60 * 1000

export async function runRetention(now: Date = new Date()): Promise<number> {
  const devicesWithSettings = await listDevicesWithSettings()
  let deleted = 0

  for (const { device, settings } of devicesWithSettings) {
    if (settings.rawRetentionDays <= 0) continue

    const cutoff = new Date(now.getTime() - settings.rawRetentionDays * 86_400_000)
    const stale = await db
      .select({ id: telemetryRaw.id })
      .from(telemetryRaw)
      .where(and(eq(telemetryRaw.deviceId, device.id), lt(telemetryRaw.recordedAt, cutoff)))

    if (stale.length === 0) continue

    await db.delete(telemetryRaw).where(
      inArray(
        telemetryRaw.id,
        stale.map((row) => row.id),
      ),
    )
    deleted += stale.length
  }

  return deleted
}

export const retentionJob: ScheduledJob = {
  name: 'retention',
  intervalMs: RETENTION_TICK_MS,
  runOnStart: true,
  run: async () => {
    const count = await runRetention()
    if (count > 0) {
      logger.info({ count }, 'retensi telemetry_raw dijalankan')
    }
  },
}
