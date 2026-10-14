import { describe, expect, test } from 'bun:test'
import { evaluateMaturity, holdSeconds, toMaturityInfo } from '../../src/services/maturity'

const base = {
  nh3Ppm: 26,
  thresholdPpm: 25,
  holdMin: 30,
  previousStreakSec: 0,
  wasMature: false,
  elapsedSec: 10,
  maxGapSec: 30,
}

describe('evaluateMaturity', () => {
  test('NH3 di bawah ambang mereset streak', () => {
    const result = evaluateMaturity({ ...base, nh3Ppm: 10, previousStreakSec: 600 })
    expect(result.streakSec).toBe(0)
    expect(result.progress).toBe(0)
    expect(result.mature).toBe(false)
  })

  test('NH3 di atas ambang mengakumulasi elapsed', () => {
    const result = evaluateMaturity({
      ...base,
      previousStreakSec: 100,
      elapsedSec: 50,
      maxGapSec: 100,
    })
    expect(result.streakSec).toBe(150)
  })

  test('progress 0.5 setelah setengah hold', () => {
    const half = holdSeconds(30) / 2
    const result = evaluateMaturity({ ...base, previousStreakSec: half, elapsedSec: 0 })
    expect(result.progress).toBe(0.5)
    expect(result.mature).toBe(false)
  })

  test('matang setelah hold dan justMatured true', () => {
    const result = evaluateMaturity({ ...base, previousStreakSec: holdSeconds(30) })
    expect(result.mature).toBe(true)
    expect(result.justMatured).toBe(true)
    expect(result.progress).toBe(1)
  })

  test('sudah matang sebelumnya tidak memicu justMatured', () => {
    const result = evaluateMaturity({
      ...base,
      previousStreakSec: holdSeconds(30) + 60,
      wasMature: true,
    })
    expect(result.mature).toBe(true)
    expect(result.justMatured).toBe(false)
  })

  test('gap terlalu lama (offline) mereset streak', () => {
    const result = evaluateMaturity({
      ...base,
      previousStreakSec: 600,
      elapsedSec: 120,
      maxGapSec: 30,
    })
    expect(result.streakSec).toBe(0)
  })
})

describe('toMaturityInfo', () => {
  test('menghitung progress dan batas', () => {
    const info = toMaturityInfo(holdSeconds(30) / 2, 25, 30)
    expect(info.progress).toBe(0.5)
    expect(info.mature).toBe(false)
    expect(info.threshold_ppm).toBe(25)
    expect(info.hold_minutes).toBe(30)
  })
})
