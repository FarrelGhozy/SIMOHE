import { eq } from 'drizzle-orm'
import { db } from '../../db/client'
import { latestState } from '../../db/schema'
import { getActiveDevice } from '../../lib/active-device'
import { elapsedSeconds, toUtcIso } from '../../lib/time'
import { toMaturityInfo } from '../../services/maturity'
import { getOrCreateSettings } from '../settings/service'

export interface LiveResponse {
  device: {
    id: string
    name: string
    location: string | null
    online: boolean
    last_seen_at: string | null
    firmware: string | null
  }
  state: {
    temp_c: number | null
    nh3_ppm: number | null
    temp_ok: boolean
    heater_on: boolean
    valve_open: boolean
    mode: string
    status: string
    updated_at: string | null
  }
  maturity: {
    mature: boolean
    progress: number
    threshold_ppm: number
    hold_minutes: number
    streak_sec: number
  }
}

export async function getLive(): Promise<LiveResponse> {
  const device = await getActiveDevice()
  const settingsRow = await getOrCreateSettings(device.id)
  const [state] = await db
    .select()
    .from(latestState)
    .where(eq(latestState.deviceId, device.id))
    .limit(1)

  const now = new Date()
  const offlineThresholdSec = settingsRow.ingestIntervalSec * 3
  const online =
    device.isOnline === 1 &&
    device.lastSeenAt !== null &&
    elapsedSeconds(now, device.lastSeenAt) <= offlineThresholdSec

  const streakSec = state?.matureStreakSec ?? 0

  return {
    device: {
      id: String(device.id),
      name: device.name,
      location: device.location,
      online,
      last_seen_at: toUtcIso(device.lastSeenAt),
      firmware: device.firmwareVersion,
    },
    state: {
      temp_c: state?.tempC ?? null,
      nh3_ppm: state?.nh3Ppm ?? null,
      temp_ok: (state?.tempOk ?? 1) === 1,
      heater_on: (state?.heaterOn ?? 0) === 1,
      valve_open: (state?.valveOpen ?? 0) === 1,
      mode: state?.mode ?? 'AUTO',
      status: state?.status ?? 'idle',
      updated_at: toUtcIso(state?.updatedAt),
    },
    maturity: toMaturityInfo(streakSec, settingsRow.nh3MaturePpm, settingsRow.matureHoldMin),
  }
}
