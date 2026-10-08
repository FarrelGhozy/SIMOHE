import { Elysia } from 'elysia'
import { authApp } from '../../middlewares/auth-app'
import { getLive } from './service'

export const liveRoutes = new Elysia({ prefix: '/api' })
  .use(authApp)
  .get('/live', () => getLive(), { app: true })
