import type { EventSeverity, EventType, NewEvent } from '../db/schema'

export interface BuildEventInput {
  deviceId: number
  type: EventType
  message: string
  severity?: EventSeverity
  payload?: Record<string, unknown>
}

const defaultSeverity: Record<EventType, EventSeverity> = {
  mature: 'info',
  temp_low: 'warning',
  temp_high: 'critical',
  heater_on: 'info',
  heater_off: 'info',
  valve_open: 'info',
  valve_close: 'info',
  device_offline: 'warning',
  device_online: 'info',
  safety_cutoff: 'critical',
}

interface DeviceEventMap {
  type: EventType
  severity: EventSeverity
  message: string
}

const deviceEventMap: Record<string, DeviceEventMap> = {
  SAFETY_CUTOFF: {
    type: 'safety_cutoff',
    severity: 'critical',
    message: 'Safety cutoff dipicu oleh perangkat',
  },
  DEVICE_ONLINE: {
    type: 'device_online',
    severity: 'info',
    message: 'Perangkat kembali online',
  },
}

export function buildEvent(input: BuildEventInput): NewEvent {
  return {
    deviceId: input.deviceId,
    type: input.type,
    severity: input.severity ?? defaultSeverity[input.type],
    message: input.message,
    payload: input.payload ?? null,
  }
}

export function matureEvent(deviceId: number, nh3Ppm: number, thresholdPpm: number): NewEvent {
  return buildEvent({
    deviceId,
    type: 'mature',
    message: `Pupuk matang: NH3 ${nh3Ppm} ppm bertahan di atas ambang ${thresholdPpm} ppm`,
    severity: 'info',
    payload: { nh3_ppm: nh3Ppm, threshold_ppm: thresholdPpm },
  })
}

export function deviceOfflineEvent(deviceId: number, lastSeenAt: Date | null): NewEvent {
  return buildEvent({
    deviceId,
    type: 'device_offline',
    message: 'Perangkat tidak mengirim data (offline)',
    payload: { last_seen_at: lastSeenAt?.toISOString() ?? null },
  })
}

export function deviceOnlineEvent(deviceId: number): NewEvent {
  return buildEvent({
    deviceId,
    type: 'device_online',
    message: 'Perangkat kembali online',
    payload: {},
  })
}

export function fromDeviceEvent(
  deviceId: number,
  code: string,
  detail?: string,
  ts?: string,
): NewEvent | null {
  const mapped = deviceEventMap[code.toUpperCase()]
  if (!mapped) return null

  return buildEvent({
    deviceId,
    type: mapped.type,
    severity: mapped.severity,
    message: detail ? `${mapped.message} (${detail})` : mapped.message,
    payload: { code, detail, ts },
  })
}
