import { describe, expect, test } from 'bun:test'
import { deriveStatus, deriveThermalEvents, type ThermalSnapshot } from '../../src/services/thermal'

const thresholds = { tempMinC: 30, tempMaxC: 45 }

function snapshot(partial: Partial<ThermalSnapshot>): ThermalSnapshot {
  return {
    tempC: 33,
    tempOk: true,
    heaterOn: false,
    valveOpen: false,
    mode: 'AUTO',
    ...partial,
  }
}

describe('deriveStatus', () => {
  test('sensor gagal -> error', () => {
    expect(deriveStatus({ tempOk: false, valveOpen: false, mature: false, heaterOn: false })).toBe(
      'error',
    )
  })

  test('katup terbuka -> draining', () => {
    expect(deriveStatus({ tempOk: true, valveOpen: true, mature: true, heaterOn: true })).toBe(
      'draining',
    )
  })

  test('matang -> mature', () => {
    expect(deriveStatus({ tempOk: true, valveOpen: false, mature: true, heaterOn: false })).toBe(
      'mature',
    )
  })

  test('heater menyala -> heating', () => {
    expect(deriveStatus({ tempOk: true, valveOpen: false, mature: false, heaterOn: true })).toBe(
      'heating',
    )
  })

  test('default -> idle', () => {
    expect(deriveStatus({ tempOk: true, valveOpen: false, mature: false, heaterOn: false })).toBe(
      'idle',
    )
  })
})

describe('deriveThermalEvents', () => {
  test('suhu turun di bawah minimum memicu temp_low', () => {
    const events = deriveThermalEvents(snapshot({ tempC: 31 }), snapshot({ tempC: 27 }), thresholds)
    expect(events.map((e) => e.type)).toContain('temp_low')
  })

  test('tetap dingin tidak mengulang temp_low', () => {
    const events = deriveThermalEvents(snapshot({ tempC: 27 }), snapshot({ tempC: 26 }), thresholds)
    expect(events.map((e) => e.type)).not.toContain('temp_low')
  })

  test('suhu mencapai batas atas memicu temp_high critical', () => {
    const events = deriveThermalEvents(snapshot({ tempC: 44 }), snapshot({ tempC: 46 }), thresholds)
    const high = events.find((e) => e.type === 'temp_high')
    expect(high?.severity).toBe('critical')
  })

  test('transisi heater memicu heater_on / heater_off', () => {
    const on = deriveThermalEvents(
      snapshot({ heaterOn: false }),
      snapshot({ heaterOn: true }),
      thresholds,
    )
    expect(on.map((e) => e.type)).toContain('heater_on')

    const off = deriveThermalEvents(
      snapshot({ heaterOn: true }),
      snapshot({ heaterOn: false }),
      thresholds,
    )
    expect(off.map((e) => e.type)).toContain('heater_off')
  })

  test('transisi katup memicu valve_open / valve_close', () => {
    const open = deriveThermalEvents(
      snapshot({ valveOpen: false }),
      snapshot({ valveOpen: true }),
      thresholds,
    )
    expect(open.map((e) => e.type)).toContain('valve_open')

    const close = deriveThermalEvents(
      snapshot({ valveOpen: true }),
      snapshot({ valveOpen: false }),
      thresholds,
    )
    expect(close.map((e) => e.type)).toContain('valve_close')
  })

  test('sensor suhu gagal memicu safety_cutoff', () => {
    const events = deriveThermalEvents(
      snapshot({ tempOk: true }),
      snapshot({ tempOk: false, tempC: null }),
      thresholds,
    )
    expect(events.map((e) => e.type)).toContain('safety_cutoff')
  })
})
