import { cors } from '@elysiajs/cors'
import { swagger } from '@elysiajs/swagger'
import { Elysia } from 'elysia'
import { env, isProduction } from './env'
import { errorHandler } from './middlewares/error'
import { rateLimiter } from './middlewares/rate-limit'
import { batchRoutes } from './modules/batches'
import { commandRoutes } from './modules/commands'
import { deviceRoutes } from './modules/device'
import { eventRoutes } from './modules/events'
import { healthRoutes } from './modules/health'
import { iotRoutes } from './modules/iot'
import { liveRoutes } from './modules/live'
import { readingsRoutes } from './modules/readings'
import { settingsRoutes } from './modules/settings'
import { summaryRoutes } from './modules/summary'

function corsOrigin(): true | string[] {
  if (env.APP_CORS_ORIGIN.trim() === '*') return true
  return env.APP_CORS_ORIGIN.split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0)
}

export const app = new Elysia()
  .use(errorHandler)
  .use(
    cors({
      origin: corsOrigin(),
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Device-Key'],
      credentials: false,
    }),
  )
  .use(rateLimiter)
  .use(healthRoutes)
  .use(iotRoutes)
  .use(liveRoutes)
  .use(readingsRoutes)
  .use(summaryRoutes)
  .use(settingsRoutes)
  .use(commandRoutes)
  .use(eventRoutes)
  .use(batchRoutes)
  .use(deviceRoutes)

if (!isProduction) {
  app.use(
    swagger({
      path: '/api/docs',
      documentation: {
        info: { title: 'SIMOHE API', version: '0.1.0' },
      },
    }),
  )
}
