import { and, asc, eq, gte, lte, sql } from 'drizzle-orm'
import { db } from '../../db/client'
import { sensorReadings, telemetryRaw } from '../../db/schema'
import { toUtcIso } from '../../lib/time'
import type { ReadingBucket } from './bucket'

export interface ReadingPoint {
  ts: string | null
  temp_c: number | null
  nh3_ppm: number | null
  heater_on: boolean
  valve_open: boolean
}

export interface ReadingsQuery {
  deviceId: number
  from: Date
  to: Date
  bucket: ReadingBucket
  limit: number
}

function toNumber(value: unknown): number | null {
  if (value === null || value === undefined) return null
  const parsed = Number(value)
  return Number.isNaN(parsed) ? null : parsed
}

export async function getReadings(query: ReadingsQuery): Promise<ReadingPoint[]> {
  if (query.bucket === 'raw') {
    const rows = await db
      .select()
      .from(telemetryRaw)
      .where(
        and(
          eq(telemetryRaw.deviceId, query.deviceId),
          gte(telemetryRaw.recordedAt, query.from),
          lte(telemetryRaw.recordedAt, query.to),
        ),
      )
      .orderBy(asc(telemetryRaw.recordedAt))
      .limit(query.limit)

    return rows.map((row) => ({
      ts: toUtcIso(row.recordedAt),
      temp_c: row.tempC,
      nh3_ppm: row.nh3Ppm,
      heater_on: row.heaterOn === 1,
      valve_open: row.valveOpen === 1,
    }))
  }

  if (query.bucket === '15m') {
    const rows = await db
      .select()
      .from(sensorReadings)
      .where(
        and(
          eq(sensorReadings.deviceId, query.deviceId),
          gte(sensorReadings.sampledAt, query.from),
          lte(sensorReadings.sampledAt, query.to),
        ),
      )
      .orderBy(asc(sensorReadings.sampledAt))
      .limit(query.limit)

    return rows.map((row) => ({
      ts: toUtcIso(row.sampledAt),
      temp_c: row.tempC,
      nh3_ppm: row.nh3Ppm,
      heater_on: row.heaterOn === 1,
      valve_open: row.valveOpen === 1,
    }))
  }

  const rows = await db
    .select({
      ts: sql<string>`FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(${sensorReadings.sampledAt}) / 3600) * 3600)`,
      tempC: sql<number>`AVG(${sensorReadings.tempC})`,
      nh3Ppm: sql<number>`AVG(${sensorReadings.nh3Ppm})`,
      heaterOn: sql<number>`MAX(${sensorReadings.heaterOn})`,
      valveOpen: sql<number>`MAX(${sensorReadings.valveOpen})`,
    })
    .from(sensorReadings)
    .where(
      and(
        eq(sensorReadings.deviceId, query.deviceId),
        gte(sensorReadings.sampledAt, query.from),
        lte(sensorReadings.sampledAt, query.to),
      ),
    )
    .groupBy(sql`ts`)
    .orderBy(sql`ts`)
    .limit(query.limit)

  return rows.map((row) => ({
    ts: toUtcIso(row.ts),
    temp_c: toNumber(row.tempC),
    nh3_ppm: toNumber(row.nh3Ppm),
    heater_on: Number(row.heaterOn) === 1,
    valve_open: Number(row.valveOpen) === 1,
  }))
}
