import { and, desc, eq } from 'drizzle-orm'
import { db } from '../../db/client'
import { type Batch, batches } from '../../db/schema'
import { AppError } from '../../lib/app-error'
import { toUtcIso } from '../../lib/time'

export function toBatchResponse(row: Batch) {
  return {
    id: row.id,
    label: row.label,
    status: row.status,
    started_at: toUtcIso(row.startedAt),
    matured_at: toUtcIso(row.maturedAt),
    harvested_at: toUtcIso(row.harvestedAt),
    created_at: toUtcIso(row.createdAt),
  }
}

export async function listBatches(deviceId: number, limit: number) {
  const rows = await db
    .select()
    .from(batches)
    .where(eq(batches.deviceId, deviceId))
    .orderBy(desc(batches.startedAt))
    .limit(limit)
  return rows.map(toBatchResponse)
}

export async function createBatch(deviceId: number, label?: string) {
  const [active] = await db
    .select()
    .from(batches)
    .where(and(eq(batches.deviceId, deviceId), eq(batches.status, 'fermenting')))
    .limit(1)

  if (active) {
    throw new AppError(409, 'BATCH_ACTIVE', 'Masih ada batch yang sedang berfermentasi')
  }

  await db.insert(batches).values({
    deviceId,
    label: label ?? null,
    startedAt: new Date(),
  })

  const [created] = await db
    .select()
    .from(batches)
    .where(eq(batches.deviceId, deviceId))
    .orderBy(desc(batches.startedAt))
    .limit(1)

  if (!created) {
    throw new AppError(500, 'BATCH_CREATE_FAILED', 'Gagal membuat batch')
  }
  return toBatchResponse(created)
}

export async function harvestBatch(deviceId: number, id: number) {
  const [row] = await db
    .select()
    .from(batches)
    .where(and(eq(batches.id, id), eq(batches.deviceId, deviceId)))
    .limit(1)

  if (!row) {
    throw new AppError(404, 'BATCH_NOT_FOUND', 'Batch tidak ditemukan')
  }
  if (row.status === 'harvested') {
    throw new AppError(409, 'BATCH_HARVESTED', 'Batch sudah dipanen')
  }

  const now = new Date()
  await db.update(batches).set({ status: 'harvested', harvestedAt: now }).where(eq(batches.id, id))

  return { id, status: 'harvested' as const, harvested_at: now.toISOString() }
}
