// jobs-tick — Pengganti 4 job in-process server lama (Fase 8.4).
// Dipicu Scheduled Cron tiap 1 menit (lihat supabase/cron.sql) + bisa manual.
// Tugas (idempoten, sama seperti server lama):
//   sampling          — latest_state -> sensor_readings bila history_interval_min terlewati
//   offline-detector  — last_seen > 3x ingest -> is_online=false + event device_offline
//   command-expiry    — pending lewat TTL -> expired
//   retention         — hapus telemetry_raw > raw_retention_days
//
// POST /functions/v1/jobs-tick -> 200 { sampling, offline, expired, retention }

import { guardAppWrite } from "../_shared/auth.ts";
import { getOrCreateSettings, serviceDb, type SettingsRow } from "../_shared/db.ts";
import { AppError, errorBody, methodGuard, toAppError } from "../_shared/errors.ts";
import { deviceOfflineEvent } from "../_shared/logic.ts";

async function runSampling(
  db: ReturnType<typeof serviceDb>,
  deviceId: number,
  settings: SettingsRow,
  now: Date,
): Promise<number> {
  const intervalSec = settings.history_interval_min * 60;
  const { data: last } = await db.from("sensor_readings").select("sampled_at").eq(
    "device_id",
    deviceId,
  ).order("sampled_at", { ascending: false }).limit(1).maybeSingle();
  if (last && (now.getTime() - new Date((last as { sampled_at: string }).sampled_at).getTime()) / 1000 < intervalSec) {
    return 0;
  }
  const { data: state } = await db.from("latest_state").select("*").eq("device_id", deviceId)
    .limit(1).maybeSingle();
  if (!state) return 0;
  const s = state as Record<string, unknown>;
  const { error } = await db.from("sensor_readings").insert({
    device_id: deviceId,
    temp_c: s.temp_c ?? null,
    nh3_ppm: s.nh3_ppm ?? null,
    heater_on: s.heater_on === true,
    valve_open: s.valve_open === true,
    status: s.status ?? "idle",
    sampled_at: now.toISOString(),
  });
  if (error) throw new AppError(500, "DB_ERROR", error.message);
  return 1;
}

Deno.serve(async (req) => {
  try {
    const methodError = methodGuard(req, ["POST"]);
    if (methodError) return methodError;
    guardAppWrite(req);

    const db = serviceDb();
    const now = new Date();
    const result = { sampling: 0, offline: 0, expired: 0, retention: 0 };

    const { data: devices, error: devicesError } = await db.from("devices").select("*");
    if (devicesError) throw new AppError(500, "DB_ERROR", devicesError.message);

    for (const device of (devices ?? []) as { id: number; last_seen_at: string | null; is_online: boolean }[]) {
      const settings = await getOrCreateSettings(db, device.id);

      result.sampling += await runSampling(db, device.id, settings, now);

      // offline-detector (sekali per transisi: hanya bila masih online)
      if (device.is_online === true && device.last_seen_at) {
        const thresholdSec = settings.ingest_interval_sec * 3;
        if ((now.getTime() - new Date(device.last_seen_at).getTime()) / 1000 > thresholdSec) {
          const { error: offlineError } = await db.from("devices").update({ is_online: false }).eq(
            "id",
            device.id,
          );
          if (offlineError) throw new AppError(500, "DB_ERROR", offlineError.message);
          const { error: offlineEventError } = await db.from("events").insert(
            deviceOfflineEvent(device.id, device.last_seen_at),
          );
          if (offlineEventError) throw new AppError(500, "DB_ERROR", offlineEventError.message);
          result.offline += 1;
        }
      }

      // retention
      if (settings.raw_retention_days > 0) {
        const cutoff = new Date(now.getTime() - settings.raw_retention_days * 86_400_000).toISOString();
        const { data: stale } = await db.from("telemetry_raw").select("id").eq(
          "device_id",
          device.id,
        ).lt("recorded_at", cutoff).limit(1000);
        const ids = ((stale ?? []) as { id: number }[]).map((r) => r.id);
        if (ids.length > 0) {
          const { error: deleteError } = await db.from("telemetry_raw").delete().in("id", ids);
          if (deleteError) throw new AppError(500, "DB_ERROR", deleteError.message);
          result.retention += ids.length;
        }
      }
    }

    // command-expiry (global, semua device)
    const { data: expired } = await db.from("commands").select("id").eq("status", "pending").lte(
      "expires_at",
      now.toISOString(),
    );
    const expiredIds = ((expired ?? []) as { id: string }[]).map((c) => c.id);
    if (expiredIds.length > 0) {
      const { error: expireError } = await db.from("commands").update({ status: "expired" }).in(
        "id",
        expiredIds,
      );
      if (expireError) throw new AppError(500, "DB_ERROR", expireError.message);
      result.expired = expiredIds.length;
    }

    return Response.json(result);
  } catch (error) {
    const appError = toAppError(error);
    return errorBody(appError.code, appError.message);
  }
});
