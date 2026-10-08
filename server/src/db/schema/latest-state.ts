import { sql } from 'drizzle-orm'
import { bigint, datetime, decimal, int, mysqlTable, tinyint, varchar } from 'drizzle-orm/mysql-core'
import { devices } from './devices'
import type { DeviceStatus, HeaterMode } from './enums'

export const latestState = mysqlTable('latest_state', {
  deviceId: bigint('device_id', { mode: 'number', unsigned: true })
    .primaryKey()
    .references(() => devices.id, { onDelete: 'cascade' }),
  tempC: decimal('temp_c', { precision: 5, scale: 2, mode: 'number' }),
  nh3Ppm: decimal('nh3_ppm', { precision: 8, scale: 3, mode: 'number' }),
  tempOk: tinyint('temp_ok').notNull().default(1),
  heaterOn: tinyint('heater_on').notNull().default(0),
  valveOpen: tinyint('valve_open').notNull().default(0),
  mode: varchar('mode', { length: 16 }).$type<HeaterMode>().notNull().default('AUTO'),
  status: varchar('status', { length: 24 }).$type<DeviceStatus>().notNull().default('idle'),
  matureStreakSec: int('mature_streak_sec').notNull().default(0),
  updatedAt: datetime('updated_at', { mode: 'date' })
    .notNull()
    .default(sql`CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`),
})

export type LatestState = typeof latestState.$inferSelect
export type NewLatestState = typeof latestState.$inferInsert
