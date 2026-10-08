import { sql } from 'drizzle-orm'
import { bigint, char, datetime, mysqlTable, tinyint, varchar } from 'drizzle-orm/mysql-core'

export const devices = mysqlTable('devices', {
  id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
  name: varchar('name', { length: 120 }).notNull(),
  deviceKey: char('device_key', { length: 64 }).notNull().unique(),
  location: varchar('location', { length: 160 }),
  firmwareVersion: varchar('firmware_version', { length: 32 }),
  lastSeenAt: datetime('last_seen_at', { mode: 'date' }),
  isOnline: tinyint('is_online').notNull().default(0),
  createdAt: datetime('created_at', { mode: 'date' })
    .notNull()
    .default(sql`CURRENT_TIMESTAMP`),
  updatedAt: datetime('updated_at', { mode: 'date' })
    .notNull()
    .default(sql`CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`),
})

export type Device = typeof devices.$inferSelect
export type NewDevice = typeof devices.$inferInsert
