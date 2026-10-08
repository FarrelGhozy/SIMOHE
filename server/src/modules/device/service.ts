import type { Device } from '../../db/schema'
import { elapsedSeconds, toUtcIso } from '../../lib/time'

export interface DeviceResponse {
  id: string
  name: string
  location: string | null
  firmware: string | null
  is_online: boolean
  last_seen_at: string | null
  created_at: string
}

export function toDeviceResponse(device: Device, offlineThresholdSec: number): DeviceResponse {
  const online =
    device.isOnline === 1 &&
    device.lastSeenAt !== null &&
    elapsedSeconds(new Date(), device.lastSeenAt) <= offlineThresholdSec

  return {
    id: String(device.id),
    name: device.name,
    location: device.location,
    firmware: device.firmwareVersion,
    is_online: online,
    last_seen_at: toUtcIso(device.lastSeenAt),
    created_at: device.createdAt.toISOString(),
  }
}
