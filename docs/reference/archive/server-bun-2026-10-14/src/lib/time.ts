export function toUtcIso(value: Date | string | null | undefined): string | null {
  if (value === null || value === undefined) return null
  if (value instanceof Date) return value.toISOString()

  const normalized = value.includes('T') ? value : `${value.replace(' ', 'T')}Z`
  const date = new Date(normalized)
  return Number.isNaN(date.getTime()) ? null : date.toISOString()
}

export function elapsedSeconds(now: Date, earlier: Date | null | undefined): number {
  if (!earlier) return 0
  return Math.max(0, (now.getTime() - earlier.getTime()) / 1000)
}

const RANGE_PATTERN = /^(\d+)([mhd])$/

export function parseRange(range: string | undefined, now: Date, fallbackHours = 24): Date {
  if (range === 'all') return new Date(0)
  const match = range ? RANGE_PATTERN.exec(range) : null
  if (!match) return new Date(now.getTime() - fallbackHours * 3_600_000)

  const amount = Number(match[1])
  const unit = match[2]
  const factor = unit === 'm' ? 60_000 : unit === 'h' ? 3_600_000 : 86_400_000
  return new Date(now.getTime() - amount * factor)
}
