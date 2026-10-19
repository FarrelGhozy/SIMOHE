export type ScenarioName = 'normal' | 'mature' | 'offline' | 'overheat'

export interface SimulatorConfig {
  baseUrl: string
  deviceKey: string
  appToken?: string
  intervalSec: number
  scenario: ScenarioName
  once: boolean
  autoconfig: boolean
  historyIntervalMin: number
  matureHoldMin: number
  firmware: string
}

const SCENARIOS: ScenarioName[] = ['normal', 'mature', 'offline', 'overheat']

function parseArgs(argv: string[]): Record<string, string | boolean> {
  const args: Record<string, string | boolean> = {}
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index]
    if (!token?.startsWith('--')) continue
    const key = token.slice(2)
    const next = argv[index + 1]
    if (next && !next.startsWith('--')) {
      args[key] = next
      index += 1
    } else {
      args[key] = true
    }
  }
  return args
}

export const USAGE = `Penggunaan: bun run sim -- --device-key <KEY> [opsi]

Opsi:
  --device-key <KEY>        Device key (atau env DEVICE_KEY) [wajib]
  --base-url <URL>          Base URL server (default http://localhost:3000)
  --interval <SEC>          Interval ingest detik (default 10)
  --scenario <nama>         normal | mature | offline | overheat (default normal)
  --once                    Kirim satu ingest lalu keluar
  --autoconfig              Set settings via APP_TOKEN (perlu --app-token)
  --app-token <TOKEN>       Token aplikasi untuk autoconfig
  --history-interval <MIN>  history_interval_min saat autoconfig (default 1)
  --mature-hold <MIN>       mature_hold_min saat autoconfig (default 1)
  --firmware <VER>          Versi firmware yang dilaporkan (default sim-0.1.0)
`

export function loadConfig(argv: string[] = process.argv.slice(2)): SimulatorConfig {
  const args = parseArgs(argv)
  const deviceKey = (args['device-key'] as string) ?? process.env.DEVICE_KEY ?? ''
  if (deviceKey === '') {
    throw new Error(`--device-key wajib diisi.\n\n${USAGE}`)
  }

  const scenarioArg = (args.scenario as string) ?? 'normal'
  const scenario = SCENARIOS.includes(scenarioArg as ScenarioName)
    ? (scenarioArg as ScenarioName)
    : 'normal'

  return {
    baseUrl: (args['base-url'] as string) ?? process.env.API_BASE_URL ?? 'http://localhost:3000',
    deviceKey,
    appToken: (args['app-token'] as string) ?? process.env.APP_TOKEN,
    intervalSec: Number(args.interval ?? 10),
    scenario,
    once: args.once === true,
    autoconfig: args.autoconfig === true,
    historyIntervalMin: Number(args['history-interval'] ?? 1),
    matureHoldMin: Number(args['mature-hold'] ?? 1),
    firmware: (args.firmware as string) ?? 'sim-0.1.0',
  }
}
