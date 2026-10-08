import { Elysia, t } from 'elysia'
import { parseRange } from '../../lib/time'
import { authApp } from '../../middlewares/auth-app'
import { getSummary } from './service'

export const summaryRoutes = new Elysia({ prefix: '/api' }).use(authApp).get(
  '/summary',
  async ({ device, query }) => {
    const now = new Date()
    const from = parseRange(query.range, now, 24)
    return getSummary(device.id, from, now)
  },
  {
    app: true,
    query: t.Object({
      range: t.Optional(t.String({ maxLength: 12 })),
    }),
  },
)
