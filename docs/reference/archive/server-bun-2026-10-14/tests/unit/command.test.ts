import { describe, expect, test } from 'bun:test'
import {
  computeExpiry,
  isDeliverable,
  isExpired,
  nextStatusOnAck,
  nextStatusOnDeliver,
} from '../../src/services/command'

describe('command service', () => {
  const now = new Date('2026-10-08T10:00:00Z')

  test('computeExpiry menambahkan TTL detik', () => {
    expect(computeExpiry(now, 60).toISOString()).toBe('2026-10-08T10:01:00.000Z')
  })

  test('isExpired benar setelah TTL', () => {
    expect(isExpired(new Date('2026-10-08T09:59:00Z'), now)).toBe(true)
    expect(isExpired(new Date('2026-10-08T10:01:00Z'), now)).toBe(false)
  })

  test('hanya pending & belum kedaluwarsa yang dapat dikirim', () => {
    expect(
      isDeliverable({ status: 'pending', expiresAt: new Date('2026-10-08T10:01:00Z') }, now),
    ).toBe(true)
    expect(
      isDeliverable({ status: 'sent', expiresAt: new Date('2026-10-08T10:01:00Z') }, now),
    ).toBe(false)
    expect(
      isDeliverable({ status: 'pending', expiresAt: new Date('2026-10-08T09:59:00Z') }, now),
    ).toBe(false)
  })

  test('transisi status', () => {
    expect(nextStatusOnDeliver('pending')).toBe('sent')
    expect(nextStatusOnDeliver('acked')).toBe('acked')
    expect(nextStatusOnAck(true)).toBe('acked')
    expect(nextStatusOnAck(false)).toBe('failed')
  })
})
