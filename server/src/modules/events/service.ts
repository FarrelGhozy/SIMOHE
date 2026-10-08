import { and, desc, eq } from 'drizzle-orm'
import { db } from '../../db/client'
import { type Event, events } from '../../db/schema'
import { AppError } from '../../lib/app-error'
import { toUtcIso } from '../../lib/time'

export function toEventResponse(row: Event) {
  return {
    id: row.id,
    type: row.type,
    severity: row.severity,
    message: row.message,
    payload: row.payload ?? {},
    is_read: row.isRead === 1,
    created_at: toUtcIso(row.createdAt),
  }
}

export async function listEvents(deviceId: number, filter: { unreadOnly: boolean; limit: number }) {
  const conditions = [eq(events.deviceId, deviceId)]
  if (filter.unreadOnly) conditions.push(eq(events.isRead, 0))

  const rows = await db
    .select()
    .from(events)
    .where(and(...conditions))
    .orderBy(desc(events.createdAt))
    .limit(filter.limit)

  return rows.map(toEventResponse)
}

export async function countUnread(deviceId: number): Promise<number> {
  const rows = await db
    .select({ id: events.id })
    .from(events)
    .where(and(eq(events.deviceId, deviceId), eq(events.isRead, 0)))
  return rows.length
}

export async function markEventRead(deviceId: number, id: number) {
  const [row] = await db
    .select()
    .from(events)
    .where(and(eq(events.id, id), eq(events.deviceId, deviceId)))
    .limit(1)

  if (!row) {
    throw new AppError(404, 'EVENT_NOT_FOUND', 'Event tidak ditemukan')
  }

  await db.update(events).set({ isRead: 1 }).where(eq(events.id, id))
  return { id, is_read: true }
}

export async function markAllEventsRead(deviceId: number) {
  await db.update(events).set({ isRead: 1 }).where(eq(events.deviceId, deviceId))
  return { ok: true }
}
