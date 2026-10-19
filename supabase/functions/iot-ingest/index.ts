// iot-ingest — Pengganti POST /api/iot/ingest (Fase 8.2).
// Kontrak request/response SAMA PERSIS dengan docs/05 §2 agar firmware minim.
// Auth: header X-Device-Key (hash SHA-256 dicocokkan ke devices.device_key).
// verify_jwt=false (lihat supabase/config.toml): ESP tidak memakai JWT user.
//
// POST /functions/v1/iot-ingest
//   -> 200 { server_time, config, commands[], poll_after_sec }
//   -> 400 VALIDATION_ERROR | 401 UNAUTHORIZED | 429 RATE_LIMITED

import { deviceFromRequest } from "../_shared/auth.ts";
import { num, getOrCreateSettings } from "../_shared/db.ts";
import { AppError, errorBody, methodGuard, toAppError } from "../_shared/errors.ts";
import {
  buildEvent,
  deriveStatus,
  deriveThermalEvents,
  deviceOnlineEvent,
  evaluateMaturity,
  fromDeviceEvent,
  holdSeconds,
  isDeliverable,
  matureEvent,
  toDeviceConfig,
  type HeaterMode,
} from "../_shared/logic.ts";
import { MAX_BODY_BYTES, validateIngestBody } from "../_shared/validation.ts";

// Rate limit best-effort per device (1 req/detik, sama seperti server lama).
// Catatan: Map ini per-isolate Edge Function, jadi bersifat approximasi.
const lastHit = new Map<number, number>();

Deno.serve(async (req) => {
  try {
    const methodError = methodGuard(req, ["POST"]);
    if (methodError) return methodError;

    const text = await req.text();
    if (text.length > MAX_BODY_BYTES) {
      throw new AppError(400, "BODY_TOO_LARGE", "Body melebihi 16 KB");
    }
    let raw: unknown;
    try {
      raw = JSON.parse(text);
    } catch {
      throw new AppError(400, "INVALID_JSON", "Body bukan JSON yang valid");
    }
    const body = validateIngestBody(raw);

    const { db, device } = await deviceFromRequest(req);

    const nowMs = Date.now();
    const prevHit = lastHit.get(device.id) ?? 0;
    if (nowMs - prevHit < 1000) {
      return errorBody("RATE_LIMITED", "Terlalu banyak permintaan");
    }
    lastHit.set(device.id, nowMs);

    const now = new Date();
    const settings = await getOrCreateSettings(db, device.id);

    const { data: prevRow, error: prevError } = await db.from("latest_state").select("*").eq(
      "device_id",
      device.id,
    ).limit(1).maybeSingle();
    if (prevError) throw new AppError(500, "DB_ERROR", prevError.message);

    const previous = {
      tempC: prevRow ? (prevRow.temp_c === null ? null : num(prevRow.temp_c)) : null,
      nh3Ppm: prevRow ? (prevRow.nh3_ppm === null ? null : num(prevRow.nh3_ppm)) : null,
      tempOk: prevRow ? prevRow.temp_ok === true : true,
      heaterOn: prevRow ? prevRow.heater_on === true : false,
      valveOpen: prevRow ? prevRow.valve_open === true : false,
      mode: (prevRow?.mode ?? "AUTO") as HeaterMode,
      matureStreakSec: prevRow ? num(prevRow.mature_streak_sec) : 0,
      updatedAt: prevRow?.updated_at ? new Date(prevRow.updated_at) : now,
    };

    const tel = body.telemetry;
    const tempC = tel.temp_c ?? null;
    const nh3Ppm = tel.nh3_ppm ?? null;
    const tempOk = tel.temp_ok ?? tempC !== null;
    const heaterOn = tel.heater ?? false;
    const valveOpen = tel.valve ?? false;
    const mode = (tel.mode ?? "AUTO") as HeaterMode;

    const elapsedSec = Math.max(0, (now.getTime() - previous.updatedAt.getTime()) / 1000);
    const maturity = evaluateMaturity({
      nh3Ppm,
      thresholdPpm: settings.nh3_mature_ppm,
      holdMin: settings.mature_hold_min,
      previousStreakSec: previous.matureStreakSec,
      wasMature: previous.matureStreakSec >= holdSeconds(settings.mature_hold_min),
      elapsedSec,
      maxGapSec: settings.ingest_interval_sec * 3,
    });

    const status = deriveStatus({ tempOk, valveOpen, mature: maturity.mature, heaterOn });

    const newEvents: Record<string, unknown>[] = [];
    if (device.is_online !== true) {
      newEvents.push(deviceOnlineEvent(device.id));
    }
    for (
      const item of deriveThermalEvents(
        { tempC: previous.tempC, tempOk: previous.tempOk, heaterOn: previous.heaterOn, valveOpen: previous.valveOpen, mode: previous.mode },
        { tempC, tempOk, heaterOn, valveOpen, mode },
        { tempMinC: settings.temp_min_c, tempMaxC: settings.temp_max_c },
      )
    ) {
      newEvents.push(
        buildEvent({ deviceId: device.id, type: item.type, severity: item.severity, message: item.message, payload: item.payload }),
      );
    }
    if (maturity.justMatured) {
      newEvents.push(matureEvent(device.id, nh3Ppm ?? 0, settings.nh3_mature_ppm));
    }
    for (const reported of body.events ?? []) {
      const built = fromDeviceEvent(device.id, reported.code, reported.detail, reported.ts);
      if (built) newEvents.push(built);
      else console.warn(`kode event perangkat tidak dikenal diabaikan: ${reported.code}`);
    }

    const { error: upsertError } = await db.from("latest_state").upsert({
      device_id: device.id,
      temp_c: tempC,
      nh3_ppm: nh3Ppm,
      temp_ok: tempOk,
      heater_on: heaterOn,
      valve_open: valveOpen,
      mode,
      status,
      mature_streak_sec: maturity.streakSec,
      updated_at: now.toISOString(),
    }, { onConflict: "device_id" });
    if (upsertError) throw new AppError(500, "DB_ERROR", upsertError.message);

    const { error: deviceError } = await db.from("devices").update({
      last_seen_at: now.toISOString(),
      is_online: true,
      firmware_version: body.firmware ?? device.firmware_version,
    }).eq("id", device.id);
    if (deviceError) throw new AppError(500, "DB_ERROR", deviceError.message);

    if (maturity.justMatured) {
      const { data: activeBatch } = await db.from("batches").select("id").eq("device_id", device.id)
        .eq("status", "fermenting").order("started_at", { ascending: false }).limit(1)
        .maybeSingle();
      if (activeBatch) {
        const { error: batchError } = await db.from("batches").update({
          matured_at: now.toISOString(),
          status: "mature",
        }).eq("id", (activeBatch as { id: number }).id);
        if (batchError) throw new AppError(500, "DB_ERROR", batchError.message);
      }
    }

    if (newEvents.length > 0) {
      const { error: eventError } = await db.from("events").insert(newEvents);
      if (eventError) throw new AppError(500, "DB_ERROR", eventError.message);
    }

    if (settings.raw_retention_days > 0) {
      const { error: rawError } = await db.from("telemetry_raw").insert({
        device_id: device.id,
        temp_c: tempC,
        nh3_ppm: nh3Ppm,
        heater_on: heaterOn,
        valve_open: valveOpen,
        recorded_at: now.toISOString(),
      });
      if (rawError) throw new AppError(500, "DB_ERROR", rawError.message);
    }

    for (const ack of body.acks ?? []) {
      const { error: ackError } = await db.from("commands").update({
        status: ack.ok ? "acked" : "failed",
        acked_at: now.toISOString(),
      }).eq("id", ack.id).eq("device_id", device.id);
      if (ackError) throw new AppError(500, "DB_ERROR", ackError.message);
    }

    const { data: pending, error: pendingError } = await db.from("commands").select("*").eq(
      "device_id",
      device.id,
    ).eq("status", "pending");
    if (pendingError) throw new AppError(500, "DB_ERROR", pendingError.message);

    const rows = (pending ?? []) as { id: string; action: string; payload: Record<string, unknown> | null; status: string; expires_at: string }[];
    const deliverable = rows.filter((c) => isDeliverable(c.status, new Date(c.expires_at), now));
    const expiredIds = rows.filter((c) => !isDeliverable(c.status, new Date(c.expires_at), now)).map((c) => c.id);

    if (expiredIds.length > 0) {
      const { error: expireError } = await db.from("commands").update({ status: "expired" }).in(
        "id",
        expiredIds,
      );
      if (expireError) throw new AppError(500, "DB_ERROR", expireError.message);
    }
    if (deliverable.length > 0) {
      const { error: sentError } = await db.from("commands").update({
        status: "sent",
        sent_at: now.toISOString(),
      }).in("id", deliverable.map((c) => c.id));
      if (sentError) throw new AppError(500, "DB_ERROR", sentError.message);
    }

    return Response.json({
      server_time: now.toISOString(),
      config: toDeviceConfig({
        ingest_interval_sec: settings.ingest_interval_sec,
        temp_min_c: settings.temp_min_c,
        temp_max_c: settings.temp_max_c,
        temp_hysteresis_c: settings.temp_hysteresis_c,
        nh3_mature_ppm: settings.nh3_mature_ppm,
        mature_hold_min: settings.mature_hold_min,
        heater_auto: settings.heater_auto,
        heater_max_on_min: settings.heater_max_on_min,
        valve_max_open_min: settings.valve_max_open_min,
        command_ttl_sec: settings.command_ttl_sec,
      }),
      commands: deliverable.map((c) => ({
        id: c.id,
        action: c.action,
        args: c.payload ?? {},
        expires_at: c.expires_at ? new Date(c.expires_at).toISOString() : null,
      })),
      poll_after_sec: deliverable.length > 0 ? 2 : settings.ingest_interval_sec,
    });
  } catch (error) {
    const appError = toAppError(error);
    return errorBody(appError.code, appError.message);
  }
});
