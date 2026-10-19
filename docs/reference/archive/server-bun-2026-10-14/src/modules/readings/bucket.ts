export type ReadingBucket = 'raw' | '15m' | '1h'

export function normalizeBucket(value: string | undefined): ReadingBucket {
  if (value === 'raw' || value === '1h') return value
  return '15m'
}
