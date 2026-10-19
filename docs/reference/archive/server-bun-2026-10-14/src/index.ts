import { app } from './app'
import { pool } from './db/client'
import { env } from './env'
import { startJobs } from './jobs'
import type { Scheduler } from './lib/scheduler'
import { logger } from './logger'

app.listen(env.PORT, () => {
  logger.info(`SIMOHE server berjalan di http://localhost:${env.PORT}`)
  if (env.NODE_ENV !== 'production') {
    logger.info(`Dokumentasi API: http://localhost:${env.PORT}/api/docs`)
  }
})

const scheduler: Scheduler | null = env.JOBS_ENABLED ? startJobs() : null
if (!env.JOBS_ENABLED) {
  logger.warn('job background dimatikan (JOBS_ENABLED=false)')
}

let shuttingDown = false
async function shutdown(signal: string): Promise<void> {
  if (shuttingDown) return
  shuttingDown = true
  logger.info({ signal }, 'menghentikan server...')
  scheduler?.stop()
  await app.stop()
  await pool.end()
  process.exit(0)
}

process.on('SIGINT', () => void shutdown('SIGINT'))
process.on('SIGTERM', () => void shutdown('SIGTERM'))

export { app }
