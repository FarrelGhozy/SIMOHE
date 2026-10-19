// _shared/logic.ts — Logika bisnis (porting 1:1 dari server lama).
// Sumber: services/maturity.ts, services/thermal.ts, services/command.ts,
// services/event.ts. Jangan ubah perilaku tanpa update docs/09.

export type HeaterMode = "AUTO" | "FORCE_ON" | "FORCE_OFF";
export type DeviceStatus = "idle" | "heating" | "mature" | "draining" | "error";
export type EventType =
  | "mature"
  | "temp_low"
  | "temp_high"
  | "heater_on"
  | "heater_off"
  | "valve_open"
  | "valve_close"
  | "device_offline"
  | "device_online"
  | "safety_cutoff";
export type EventSeverity = "info" | "warning" | "critical";

// ── maturity ─────────────────────────────────────────────────────────────
export function holdSeconds(holdMin: number): number {
  return Math.max(holdMin * 60, 1);
}

export function evaluateMaturity(input: {
  nh3Ppm: number | null;
  thresholdPpm: number;
  holdMin: number;
  previousStreakSec: number;
  wasMature: boolean;
  elapsedSec: number;
  maxGapSec: number;
}): { streakSec: number; progress: number; mature: boolean; justMatured: boolean } {
  const holdSec = holdSeconds(input.holdMin);
  const continuous = input.elapsedSec >= 0 && input.elapsedSec <= input.maxGapSec;
  const aboveThreshold = input.nh3Ppm !== null && input.nh3Ppm >= input.thresholdPpm;

  let streakSec: number;
  if (!aboveThreshold) {
    streakSec = 0;
  } else if (!continuous) {
    streakSec = 0;
  } else {
    streakSec = input.previousStreakSec + input.elapsedSec;
  }

  const progress = Math.min(streakSec / holdSec, 1);
  const mature = progress >= 1;
  return {
    streakSec: Math.round(streakSec),
    progress: Number(progress.toFixed(4)),
    mature,
    justMatured: mature && !input.wasMature,
  };
}

export function toMaturityInfo(streakSec: number, thresholdPpm: number, holdMin: number) {
  const holdSec = holdSeconds(holdMin);
  return {
    mature: streakSec >= holdSec,
    progress: Number(Math.min(streakSec / holdSec, 1).toFixed(4)),
    threshold_ppm: thresholdPpm,
    hold_minutes: holdMin,
    streak_sec: Math.round(streakSec),
  };
}

// ── thermal ──────────────────────────────────────────────────────────────
export function deriveStatus(input: {
  tempOk: boolean;
  valveOpen: boolean;
  mature: boolean;
  heaterOn: boolean;
}): DeviceStatus {
  if (!input.tempOk) return "error";
  if (input.valveOpen) return "draining";
  if (input.mature) return "mature";
  if (input.heaterOn) return "heating";
  return "idle";
}

export interface ThermalSnapshot {
  tempC: number | null;
  tempOk: boolean;
  heaterOn: boolean;
  valveOpen: boolean;
  mode: HeaterMode;
}

export interface DerivedEvent {
  type: EventType;
  severity: EventSeverity;
  message: string;
  payload: Record<string, unknown>;
}

export function deriveThermalEvents(
  previous: ThermalSnapshot,
  next: ThermalSnapshot,
  thresholds: { tempMinC: number; tempMaxC: number },
): DerivedEvent[] {
  const events: DerivedEvent[] = [];
  const temp = next.tempC;

  if (!next.tempOk && previous.tempOk) {
    events.push({
      type: "safety_cutoff",
      severity: "critical",
      message: "Sensor suhu gagal dibaca, heater dimatikan (fail-safe)",
      payload: { reason: "sensor_error" },
    });
  }

  if (temp !== null) {
    const prevBelowMin = previous.tempC !== null && previous.tempC < thresholds.tempMinC;
    if (temp < thresholds.tempMinC && !prevBelowMin) {
      events.push({
        type: "temp_low",
        severity: "warning",
        message: `Suhu ${temp}°C di bawah batas minimum ${thresholds.tempMinC}°C`,
        payload: { temp_c: temp, temp_min_c: thresholds.tempMinC },
      });
    }

    const prevAboveMax = previous.tempC !== null && previous.tempC >= thresholds.tempMaxC;
    if (temp >= thresholds.tempMaxC && !prevAboveMax) {
      events.push({
        type: "temp_high",
        severity: "critical",
        message: `Suhu ${temp}°C mencapai batas aman ${thresholds.tempMaxC}°C`,
        payload: { temp_c: temp, temp_max_c: thresholds.tempMaxC },
      });
    }
  }

  if (next.heaterOn && !previous.heaterOn) {
    events.push({ type: "heater_on", severity: "info", message: "Heater menyala", payload: { temp_c: temp } });
  }
  if (!next.heaterOn && previous.heaterOn) {
    events.push({ type: "heater_off", severity: "info", message: "Heater mati", payload: { temp_c: temp } });
  }
  if (next.valveOpen && !previous.valveOpen) {
    events.push({ type: "valve_open", severity: "info", message: "Katup solenoid dibuka", payload: {} });
  }
  if (!next.valveOpen && previous.valveOpen) {
    events.push({ type: "valve_close", severity: "info", message: "Katup solenoid ditutup", payload: {} });
  }
  return events;
}

// ── command ──────────────────────────────────────────────────────────────
export function computeExpiry(now: Date, ttlSec: number): Date {
  return new Date(now.getTime() + Math.max(ttlSec, 1) * 1000);
}

export function isExpired(expiresAt: Date, now: Date = new Date()): boolean {
  return expiresAt.getTime() <= now.getTime();
}

export function isDeliverable(status: string, expiresAt: Date, now: Date = new Date()): boolean {
  return status === "pending" && !isExpired(expiresAt, now);
}

// ── event ────────────────────────────────────────────────────────────────
const defaultSeverity: Record<EventType, EventSeverity> = {
  mature: "info",
  temp_low: "warning",
  temp_high: "critical",
  heater_on: "info",
  heater_off: "info",
  valve_open: "info",
  valve_close: "info",
  device_offline: "warning",
  device_online: "info",
  safety_cutoff: "critical",
};

const deviceEventMap: Record<string, { type: EventType; severity: EventSeverity; message: string }> = {
  SAFETY_CUTOFF: { type: "safety_cutoff", severity: "critical", message: "Safety cutoff dipicu oleh perangkat" },
  DEVICE_ONLINE: { type: "device_online", severity: "info", message: "Perangkat kembali online" },
};

export function buildEvent(input: {
  deviceId: number;
  type: EventType;
  message: string;
  severity?: EventSeverity;
  payload?: Record<string, unknown>;
}) {
  return {
    device_id: input.deviceId,
    type: input.type,
    severity: input.severity ?? defaultSeverity[input.type],
    message: input.message,
    payload: input.payload ?? null,
  };
}

export function matureEvent(deviceId: number, nh3Ppm: number, thresholdPpm: number) {
  return buildEvent({
    deviceId,
    type: "mature",
    message: `Pupuk matang: NH3 ${nh3Ppm} ppm bertahan di atas ambang ${thresholdPpm} ppm`,
    severity: "info",
    payload: { nh3_ppm: nh3Ppm, threshold_ppm: thresholdPpm },
  });
}

export function deviceOfflineEvent(deviceId: number, lastSeenAt: string | null) {
  return buildEvent({
    deviceId,
    type: "device_offline",
    message: "Perangkat tidak mengirim data (offline)",
    payload: { last_seen_at: lastSeenAt },
  });
}

export function deviceOnlineEvent(deviceId: number) {
  return buildEvent({ deviceId, type: "device_online", message: "Perangkat kembali online", payload: {} });
}

export function fromDeviceEvent(
  deviceId: number,
  code: string,
  detail?: string,
  ts?: string,
): ReturnType<typeof buildEvent> | null {
  const mapped = deviceEventMap[code.toUpperCase()];
  if (!mapped) return null;
  return buildEvent({
    deviceId,
    type: mapped.type,
    severity: mapped.severity,
    message: detail ? `${mapped.message} (${detail})` : mapped.message,
    payload: { code, detail, ts },
  });
}

// ── response mapper ──────────────────────────────────────────────────────
export function toDeviceConfig(s: {
  ingest_interval_sec: number;
  temp_min_c: number;
  temp_max_c: number;
  temp_hysteresis_c: number;
  nh3_mature_ppm: number;
  mature_hold_min: number;
  heater_auto: boolean;
  heater_max_on_min: number;
  valve_max_open_min: number;
  command_ttl_sec: number;
}) {
  return {
    ingest_interval_sec: s.ingest_interval_sec,
    temp_min_c: s.temp_min_c,
    temp_max_c: s.temp_max_c,
    temp_hysteresis_c: s.temp_hysteresis_c,
    nh3_mature_ppm: s.nh3_mature_ppm,
    mature_hold_min: s.mature_hold_min,
    heater_auto: s.heater_auto ? 1 : 0,
    heater_max_on_min: s.heater_max_on_min,
    valve_max_open_min: s.valve_max_open_min,
    command_ttl_sec: s.command_ttl_sec,
  };
}
