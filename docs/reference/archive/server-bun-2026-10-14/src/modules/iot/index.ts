import { Elysia } from 'elysia'
import { authDevice } from '../../middlewares/auth-device'
import { ingestTelemetry } from './ingest'
import { ingestBody } from './schema'

export const iotRoutes = new Elysia({ prefix: '/api' })
  .use(authDevice)
  .post('/iot/ingest', async ({ device, body }) => ingestTelemetry(device, body), {
    device: true,
    body: ingestBody,
  })
  .get(
    '/iot/ping',
    ({ device }) => ({
      ok: true,
      device_id: String(device.id),
      server_time: new Date().toISOString(),
    }),
    { device: true },
  )
