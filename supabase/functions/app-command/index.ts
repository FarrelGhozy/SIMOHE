// app-command — Pengganti POST /api/commands + cancel (Fase 8.3).
// Dipanggil aplikasi via functions.invoke('app-command', body).
//
// create: { action, args? }            -> 201 { id, action, status, expires_at }
// cancel: { op: 'cancel', id }         -> 200 { id, status: 'expired' }
//   -> 400 VALIDATION_ERROR | 401 | 404 COMMAND_NOT_FOUND | 409 COMMAND_NOT_PENDING

import { guardAppWrite } from "../_shared/auth.ts";
import { getActiveDevice, getOrCreateSettings, serviceDb } from "../_shared/db.ts";
import { AppError, errorBody, methodGuard, toAppError } from "../_shared/errors.ts";
import { computeExpiry } from "../_shared/logic.ts";
import { validateCommandBody } from "../_shared/validation.ts";

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

    const db = serviceDb();
    const device = await getActiveDevice(db);

    const body = raw as Record<string, unknown>;
    if (body.op === "cancel") {
      const id = body.id;
      if (typeof id !== "string" || id.length < 1 || id.length > 36) {
        throw new AppError(400, "VALIDATION_ERROR", "id 1..36 karakter");
      }
      const { data: row, error } = await db.from("commands").select("*").eq("id", id).eq(
        "device_id",
        device.id,
      ).limit(1).maybeSingle();
      if (error) throw new AppError(500, "DB_ERROR", error.message);
      if (!row) throw new AppError(404, "COMMAND_NOT_FOUND", "Perintah tidak ditemukan");
      if ((row as { status: string }).status !== "pending") {
        throw new AppError(
          409,
          "COMMAND_NOT_PENDING",
          `Perintah sudah berstatus ${(row as { status: string }).status}`,
        );
      }
      const { error: updateError } = await db.from("commands").update({ status: "expired" }).eq(
        "id",
        id,
      );
      if (updateError) throw new AppError(500, "DB_ERROR", updateError.message);
      return Response.json({ id, status: "expired" });
    }

    const { action, args } = validateCommandBody(raw);
    const settings = await getOrCreateSettings(db, device.id);
    const now = new Date();
    const expiresAt = computeExpiry(now, settings.command_ttl_sec);

    // Safety: clamp durasi heater_on ke 1..heater_max_on_min (maks 1440).
    const payload: Record<string, unknown> = { ...args };
    if (action === "heater_on" && typeof payload.duration_min === "number") {
      payload.duration_min = Math.min(
        Math.max(Math.round(payload.duration_min), 1),
        Math.min(settings.heater_max_on_min, 1440),
      );
    }

    const { data: created, error: insertError } = await db.from("commands").insert({
      device_id: device.id,
      action,
      payload,
      status: "pending",
      expires_at: expiresAt.toISOString(),
    }).select("id").limit(1).maybeSingle();
    if (insertError || !created) {
      throw new AppError(500, "DB_ERROR", insertError?.message ?? "Gagal membuat perintah");
    }

    return Response.json(
      {
        id: (created as { id: string }).id,
        action,
        status: "pending",
        expires_at: expiresAt.toISOString(),
      },
      { status: 201 },
    );
  } catch (error) {
    const appError = toAppError(error);
    return errorBody(appError.code, appError.message);
  }
});
