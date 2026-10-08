import { t } from 'elysia'

export const settingsPatchBody = t.Object({
  history_interval_min: t.Optional(t.Integer({ minimum: 1, maximum: 1440 })),
  ingest_interval_sec: t.Optional(t.Integer({ minimum: 2, maximum: 3600 })),
  temp_min_c: t.Optional(t.Number({ minimum: -20, maximum: 120 })),
  temp_max_c: t.Optional(t.Number({ minimum: -20, maximum: 120 })),
  temp_hysteresis_c: t.Optional(t.Number({ minimum: 0, maximum: 20 })),
  nh3_mature_ppm: t.Optional(t.Number({ minimum: 0, maximum: 1000 })),
  mature_hold_min: t.Optional(t.Integer({ minimum: 1, maximum: 1440 })),
  heater_auto: t.Optional(t.Boolean()),
  heater_max_on_min: t.Optional(t.Integer({ minimum: 1, maximum: 1440 })),
  valve_max_open_min: t.Optional(t.Integer({ minimum: 1, maximum: 1440 })),
  command_ttl_sec: t.Optional(t.Integer({ minimum: 5, maximum: 3600 })),
  raw_retention_days: t.Optional(t.Integer({ minimum: 0, maximum: 3650 })),
})

export type SettingsPatchBody = typeof settingsPatchBody.static
