-- SMARMELLOPOLY: da incollare in Supabase > SQL Editor > New query > Run (una volta sola)

create table if not exists public.games (
  id text primary key,
  state jsonb,
  rev integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.photos (
  game_id text not null,
  code text not null,
  img text not null,
  updated_at timestamptz not null default now(),
  primary key (game_id, code)
);

alter table public.games enable row level security;
alter table public.photos enable row level security;

drop policy if exists "leggi partite" on public.games;
create policy "leggi partite" on public.games for select using (true);

drop policy if exists "leggi foto" on public.photos;
drop policy if exists "carica foto" on public.photos;
drop policy if exists "aggiorna foto" on public.photos;
drop policy if exists "togli foto" on public.photos;
create policy "leggi foto" on public.photos for select using (true);
create policy "carica foto" on public.photos for insert
  with check (length(img) < 400000 and code ~ '^[a-z0-9]{4,8}$' and img like 'data:image/jpeg;base64,%');
create policy "aggiorna foto" on public.photos for update using (true)
  with check (length(img) < 400000 and img like 'data:image/jpeg;base64,%');
create policy "togli foto" on public.photos for delete using (true);

-- Le partite si scrivono solo tramite questa funzione, che rifiuta le mosse arrivate in ritardo.
create or replace function public.commit_state(p_id text, p_base integer, p_state jsonb)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare n integer;
begin
  if p_id !~ '^[a-z0-9]{4,12}$' then raise exception 'codice stanza non valido'; end if;
  if octet_length(p_state::text) > 900000 then raise exception 'partita troppo grande'; end if;
  if p_base = 0 then
    insert into games(id, state, rev) values (p_id, p_state, 1) on conflict (id) do nothing;
    get diagnostics n = row_count;
    if n = 1 then return true; end if;
  end if;
  update games set state = p_state, rev = rev + 1, updated_at = now()
   where id = p_id and rev = p_base;
  get diagnostics n = row_count;
  return n = 1;
end $$;

revoke all on function public.commit_state(text, integer, jsonb) from public;
grant execute on function public.commit_state(text, integer, jsonb) to anon, authenticated;

-- Aggiornamenti in tempo reale verso i telefoni
do $$ begin
  begin alter publication supabase_realtime add table public.games; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.photos; exception when duplicate_object then null; end;
end $$;
