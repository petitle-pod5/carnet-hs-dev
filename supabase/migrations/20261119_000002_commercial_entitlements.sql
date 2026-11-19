-- Carnet HS DEV only — couche commerciale additive.
-- A appliquer manuellement uniquement apres verification du projet cible.
-- Ne modifie pas les six tables historiques, hors ajout de client_code a profiles.

begin;

-- Identifiant commercial permanent, distinct de l'UUID Supabase.
alter table public.profiles add column if not exists client_code text;

create unique index if not exists profiles_client_code_uidx
  on public.profiles (client_code)
  where client_code is not null;

create or replace function public.generate_client_code()
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  candidate text;
begin
  loop
    candidate := 'CHS-' || upper(substring(replace(gen_random_uuid()::text, '-', '') from 1 for 10));
    exit when not exists (
      select 1 from public.profiles where client_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

create or replace function public.profiles_assign_client_code()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.client_code is null or btrim(new.client_code) = '' then
      new.client_code := public.generate_client_code();
    end if;
  elsif new.client_code is distinct from old.client_code then
    raise exception 'client_code is permanent and cannot be changed';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_assign_client_code on public.profiles;
create trigger profiles_assign_client_code
before insert or update of client_code on public.profiles
for each row execute function public.profiles_assign_client_code();

update public.profiles
set client_code = public.generate_client_code()
where client_code is null or btrim(client_code) = '';

alter table public.profiles alter column client_code set not null;

-- Catalogue: pas de tarifs ni de promesses fonctionnelles non valides ici.
create table if not exists public.plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.plan_entitlements (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans(id) on delete cascade,
  entitlement_key text not null,
  enabled boolean not null default false,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (plan_id, entitlement_key)
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  plan_id uuid not null references public.plans(id),
  status text not null check (status in ('pending','active','past_due','grace','canceled','expired')),
  current_period_start timestamptz,
  current_period_end timestamptz,
  grace_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (current_period_end is null or current_period_start is null or current_period_end >= current_period_start)
);

create table if not exists public.subscription_events (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions(id) on delete cascade,
  event_type text not null,
  effective_at timestamptz not null default now(),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.billing_customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  provider text not null,
  provider_customer_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_customer_id)
);

create index if not exists subscription_events_subscription_idx
  on public.subscription_events(subscription_id, effective_at desc);

alter table public.plans enable row level security;
alter table public.plan_entitlements enable row level security;
alter table public.subscriptions enable row level security;
alter table public.subscription_events enable row level security;
alter table public.billing_customers enable row level security;

-- RLS restrictive: catalogue lisible uniquement par les comptes connectes;
-- les donnees commerciales sont consultables par leur titulaire seulement.
drop policy if exists plans_select_active on public.plans;
create policy plans_select_active on public.plans
for select to authenticated using (is_active);

drop policy if exists plan_entitlements_select_active on public.plan_entitlements;
create policy plan_entitlements_select_active on public.plan_entitlements
for select to authenticated using (
  exists (select 1 from public.plans p where p.id = plan_id and p.is_active)
);

drop policy if exists subscriptions_select_own on public.subscriptions;
create policy subscriptions_select_own on public.subscriptions
for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists subscription_events_select_own on public.subscription_events;
create policy subscription_events_select_own on public.subscription_events
for select to authenticated using (
  exists (select 1 from public.subscriptions s
    where s.id = subscription_id and s.user_id = (select auth.uid()))
);

drop policy if exists billing_customers_select_own on public.billing_customers;
create policy billing_customers_select_own on public.billing_customers
for select to authenticated using ((select auth.uid()) = user_id);

-- Aucun droit client d'ecriture n'est accorde: seule la couche serveur/service
-- authentifiee peut gerer les offres, abonnements, evenements et paiements.
revoke all on public.plans, public.plan_entitlements, public.subscriptions,
  public.subscription_events, public.billing_customers from anon, authenticated;
grant select on public.plans, public.plan_entitlements, public.subscriptions,
  public.subscription_events, public.billing_customers to authenticated;
grant select (id, client_code) on public.profiles to authenticated;

commit;

