export const heaterModes = ['AUTO', 'FORCE_ON', 'FORCE_OFF'] as const
export type HeaterMode = (typeof heaterModes)[number]

export const deviceStatuses = ['idle', 'heating', 'mature', 'draining', 'error'] as const
export type DeviceStatus = (typeof deviceStatuses)[number]

export const commandActions = [
  'valve_open',
  'valve_close',
  'heater_on',
  'heater_off',
  'heater_auto',
] as const
export type CommandAction = (typeof commandActions)[number]

export const commandStatuses = ['pending', 'sent', 'acked', 'failed', 'expired'] as const
export type CommandStatus = (typeof commandStatuses)[number]

export const eventTypes = [
  'mature',
  'temp_low',
  'temp_high',
  'heater_on',
  'heater_off',
  'valve_open',
  'valve_close',
  'device_offline',
  'device_online',
  'safety_cutoff',
] as const
export type EventType = (typeof eventTypes)[number]

export const eventSeverities = ['info', 'warning', 'critical'] as const
export type EventSeverity = (typeof eventSeverities)[number]

export const batchStatuses = ['fermenting', 'mature', 'harvested'] as const
export type BatchStatus = (typeof batchStatuses)[number]
