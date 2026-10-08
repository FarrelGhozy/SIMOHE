import { Elysia, t } from 'elysia'
import { authApp } from '../../middlewares/auth-app'
import { countUnread, listEvents, markAllEventsRead, markEventRead } from './service'

export const eventRoutes = new Elysia({ prefix: '/api' })
  .use(authApp)
  .get(
    '/events',
    async ({ device, query }) => {
      const items = await listEvents(device.id, {
        unreadOnly: query.unread === true,
        limit: query.limit ?? 50,
      })
      return { items, unread_count: await countUnread(device.id) }
    },
    {
      app: true,
      query: t.Object({
        unread: t.Optional(t.Boolean()),
        limit: t.Optional(t.Integer({ minimum: 1, maximum: 500 })),
      }),
    },
  )
  .post('/events/read-all', ({ device }) => markAllEventsRead(device.id), { app: true })
  .post('/events/:id/read', ({ device, params }) => markEventRead(device.id, Number(params.id)), {
    app: true,
    params: t.Object({ id: t.Numeric({ minimum: 1 }) }),
  })
