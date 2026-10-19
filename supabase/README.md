# Supabase SIMOHE (scaffold Fase 8)

Backend Supabase-only pengganti `server/` (Bun+Elysia+MySQL, diarsipkan).
Rancangan penuh: `docs/17-SUPABASE-MIGRATION.md`. Checklist: `TODO.md` Fase 8.

## Struktur

```
supabase/
├── README.md               # file ini
├── SETUP.md                # panduan klik-per-klik (project → cron → app)
├── .env.example            # SUPABASE_URL + PUBLISHABLE_KEY (tanpa secret)
├── config.toml             # verify_jwt=false (auth via X-Device-Key/app key)
├── migrations/
│   ├── 0001_init.sql       # 8 tabel + RLS anon SELECT (TODO 8.1)
│   └── 0002_events_read.sql# UPDATE is_read oleh anon + trigger guard (8.5)
├── seed.sql                # device + settings + batch awal (TODO 8.1)
├── cron.sql                # Scheduled Cron jobs-tick tiap menit (TODO 8.4)
├── functions/
│   ├── _shared/            # errors, db, auth, logic, validation
│   ├── iot-ingest/         # POST ingest ESP (TODO 8.2)
│   ├── app-command/        # POST command + cancel (TODO 8.3)
│   ├── app-settings/       # PUT settings (TODO 8.3)
│   ├── app-batch/          # start/harvest batch (TODO 8.3)
│   └── jobs-tick/          # sampling/offline/expiry/retention + Cron (TODO 8.4)
└── tools/sim-curl.sh       # simulator curl (normal/mature/overheat/offline/safety)
```

## Status

Fase 8 selesai diimplementasi (2026-10-14): migrasi + functions + cron +
app + firmware. Verifikasi cloud penuh (deploy + sim-curl + matriks T1–T10)
menunggu project Supabase dibuat — ikuti `SETUP.md`.

## Perintah cepat (diisi agent saat implementasi)

```bash
# link + deploy (butuh supabase CLI + access token, tidak di-commit)
supabase link --project-ref <ref>
supabase db push
supabase functions deploy iot-ingest app-command app-settings app-batch jobs-tick
```
