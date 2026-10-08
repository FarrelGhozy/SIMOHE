import { logger } from '../logger'

export interface ScheduledJob {
  name: string
  intervalMs: number
  runOnStart?: boolean
  run: () => Promise<void>
}

export interface Scheduler {
  stop: () => void
}

interface JobHandle {
  job: ScheduledJob
  timer: ReturnType<typeof setInterval> | null
  running: boolean
}

async function execute(handle: JobHandle): Promise<void> {
  if (handle.running) {
    logger.warn({ job: handle.job.name }, 'job sebelumnya belum selesai, dilewati')
    return
  }

  handle.running = true
  const startedAt = Date.now()
  try {
    await handle.job.run()
    logger.debug({ job: handle.job.name, ms: Date.now() - startedAt }, 'job selesai')
  } catch (error) {
    logger.error({ err: error, job: handle.job.name }, 'job gagal')
  } finally {
    handle.running = false
  }
}

export function startScheduler(jobs: ScheduledJob[]): Scheduler {
  const handles: JobHandle[] = jobs.map((job) => ({ job, timer: null, running: false }))

  for (const handle of handles) {
    if (handle.job.runOnStart) {
      void execute(handle)
    }
    handle.timer = setInterval(() => {
      void execute(handle)
    }, handle.job.intervalMs)
    handle.timer.unref?.()
  }

  logger.info({ jobs: jobs.map((job) => job.name) }, 'job background dimulai')

  return {
    stop() {
      for (const handle of handles) {
        if (handle.timer) clearInterval(handle.timer)
      }
      logger.info('job background dihentikan')
    },
  }
}
