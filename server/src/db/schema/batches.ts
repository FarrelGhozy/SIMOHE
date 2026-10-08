import { sql } from 'drizzle-orm'
import { bigint, datetime, index, mysqlTable, varchar } from 'drizzle-orm/mysql-core'
import { devices } from './devices'
import type { BatchStatus } from './enums'

export const batches = mysqlTable(
  'batches',
  {
    id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
    deviceId: bigint('device_id', { mode: 'number', unsigned: true })
      .notNull()
      .references(() => devices.id, { onDelete: 'cascade' }),
    label: varchar('label', { length: 120 }),
    startedAt: datetime('started_at', { mode: 'date' }).notNull(),
    maturedAt: datetime('matured_at', { mode: 'date' }),
    harvestedAt: datetime('harvested_at', { mode: 'date' }),
    status: varchar('status', { length: 16 })
      .$type<BatchStatus>()
      .notNull()
      .default('fermenting'),
    createdAt: datetime('created_at', { mode: 'date' })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP`),
  },
  (table) => [index('idx_batch_device').on(table.deviceId, table.status)],
)

export type Batch = typeof batches.$inferSelect
export type NewBatch = typeof batches.$inferInsert
