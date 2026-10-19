-- 0001_init.sql — Skema awal SIMOHE di Postgres (Supabase).
-- Porting docs/07-DATABASE-DESIGN.md (MySQL → Postgres), Fase 8.1.
-- Jalankan sekali di SQL Editor / `supabase db push`.
-- Konvensi: semua waktu timestamptz (UTC), boolean native, payload jsonb.

-- ── devices ─────────────────────────────────────────────────────────────
create table public.devices (
  id               bigint generated always as identity primary key,
  name             varchar(120) not null,
  device_key       char(64) not null unique, -- hash SHA-256 hex dari device key
  location         varchar(160),
  firmware_version varchar(32),
  last_seen_at     timestamptz,
  is_online        boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ── latest_state (1:1 dengan device) ─────────────────────────────────────
create table public.latest_state (
  device_id         bigint primary key references public.devices (id) on delete cascade,
  temp_c            numeric(5, 2),
  nh3_ppm           numeric(8, 3),
  temp_ok           boolean not null default true,
  heater_on         boolean not null default false,
  valve_open        boolean not null default false,
  mode              varchar(16) not null default 'AUTO',   -- AUTO|FORCE_ON|FORCE_OFF
  status            varchar(24) not null default 'idle',   -- idle|heating|mature|draining|error
  mature_streak_sec integer not null default 0,
  updated_at        timestamptz not null default now()
);

-- ── telemetry_raw (opsional, ikut retensi) ───────────────────────────────
create table public.telemetry_raw (
  id          bigint generated always as identity primary key,
  device_id   bigint not null references public.devices (id) on delete cascade,
  temp_c      numeric(5, 2),
  nh3_ppm     numeric(8, 3),
  heater_on   boolean not null default false,
  valve_open  boolean not null default false,
  recorded_at timestamptz not null
);
create index idx_raw_device_time on public.telemetry_raw (device_id, recorded_at);

-- ── sensor_readings (histori tersampling) ────────────────────────────────
create table public.sensor_readings (
  id          bigint generated always as identity primary key,
  device_id   bigint not null references public.devices (id) on delete cascade,
  temp_c      numeric(5, 2),
  nh3_ppm     numeric(8, 3),
  heater_on   boolean not null default false,
  valve_open  boolean not null default false,
  status      varchar(24) not null default 'idle',
  sampled_at  timestamptz not null
);
create index idx_read_device_time on public.sensor_readings (device_id, sampled_at);

-- ── settings (1:1 dengan device) ─────────────────────────────────────────
create table public.settings (
  id                  bigint generated always as identity primary key,
  device_id           bigint not null unique references public.devices (id) on delete cascade,
  history_interval_min integer not null default 15,
  ingest_interval_sec  integer not null default 10,
  temp_min_c          numeric(5, 2) not null default 30.00,
  temp_max_c          numeric(5, 2) not null default 45.00,
  temp_hysteresis_c   numeric(5, 2) not null default 2.00,
  nh3_mature_ppm      numeric(8, 3) not null default 25.000,
  mature_hold_min     integer not null default 30,
  heater_auto         boolean not null default true,
  heater_max_on_min   integer not null default 60,
  valve_max_open_min  integer not null default 10,
  command_ttl_sec     integer not null default 60,
  raw_retention_days  integer not null default 30,
  updated_at          timestamptz not null default now()
);

-- ── commands ─────────────────────────────────────────────────────────────
create table public.commands (
  id          uuid primary key default gen_random_uuid(),
  device_id   bigint not null references public.devices (id) on delete cascade,
  action      varchar(24) not null, -- valve_open|valve_close|heater_on|heater_off|heater_auto
  payload     jsonb,                -- args, mis. {"duration_min": 30}
  status      varchar(16) not null default 'pending', -- pending|sent|acked|failed|expired
  created_at  timestamptz not null default now(),
  sent_at     timestamptz,
  acked_at    timestamptz,
  expires_at  timestamptz not null
);
create index idx_cmd_device_status on public.commands (device_id, status);

-- ── events (notifikasi) ──────────────────────────────────────────────────
create table public.events (
  id          bigint generated always as identity primary key,
  device_id   bigint not null references public.devices (id) on delete cascade,
  type        varchar(32) not null, -- mature|temp_low|temp_high|heater_on|heater_off|
                                    -- valve_open|valve_close|device_offline|device_online|safety_cutoff
  severity    varchar(16) not null default 'info', -- info|warning|critical
  message     text not null,
  payload     jsonb,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);
create index idx_evt_device_time on public.events (device_id, created_at);
create index idx_evt_unread on public.events (is_read);

-- ── batches (siklus fermentasi) ──────────────────────────────────────────
create table public.batches (
  id           bigint generated always as identity primary key,
  device_id    bigint not null references public.devices (id) on delete cascade,
  label        varchar(120),
  started_at   timestamptz not null,
  matured_at   timestamptz,
  harvested_at timestamptz,
  status       varchar(16) not null default 'fermenting', -- fermenting|mature|harvested
  created_at   timestamptz not null default now()
);
create index idx_batch_device on public.batches (device_id, status);

-- ── RLS: single user tanpa login ─────────────────────────────────────────
-- anon hanya SELECT (dibaca aplikasi). Semua tulis lewat Edge Functions
-- (service_role, bypass RLS). service_role tidak pernah ke app/firmware.
alter table public.devices         enable row level security;
alter table public.latest_state    enable row level security;
alter table public.telemetry_raw   enable row level security;
alter table public.sensor_readings enable row level security;
alter table public.settings        enable row level security;
alter table public.commands        enable row level security;
alter table public.events          enable row level security;
alter table public.batches         enable row level security;

create policy "anon_select" on public.devices         for select to anon using (true);
create policy "anon_select" on public.latest_state    for select to anon using (true);
create policy "anon_select" on public.telemetry_raw   for select to anon using (true);
create policy "anon_select" on public.sensor_readings for select to anon using (true);
create policy "anon_select" on public.settings        for select to anon using (true);
create policy "anon_select" on public.commands        for select to anon using (true);
create policy "anon_select" on public.events          for select to anon using (true);
create policy "anon_select" on public.batches         for select to anon using (true);

-- Grant baca agar policy anon berlaku (RLS saja tidak cukup tanpa grant).
grant select on public.devices to anon;
grant select on public.latest_state to anon;
grant select on public.telemetry_raw to anon;
grant select on public.sensor_readings to anon;
grant select on public.settings to anon;
grant select on public.commands to anon;
grant select on public.events to anon;
grant select on public.batches to anon;
alter default privileges in schema public grant select on tables to anon;
