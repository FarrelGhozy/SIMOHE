-- seed.sql — Seed awal SIMOHE (Fase 8.1). Jalankan sekali di SQL Editor
-- SETELAH 0001_init.sql.
--
-- 1. Hitung hash device key di terminal (jangan commit plaintext ke repo):
--      echo -n 'KUNCI_PERANGKAT_32_CHAR' | sha256sum
-- 2. Ganti DEVICE_KEY_HASH_HEX di bawah dengan hasil hash (64 hex).
-- 3. Sesuaikan nama/lokasi bila perlu, lalu Run.

with new_device as (
  insert into public.devices (name, device_key, location)
  values ('Reaktor Pupuk 1', 'DEVICE_KEY_HASH_HEX', null)
  on conflict (device_key) do update set name = excluded.name
  returning id
),
new_settings as (
  insert into public.settings (device_id)
  select id from new_device
  on conflict (device_id) do nothing
  returning device_id
),
new_state as (
  insert into public.latest_state (device_id)
  select id from new_device
  on conflict (device_id) do nothing
  returning device_id
)
insert into public.batches (device_id, label, started_at)
select id, 'Batch awal', now() from new_device
where not exists (
  select 1 from public.batches b where b.device_id = (select id from new_device)
);
