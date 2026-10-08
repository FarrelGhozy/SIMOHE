import { describe, expect, test } from 'bun:test'
import {
  buildEvent,
  deviceOfflineEvent,
  fromDeviceEvent,
  matureEvent,
} from '../../src/services/event'

describe('event service', () => {
  test('buildEvent memakai severity default per tipe', () => {
    expect(buildEvent({ deviceId: 1, type: 'temp_high', message: 'x' }).severity).toBe('critical')
    expect(buildEvent({ deviceId: 1, type: 'heater_on', message: 'x' }).severity).toBe('info')
  })

  test('buildEvent menghormati severity eksplisit', () => {
    expect(
      buildEvent({ deviceId: 1, type: 'mature', message: 'x', severity: 'warning' }).severity,
    ).toBe('warning')
  })

  test('matureEvent membawa payload ambang', () => {
    const event = matureEvent(1, 26, 25)
    expect(event.type).toBe('mature')
    expect(event.payload).toEqual({ nh3_ppm: 26, threshold_ppm: 25 })
  })

  test('fromDeviceEvent memetakan SAFETY_CUTOFF', () => {
    const event = fromDeviceEvent(1, 'SAFETY_CUTOFF', 'heater_max_on')
    expect(event?.type).toBe('safety_cutoff')
    expect(event?.severity).toBe('critical')
  })

  test('fromDeviceEvent tidak null untuk kode tak dikenal', () => {
    expect(fromDeviceEvent(1, 'WHATEVER')).not.toBeNull()
  })

  test('deviceOfflineEvent menyertakan last_seen_at', () => {
    const event = deviceOfflineEvent(1, new Date('2026-10-08T10:00:00Z'))
    expect(event.type).toBe('device_offline')
    expect(event.payload).toEqual({ last_seen_at: '2026-10-08T10:00:00.000Z' })
  })
})
