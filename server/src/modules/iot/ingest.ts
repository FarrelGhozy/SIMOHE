import { and, desc, eq, inArray } from 'drizzle-orm'
import { db } from '../../db/client'
import {
  batches,
  commands,
  type Device,
  devices,
  events,
  latestState,
  type NewEvent,
  telemetryRaw,
} from '../../db/schema'
import { elapsedSeconds } from '../../lib/time'
import { logger } from '../../logger'
import {
  buildEvent,
  deriveStatus,
  deriveThermalEvents,
  deviceOnlineEvent,
  evaluateMaturity,
  fromDeviceEvent,
  holdSeconds,
  isDeliverable,
  matureEvent,
  nextStatusOnAck,
} from '../../services'
import { getOrCreateSettings } from '../settings/service'
import type { CommandDelivery, DeviceConfigResponse } from './response'
import { toCommandDelivery, toDeviceConfig } from './response'
import type { IngestBody } from './schema'

export interface IngestResult {
  server_time: string
  config: DeviceConfigResponse
  commands: CommandDelivery[]
  poll_after_sec: number
}

export async function ingestTelemetry(device: Device, body: IngestBody): Promise<IngestResult> {
  const now = new Date()
  const settingsRow = await getOrCreateSettings(device.id)

  const [previousRow] = await db
    .select()
    .from(latestState)
    .where(eq(latestState.deviceId, device.id))
    .limit(1)

  const previous = previousRow ?? {
    tempC: null,
    nh3Ppm: null,
    tempOk: 1,
    heaterOn: 0,
    valveOpen: 0,
    mode: 'AUTO' as const,
    status: 'idle' as const,
    matureStreakSec: 0,
    updatedAt: now,
  }

  const telemetry = body.telemetry
  const tempC = telemetry.temp_c ?? null
  const nh3Ppm = telemetry.nh3_ppm ?? null
  const tempOk = telemetry.temp_ok ?? true
  const heaterOn = telemetry.heater ?? false
  const valveOpen = telemetry.valve ?? false
  const mode = telemetry.mode ?? 'AUTO'

  const maturity = evaluateMaturity({
    nh3Ppm,
    thresholdPpm: settingsRow.nh3MaturePpm,
    holdMin: settingsRow.matureHoldMin,
    previousStreakSec: previous.matureStreakSec,
    wasMature: previous.matureStreakSec >= holdSeconds(settingsRow.matureHoldMin),
    elapsedSec: elapsedSeconds(now, previous.updatedAt),
    maxGapSec: settingsRow.ingestIntervalSec * 3,
  })

  const status = deriveStatus({ tempOk, valveOpen, mature: maturity.mature, heaterOn })

  const newEvents: NewEvent[] = []
  if (device.isOnline === 0) {
    newEvents.push(deviceOnlineEvent(device.id))
  }

  const thermalEvents = deriveThermalEvents(
    {
      tempC: previous.tempC ?? null,
      tempOk: previous.tempOk === 1,
      heaterOn: previous.heaterOn === 1,
      valveOpen: previous.valveOpen === 1,
      mode: previous.mode,
    },
    { tempC, tempOk, heaterOn, valveOpen, mode },
    { tempMinC: settingsRow.tempMinC, tempMaxC: settingsRow.tempMaxC },
  )
  for (const item of thermalEvents) {
    newEvents.push(
      buildEvent({
        deviceId: device.id,
        type: item.type,
        severity: item.severity,
        message: item.message,
        payload: item.payload,
      }),
    )
  }

  if (maturity.justMatured) {
    newEvents.push(matureEvent(device.id, nh3Ppm ?? 0, settingsRow.nh3MaturePpm))
  }

  for (const reported of body.events ?? []) {
    const built = fromDeviceEvent(device.id, reported.code, reported.detail, reported.ts)
    if (built) {
      newEvents.push(built)
    } else {
      logger.warn(
        { deviceId: device.id, code: reported.code },
        'kode event perangkat tidak dikenal diabaikan',
      )
    }
  }

  await db
    .insert(latestState)
    .values({
      deviceId: device.id,
      tempC,
      nh3Ppm,
      tempOk: tempOk ? 1 : 0,
      heaterOn: heaterOn ? 1 : 0,
      valveOpen: valveOpen ? 1 : 0,
      mode,
      status,
      matureStreakSec: maturity.streakSec,
    })
    .onDuplicateKeyUpdate({
      set: {
        tempC,
        nh3Ppm,
        tempOk: tempOk ? 1 : 0,
        heaterOn: heaterOn ? 1 : 0,
        valveOpen: valveOpen ? 1 : 0,
        mode,
        status,
        matureStreakSec: maturity.streakSec,
      },
    })

  await db
    .update(devices)
    .set({
      lastSeenAt: now,
      isOnline: 1,
      firmwareVersion: body.firmware ?? device.firmwareVersion,
    })
    .where(eq(devices.id, device.id))

  if (maturity.justMatured) {
    const [activeBatch] = await db
      .select()
      .from(batches)
      .where(and(eq(batches.deviceId, device.id), eq(batches.status, 'fermenting')))
      .orderBy(desc(batches.startedAt))
      .limit(1)
    if (activeBatch) {
      await db
        .update(batches)
        .set({ maturedAt: now, status: 'mature' })
        .where(eq(batches.id, activeBatch.id))
    }
  }

  if (newEvents.length > 0) {
    await db.insert(events).values(newEvents)
  }

  if (settingsRow.rawRetentionDays > 0) {
    await db.insert(telemetryRaw).values({
      deviceId: device.id,
      tempC,
      nh3Ppm,
      heaterOn: heaterOn ? 1 : 0,
      valveOpen: valveOpen ? 1 : 0,
      recordedAt: now,
    })
  }

  for (const ack of body.acks ?? []) {
    await db
      .update(commands)
      .set({ status: nextStatusOnAck(ack.ok), ackedAt: now })
      .where(and(eq(commands.id, ack.id), eq(commands.deviceId, device.id)))
  }

  const pending = await db
    .select()
    .from(commands)
    .where(and(eq(commands.deviceId, device.id), eq(commands.status, 'pending')))

  const deliverable = pending.filter((command) => isDeliverable(command, now))
  const expiredIds = pending
    .filter((command) => !isDeliverable(command, now))
    .map((command) => command.id)

  if (expiredIds.length > 0) {
    await db.update(commands).set({ status: 'expired' }).where(inArray(commands.id, expiredIds))
  }
  if (deliverable.length > 0) {
    await db
      .update(commands)
      .set({ status: 'sent', sentAt: now })
      .where(
        inArray(
          commands.id,
          deliverable.map((command) => command.id),
        ),
      )
  }

  return {
    server_time: now.toISOString(),
    config: toDeviceConfig(settingsRow),
    commands: deliverable.map(toCommandDelivery),
    poll_after_sec: deliverable.length > 0 ? 2 : settingsRow.ingestIntervalSec,
  }
}
