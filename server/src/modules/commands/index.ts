import { Elysia, t } from 'elysia'
import type { CommandAction, CommandStatus } from '../../db/schema'
import { authApp } from '../../middlewares/auth-app'
import { createCommandBody } from './schema'
import { cancelCommand, createCommand, listCommands } from './service'

const commandStatusSchema = t.Optional(
  t.Union([
    t.Literal('pending'),
    t.Literal('sent'),
    t.Literal('acked'),
    t.Literal('failed'),
    t.Literal('expired'),
  ]),
)

export const commandRoutes = new Elysia({ prefix: '/api' })
  .use(authApp)
  .post(
    '/commands',
    async ({ device, body, set }) => {
      set.status = 201
      return createCommand(device.id, {
        action: body.action as CommandAction,
        args: body.args as Record<string, unknown> | undefined,
      })
    },
    { app: true, body: createCommandBody },
  )
  .get(
    '/commands',
    async ({ device, query }) =>
      listCommands(device.id, {
        status: query.status as CommandStatus | undefined,
        limit: query.limit ?? 50,
      }),
    {
      app: true,
      query: t.Object({
        status: commandStatusSchema,
        limit: t.Optional(t.Integer({ minimum: 1, maximum: 500 })),
      }),
    },
  )
  .post('/commands/:id/cancel', async ({ device, params }) => cancelCommand(device.id, params.id), {
    app: true,
    params: t.Object({ id: t.String({ maxLength: 36 }) }),
  })
