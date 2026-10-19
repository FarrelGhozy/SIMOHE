import { Elysia } from 'elysia'
import { AppError } from '../lib/app-error'
import { logger } from '../logger'

export { AppError }

interface ErrorBody {
  error: { code: string; message: string }
}

function body(code: string, message: string): ErrorBody {
  return { error: { code, message } }
}

export const errorHandler = new Elysia({ name: 'error-handler' }).onError(
  { as: 'global' },
  (ctx): ErrorBody => {
    if (ctx.error instanceof AppError) {
      ctx.set.status = ctx.error.status
      return body(ctx.error.code, ctx.error.message)
    }

    switch (ctx.code) {
      case 'VALIDATION': {
        const first = ctx.error.all[0]
        ctx.set.status = 400
        return body('VALIDATION_ERROR', first?.message ?? 'Payload tidak valid')
      }
      case 'NOT_FOUND':
        ctx.set.status = 404
        return body('NOT_FOUND', `Rute tidak ditemukan: ${ctx.path}`)
      case 'PARSE':
        ctx.set.status = 400
        return body('INVALID_JSON', 'Body bukan JSON yang valid')
      default:
        logger.error({ err: ctx.error, path: ctx.path }, 'unhandled error')
        ctx.set.status = 500
        return body('INTERNAL_ERROR', 'Terjadi kesalahan pada server')
    }
  },
)
