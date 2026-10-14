// app-batch — Pengganti POST /api/batches + harvest (Fase 8.3).
// Dipanggil aplikasi via functions.invoke('app-batch', body).
//
// create:  { op: 'create', label? } -> 201 batch penuh
// harvest: { op: 'harvest', id }    -> 200 { id, status, harvested_at }
//   -> 400 | 401 | 404 BATCH_NOT_FOUND | 409 BATCH_ACTIVE/BATCH_HARVESTED

import { guardAppWrite } from "../_shared/auth.ts";
import { getActiveDevice, serviceDb } from "../_shared/db.ts";
import { AppError, errorBody, methodGuard, toAppError } from "../_shared/errors.ts";

function toBatchResponse(row: Record<string, unknown>) {
  return {
    id: Number(row.id),
    label: (row.label ?? null) as string | null,
    status: row.status,
    started_at: row.started_at ? new Date(String(row.started_at)).toISOString() : null,
    matured_at: row.matured_at ? new Date(String(row.matured_at)).toISOString() : null,
    harvested_at: row.harvested_at ? new Date(String(row.harvested_at)).toISOString() : null,
    created_at: row.created_at ? new Date(String(row.created_at)).toISOString() : null,
  };
}

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
    const body = raw as Record<string, unknown>;

    const db = serviceDb();
    const device = await getActiveDevice(db);
    const op = body.op ?? "create";

    if (op === "harvest") {
      const id = Number(body.id);
      if (!Number.isInteger(id)) throw new AppError(400, "VALIDATION_ERROR", "id harus integer");
      const { data: row, error } = await db.from("batches").select("*").eq("id", id).eq(
        "device_id",
        device.id,
      ).limit(1).maybeSingle();
      if (error) throw new AppError(500, "DB_ERROR", error.message);
      if (!row) throw new AppError(404, "BATCH_NOT_FOUND", "Batch tidak ditemukan");
      if ((row as { status: string }).status === "harvested") {
        throw new AppError(409, "BATCH_HARVESTED", "Batch sudah dipanen");
      }
      const now = new Date();
      const { error: updateError } = await db.from("batches").update({
        status: "harvested",
        harvested_at: now.toISOString(),
      }).eq("id", id);
      if (updateError) throw new AppError(500, "DB_ERROR", updateError.message);
      return Response.json({ id, status: "harvested", harvested_at: now.toISOString() });
    }

    if (op !== "create") throw new AppError(400, "VALIDATION_ERROR", "op tidak dikenal");
    const label = body.label;
    if (label !== undefined && (typeof label !== "string" || label.length > 120)) {
      throw new AppError(400, "VALIDATION_ERROR", "label maks 120 karakter");
    }

    const { data: active } = await db.from("batches").select("id").eq("device_id", device.id).eq(
      "status",
      "fermenting",
    ).limit(1).maybeSingle();
    if (active) {
      throw new AppError(409, "BATCH_ACTIVE", "Masih ada batch yang sedang berfermentasi");
    }

    const { data: created, error: insertError } = await db.from("batches").insert({
      device_id: device.id,
      label: label ?? null,
      started_at: new Date().toISOString(),
    }).select("*").limit(1).maybeSingle();
    if (insertError || !created) {
      throw new AppError(500, "DB_ERROR", insertError?.message ?? "Gagal membuat batch");
    }
    return Response.json(toBatchResponse(created as Record<string, unknown>), { status: 201 });
  } catch (error) {
    const appError = toAppError(error);
    return errorBody(appError.code, appError.message);
  }
});
