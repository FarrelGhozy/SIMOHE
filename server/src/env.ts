import { type Static, Type } from '@sinclair/typebox'
import { Value } from '@sinclair/typebox/value'

const LogLevel = Type.Union([
  Type.Literal('fatal'),
  Type.Literal('error'),
  Type.Literal('warn'),
  Type.Literal('info'),
  Type.Literal('debug'),
  Type.Literal('trace'),
])

const EnvSchema = Type.Object({
  NODE_ENV: Type.Union([
    Type.Literal('development'),
    Type.Literal('test'),
    Type.Literal('production'),
  ]),
  PORT: Type.Integer({ minimum: 1, maximum: 65535 }),
  LOG_LEVEL: LogLevel,
  DATABASE_URL: Type.String({ minLength: 1 }),
  APP_TOKEN: Type.String({ minLength: 1 }),
  APP_CORS_ORIGIN: Type.String({ minLength: 1 }),
  DEVICE_KEY: Type.Optional(Type.String()),
  DEVICE_NAME: Type.String({ minLength: 1 }),
  DEVICE_LOCATION: Type.Optional(Type.String()),
  RATE_LIMIT_INGEST_PER_SEC: Type.Integer({ minimum: 1 }),
  RATE_LIMIT_APP_PER_SEC: Type.Integer({ minimum: 1 }),
  JOBS_ENABLED: Type.Boolean(),
})

export type Env = Static<typeof EnvSchema>

function toInt(value: string | undefined, fallback: number): number {
  if (value === undefined || value.trim() === '') return fallback
  const parsed = Number(value)
  return Number.isInteger(parsed) ? parsed : Number.NaN
}

function optional(value: string | undefined): string | undefined {
  return value && value.trim() !== '' ? value : undefined
}

const raw = {
  NODE_ENV: process.env.NODE_ENV ?? 'development',
  PORT: toInt(process.env.PORT, 3000),
  LOG_LEVEL: process.env.LOG_LEVEL ?? 'info',
  DATABASE_URL: process.env.DATABASE_URL ?? '',
  APP_TOKEN: process.env.APP_TOKEN ?? '',
  APP_CORS_ORIGIN: process.env.APP_CORS_ORIGIN ?? '*',
  DEVICE_KEY: optional(process.env.DEVICE_KEY),
  DEVICE_NAME: process.env.DEVICE_NAME ?? 'Reaktor Pupuk 1',
  DEVICE_LOCATION: optional(process.env.DEVICE_LOCATION),
  RATE_LIMIT_INGEST_PER_SEC: toInt(process.env.RATE_LIMIT_INGEST_PER_SEC, 1),
  RATE_LIMIT_APP_PER_SEC: toInt(process.env.RATE_LIMIT_APP_PER_SEC, 10),
  JOBS_ENABLED: process.env.JOBS_ENABLED !== 'false',
}

if (!Value.Check(EnvSchema, raw)) {
  const issues = [...Value.Errors(EnvSchema, raw)]
    .map((issue) => `  - ${issue.path}: ${issue.message}`)
    .join('\n')
  throw new Error(
    `Konfigurasi environment tidak valid:\n${issues}\n\nSalin server/.env.example ke server/.env`,
  )
}

export const env: Env = raw
export const isProduction = env.NODE_ENV === 'production'
export const isTest = env.NODE_ENV === 'test'
