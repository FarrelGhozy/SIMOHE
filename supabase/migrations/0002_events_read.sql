-- 0002_events_read.sql — Tandai event dibaca tanpa Edge Function (Fase 8.5).
-- Aplikasi boleh UPDATE hanya kolom is_read; trigger menolak perubahan lain.
-- Jalankan sekali di SQL Editor / `supabase db push`.

create policy "anon_update_is_read" on public.events
  for update to anon
  using (true)
  with check (true);

create or replace function public.events_read_guard()
returns trigger
language plpgsql
as $$
begin
  if (
    old.device_id is distinct from new.device_id
    or old.type is distinct from new.type
    or old.severity is distinct from new.severity
    or old.message is distinct from new.message
    or old.payload is distinct from new.payload
    or old.created_at is distinct from new.created_at
  ) then
    raise exception 'hanya kolom is_read yang boleh diubah (%)', old.id
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_events_read_guard on public.events;
create trigger trg_events_read_guard
  before update on public.events
  for each row execute function public.events_read_guard();

-- Grant tulis terbatas agar policy update anon berlaku.
grant update (is_read) on public.events to anon;
