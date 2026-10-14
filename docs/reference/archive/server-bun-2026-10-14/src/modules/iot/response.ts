import type { Command, Settings } from '../../db/schema'
import { toUtcIso } from '../../lib/time'

export interface DeviceConfigResponse {
  ingest_interval_sec: number
  temp_min_c: number
  temp_max_c: number
  temp_hysteresis_c: number
  nh3_mature_ppm: number
  mature_hold_min: number
  heater_auto: number
  heater_max_on_min: number
  valve_max_open_min: number
  command_ttl_sec: number
}

export function toDeviceConfig(row: Settings): DeviceConfigResponse {
  return {
    ingest_interval_sec: row.ingestIntervalSec,
    temp_min_c: row.tempMinC,
    temp_max_c: row.tempMaxC,
    temp_hysteresis_c: row.tempHysteresisC,
    nh3_mature_ppm: row.nh3MaturePpm,
    mature_hold_min: row.matureHoldMin,
    heater_auto: row.heaterAuto,
    heater_max_on_min: row.heaterMaxOnMin,
    valve_max_open_min: row.valveMaxOpenMin,
    command_ttl_sec: row.commandTtlSec,
  }
}

export interface CommandDelivery {
  id: string
  action: string
  args: Record<string, unknown>
  expires_at: string | null
}

export function toCommandDelivery(row: Command): CommandDelivery {
  return {
    id: row.id,
    action: row.action,
    args: row.payload ?? {},
    expires_at: toUtcIso(row.expiresAt),
  }
}
