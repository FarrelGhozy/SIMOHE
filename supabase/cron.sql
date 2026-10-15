-- cron.sql — Scheduled Cron jobs-tick tiap menit (Fase 8.4).
-- Jalankan sekali di SQL Editor (butuh ekstensi pg_cron + pg_net, aktif di
-- Dashboard → Database → Extensions). Ganti <PROJECT_REF> dan kunci.
--
-- Bila APP_WRITE_KEY diset di Edge Function secrets, sertakan header
-- x-app-key yang sama di bawah. Bila kosong, hapus baris header tersebut.

select cron.schedule(
  'simohe-jobs-tick',
  '* * * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/jobs-tick',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', '<SUPABASE_PUBLISHABLE_KEY>',
      'Authorization', 'Bearer <SUPABASE_PUBLISHABLE_KEY>',
      'x-app-key', '<APP_WRITE_KEY_JIKA_DISET>'
    ),
    body := '{}'::jsonb
  );
  $$
);
