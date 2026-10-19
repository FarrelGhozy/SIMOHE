import type { Command, CommandStatus } from '../db/schema'

export function computeExpiry(now: Date, ttlSec: number): Date {
  return new Date(now.getTime() + Math.max(ttlSec, 1) * 1000)
}

export function isExpired(expiresAt: Date, now: Date = new Date()): boolean {
  return expiresAt.getTime() <= now.getTime()
}

export function isDeliverable(
  command: Pick<Command, 'status' | 'expiresAt'>,
  now: Date = new Date(),
): boolean {
  return command.status === 'pending' && !isExpired(command.expiresAt, now)
}

export function nextStatusOnDeliver(status: CommandStatus): CommandStatus {
  return status === 'pending' ? 'sent' : status
}

export function nextStatusOnAck(ok: boolean): CommandStatus {
  return ok ? 'acked' : 'failed'
}
