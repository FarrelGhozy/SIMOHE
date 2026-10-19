// _shared/validation.ts — Validasi input di boundary (porting skema Elysia).
// Sumber: modules/iot/schema.ts, modules/commands/schema.ts,
// modules/settings/schema.ts. Batas body 16 KB (sama seperti server lama).

import { AppError } from "./errors.ts";

export const MAX_BODY_BYTES = 16 * 1024;

export const HEATER_MODES = ["AUTO", "FORCE_ON", "FORCE_OFF"] as const;
export const COMMAND_ACTIONS = [
  "valve_open",
  "valve_close",
  "heater_on",
  "heater_off",
  "heater_auto",
] as const;

function isNum(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

function optRange(
  value: unknown,
  min: number,
  max: number,
  field: string,
): number | null | undefined {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (!isNum(value) || value < min || value > max) {
    throw new AppError(400, "VALIDATION_ERROR", `${field} di luar rentang ${min}..${max}`);
  }
  return value;
}

export interface IngestTelemetry {
  temp_c?: number | null;
  nh3_ppm?: number | null;
  temp_ok?: boolean;
  heater?: boolean;
  valve?: boolean;
  mode?: (typeof HEATER_MODES)[number];
  mature?: boolean;
  uptime?: number;
}

export interface IngestBody {
  seq?: number;
  firmware?: string;
  ts?: string;
  telemetry: IngestTelemetry;
  events?: { code: string; detail?: string; ts?: string }[];
  acks?: { id: string; ok: boolean }[];
}

export function validateIngestBody(raw: unknown): IngestBody {
  if (typeof raw !== "object" || raw === null) {
    throw new AppError(400, "VALIDATION_ERROR", "Body harus objek JSON");
  }
  const body = raw as Record<string, unknown>;
  const t = body.telemetry;
  if (typeof t !== "object" || t === null) {
    throw new AppError(400, "VALIDATION_ERROR", "telemetry wajib diisi");
  }
  const tel = t as Record<string, unknown>;

  const mode = tel.mode;
  if (mode !== undefined && !(HEATER_MODES as readonly string[]).includes(String(mode))) {
    throw new AppError(400, "VALIDATION_ERROR", "mode tidak dikenal");
  }

  const events = body.events;
  if (events !== undefined) {
    if (!Array.isArray(events)) throw new AppError(400, "VALIDATION_ERROR", "events harus array");
    for (const e of events) {
      const ev = e as Record<string, unknown>;
      if (typeof ev.code !== "string" || ev.code.length < 1 || ev.code.length > 40) {
        throw new AppError(400, "VALIDATION_ERROR", "events[].code 1..40 karakter");
      }
      if (ev.detail !== undefined && (typeof ev.detail !== "string" || ev.detail.length > 120)) {
        throw new AppError(400, "VALIDATION_ERROR", "events[].detail maks 120 karakter");
      }
    }
  }

  const acks = body.acks;
  if (acks !== undefined) {
    if (!Array.isArray(acks)) throw new AppError(400, "VALIDATION_ERROR", "acks harus array");
    for (const a of acks) {
      const ack = a as Record<string, unknown>;
      if (typeof ack.id !== "string" || ack.id.length < 1 || ack.id.length > 36) {
        throw new AppError(400, "VALIDATION_ERROR", "acks[].id 1..36 karakter");
      }
      if (typeof ack.ok !== "boolean") {
        throw new AppError(400, "VALIDATION_ERROR", "acks[].ok harus boolean");
      }
    }
  }

  return {
    seq: isNum(body.seq) ? body.seq : undefined,
    firmware: typeof body.firmware === "string" ? body.firmware.slice(0, 32) : undefined,
    ts: typeof body.ts === "string" ? body.ts.slice(0, 40) : undefined,
    telemetry: {
      temp_c: optRange(tel.temp_c, -20, 120, "temp_c"),
      nh3_ppm: optRange(tel.nh3_ppm, 0, 1000, "nh3_ppm"),
      temp_ok: typeof tel.temp_ok === "boolean" ? tel.temp_ok : undefined,
      heater: typeof tel.heater === "boolean" ? tel.heater : undefined,
      valve: typeof tel.valve === "boolean" ? tel.valve : undefined,
      mode: mode as IngestTelemetry["mode"],
      mature: typeof tel.mature === "boolean" ? tel.mature : undefined,
      uptime: isNum(tel.uptime) ? tel.uptime : undefined,
    },
    events: events as IngestBody["events"],
    acks: acks as IngestBody["acks"],
  };
}

export function validateCommandBody(raw: unknown): {
  action: (typeof COMMAND_ACTIONS)[number];
  args: Record<string, unknown>;
} {
  if (typeof raw !== "object" || raw === null) {
    throw new AppError(400, "VALIDATION_ERROR", "Body harus objek JSON");
  }
  const body = raw as Record<string, unknown>;
  if (!(COMMAND_ACTIONS as readonly string[]).includes(String(body.action))) {
    throw new AppError(400, "VALIDATION_ERROR", "action tidak dikenal");
  }
  const args = (body.args ?? {}) as Record<string, unknown>;
  if (typeof args !== "object" || args === null || Array.isArray(args)) {
    throw new AppError(400, "VALIDATION_ERROR", "args harus objek");
  }
  const duration: unknown = args.duration_min;
  if (duration !== undefined) {
    if (
      typeof duration !== "number" || !Number.isInteger(duration) || duration < 1 ||
      duration > 1440
    ) {
      throw new AppError(400, "VALIDATION_ERROR", "args.duration_min 1..1440");
    }
  }
  return { action: body.action as (typeof COMMAND_ACTIONS)[number], args };
}

const SETTINGS_LIMITS: Record<string, { min: number; max: number; int: boolean }> = {
  history_interval_min: { min: 1, max: 1440, int: true },
  ingest_interval_sec: { min: 2, max: 3600, int: true },
  temp_min_c: { min: -20, max: 120, int: false },
  temp_max_c: { min: -20, max: 120, int: false },
  temp_hysteresis_c: { min: 0, max: 20, int: false },
  nh3_mature_ppm: { min: 0, max: 1000, int: false },
  mature_hold_min: { min: 1, max: 1440, int: true },
  heater_max_on_min: { min: 1, max: 1440, int: true },
  valve_max_open_min: { min: 1, max: 1440, int: true },
  command_ttl_sec: { min: 5, max: 3600, int: true },
  raw_retention_days: { min: 0, max: 3650, int: true },
};

export function validateSettingsPatch(raw: unknown): Record<string, number | boolean> {
  if (typeof raw !== "object" || raw === null) {
    throw new AppError(400, "VALIDATION_ERROR", "Body harus objek JSON");
  }
  const body = raw as Record<string, unknown>;
  const out: Record<string, number | boolean> = {};
  for (const [key, rule] of Object.entries(SETTINGS_LIMITS)) {
    const value = body[key];
    if (value === undefined) continue;
    if (!isNum(value) || value < rule.min || value > rule.max) {
      throw new AppError(400, "VALIDATION_ERROR", `${key} di luar rentang ${rule.min}..${rule.max}`);
    }
    if (rule.int && !Number.isInteger(value)) {
      throw new AppError(400, "VALIDATION_ERROR", `${key} harus bilangan bulat`);
    }
    out[key] = value;
  }
  if (body.heater_auto !== undefined) {
    if (typeof body.heater_auto !== "boolean") {
      throw new AppError(400, "VALIDATION_ERROR", "heater_auto harus boolean");
    }
    out.heater_auto = body.heater_auto;
  }
  return out;
}
