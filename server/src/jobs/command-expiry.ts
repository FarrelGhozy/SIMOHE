import { and, eq, inArray, lte } from 'drizzle-orm'
import { db } from '../db/client'
import { commands } from '../db/schema'
import type { ScheduledJob } from '../lib/scheduler'
import { logger } from '../logger'

export const COMMAND_EXPIRY_TICK_MS = 30_000

export async function runCommandExpiry(now: Date = new Date()): Promise<number> {
  const expired = await db
    .select({ id: commands.id })
    .from(commands)
    .where(and(eq(commands.status, 'pending'), lte(commands.expiresAt, now)))

  if (expired.length === 0) return 0

  await db
    .update(commands)
    .set({ status: 'expired' })
    .where(
      inArray(
        commands.id,
        expired.map((command) => command.id),
      ),
    )

  return expired.length
}

export const commandExpiryJob: ScheduledJob = {
  name: 'command-expiry',
  intervalMs: COMMAND_EXPIRY_TICK_MS,
  runOnStart: true,
  run: async () => {
    const count = await runCommandExpiry()
    if (count > 0) {
      logger.info({ count }, 'perintah kedaluwarsa ditandai')
    }
  },
}
