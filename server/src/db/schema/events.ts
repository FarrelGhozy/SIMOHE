import { sql } from 'drizzle-orm'
import {
  bigint,
  datetime,
  index,
  json,
  mysqlTable,
  text,
  tinyint,
  varchar,
} from 'drizzle-orm/mysql-core'
import { devices } from './devices'
import type { EventSeverity, EventType } from './enums'

export const events = mysqlTable(
  'events',
  {
    id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
    deviceId: bigint('device_id', { mode: 'number', unsigned: true })
      .notNull()
      .references(() => devices.id, { onDelete: 'cascade' }),
    type: varchar('type', { length: 32 }).$type<EventType>().notNull(),
    severity: varchar('severity', { length: 16 })
      .$type<EventSeverity>()
      .notNull()
      .default('info'),
    message: text('message').notNull(),
    payload: json('payload').$type<Record<string, unknown>>(),
    isRead: tinyint('is_read').notNull().default(0),
    createdAt: datetime('created_at', { mode: 'date' })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP`),
  },
  (table) => [
    index('idx_evt_device_time').on(table.deviceId, table.createdAt),
    index('idx_evt_unread').on(table.isRead),
  ],
)

export type Event = typeof events.$inferSelect
export type NewEvent = typeof events.$inferInsert
