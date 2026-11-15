-- Carnet HS DEV — schéma initial et isolation des données
-- À exécuter uniquement dans le projet Supabase carnet-hs-dev.
-- Ce script est conçu pour être relancé sans recréer les objets existants.

create extension if not exists pgcrypto;

-- 1) Profil privé associé au compte Supabase Auth.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  employee_id text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2) Missions : une mission appartient à un seul compte salarié.
create table if not exists public.missions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  agency text not null,
  employer text not null,
  workplace text not null,
  manager_name text not null,
  manager_email text,
  agency_email text,
  start_date date,
  end_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint missions_dates_valid check (end_date is null or start_date is null or end_date >= start_date),
  constraint missions_id_user_unique unique (id, user_id)
);

-- 3) Enregistrements d'heures supplémentaires.
create table if not exists public.overtime_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mission_id uuid,
  started_at timestamptz not null,
  ended_at timestamptz,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint overtime_time_valid check (ended_at is null or ended_at > started_at),
  constraint overtime_mission_owner_fk
    foreign key (mission_id, user_id) references public.missions(id, user_id) on delete restrict
);

-- 4) Validations. Dans cette première version, seule l'auto-déclaration
-- authentifiée est permise. Une validation par chef nécessitera une délégation
-- explicite et une politique RLS dédiée avant activation.
create table if not exists public.validations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mission_id uuid,
  work_date date not null,
  validator_user_id uuid not null references auth.users(id),
  validator_display_name text,
  validation_mode text not null default 'self_recorded'
    check (validation_mode in ('self_recorded')),
  created_at timestamptz not null default now(),
  constraint validations_mission_owner_fk
    foreign key (mission_id, user_id) references public.missions(id, user_id) on delete restrict
);

-- 5) Journal d'audit minimal, non modifiable par les utilisateurs après insertion.
create table if not exists public.audit_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  actor_user_id uuid not null references auth.users(id),
  event_type text not null,
  target_type text,
  target_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- 6) Reçus de synchronisation pour rendre les envois hors ligne idempotents.
create table if not exists public.sync_receipts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  operation_id uuid not null,
  received_at timestamptz not null default now(),
  constraint sync_receipts_user_operation_unique unique (user_id, operation_id)
);

-- Index utiles aux listes courantes.
create index if not exists missions_user_id_idx on public.missions(user_id);
create index if not exists overtime_entries_user_started_idx on public.overtime_entries(user_id, started_at desc);
create index if not exists overtime_entries_mission_idx on public.overtime_entries(mission_id);
create index if not exists validations_user_date_idx on public.validations(user_id, work_date desc);
create index if not exists audit_events_user_created_idx on public.audit_events(user_id, created_at desc);

-- Mise à jour automatique de updated_at.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists missions_set_updated_at on public.missions;
create trigger missions_set_updated_at before update on public.missions
for each row execute function public.set_updated_at();

drop trigger if exists overtime_entries_set_updated_at on public.overtime_entries;
create trigger overtime_entries_set_updated_at before update on public.overtime_entries
for each row execute function public.set_updated_at();

-- Crée automatiquement un profil vide à la création d'un compte Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Activer RLS sur toutes les tables exposées.
alter table public.profiles enable row level security;
alter table public.missions enable row level security;
alter table public.overtime_entries enable row level security;
alter table public.validations enable row level security;
alter table public.audit_events enable row level security;
alter table public.sync_receipts enable row level security;

-- Retirer les policies de ce script avant de les recréer.
drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "missions_select_own" on public.missions;
drop policy if exists "missions_insert_own" on public.missions;
drop policy if exists "missions_update_own" on public.missions;
drop policy if exists "missions_delete_own" on public.missions;
drop policy if exists "overtime_select_own" on public.overtime_entries;
drop policy if exists "overtime_insert_own" on public.overtime_entries;
drop policy if exists "overtime_update_own" on public.overtime_entries;
drop policy if exists "overtime_delete_own" on public.overtime_entries;
drop policy if exists "validations_select_own" on public.validations;
drop policy if exists "validations_insert_self" on public.validations;
drop policy if exists "audit_select_own" on public.audit_events;
drop policy if exists "audit_insert_own" on public.audit_events;
drop policy if exists "sync_select_own" on public.sync_receipts;
drop policy if exists "sync_insert_own" on public.sync_receipts;

-- Profiles : chaque utilisateur ne voit et ne modifie que son propre profil.
create policy "profiles_select_own" on public.profiles
for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_insert_own" on public.profiles
for insert to authenticated with check ((select auth.uid()) = id);
create policy "profiles_update_own" on public.profiles
for update to authenticated using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- Missions : accès strictement limité au propriétaire.
create policy "missions_select_own" on public.missions
for select to authenticated using ((select auth.uid()) = user_id);
create policy "missions_insert_own" on public.missions
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "missions_update_own" on public.missions
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "missions_delete_own" on public.missions
for delete to authenticated using ((select auth.uid()) = user_id);

-- Heures : le propriétaire doit aussi posséder la mission liée.
create policy "overtime_select_own" on public.overtime_entries
for select to authenticated using ((select auth.uid()) = user_id);
create policy "overtime_insert_own" on public.overtime_entries
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "overtime_update_own" on public.overtime_entries
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "overtime_delete_own" on public.overtime_entries
for delete to authenticated using ((select auth.uid()) = user_id);

-- Validation initiale : l'utilisateur ne peut déclarer que sa propre validation.
create policy "validations_select_own" on public.validations
for select to authenticated using ((select auth.uid()) = user_id);
create policy "validations_insert_self" on public.validations
for insert to authenticated with check (
  (select auth.uid()) = user_id
  and validator_user_id = (select auth.uid())
  and validation_mode = 'self_recorded'
);

-- Audit : consultation et ajout par le propriétaire ; aucune mise à jour/suppression.
create policy "audit_select_own" on public.audit_events
for select to authenticated using ((select auth.uid()) = user_id);
create policy "audit_insert_own" on public.audit_events
for insert to authenticated with check (
  (select auth.uid()) = user_id
  and actor_user_id = (select auth.uid())
);

-- Synchronisation : reçus propres à chaque utilisateur.
create policy "sync_select_own" on public.sync_receipts
for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_insert_own" on public.sync_receipts
for insert to authenticated with check ((select auth.uid()) = user_id);

-- Accorder les opérations nécessaires au rôle authentifié.
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.missions to authenticated;
grant select, insert, update, delete on public.overtime_entries to authenticated;
grant select, insert on public.validations to authenticated;
grant select, insert on public.audit_events to authenticated;
grant select, insert on public.sync_receipts to authenticated;

-- Note : aucun droit n'est accordé à anon. Les opérations doivent être authentifiées.
