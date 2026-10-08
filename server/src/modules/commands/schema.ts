import { t } from 'elysia'

export const commandActionSchema = t.Union([
  t.Literal('valve_open'),
  t.Literal('valve_close'),
  t.Literal('heater_on'),
  t.Literal('heater_off'),
  t.Literal('heater_auto'),
])

export const createCommandBody = t.Object({
  action: commandActionSchema,
  args: t.Optional(
    t.Object({
      duration_min: t.Optional(t.Integer({ minimum: 1, maximum: 1440 })),
    }),
  ),
})

export type CreateCommandBody = typeof createCommandBody.static
