import type { HeaterMode } from '../../src/db/schema'

export interface DeviceState {
  heater: boolean
  valve: boolean
  valveOpenedAt: number | null
  mode: HeaterMode
  forceOnUntil: number | null
}

export interface SimCommand {
  id: string
  action: string
  args: Record<string, unknown>
  expires_at: string | null
}

export interface HeaterThresholds {
  tempMinC: number
  tempMaxC: number
  hysteresisC: number
}

export function createDeviceState(): DeviceState {
  return { heater: false, valve: false, valveOpenedAt: null, mode: 'AUTO', forceOnUntil: null }
}

export function applyCommand(state: DeviceState, command: SimCommand, now: number): boolean {
  switch (command.action) {
    case 'valve_open':
      if (!state.valve) state.valveOpenedAt = now
      state.valve = true
      return true
    case 'valve_close':
      state.valve = false
      state.valveOpenedAt = null
      return true
    case 'heater_on': {
      const minutes = Number(command.args.duration_min ?? 30)
      state.mode = 'FORCE_ON'
      state.forceOnUntil = now + minutes * 60_000
      return true
    }
    case 'heater_off':
      state.mode = 'FORCE_OFF'
      state.forceOnUntil = null
      return true
    case 'heater_auto':
      state.mode = 'AUTO'
      state.forceOnUntil = null
      return true
    default:
      return false
  }
}

function autoHeater(previousOn: boolean, tempC: number, t: HeaterThresholds): boolean {
  if (previousOn) return tempC < t.tempMinC + t.hysteresisC
  return tempC < t.tempMinC
}

export function computeHeater(
  state: DeviceState,
  tempC: number | null,
  thresholds: HeaterThresholds,
  now: number,
): boolean {
  if (tempC === null) {
    state.heater = false
    return false
  }

  if (tempC >= thresholds.tempMaxC) {
    state.mode = 'AUTO'
    state.forceOnUntil = null
    state.heater = false
    return false
  }

  if (state.mode === 'FORCE_OFF') {
    state.heater = false
    return false
  }

  if (state.mode === 'FORCE_ON' && state.forceOnUntil !== null && now < state.forceOnUntil) {
    state.heater = true
    return true
  }

  if (state.mode === 'FORCE_ON') {
    state.mode = 'AUTO'
    state.forceOnUntil = null
  }

  state.heater = autoHeater(state.heater, tempC, thresholds)
  return state.heater
}

/**
 * Meniru safety firmware: katup ditutup paksa bila terbuka melewati
 * `valve_max_open_min`. Mengembalikan `true` saat baru saja menutup agar
 * pemanggil dapat mengirim event SAFETY_CUTOFF.
 */
export function enforceValveSafety(state: DeviceState, now: number, maxOpenMin: number): boolean {
  if (!state.valve || state.valveOpenedAt === null) return false
  const maxOpenMs = Math.max(maxOpenMin, 1) * 60_000
  if (now - state.valveOpenedAt < maxOpenMs) return false
  state.valve = false
  state.valveOpenedAt = null
  return true
}
