import { t } from 'elysia'

export const heaterModeSchema = t.Union([
  t.Literal('AUTO'),
  t.Literal('FORCE_ON'),
  t.Literal('FORCE_OFF'),
])

const nullableNumber = (options: { minimum: number; maximum: number }) =>
  t.Optional(t.Union([t.Number(options), t.Null()]))

export const ingestBody = t.Object({
  seq: t.Optional(t.Number()),
  firmware: t.Optional(t.String({ maxLength: 32 })),
  ts: t.Optional(t.String({ maxLength: 40 })),
  telemetry: t.Object({
    temp_c: nullableNumber({ minimum: -20, maximum: 120 }),
    nh3_ppm: nullableNumber({ minimum: 0, maximum: 1000 }),
    temp_ok: t.Optional(t.Boolean()),
    heater: t.Optional(t.Boolean()),
    valve: t.Optional(t.Boolean()),
    mode: t.Optional(heaterModeSchema),
    mature: t.Optional(t.Boolean()),
    uptime: t.Optional(t.Number()),
  }),
  events: t.Optional(
    t.Array(
      t.Object({
        code: t.String({ minLength: 1, maxLength: 40 }),
        detail: t.Optional(t.String({ maxLength: 120 })),
        ts: t.Optional(t.String({ maxLength: 40 })),
      }),
    ),
  ),
  acks: t.Optional(
    t.Array(
      t.Object({
        id: t.String({ minLength: 1, maxLength: 36 }),
        ok: t.Boolean(),
      }),
    ),
  ),
})

export type IngestBody = typeof ingestBody.static
