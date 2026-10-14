import {
  applyAutoconfig,
  DEFAULT_CONFIG,
  type IngestBody,
  type SimAck,
  type SimEvent,
  sendIngest,
} from './client'
import { loadConfig } from './config'
import { applyCommand, computeHeater, createDeviceState, enforceValveSafety } from './device-state'
import { createScenarioState, stepScenario } from './scenario'

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function stamp(): string {
  return new Date().toISOString().slice(11, 19)
}

async function main(): Promise<void> {
  const config = loadConfig()

  if (config.autoconfig) {
    await applyAutoconfig(config)
  }

  const deviceState = createDeviceState()
  const scenarioState = createScenarioState(config.scenario)
  const thresholds = {
    tempMinC: DEFAULT_CONFIG.temp_min_c,
    tempMaxC: DEFAULT_CONFIG.temp_max_c,
    hysteresisC: DEFAULT_CONFIG.temp_hysteresis_c,
  }
  let valveMaxOpenMin = DEFAULT_CONFIG.valve_max_open_min
  const pendingAcks: SimAck[] = []
  const startTime = Date.now()
  let overheatReported = false
  let seq = 1

  console.log(`Simulator mulai: scenario=${config.scenario} -> ${config.baseUrl}`)

  for (;;) {
    const reading = stepScenario(scenarioState, config.scenario, deviceState.heater)
    let waitSec = config.intervalSec

    if (reading.offline) {
      console.log(`[${stamp()}] (offline simulasi, tidak mengirim)`)
    } else {
      const heater = computeHeater(deviceState, reading.tempC, thresholds, Date.now())
      const valveClosedBySafety = enforceValveSafety(deviceState, Date.now(), valveMaxOpenMin)

      const events: SimEvent[] = []
      if (
        config.scenario === 'overheat' &&
        reading.tempC >= thresholds.tempMaxC &&
        !overheatReported
      ) {
        events.push({ code: 'SAFETY_CUTOFF', detail: 'temp_high', ts: new Date().toISOString() })
        overheatReported = true
      }
      if (reading.tempC < thresholds.tempMaxC) {
        overheatReported = false
      }
      if (valveClosedBySafety) {
        events.push({
          code: 'SAFETY_CUTOFF',
          detail: 'valve_max_open',
          ts: new Date().toISOString(),
        })
      }

      const body: IngestBody = {
        seq: seq++,
        firmware: config.firmware,
        ts: new Date().toISOString(),
        telemetry: {
          temp_c: reading.tempC,
          nh3_ppm: reading.nh3Ppm,
          temp_ok: reading.tempOk,
          heater,
          valve: deviceState.valve,
          mode: deviceState.mode,
          mature: false,
          uptime: Math.round((Date.now() - startTime) / 1000),
        },
      }
      if (events.length > 0) body.events = events
      if (pendingAcks.length > 0) body.acks = pendingAcks.splice(0, pendingAcks.length)

      try {
        const response = await sendIngest(config, body)
        thresholds.tempMinC = response.config.temp_min_c
        thresholds.tempMaxC = response.config.temp_max_c
        thresholds.hysteresisC = response.config.temp_hysteresis_c
        valveMaxOpenMin = response.config.valve_max_open_min

        const handled: string[] = []
        for (const command of response.commands) {
          const ok = applyCommand(deviceState, command, Date.now())
          pendingAcks.push({ id: command.id, ok })
          handled.push(`${command.action}${ok ? '' : '(?)'}`)
        }
        if (response.commands.length > 0) {
          waitSec = Math.min(response.poll_after_sec, config.intervalSec)
        }

        console.log(
          `[${stamp()}] seq=${body.seq} temp=${reading.tempC}C nh3=${reading.nh3Ppm}ppm ` +
            `heater=${heater ? 'ON' : 'off'} valve=${deviceState.valve ? 'open' : 'closed'} ` +
            `mode=${deviceState.mode}${handled.length > 0 ? ` cmd=${handled.join(',')}` : ''}`,
        )
      } catch (error) {
        console.error(`[${stamp()}] gagal ingest: ${(error as Error).message}`)
      }
    }

    if (config.once) break
    await sleep(Math.max(waitSec, 1) * 1000)
  }

  console.log('Simulator selesai.')
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error)
  process.exit(1)
})
