import type { SimulatorConfig } from './config'

export interface SimTelemetry {
  temp_c: number
  nh3_ppm: number
  temp_ok: boolean
  heater: boolean
  valve: boolean
  mode: string
  mature: boolean
  uptime: number
}

export interface SimEvent {
  code: string
  detail?: string
  ts?: string
}

export interface SimAck {
  id: string
  ok: boolean
}

export interface IngestBody {
  seq: number
  firmware: string
  ts: string
  telemetry: SimTelemetry
  events?: SimEvent[]
  acks?: SimAck[]
}

export interface ServerConfig {
  ingest_interval_sec: number
  temp_min_c: number
  temp_max_c: number
  temp_hysteresis_c: number
  nh3_mature_ppm: number
  mature_hold_min: number
  heater_auto: number
  heater_max_on_min: number
  valve_max_open_min: number
  command_ttl_sec: number
}

export interface ServerCommand {
  id: string
  action: string
  args: Record<string, unknown>
  expires_at: string | null
}

export interface IngestResponse {
  server_time: string
  config: ServerConfig
  commands: ServerCommand[]
  poll_after_sec: number
}

export const DEFAULT_CONFIG: ServerConfig = {
  ingest_interval_sec: 10,
  temp_min_c: 30,
  temp_max_c: 45,
  temp_hysteresis_c: 2,
  nh3_mature_ppm: 25,
  mature_hold_min: 30,
  heater_auto: 1,
  heater_max_on_min: 60,
  valve_max_open_min: 10,
  command_ttl_sec: 60,
}

export async function sendIngest(
  config: SimulatorConfig,
  body: IngestBody,
): Promise<IngestResponse> {
  const response = await fetch(`${config.baseUrl}/api/iot/ingest`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-device-key': config.deviceKey,
    },
    body: JSON.stringify(body),
  })

  const text = await response.text()
  if (!response.ok) {
    throw new Error(`ingest ${response.status}: ${text}`)
  }
  return JSON.parse(text) as IngestResponse
}

export async function applyAutoconfig(config: SimulatorConfig): Promise<void> {
  if (!config.appToken) {
    console.warn('autoconfig dilewati: --app-token / APP_TOKEN tidak diberikan')
    return
  }

  const response = await fetch(`${config.baseUrl}/api/settings`, {
    method: 'PUT',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${config.appToken}`,
    },
    body: JSON.stringify({
      history_interval_min: config.historyIntervalMin,
      mature_hold_min: config.matureHoldMin,
    }),
  })

  if (!response.ok) {
    throw new Error(`autoconfig ${response.status}: ${await response.text()}`)
  }
  console.log(
    `autoconfig: history_interval_min=${config.historyIntervalMin}, mature_hold_min=${config.matureHoldMin}`,
  )
}
