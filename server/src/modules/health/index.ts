import { sql } from 'drizzle-orm'
import { Elysia } from 'elysia'
import { db } from '../../db/client'
import { logger } from '../../logger'

export const healthRoutes = new Elysia({ prefix: '/api' }).get('/health', async ({ set }) => {
  try {
    await db.execute(sql`SELECT 1`)
    return {
      status: 'ok',
      db: 'up',
      time: new Date().toISOString(),
    }
  } catch (error) {
    logger.error({ err: error }, 'health check gagal')
    set.status = 503
    return {
      status: 'degraded',
      db: 'down',
      time: new Date().toISOString(),
    }
  }
})
