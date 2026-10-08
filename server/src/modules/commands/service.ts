import { and, desc, eq } from 'drizzle-orm'
import { db } from '../../db/client'
import { type Command, type CommandAction, type CommandStatus, commands } from '../../db/schema'
import { AppError } from '../../lib/app-error'
import { toUtcIso } from '../../lib/time'
import { computeExpiry } from '../../services/command'
import { getOrCreateSettings } from '../settings/service'

export function toCommandResponse(row: Command) {
  return {
    id: row.id,
    action: row.action,
    status: row.status,
    args: row.payload ?? {},
    created_at: toUtcIso(row.createdAt),
    sent_at: toUtcIso(row.sentAt),
    acked_at: toUtcIso(row.ackedAt),
    expires_at: toUtcIso(row.expiresAt),
  }
}

export async function createCommand(
  deviceId: number,
  input: { action: CommandAction; args?: Record<string, unknown> },
) {
  const settingsRow = await getOrCreateSettings(deviceId)
  const now = new Date()
  const expiresAt = computeExpiry(now, settingsRow.commandTtlSec)
  const id = crypto.randomUUID()

  await db.insert(commands).values({
    id,
    deviceId,
    action: input.action,
    payload: input.args ?? {},
    status: 'pending',
    expiresAt,
  })

  return {
    id,
    action: input.action,
    status: 'pending' as const,
    expires_at: expiresAt.toISOString(),
  }
}

export async function listCommands(
  deviceId: number,
  filter: { status?: CommandStatus; limit: number },
) {
  const conditions = [eq(commands.deviceId, deviceId)]
  if (filter.status) conditions.push(eq(commands.status, filter.status))

  const rows = await db
    .select()
    .from(commands)
    .where(and(...conditions))
    .orderBy(desc(commands.createdAt))
    .limit(filter.limit)

  return rows.map(toCommandResponse)
}

export async function cancelCommand(deviceId: number, id: string) {
  const [row] = await db
    .select()
    .from(commands)
    .where(and(eq(commands.id, id), eq(commands.deviceId, deviceId)))
    .limit(1)

  if (!row) {
    throw new AppError(404, 'COMMAND_NOT_FOUND', 'Perintah tidak ditemukan')
  }
  if (row.status !== 'pending') {
    throw new AppError(409, 'COMMAND_NOT_PENDING', `Perintah sudah berstatus ${row.status}`)
  }

  await db.update(commands).set({ status: 'expired' }).where(eq(commands.id, id))
  return { id, status: 'expired' as const }
}
