import pino from 'pino'
import { env, isProduction } from './env'

export const logger = pino(
  isProduction
    ? { level: env.LOG_LEVEL }
    : {
        level: env.LOG_LEVEL,
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:standard' },
        },
      },
)
