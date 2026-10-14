import pino from 'pino'
import { env } from './env'

const usePretty = env.NODE_ENV === 'development'

export const logger = pino(
  usePretty
    ? {
        level: env.LOG_LEVEL,
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:standard' },
        },
      }
    : { level: env.LOG_LEVEL },
)
