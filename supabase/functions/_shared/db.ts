// _shared/db.ts — Klien service_role + helper device/settings.
// Hanya dipakai di dalam Edge Function (bypass RLS). service_role tidak
// pernah dikirim ke app/firmware/repo.

import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { AppError } from "./errors.ts";

export type Db = SupabaseClient;

export function serviceDb(): Db {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) {
    throw new AppError(500, "MISCONFIGURED", "SUPABASE_URL / SERVICE_ROLE belum diset");
  }
  return createClient(url, key, { auth: { persistSession: false } });
}

export interface DeviceRow {
  id: number;
  name: string;
  device_key: string;
  location: string | null;
  firmware_version: string | null;
  last_seen_at: string | null;
  is_online: boolean;
  created_at: string;
  updated_at: string;
}

export interface SettingsRow {
  id: number;
  device_id: number;
  history_interval_min: number;
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
  raw_retention_days: number;
  updated_at: string;
}

export function num(value: unknown, fallback = 0): number {
  const parsed = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
}

/** Device aktif = id terkecil (single-device, sama seperti server lama). */
export async function getActiveDevice(db: Db): Promise<DeviceRow> {
  const { data, error } = await db.from("devices").select("*").order("id", {
    ascending: true,
  }).limit(1).maybeSingle();
  if (error) throw new AppError(500, "DB_ERROR", error.message);
  if (!data) throw new AppError(404, "DEVICE_NOT_FOUND", "Belum ada device terdaftar");
  return data as DeviceRow;
}

export async function getOrCreateSettings(db: Db, deviceId: number): Promise<SettingsRow> {
  const { data, error } = await db.from("settings").select("*").eq("device_id", deviceId)
    .limit(1).maybeSingle();
  if (error) throw new AppError(500, "DB_ERROR", error.message);
  if (data) return normalizeSettings(data);

  const { error: insertError } = await db.from("settings").insert({ device_id: deviceId });
  if (insertError) throw new AppError(500, "SETTINGS_MISSING", "Gagal membuat settings default");
  const { data: created, error: retryError } = await db.from("settings").select("*").eq(
    "device_id",
    deviceId,
  ).limit(1).maybeSingle();
  if (retryError || !created) {
    throw new AppError(500, "SETTINGS_MISSING", "Gagal membuat settings default");
  }
  return normalizeSettings(created);
}

/** numeric Postgres datang sebagai string — normalisasi ke number/boolean. */
export function normalizeSettings(row: Record<string, unknown>): SettingsRow {
  return {
    id: num(row.id),
    device_id: num(row.device_id),
    history_interval_min: num(row.history_interval_min, 15),
    ingest_interval_sec: num(row.ingest_interval_sec, 10),
    temp_min_c: num(row.temp_min_c, 30),
    temp_max_c: num(row.temp_max_c, 45),
    temp_hysteresis_c: num(row.temp_hysteresis_c, 2),
    nh3_mature_ppm: num(row.nh3_mature_ppm, 25),
    mature_hold_min: num(row.mature_hold_min, 30),
    heater_auto: row.heater_auto === true,
    heater_max_on_min: num(row.heater_max_on_min, 60),
    valve_max_open_min: num(row.valve_max_open_min, 10),
    command_ttl_sec: num(row.command_ttl_sec, 60),
    raw_retention_days: num(row.raw_retention_days, 30),
    updated_at: String(row.updated_at ?? new Date().toISOString()),
  };
}
