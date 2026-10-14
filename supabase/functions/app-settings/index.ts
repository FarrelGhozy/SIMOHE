// app-settings — Pengganti PUT /api/settings (Fase 8.3).
// Dipanggil aplikasi via functions.invoke('app-settings', body: patch).
// Body parsial snake_case -> 200 settings penuh (bentuk AppSettings).
//   -> 400 VALIDATION_ERROR | 401

import { guardAppWrite } from "../_shared/auth.ts";
import { getActiveDevice, getOrCreateSettings, normalizeSettings, serviceDb } from "../_shared/db.ts";
import { AppError, errorBody, methodGuard, toAppError } from "../_shared/errors.ts";
import { validateSettingsPatch } from "../_shared/validation.ts";

Deno.serve(async (req) => {
  try {
    const methodError = methodGuard(req, ["POST"]);
    if (methodError) return methodError;
    guardAppWrite(req);

    let raw: unknown;
    try {
      raw = await req.json();
    } catch {
      throw new AppError(400, "INVALID_JSON", "Body bukan JSON yang valid");
    }
    const patch = validateSettingsPatch(raw);

    const db = serviceDb();
    const device = await getActiveDevice(db);
    await getOrCreateSettings(db, device.id);

    const values: Record<string, number | boolean> = {};
    for (const [key, value] of Object.entries(patch)) {
      values[key] = key === "heater_auto" ? value === true : value;
    }
    if (Object.keys(values).length > 0) {
      const { error: updateError } = await db.from("settings").update(values).eq(
        "device_id",
        device.id,
      );
      if (updateError) throw new AppError(500, "DB_ERROR", updateError.message);
    }

    const { data: row, error } = await db.from("settings").select("*").eq(
      "device_id",
      device.id,
    ).limit(1).maybeSingle();
    if (error || !row) throw new AppError(500, "SETTINGS_MISSING", "Gagal membaca settings");
    const s = normalizeSettings(row as Record<string, unknown>);

    return Response.json({
      id: s.id,
      device_id: s.device_id,
      history_interval_min: s.history_interval_min,
      ingest_interval_sec: s.ingest_interval_sec,
      temp_min_c: s.temp_min_c,
      temp_max_c: s.temp_max_c,
      temp_hysteresis_c: s.temp_hysteresis_c,
      nh3_mature_ppm: s.nh3_mature_ppm,
      mature_hold_min: s.mature_hold_min,
      heater_auto: s.heater_auto,
      heater_max_on_min: s.heater_max_on_min,
      valve_max_open_min: s.valve_max_open_min,
      command_ttl_sec: s.command_ttl_sec,
      raw_retention_days: s.raw_retention_days,
      updated_at: s.updated_at,
    });
  } catch (error) {
    const appError = toAppError(error);
    return errorBody(appError.code, appError.message);
  }
});
