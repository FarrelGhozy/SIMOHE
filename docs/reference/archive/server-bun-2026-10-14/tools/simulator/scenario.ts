import type { ScenarioName } from './config'

export interface ScenarioState {
  tempC: number
  nh3Ppm: number
  tick: number
}

export interface ScenarioReading {
  tempC: number
  nh3Ppm: number
  tempOk: boolean
  offline: boolean
}

const INITIAL_TEMP: Record<ScenarioName, number> = {
  normal: 28,
  mature: 33,
  offline: 33,
  overheat: 40,
}

const INITIAL_NH3: Record<ScenarioName, number> = {
  normal: 8,
  mature: 22,
  offline: 12,
  overheat: 15,
}

const NH3_RATE: Record<ScenarioName, number> = {
  normal: 0.03,
  mature: 0.5,
  offline: 0.02,
  overheat: 0.05,
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}

function noise(): number {
  return (Math.random() - 0.5) * 0.2
}

export function createScenarioState(scenario: ScenarioName): ScenarioState {
  return { tempC: INITIAL_TEMP[scenario], nh3Ppm: INITIAL_NH3[scenario], tick: 0 }
}

export function stepScenario(
  state: ScenarioState,
  scenario: ScenarioName,
  heaterOn: boolean,
): ScenarioReading {
  state.tick += 1

  const drift = heaterOn ? 0.7 : -0.2
  state.tempC = clamp(state.tempC + drift + noise(), -10, 95)

  if (scenario === 'overheat' && state.tick % 20 === 0) {
    state.tempC = Math.min(state.tempC + 8, 95)
  }

  state.nh3Ppm = clamp(state.nh3Ppm + NH3_RATE[scenario] + noise() * 0.05, 0, 999)

  const offline = scenario === 'offline' && state.tick % 15 >= 9

  return {
    tempC: Number(state.tempC.toFixed(2)),
    nh3Ppm: Number(state.nh3Ppm.toFixed(3)),
    tempOk: true,
    offline,
  }
}
