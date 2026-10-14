import { Elysia } from 'elysia'
import { authApp } from '../../middlewares/auth-app'
import { settingsPatchBody } from './schema'
import { getOrCreateSettings, toSettingsResponse, updateSettings } from './service'

export const settingsRoutes = new Elysia({ prefix: '/api' })
  .use(authApp)
  .get(
    '/settings',
    async ({ device }) => toSettingsResponse(await getOrCreateSettings(device.id)),
    { app: true },
  )
  .put(
    '/settings',
    async ({ device, body }) => toSettingsResponse(await updateSettings(device.id, body)),
    { app: true, body: settingsPatchBody },
  )
