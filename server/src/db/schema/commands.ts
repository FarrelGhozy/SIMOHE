import { sql } from 'drizzle-orm'
import {
  bigint,
  char,
  datetime,
  index,
  json,
  mysqlTable,
  varchar,
} from 'drizzle-orm/mysql-core'
import { devices } from './devices'
import type { CommandAction, CommandStatus } from './enums'

export const commands = mysqlTable(
  'commands',
  {
    id: char('id', { length: 36 }).primaryKey(),
    deviceId: bigint('device_id', { mode: 'number', unsigned: true })
      .notNull()
      .references(() => devices.id, { onDelete: 'cascade' }),
    action: varchar('action', { length: 24 }).$type<CommandAction>().notNull(),
    payload: json('payload').$type<Record<string, unknown>>(),
    status: varchar('status', { length: 16 }).$type<CommandStatus>().notNull().default('pending'),
    createdAt: datetime('created_at', { mode: 'date' })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP`),
    sentAt: datetime('sent_at', { mode: 'date' }),
    ackedAt: datetime('acked_at', { mode: 'date' }),
    expiresAt: datetime('expires_at', { mode: 'date' }).notNull(),
  },
  (table) => [index('idx_cmd_device_status').on(table.deviceId, table.status)],
)

export type Command = typeof commands.$inferSelect
export type NewCommand = typeof commands.$inferInsert
