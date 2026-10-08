export interface MaturityInput {
  nh3Ppm: number | null
  thresholdPpm: number
  holdMin: number
  previousStreakSec: number
  wasMature: boolean
  elapsedSec: number
  maxGapSec: number
}

export interface MaturityResult {
  streakSec: number
  progress: number
  mature: boolean
  justMatured: boolean
}

export interface MaturityInfo {
  mature: boolean
  progress: number
  threshold_ppm: number
  hold_minutes: number
  streak_sec: number
}

export function holdSeconds(holdMin: number): number {
  return Math.max(holdMin * 60, 1)
}

export function evaluateMaturity(input: MaturityInput): MaturityResult {
  const holdSec = holdSeconds(input.holdMin)
  const continuous = input.elapsedSec >= 0 && input.elapsedSec <= input.maxGapSec
  const aboveThreshold = input.nh3Ppm !== null && input.nh3Ppm >= input.thresholdPpm

  let streakSec: number
  if (!aboveThreshold) {
    streakSec = 0
  } else if (!continuous) {
    streakSec = 0
  } else {
    streakSec = input.previousStreakSec + input.elapsedSec
  }

  const progress = Math.min(streakSec / holdSec, 1)
  const mature = progress >= 1

  return {
    streakSec: Math.round(streakSec),
    progress: Number(progress.toFixed(4)),
    mature,
    justMatured: mature && !input.wasMature,
  }
}

export function toMaturityInfo(
  streakSec: number,
  thresholdPpm: number,
  holdMin: number,
): MaturityInfo {
  const holdSec = holdSeconds(holdMin)
  return {
    mature: streakSec >= holdSec,
    progress: Number(Math.min(streakSec / holdSec, 1).toFixed(4)),
    threshold_ppm: thresholdPpm,
    hold_minutes: holdMin,
    streak_sec: Math.round(streakSec),
  }
}
