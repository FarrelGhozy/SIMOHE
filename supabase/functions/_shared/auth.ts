// _shared/auth.ts — Auth device (X-Device-Key) + guard tulis aplikasi.
// Diporting dari server lama (middlewares/auth-device.ts + lib/hash.ts).

import { AppError } from "./errors.ts";
import { serviceDb, type Db, type DeviceRow } from "./db.ts";

export async function sha256Hex(input: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(input));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export async function findDeviceByKey(db: Db, rawKey: string | null): Promise<DeviceRow> {
  const key = (rawKey ?? "").trim();
  if (!key) throw new AppError(401, "UNAUTHORIZED", "Header X-Device-Key wajib diisi");

  const { data, error } = await db.from("devices").select("*").eq(
    "device_key",
    await sha256Hex(key),
  ).limit(1).maybeSingle();
  if (error) throw new AppError(500, "DB_ERROR", error.message);
  if (!data) throw new AppError(401, "UNAUTHORIZED", "Device key tidak valid");
  return data as DeviceRow;
}

/**
 * Guard tulis aplikasi. Tanpa login (sesuai keputusan): bila secret
 * APP_WRITE_KEY diset di Edge Function, pemanggil wajib mengirim header
 * X-App-Key yang cocok. Bila secret kosong, guard dilewati (tetap RLS
 * read-only + validasi ketat di tiap function).
 */
export function guardAppWrite(req: Request): void {
  const required = (Deno.env.get("APP_WRITE_KEY") ?? "").trim();
  if (!required) return;
  const given = (req.headers.get("x-app-key") ?? "").trim();
  if (given !== required) {
    throw new AppError(401, "UNAUTHORIZED", "Kunci tulis aplikasi tidak valid");
  }
}

export async function deviceFromRequest(req: Request): Promise<{ db: Db; device: DeviceRow }> {
  const db = serviceDb();
  const device = await findDeviceByKey(db, req.headers.get("x-device-key"));
  return { db, device };
}
