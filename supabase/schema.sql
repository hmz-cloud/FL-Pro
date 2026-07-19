-- FleetOps Pro — Multi-Tenant Schema
-- Run in Supabase SQL Editor

create extension if not exists "uuid-ossp";

-- ORGANIZATIONS (tenants)
create table organizations (
  id                     uuid primary key default uuid_generate_v4(),
  name                   text not null,
  slug                   text unique not null,
  plan                   text default 'starter',
  plan_status            text default 'active',
  stripe_customer_id     text unique,
  stripe_subscription_id text unique,
  vehicle_limit          int default 5,
  created_at             timestamptz default now()
);

-- PROFILES (users)
create table profiles (
  id         uuid primary key references auth.users on delete cascade,
  org_id     uuid references organizations(id) on delete cascade,
  full_name  text,
  email      text,
  role       text default 'viewer',
  status     text default 'active',
  last_login timestamptz,
  created_at timestamptz default now()
);

-- COST CENTERS
create table cost_centers (
  id          uuid primary key default uuid_generate_v4(),
  org_id      uuid references organizations(id) on delete cascade,
  name        text not null,
  code        text,
  description text,
  budget      numeric default 0,
  is_active   boolean default true,
  created_at  timestamptz default now()
);

-- VEHICLES
create table vehicles (
  id                  uuid primary key default uuid_generate_v4(),
  org_id              uuid references organizations(id) on delete cascade,
  make                text, model text, year int,
  license_plate       text, vin text, fleet_number text,
  status              text default 'available',
  vehicle_type        text, fuel_type text,
  mileage             int default 0,
  cost_center_id      uuid references cost_centers(id) on delete set null,
  driver_id           uuid references profiles(id) on delete set null,
  cost_ytd            numeric default 0,
  last_maintenance    date, next_maintenance date,
  insurance_expiry    date, registration_expiry date, inspection_expiry date,
  gps_lat             numeric, gps_lng numeric,
  gps_speed           int default 0,
  gps_online          boolean default false,
  gps_last_ping       timestamptz,
  created_at          timestamptz default now()
);

-- TRANSFERS
create table transfers (
  id                  uuid primary key default uuid_generate_v4(),
  org_id              uuid references organizations(id) on delete cascade,
  vehicle_id          uuid references vehicles(id) on delete cascade,
  from_cost_center_id uuid references cost_centers(id),
  to_cost_center_id   uuid references cost_centers(id),
  status              text default 'pending',
  reason text, comment text,
  requested_by        uuid references profiles(id),
  approved_by         uuid references profiles(id),
  created_at          timestamptz default now()
);

-- AUDIT LOG
create table audit_log (
  id         uuid primary key default uuid_generate_v4(),
  org_id     uuid references organizations(id) on delete cascade,
  actor_id   uuid references profiles(id),
  action     text not null,
  detail     text,
  entity     text,
  entity_id  uuid,
  created_at timestamptz default now()
);

-- GPS INTEGRATIONS
create table gps_integrations (
  id         uuid primary key default uuid_generate_v4(),
  org_id     uuid references organizations(id) on delete cascade,
  provider   text,
  api_key    text,
  api_url    text,
  is_active  boolean default false,
  last_sync  timestamptz,
  created_at timestamptz default now()
);

-- ROW LEVEL SECURITY
alter table organizations    enable row level security;
alter table profiles         enable row level security;
alter table cost_centers     enable row level security;
alter table vehicles         enable row level security;
alter table transfers        enable row level security;
alter table audit_log        enable row level security;
alter table gps_integrations enable row level security;

create or replace function get_my_org_id()
returns uuid language sql security definer
as $$ select org_id from profiles where id = auth.uid() $$;

create policy "tenant_isolation" on organizations    for all using (id = get_my_org_id());
create policy "tenant_isolation" on profiles         for all using (org_id = get_my_org_id());
create policy "tenant_isolation" on cost_centers     for all using (org_id = get_my_org_id());
create policy "tenant_isolation" on vehicles         for all using (org_id = get_my_org_id());
create policy "tenant_isolation" on transfers        for all using (org_id = get_my_org_id());
create policy "tenant_isolation" on audit_log        for all using (org_id = get_my_org_id());
create policy "tenant_isolation" on gps_integrations for all using (org_id = get_my_org_id());

-- INDEXES
create index on vehicles  (org_id, status);
create index on vehicles  (org_id, next_maintenance);
create index on transfers (org_id, status);
create index on audit_log (org_id, created_at desc);
