import { Elysia, t } from 'elysia'
import { authApp } from '../../middlewares/auth-app'
import { createBatch, harvestBatch, listBatches } from './service'

export const batchRoutes = new Elysia({ prefix: '/api' })
  .use(authApp)
  .get('/batches', ({ device, query }) => listBatches(device.id, query.limit ?? 50), {
    app: true,
    query: t.Object({ limit: t.Optional(t.Integer({ minimum: 1, maximum: 200 })) }),
  })
  .post(
    '/batches',
    ({ device, body, set }) => {
      set.status = 201
      return createBatch(device.id, body?.label)
    },
    {
      app: true,
      body: t.Optional(t.Object({ label: t.Optional(t.String({ maxLength: 120 })) })),
    },
  )
  .post(
    '/batches/:id/harvest',
    ({ device, params }) => harvestBatch(device.id, Number(params.id)),
    {
      app: true,
      params: t.Object({ id: t.Numeric({ minimum: 1 }) }),
    },
  )
