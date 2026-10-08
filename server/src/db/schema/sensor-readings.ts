import {
  bigint,
  datetime,
  decimal,
  index,
  mysqlTable,
  tinyint,
  varchar,
} from 'drizzle-orm/mysql-core'
import { devices } from './devices'
import type { DeviceStatus } from './enums'

export const sensorReadings = mysqlTable(
  'sensor_readings',
  {
    id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
    deviceId: bigint('device_id', { mode: 'number', unsigned: true })
      .notNull()
      .references(() => devices.id, { onDelete: 'cascade' }),
    tempC: decimal('temp_c', { precision: 5, scale: 2, mode: 'number' }),
    nh3Ppm: decimal('nh3_ppm', { precision: 8, scale: 3, mode: 'number' }),
    heaterOn: tinyint('heater_on').notNull().default(0),
    valveOpen: tinyint('valve_open').notNull().default(0),
    status: varchar('status', { length: 24 }).$type<DeviceStatus>().notNull().default('idle'),
    sampledAt: datetime('sampled_at', { mode: 'date' }).notNull(),
  },
  (table) => [index('idx_read_device_time').on(table.deviceId, table.sampledAt)],
)

export type SensorReading = typeof sensorReadings.$inferSelect
export type NewSensorReading = typeof sensorReadings.$inferInsert
