import { eq } from 'drizzle-orm'
import { db } from '../../db/client'
import { type Settings, settings } from '../../db/schema'
import { AppError } from '../../lib/app-error'

export async function getOrCreateSettings(deviceId: number): Promise<Settings> {
  const [existing] = await db
    .select()
    .from(settings)
    .where(eq(settings.deviceId, deviceId))
    .limit(1)
  if (existing) return existing

  await db.insert(settings).values({ deviceId })
  const [created] = await db.select().from(settings).where(eq(settings.deviceId, deviceId)).limit(1)
  if (!created) {
    throw new AppError(500, 'SETTINGS_MISSING', 'Gagal membuat settings default')
  }
  return created
}

export interface SettingsPatch {
  history_interval_min?: number
  ingest_interval_sec?: number
  temp_min_c?: number
  temp_max_c?: number
  temp_hysteresis_c?: number
  nh3_mature_ppm?: number
  mature_hold_min?: number
  heater_auto?: boolean
  heater_max_on_min?: number
  valve_max_open_min?: number
  command_ttl_sec?: number
  raw_retention_days?: number
}

export function toSettingsResponse(row: Settings) {
  return {
    id: row.id,
    device_id: row.deviceId,
    history_interval_min: row.historyIntervalMin,
    ingest_interval_sec: row.ingestIntervalSec,
    temp_min_c: row.tempMinC,
    temp_max_c: row.tempMaxC,
    temp_hysteresis_c: row.tempHysteresisC,
    nh3_mature_ppm: row.nh3MaturePpm,
    mature_hold_min: row.matureHoldMin,
    heater_auto: row.heaterAuto === 1,
    heater_max_on_min: row.heaterMaxOnMin,
    valve_max_open_min: row.valveMaxOpenMin,
    command_ttl_sec: row.commandTtlSec,
    raw_retention_days: row.rawRetentionDays,
    updated_at: row.updatedAt.toISOString(),
  }
}

export async function updateSettings(deviceId: number, patch: SettingsPatch): Promise<Settings> {
  await getOrCreateSettings(deviceId)

  const values: Partial<typeof settings.$inferInsert> = {}
  if (patch.history_interval_min !== undefined)
    values.historyIntervalMin = patch.history_interval_min
  if (patch.ingest_interval_sec !== undefined) values.ingestIntervalSec = patch.ingest_interval_sec
  if (patch.temp_min_c !== undefined) values.tempMinC = patch.temp_min_c
  if (patch.temp_max_c !== undefined) values.tempMaxC = patch.temp_max_c
  if (patch.temp_hysteresis_c !== undefined) values.tempHysteresisC = patch.temp_hysteresis_c
  if (patch.nh3_mature_ppm !== undefined) values.nh3MaturePpm = patch.nh3_mature_ppm
  if (patch.mature_hold_min !== undefined) values.matureHoldMin = patch.mature_hold_min
  if (patch.heater_auto !== undefined) values.heaterAuto = patch.heater_auto ? 1 : 0
  if (patch.heater_max_on_min !== undefined) values.heaterMaxOnMin = patch.heater_max_on_min
  if (patch.valve_max_open_min !== undefined) values.valveMaxOpenMin = patch.valve_max_open_min
  if (patch.command_ttl_sec !== undefined) values.commandTtlSec = patch.command_ttl_sec
  if (patch.raw_retention_days !== undefined) values.rawRetentionDays = patch.raw_retention_days

  if (Object.keys(values).length > 0) {
    await db.update(settings).set(values).where(eq(settings.deviceId, deviceId))
  }

  return getOrCreateSettings(deviceId)
}
