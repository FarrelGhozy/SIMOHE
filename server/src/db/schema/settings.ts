import { sql } from 'drizzle-orm'
import { bigint, datetime, decimal, int, mysqlTable, tinyint } from 'drizzle-orm/mysql-core'
import { devices } from './devices'

export const settings = mysqlTable('settings', {
  id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
  deviceId: bigint('device_id', { mode: 'number', unsigned: true })
    .notNull()
    .unique()
    .references(() => devices.id, { onDelete: 'cascade' }),
  historyIntervalMin: int('history_interval_min').notNull().default(15),
  ingestIntervalSec: int('ingest_interval_sec').notNull().default(10),
  tempMinC: decimal('temp_min_c', { precision: 5, scale: 2, mode: 'number' }).notNull().default(30),
  tempMaxC: decimal('temp_max_c', { precision: 5, scale: 2, mode: 'number' }).notNull().default(45),
  tempHysteresisC: decimal('temp_hysteresis_c', { precision: 5, scale: 2, mode: 'number' })
    .notNull()
    .default(2),
  nh3MaturePpm: decimal('nh3_mature_ppm', { precision: 8, scale: 3, mode: 'number' })
    .notNull()
    .default(25),
  matureHoldMin: int('mature_hold_min').notNull().default(30),
  heaterAuto: tinyint('heater_auto').notNull().default(1),
  heaterMaxOnMin: int('heater_max_on_min').notNull().default(60),
  valveMaxOpenMin: int('valve_max_open_min').notNull().default(10),
  commandTtlSec: int('command_ttl_sec').notNull().default(60),
  rawRetentionDays: int('raw_retention_days').notNull().default(30),
  updatedAt: datetime('updated_at', { mode: 'date' })
    .notNull()
    .default(sql`CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`),
})

export type Settings = typeof settings.$inferSelect
export type NewSettings = typeof settings.$inferInsert
