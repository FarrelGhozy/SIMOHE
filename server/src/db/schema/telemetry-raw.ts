import {
  bigint,
  datetime,
  decimal,
  index,
  mysqlTable,
  tinyint,
} from 'drizzle-orm/mysql-core'
import { devices } from './devices'

export const telemetryRaw = mysqlTable(
  'telemetry_raw',
  {
    id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
    deviceId: bigint('device_id', { mode: 'number', unsigned: true })
      .notNull()
      .references(() => devices.id, { onDelete: 'cascade' }),
    tempC: decimal('temp_c', { precision: 5, scale: 2, mode: 'number' }),
    nh3Ppm: decimal('nh3_ppm', { precision: 8, scale: 3, mode: 'number' }),
    heaterOn: tinyint('heater_on').notNull().default(0),
    valveOpen: tinyint('valve_open').notNull().default(0),
    recordedAt: datetime('recorded_at', { mode: 'date' }).notNull(),
  },
  (table) => [index('idx_raw_device_time').on(table.deviceId, table.recordedAt)],
)

export type TelemetryRaw = typeof telemetryRaw.$inferSelect
export type NewTelemetryRaw = typeof telemetryRaw.$inferInsert
