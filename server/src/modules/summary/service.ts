import { and, eq, gte, sql } from 'drizzle-orm'
import { db } from '../../db/client'
import { sensorReadings } from '../../db/schema'

export interface SummaryResponse {
  from: string
  to: string
  range_count: number
  temp_c: { min: number | null; max: number | null; avg: number | null }
  nh3_ppm: { min: number | null; max: number | null; avg: number | null }
}

function toNumber(value: unknown): number | null {
  if (value === null || value === undefined) return null
  const parsed = Number(value)
  return Number.isNaN(parsed) ? null : parsed
}

export async function getSummary(deviceId: number, from: Date, to: Date): Promise<SummaryResponse> {
  const [row] = await db
    .select({
      minTemp: sql<number>`MIN(${sensorReadings.tempC})`,
      maxTemp: sql<number>`MAX(${sensorReadings.tempC})`,
      avgTemp: sql<number>`AVG(${sensorReadings.tempC})`,
      minNh3: sql<number>`MIN(${sensorReadings.nh3Ppm})`,
      maxNh3: sql<number>`MAX(${sensorReadings.nh3Ppm})`,
      avgNh3: sql<number>`AVG(${sensorReadings.nh3Ppm})`,
      count: sql<number>`COUNT(*)`,
    })
    .from(sensorReadings)
    .where(
      and(
        eq(sensorReadings.deviceId, deviceId),
        gte(sensorReadings.sampledAt, from),
        sql`${sensorReadings.sampledAt} <= ${to}`,
      ),
    )

  return {
    from: from.toISOString(),
    to: to.toISOString(),
    range_count: toNumber(row?.count) ?? 0,
    temp_c: {
      min: toNumber(row?.minTemp),
      max: toNumber(row?.maxTemp),
      avg: toNumber(row?.avgTemp),
    },
    nh3_ppm: {
      min: toNumber(row?.minNh3),
      max: toNumber(row?.maxNh3),
      avg: toNumber(row?.avgNh3),
    },
  }
}
