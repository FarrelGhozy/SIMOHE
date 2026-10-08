import { Elysia } from 'elysia'
import { env } from '../env'
import { AppError } from './error'

export function verifyAppToken(authorization: string | undefined): void {
  const token = authorization?.startsWith('Bearer ') ? authorization.slice(7).trim() : ''
  if (token === '' || token !== env.APP_TOKEN) {
    throw new AppError(401, 'UNAUTHORIZED', 'Token aplikasi tidak valid')
  }
}

export const authApp = new Elysia({ name: 'auth-app' }).macro({
  app: {
    beforeHandle({ headers }) {
      verifyAppToken(headers.authorization)
    },
  },
})
