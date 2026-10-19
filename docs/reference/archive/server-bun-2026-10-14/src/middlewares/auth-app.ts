import { Elysia } from 'elysia'
import { env } from '../env'
import { getActiveDevice } from '../lib/active-device'
import { AppError } from '../lib/app-error'

export function verifyAppToken(authorization: string | undefined): void {
  const token = authorization?.startsWith('Bearer ') ? authorization.slice(7).trim() : ''
  if (token === '' || token !== env.APP_TOKEN) {
    throw new AppError(401, 'UNAUTHORIZED', 'Token aplikasi tidak valid')
  }
}

export const authApp = new Elysia({ name: 'auth-app' }).macro({
  app: {
    async resolve({ headers }) {
      verifyAppToken(headers.authorization)
      const device = await getActiveDevice()
      return { device }
    },
  },
})
