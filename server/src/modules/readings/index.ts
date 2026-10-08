import { Elysia, t } from 'elysia'
import { AppError } from '../../lib/app-error'
import { authApp } from '../../middlewares/auth-app'
import { normalizeBucket } from './bucket'
import { getReadings } from './service'

function parseDate(value: string | undefined, fallback: Date): Date {
  if (!value) return fallback
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) {
    throw new AppError(400, 'INVALID_DATE', `Tanggal tidak valid: ${value}`)
  }
  return parsed
}

export const readingsRoutes = new Elysia({ prefix: '/api' }).use(authApp).get(
  '/readings',
  async ({ device, query }) => {
    const now = new Date()
    const from = parseDate(query.from, new Date(now.getTime() - 24 * 3_600_000))
    const to = parseDate(query.to, now)
    const bucket = normalizeBucket(query.bucket)
    const limit = query.limit ?? 500

    const items = await getReadings({ deviceId: device.id, from, to, bucket, limit })
    return { bucket, from: from.toISOString(), to: to.toISOString(), items }
  },
  {
    app: true,
    query: t.Object({
      from: t.Optional(t.String()),
      to: t.Optional(t.String()),
      bucket: t.Optional(t.Union([t.Literal('raw'), t.Literal('15m'), t.Literal('1h')])),
      limit: t.Optional(t.Integer({ minimum: 1, maximum: 5000 })),
    }),
  },
)
