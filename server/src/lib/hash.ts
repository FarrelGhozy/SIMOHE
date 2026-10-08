import { createHash, randomBytes } from 'node:crypto'

export function hashDeviceKey(key: string): string {
  return createHash('sha256').update(key).digest('hex')
}

export function generateDeviceKey(): string {
  return randomBytes(16).toString('hex')
}
