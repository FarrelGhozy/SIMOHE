import { eq } from 'drizzle-orm'
import { env } from '../env'
import { logger } from '../logger'
import { generateDeviceKey, hashDeviceKey } from '../lib/hash'
import { db, pool } from './client'
import { batches, devices, latestState, settings } from './schema'

async function seed(): Promise<void> {
  const plainKey = env.DEVICE_KEY ?? generateDeviceKey()
  const keyHash = hashDeviceKey(plainKey)

  const existingDevice = await db
    .select({ id: devices.id })
    .from(devices)
    .where(eq(devices.deviceKey, keyHash))
    .limit(1)

  let deviceId: number
  if (existingDevice[0]) {
    deviceId = existingDevice[0].id
    logger.info({ deviceId }, 'device sudah ada, melewati pembuatan device')
  } else {
    await db.insert(devices).values({
      name: env.DEVICE_NAME,
      deviceKey: keyHash,
      location: env.DEVICE_LOCATION ?? null,
    })
    const created = await db
      .select({ id: devices.id })
      .from(devices)
      .where(eq(devices.deviceKey, keyHash))
      .limit(1)
    deviceId = created[0]!.id
    logger.info({ deviceId }, 'device dibuat')
  }

  const existingSettings = await db
    .select({ id: settings.id })
    .from(settings)
    .where(eq(settings.deviceId, deviceId))
    .limit(1)
  if (!existingSettings[0]) {
    await db.insert(settings).values({ deviceId })
    logger.info('settings default dibuat')
  }

  const existingState = await db
    .select({ deviceId: latestState.deviceId })
    .from(latestState)
    .where(eq(latestState.deviceId, deviceId))
    .limit(1)
  if (!existingState[0]) {
    await db.insert(latestState).values({ deviceId })
    logger.info('latest_state awal dibuat')
  }

  const existingBatch = await db
    .select({ id: batches.id })
    .from(batches)
    .where(eq(batches.deviceId, deviceId))
    .limit(1)
  if (!existingBatch[0]) {
    await db.insert(batches).values({
      deviceId,
      label: 'Batch awal',
      startedAt: new Date(),
    })
    logger.info('batch awal dibuat')
  }

  console.log('')
  console.log('===========================================================')
  console.log(' DEVICE KEY (disimpan sebagai hash di DB, tampil sekali):')
  console.log(`   ${plainKey}`)
  console.log('===========================================================')
  console.log('')
}

try {
  await seed()
} catch (error) {
  logger.error({ err: error }, 'seed gagal')
  process.exitCode = 1
} finally {
  await pool.end()
}
