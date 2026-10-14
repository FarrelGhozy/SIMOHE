import type { DeviceStatus, EventSeverity, EventType, HeaterMode } from '../db/schema'

export interface ThermalSnapshot {
  tempC: number | null
  tempOk: boolean
  heaterOn: boolean
  valveOpen: boolean
  mode: HeaterMode
}

export interface ThermalThresholds {
  tempMinC: number
  tempMaxC: number
}

export interface DerivedEvent {
  type: EventType
  severity: EventSeverity
  message: string
  payload: Record<string, unknown>
}

export function deriveStatus(input: {
  tempOk: boolean
  valveOpen: boolean
  mature: boolean
  heaterOn: boolean
}): DeviceStatus {
  if (!input.tempOk) return 'error'
  if (input.valveOpen) return 'draining'
  if (input.mature) return 'mature'
  if (input.heaterOn) return 'heating'
  return 'idle'
}

export function deriveThermalEvents(
  previous: ThermalSnapshot,
  next: ThermalSnapshot,
  thresholds: ThermalThresholds,
): DerivedEvent[] {
  const events: DerivedEvent[] = []
  const temp = next.tempC

  if (!next.tempOk && previous.tempOk) {
    events.push({
      type: 'safety_cutoff',
      severity: 'critical',
      message: 'Sensor suhu gagal dibaca, heater dimatikan (fail-safe)',
      payload: { reason: 'sensor_error' },
    })
  }

  if (temp !== null) {
    const prevBelowMin = previous.tempC !== null && previous.tempC < thresholds.tempMinC
    if (temp < thresholds.tempMinC && !prevBelowMin) {
      events.push({
        type: 'temp_low',
        severity: 'warning',
        message: `Suhu ${temp}°C di bawah batas minimum ${thresholds.tempMinC}°C`,
        payload: { temp_c: temp, temp_min_c: thresholds.tempMinC },
      })
    }

    const prevAboveMax = previous.tempC !== null && previous.tempC >= thresholds.tempMaxC
    if (temp >= thresholds.tempMaxC && !prevAboveMax) {
      events.push({
        type: 'temp_high',
        severity: 'critical',
        message: `Suhu ${temp}°C mencapai batas aman ${thresholds.tempMaxC}°C`,
        payload: { temp_c: temp, temp_max_c: thresholds.tempMaxC },
      })
    }
  }

  if (next.heaterOn && !previous.heaterOn) {
    events.push({
      type: 'heater_on',
      severity: 'info',
      message: 'Heater menyala',
      payload: { temp_c: temp },
    })
  }
  if (!next.heaterOn && previous.heaterOn) {
    events.push({
      type: 'heater_off',
      severity: 'info',
      message: 'Heater mati',
      payload: { temp_c: temp },
    })
  }
  if (next.valveOpen && !previous.valveOpen) {
    events.push({
      type: 'valve_open',
      severity: 'info',
      message: 'Katup solenoid dibuka',
      payload: {},
    })
  }
  if (!next.valveOpen && previous.valveOpen) {
    events.push({
      type: 'valve_close',
      severity: 'info',
      message: 'Katup solenoid ditutup',
      payload: {},
    })
  }

  return events
}
