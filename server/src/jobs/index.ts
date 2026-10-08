import { type ScheduledJob, type Scheduler, startScheduler } from '../lib/scheduler'
import { commandExpiryJob } from './command-expiry'
import { offlineDetectorJob } from './offline-detector'
import { retentionJob } from './retention'
import { samplingJob } from './sampling'

export const jobs: ScheduledJob[] = [
  samplingJob,
  offlineDetectorJob,
  commandExpiryJob,
  retentionJob,
]

export function startJobs(): Scheduler {
  return startScheduler(jobs)
}
