import { Elysia } from 'elysia'
import { authApp } from '../../middlewares/auth-app'
import { getOrCreateSettings } from '../settings/service'
import { toDeviceResponse } from './service'

export const deviceRoutes = new Elysia({ prefix: '/api' }).use(authApp).get(
  '/device',
  async ({ device }) => {
    const settingsRow = await getOrCreateSettings(device.id)
    return toDeviceResponse(device, settingsRow.ingestIntervalSec * 3)
  },
  { app: true },
)
