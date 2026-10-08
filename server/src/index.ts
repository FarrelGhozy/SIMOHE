import { app } from './app'
import { env } from './env'
import { logger } from './logger'

app.listen(env.PORT, () => {
  logger.info(`SIMOHE server berjalan di http://localhost:${env.PORT}`)
  if (env.NODE_ENV !== 'production') {
    logger.info(`Dokumentasi API: http://localhost:${env.PORT}/api/docs`)
  }
})

export { app }
