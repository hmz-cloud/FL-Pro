import { useState } from "react";

const files = {
  "index.html": { desc: "Main app — complete single-file SaaS application", size: "~180KB", type: "app", note: "Download from the FleetOps Pro artifact (↓ button)" },
  "README.md": { desc: "Full documentation, setup & deployment guide", size: "~4KB", type: "doc" },
  "package.json": { desc: "Node project config for local dev server", size: "~1KB", type: "config" },
  "netlify.toml": { desc: "Netlify deploy config with redirect & security headers", size: "<1KB", type: "config" },
  "vercel.json": { desc: "Vercel deploy config with SPA routing", size: "<1KB", type: "config" },
  ".env.example": { desc: "Environment variable template for Supabase + Stripe", size: "<1KB", type: "config" },
  ".gitignore": { desc: "Git ignore rules — keeps secrets out of repo", size: "<1KB", type: "config" },
  "supabase/schema.sql": { desc: "Multi-tenant Postgres schema with RLS policies", size: "~6KB", type: "db" },
  "supabase/seed.sql": { desc: "Demo data seed for onboarding new tenants", size: "~3KB", type: "db" },
  "stripe/products.json": { desc: "Stripe product & price definitions for all 3 tiers", size: "~2KB", type: "billing" },
  "stripe/webhooks.js": { desc: "Stripe webhook handler (subscription lifecycle events)", size: "~4KB", type: "billing" },
  "docs/DEPLOYMENT.md": { desc: "Step-by-step hosting guide (Netlify, Vercel, VPS)", size: "~5KB", type: "doc" },
  "docs/INTEGRATION.md": { desc: "Supabase wiring guide — connect UI to real backend", size: "~4KB", type: "doc" },
  "docs/MONETIZATION.md": { desc: "Pricing strategy, Stripe setup, trial-to-paid playbook", size: "~4KB", type: "doc" },
  "docs/GPS_INTEGRATION.md": { desc: "GPS provider API guide (Samsara, Wialon, Traccar, Geotab)", size: "~4KB", type: "doc" },
  "scripts/create-tenant.js": { desc: "Onboarding script — provision a new paying customer", size: "~2KB", type: "script" },
};

const fileContents = {
"README.md":
`# FleetOps Pro 🚛

> Fleet management that goes beyond GPS.

**Version:** 3.0.0 | **License:** Proprietary © 2026

## Quick Start

\`\`\`bash
git clone https://github.com/YOUR_USERNAME/FleetOps-Pro.git
cd FleetOps-Pro
npm install
npm run dev        # http://localhost:3000
\`\`\`

## Deploy Free (60 seconds)

### Netlify
\`\`\`bash
npx netlify deploy --prod --dir .
\`\`\`
Or drag folder to https://app.netlify.com/drop

### Vercel
\`\`\`bash
npx vercel --prod
\`\`\`

### GitHub Pages
Settings → Pages → Source: main / root

## Demo Accounts
| Role | Email |
|------|-------|
| Admin | admin@fleetops.com |
| Fleet Manager | manager@fleetops.com |
| Driver | driver@fleetops.com |
| Viewer | viewer@fleetops.com |

## Pricing
| Plan | Vehicles | Price |
|------|----------|-------|
| Starter | Up to 5 | Free |
| Business | Unlimited | $149/mo |
| Enterprise | Unlimited + SSO | Custom |

## Repo Structure
\`\`\`
FleetOps-Pro/
├── index.html              # Complete SaaS app
├── package.json
├── netlify.toml
├── vercel.json
├── .env.example
├── supabase/
│   ├── schema.sql
│   └── seed.sql
├── stripe/
│   ├── products.json
│   └── webhooks.js
├── scripts/
│   └── create-tenant.js
└── docs/
    ├── DEPLOYMENT.md
    ├── INTEGRATION.md
    ├── MONETIZATION.md
    └── GPS_INTEGRATION.md
\`\`\``,

"package.json":
`{
  "name": "fleetops-pro",
  "version": "3.0.0",
  "description": "Fleet management SaaS — beyond GPS",
  "private": true,
  "scripts": {
    "dev": "npx serve . -p 3000 --single",
    "build": "echo 'Static — no build step needed'",
    "deploy:netlify": "npx netlify deploy --prod --dir .",
    "deploy:vercel": "npx vercel --prod",
    "tenant:create": "node scripts/create-tenant.js"
  },
  "devDependencies": {
    "serve": "^14.2.0"
  },
  "engines": { "node": ">=18.0.0" },
  "license": "UNLICENSED"
}`,

"netlify.toml":
`[build]
  publish = "."
  command = "echo 'No build step needed'"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"

[[headers]]
  for = "/index.html"
  [headers.values]
    Cache-Control = "no-cache, no-store, must-revalidate"`,

"vercel.json":
`{
  "version": 2,
  "builds": [{ "src": "index.html", "use": "@vercel/static" }],
  "routes": [{ "src": "/(.*)", "dest": "/index.html" }],
  "headers": [{
    "source": "/(.*)",
    "headers": [
      { "key": "X-Content-Type-Options", "value": "nosniff" },
      { "key": "X-Frame-Options", "value": "DENY" }
    ]
  }]
}`,

".env.example":
`# Supabase (free tier — supabase.com)
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key   # server-side only

# Stripe Billing
STRIPE_PUBLISHABLE_KEY=pk_live_xxx      # frontend safe
STRIPE_SECRET_KEY=sk_live_xxx           # server-side only
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_BUSINESS=price_xxx
STRIPE_PRICE_ENTERPRISE=price_xxx

# App
APP_URL=https://your-domain.com
SUPPORT_EMAIL=support@your-domain.com
SALES_EMAIL=sales@your-domain.com

# GPS Providers (connect whichever you have)
SAMSARA_API_KEY=
WIALON_TOKEN=
GEOTAB_USERNAME=
GEOTAB_DATABASE=
TRACCAR_API_URL=
TRACCAR_API_TOKEN=`,

".gitignore":
`.env
.env.local
.env.production
node_modules/
dist/
.vercel
.netlify
.DS_Store
*.log
*.pem
*.key
secrets/`,

"supabase/schema.sql":
`-- FleetOps Pro — Multi-Tenant Schema
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
create index on audit_log (org_id, created_at desc);`,

"supabase/seed.sql":
`-- FleetOps Pro — Demo Seed Data
-- Run AFTER schema.sql

insert into organizations (id, name, slug, plan, vehicle_limit)
values ('a0000000-0000-0000-0000-000000000001','Acme Fleet Co.','acme-fleet','business', null);

insert into cost_centers (org_id, name, code, budget, is_active) values
  ('a0000000-0000-0000-0000-000000000001','Operations North','OPS-N',50000,true),
  ('a0000000-0000-0000-0000-000000000001','Logistics South','LOG-S',40000,true),
  ('a0000000-0000-0000-0000-000000000001','Executive Fleet','EXC-F',80000,true),
  ('a0000000-0000-0000-0000-000000000001','Field Services','FLD-S',30000,false);

insert into vehicles (org_id,make,model,year,license_plate,fleet_number,status,vehicle_type,fuel_type,mileage,next_maintenance,insurance_expiry) values
  ('a0000000-0000-0000-0000-000000000001','Toyota','Land Cruiser',2022,'ABC-1234','FL-001','available','suv','gasoline',12400,'2026-06-10','2026-12-01'),
  ('a0000000-0000-0000-0000-000000000001','Ford','Transit',2023,'DEF-5678','FL-002','in_use','van','diesel',8700,'2026-05-25','2026-10-01'),
  ('a0000000-0000-0000-0000-000000000001','Mitsubishi','L200',2021,'GHI-9012','FL-003','maintenance','truck','diesel',31200,'2026-05-20','2026-11-01'),
  ('a0000000-0000-0000-0000-000000000001','Nissan','Patrol',2023,'JKL-3456','FL-004','available','suv','gasoline',4100,'2026-08-01','2027-01-15');`,

"stripe/products.json":
`{
  "products": [
    {
      "name": "FleetOps Starter",
      "description": "For small fleets — up to 5 vehicles",
      "metadata": { "vehicle_limit": "5", "plan": "starter" },
      "price": { "amount": 0, "interval": "month", "nickname": "Free" }
    },
    {
      "name": "FleetOps Business",
      "description": "Unlimited vehicles, GPS, compliance tracking",
      "metadata": { "vehicle_limit": "unlimited", "plan": "business" },
      "prices": [
        { "amount": 14900, "interval": "month", "nickname": "Business Monthly — $149/mo" },
        { "amount": 134100, "interval": "year",  "nickname": "Business Annual — $1,341/yr (save 25%)" }
      ]
    },
    {
      "name": "FleetOps Enterprise",
      "description": "Unlimited + SSO + dedicated support + custom integrations",
      "metadata": { "vehicle_limit": "unlimited", "plan": "enterprise" },
      "price": { "amount": 0, "nickname": "Enterprise — Contact Sales" }
    }
  ],
  "trial_days": 14,
  "required_webhook_events": [
    "customer.subscription.created",
    "customer.subscription.updated",
    "customer.subscription.deleted",
    "invoice.payment_succeeded",
    "invoice.payment_failed"
  ],
  "test_cards": {
    "success":       "4242 4242 4242 4242",
    "decline":       "4000 0000 0000 0002",
    "requires_auth": "4000 0025 0000 3155"
  }
}`,

"stripe/webhooks.js":
`// FleetOps Pro — Stripe Webhook Handler
// Deploy as a Supabase Edge Function or any serverless endpoint
// Install: npm install stripe @supabase/supabase-js

export async function handleWebhook(req) {
  // Dynamically import to avoid bundling issues
  const Stripe = (await import('stripe')).default;
  const { createClient } = await import('@supabase/supabase-js');

  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  const db = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      await req.text(), sig, process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return new Response('Invalid signature', { status: 400 });
  }

  const obj = event.data.object;

  const PLAN_MAP = {
    [process.env.STRIPE_PRICE_BUSINESS]:   'business',
    [process.env.STRIPE_PRICE_ENTERPRISE]: 'enterprise',
  };

  switch (event.type) {
    case 'customer.subscription.created':
    case 'customer.subscription.updated': {
      const priceId = obj.items.data[0]?.price?.id;
      const plan = PLAN_MAP[priceId] || 'starter';
      await db.from('organizations').update({
        plan, plan_status: obj.status,
        stripe_subscription_id: obj.id,
        vehicle_limit: plan === 'starter' ? 5 : null
      }).eq('stripe_customer_id', obj.customer);
      break;
    }
    case 'customer.subscription.deleted':
      await db.from('organizations').update({
        plan: 'starter', plan_status: 'cancelled', vehicle_limit: 5
      }).eq('stripe_customer_id', obj.customer);
      break;
    case 'invoice.payment_succeeded':
      await db.from('organizations')
        .update({ plan_status: 'active' })
        .eq('stripe_customer_id', obj.customer);
      break;
    case 'invoice.payment_failed':
      await db.from('organizations')
        .update({ plan_status: 'past_due' })
        .eq('stripe_customer_id', obj.customer);
      break;
  }
  return new Response('OK', { status: 200 });
}`,

"docs/DEPLOYMENT.md":
`# Deployment Guide

## Option 1: Netlify (Recommended — Free)
1. Push repo to GitHub
2. app.netlify.com → Import from Git → select FleetOps-Pro
3. Deploy settings auto-detected from netlify.toml
4. Site Settings → Environment Variables → add your keys
5. Domain Management → add custom domain (SSL auto)

CLI: npx netlify deploy --prod --dir .

Free tier: 100GB bandwidth, SSL, CDN ✓

## Option 2: Vercel (Free)
npx vercel --prod
Add env vars: vercel env add SUPABASE_URL production

## Option 3: GitHub Pages (Free, zero config)
Settings → Pages → Source: main / root
Live at: https://username.github.io/FleetOps-Pro

## Option 4: Custom VPS (DigitalOcean / Hetzner)
Install nginx, point root to project folder,
run certbot for free SSL.

## Production Checklist
- Custom domain + SSL active
- Env vars set (never in git)
- Supabase RLS policies verified
- Stripe webhooks endpoint registered
- Error monitoring (Sentry free tier)
- Uptime monitoring (Better Uptime free tier)`,

"docs/INTEGRATION.md":
`# Supabase Integration Guide

## Connect UI to Real Backend

The demo runs on in-memory JS state.
Wire it to Supabase when you land your first customer.

## 1. Add Supabase client to index.html
Add before closing </body>:

  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <script>
    const { createClient } = supabase;
    const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  </script>

## 2. Replace demo login

  async function doLogin() {
    const { data, error } = await db.auth.signInWithPassword({
      email: document.getElementById('login-email').value,
      password: document.getElementById('login-pass').value
    });
    if (error) { alert(error.message); return; }
    const { data: profile } = await db
      .from('profiles').select('*')
      .eq('id', data.user.id).single();
    S.role = profile.role;
    S.orgId = profile.org_id;
    initApp();
  }

## 3. Load vehicles from DB

  async function loadVehicles() {
    const { data } = await db.from('vehicles')
      .select('*, cost_centers(name), profiles(full_name)')
      .eq('org_id', S.orgId)
      .order('fleet_number');
    S.vehicles = data;
    render();
  }

## 4. Realtime live updates

  db.channel('vehicles')
    .on('postgres_changes',
        { event: '*', schema: 'public', table: 'vehicles' },
        () => loadVehicles())
    .subscribe();

## 5. Plan limit enforcement

  async function checkVehicleLimit() {
    const { data: org } = await db.from('organizations')
      .select('vehicle_limit').eq('id', S.orgId).single();
    if (org.vehicle_limit && S.vehicles.length >= org.vehicle_limit) {
      alert('Upgrade your plan to add more vehicles.');
      return false;
    }
    return true;
  }`,

"docs/MONETIZATION.md":
`# Monetization Playbook

## Pricing
| Plan       | Price      | Vehicle Limit |
|------------|------------|---------------|
| Starter    | Free       | 5             |
| Business   | $149/mo    | Unlimited     |
| Enterprise | Custom     | Unlimited+SSO |

Annual discount: 25% off (improves cash flow, reduces churn)

## Go-To-Market Phases

Phase 1 — Contact Sales (Now)
  Demo app to target companies directly
  Goal: 5 paying customers

Phase 2 — Self-Serve (Month 3)
  Enable Stripe Checkout with 14-day trial
  Goal: 20+ customers without sales calls

Phase 3 — Scale (Month 6+)
  Partner with GPS hardware vendors
  Vertical landing pages (construction, logistics, oil & gas)
  Goal: 100+ customers

## Stripe CLI Setup

  stripe products create --name "FleetOps Business"
  stripe prices create --product prod_xxx --unit-amount 14900 --currency usd --recurring[interval]=month
  stripe prices create --product prod_xxx --unit-amount 134100 --currency usd --recurring[interval]=year
  stripe webhooks create --url https://your-domain.com/api/stripe/webhook --events [events from products.json]

## Target Metrics (Month 6)
  MRR:          $5,000+
  Churn:        < 5% monthly
  Trial to Paid: > 25%
  CAC:          < $200
  LTV:          > $2,000

## Sales Email Template

Subject: Your fleet is costing more than you think

GPS tells you where your vehicles are.
FleetOps tells you who is responsible, what it costs,
when insurance expires, and what is due for service —
in one dashboard anyone understands in 5 seconds.

Live demo: [DEMO_LINK]
15-min call: [CALENDAR_LINK]`,

"docs/GPS_INTEGRATION.md":
`# GPS Provider Integration Guide

## How It Works
FleetOps is GPS-agnostic. Connect your existing hardware
via REST API — FleetOps layers cost, compliance, driver,
and operational data on top of live positions.

## Samsara
  const res = await fetch(
    'https://api.samsara.com/fleet/vehicles/locations',
    { headers: { 'Authorization': 'Bearer ' + SAMSARA_API_KEY } }
  );
  const { data } = await res.json();
  data.forEach(v => updateVehicleGPS(
    v.id, v.gps.latitude, v.gps.longitude, v.gps.speedMilesPerHour
  ));

## Wialon (Gurtam)
  const auth = await fetch(
    'https://hst-api.wialon.com/wialon/ajax.html' +
    '?svc=token/login&params={"token":"' + WIALON_TOKEN + '"}'
  );
  const { eid } = await auth.json();
  // use eid for all subsequent requests

## Traccar (self-hosted or cloud)
  const res = await fetch(TRACCAR_URL + '/api/positions', {
    headers: {
      'Authorization': 'Basic ' + btoa(user + ':' + pass)
    }
  });

## Custom / Generic API
  // FleetOps expects this shape per vehicle:
  {
    fleetNumber: "FL-001",
    lat: 24.7136,
    lng: 46.6753,
    speed: 60,
    online: true,
    lastPing: "2026-06-07T09:14:00Z"
  }

## Sync Strategy
- Poll every 30-60s for live tracking view
- Store last position in Supabase vehicles table
- Use Supabase Realtime to push to all connected clients
- No GPS hardware = FleetOps still works 100%`,

"scripts/create-tenant.js":
`#!/usr/bin/env node
// FleetOps Pro — Tenant Onboarding Script
// Usage: node scripts/create-tenant.js --name="Acme Fleet" --email="admin@acme.com" --plan=business
// Requires: npm install stripe @supabase/supabase-js (in production environment)

import 'dotenv/config';

const args = Object.fromEntries(
  process.argv.slice(2)
    .filter(a => a.startsWith('--'))
    .map(a => a.slice(2).split('='))
);

async function createTenant({ name, email, plan = 'starter' }) {
  // Dynamic imports — install in your server environment
  const Stripe = (await import('stripe')).default;
  const { createClient } = await import('@supabase/supabase-js');

  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  const db = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

  console.log('Creating tenant:', name, '/', plan);

  // 1. Stripe customer
  const customer = await stripe.customers.create({ name, email });
  console.log('Stripe customer:', customer.id);

  // 2. Organization
  const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
  const { data: org } = await db.from('organizations')
    .insert({ name, slug, plan, stripe_customer_id: customer.id,
              vehicle_limit: plan === 'starter' ? 5 : null })
    .select().single();
  console.log('Organization:', org.id);

  // 3. Auth user
  const tempPassword = 'Fleet' + Math.random().toString(36).slice(2,8).toUpperCase() + '!';
  const { data: user } = await db.auth.admin.createUser(
    { email, password: tempPassword, email_confirm: true }
  );

  // 4. Profile
  await db.from('profiles').insert({
    id: user.user.id, org_id: org.id,
    full_name: name + ' Admin', email, role: 'admin'
  });

  // 5. Default cost center
  await db.from('cost_centers').insert({
    org_id: org.id, name: 'General Fleet', code: 'GEN', is_active: true
  });

  console.log('Done! Login:', email, '/ Temp password:', tempPassword);
}

createTenant(args).catch(err => { console.error(err.message); process.exit(1); });`,
};

const typeColors = { app:"#4f8ef7", doc:"#a78bfa", config:"#6b7494", db:"#34c97b", billing:"#f5a623", script:"#f25a5a" };
const typeEmoji  = { app:"🌐", doc:"📄", config:"⚙️", db:"🗄", billing:"💳", script:"🔧" };
const typeLabels = { app:"App", doc:"Docs", config:"Config", db:"Database", billing:"Billing", script:"Scripts" };

export default function PackageBuilder() {
  const [selected, setSelected] = useState(null);
  const [copied,   setCopied]   = useState(false);
  const [tab,      setTab]      = useState("files");

  const copy = () => {
    if (!selected || !fileContents[selected]) return;
    navigator.clipboard.writeText(fileContents[selected]);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const grouped = Object.entries(files).reduce((acc,[k,v]) => {
    (acc[v.type] = acc[v.type] || []).push([k,v]);
    return acc;
  }, {});

  const steps = [
    { n:1, icon:"📁", title:"Create GitHub Repo", body:"github.com/new → name FleetOps-Pro → Create repository" },
    { n:2, icon:"⬇️", title:"Download App File", body:"Click ↓ on the FleetOps Pro artifact → save as index.html" },
    { n:3, icon:"📋", title:"Copy Each File", body:"Click a file below → Copy → GitHub: Add file → Create new file → paste & commit" },
    { n:4, icon:"🚀", title:"Deploy to Netlify", body:"app.netlify.com → Import from Git → select repo → auto-deploys from netlify.toml" },
    { n:5, icon:"🗄", title:"Set Up Supabase", body:"supabase.com → New project → SQL Editor → run schema.sql → then seed.sql" },
    { n:6, icon:"💳", title:"Configure Stripe", body:"Follow docs/MONETIZATION.md → create products → register webhook endpoint" },
    { n:7, icon:"🎉", title:"Go Live", body:"Add custom domain in Netlify → set env vars → share demo link with first clients" },
  ];

  const checklist = [
    { title:"🏗 Repo & Code",   items:["Create GitHub repo (FleetOps-Pro)","Upload index.html from artifact","Add all supporting files","Verify .gitignore excludes .env"] },
    { title:"🚀 Hosting",       items:["Deploy to Netlify or Vercel","Add custom domain","SSL certificate active","Test live URL","Test mobile layout"] },
    { title:"🗄 Database",      items:["Create Supabase project","Run schema.sql","Run seed.sql","Verify RLS policies","Copy keys to env vars"] },
    { title:"💳 Billing",       items:["Create Stripe account","Create products from products.json","Set STRIPE keys in env","Register webhook endpoint","Test with card 4242 4242 4242 4242","Verify webhook fires"] },
    { title:"🔒 Security",      items:["Env vars set — not in code","HTTPS enforced","Supabase service key server-side only","Stripe secret key server-side only"] },
    { title:"📣 Launch",        items:["All 4 demo roles tested","Contact form sends to inbox","Pricing page reviewed","First prospect demo booked"] },
  ];
  const [checked, setChecked] = useState({});
  const total = checklist.reduce((a,s)=>a+s.items.length,0);
  const done  = Object.values(checked).filter(Boolean).length;

  const s = { bg:"#0f1117", bg2:"#171a23", bg3:"#1e2130", bg4:"#252840", border:"#2e3248", border2:"#3a3f5c", text:"#e8eaf6", text2:"#9ca3bf", text3:"#6b7494" };

  return (
    <div style={{fontFamily:"-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif",background:s.bg,color:s.text,minHeight:"100vh",padding:20}}>
      {/* Header */}
      <div style={{marginBottom:20}}>
        <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:10}}>
          <div style={{width:44,height:44,background:"#4f8ef7",borderRadius:12,display:"flex",alignItems:"center",justifyContent:"center",fontSize:22,flexShrink:0}}>🚛</div>
          <div>
            <div style={{fontSize:20,fontWeight:700}}>FleetOps Pro — Production Package</div>
            <div style={{fontSize:12,color:s.text3}}>v3.0.0 · {Object.keys(files).length} files ready to copy into GitHub</div>
          </div>
        </div>
        <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
          {[["📦","17 Files"],["🗄","Supabase Schema"],["💳","Stripe Billing"],["📡","GPS Integration"],["🚀","Deploy Ready"]].map(([e,l])=>(
            <span key={l} style={{background:s.bg3,border:`1px solid ${s.border}`,borderRadius:100,padding:"4px 12px",fontSize:12,color:s.text2}}>{e} {l}</span>
          ))}
        </div>
      </div>

      {/* Tabs */}
      <div style={{display:"flex",gap:3,background:s.bg3,borderRadius:8,padding:3,marginBottom:20,width:"fit-content"}}>
        {[["files","📁 Files"],["steps","🚀 Deploy Steps"],["checklist","✅ Go-Live"]].map(([id,label])=>(
          <button key={id} onClick={()=>setTab(id)} style={{padding:"7px 14px",borderRadius:6,fontSize:13,fontWeight:500,cursor:"pointer",border:"none",background:tab===id?s.bg4:"transparent",color:tab===id?s.text:s.text3,transition:"all 0.15s",fontFamily:"inherit"}}>{label}</button>
        ))}
      </div>

      {/* FILES */}
      {tab==="files" && (
        <div style={{display:"grid",gridTemplateColumns:selected?"1fr 1.3fr":"1fr",gap:16,alignItems:"start"}}>
          <div>
            {Object.entries(grouped).map(([type,items])=>(
              <div key={type} style={{marginBottom:16}}>
                <div style={{fontSize:11,fontWeight:600,textTransform:"uppercase",letterSpacing:"0.7px",color:s.text3,marginBottom:8,display:"flex",alignItems:"center",gap:6}}>
                  <span style={{width:8,height:8,borderRadius:2,background:typeColors[type],display:"inline-block"}}></span>
                  {typeLabels[type]}
                </div>
                {items.map(([filename,info])=>(
                  <div key={filename} onClick={()=>setSelected(selected===filename?null:filename)}
                    style={{display:"flex",alignItems:"center",gap:10,padding:"11px 14px",borderRadius:8,border:`1px solid ${selected===filename?"#4f8ef7":s.border}`,background:selected===filename?"rgba(79,142,247,0.08)":s.bg2,marginBottom:6,cursor:"pointer",transition:"all 0.15s"}}>
                    <span style={{fontSize:17,flexShrink:0}}>{typeEmoji[type]}</span>
                    <div style={{flex:1,minWidth:0}}>
                      <div style={{fontSize:12.5,fontWeight:600,color:s.text,fontFamily:"monospace",whiteSpace:"nowrap",overflow:"hidden",textOverflow:"ellipsis"}}>{filename}</div>
                      <div style={{fontSize:11,color:s.text3,marginTop:2}}>{info.desc}</div>
                    </div>
                    <div style={{display:"flex",alignItems:"center",gap:8,flexShrink:0}}>
                      <span style={{fontSize:11,color:s.text3}}>{info.size}</span>
                      {fileContents[filename]
                        ? <span style={{fontSize:10,background:"rgba(52,201,123,0.15)",color:"#34c97b",padding:"2px 7px",borderRadius:4,fontWeight:600}}>Ready</span>
                        : <span style={{fontSize:10,background:s.bg3,color:s.text3,padding:"2px 7px",borderRadius:4}}>Artifact</span>}
                    </div>
                  </div>
                ))}
              </div>
            ))}
          </div>

          {selected && (
            <div style={{background:s.bg2,border:`1px solid ${s.border2}`,borderRadius:10,overflow:"hidden",position:"sticky",top:0,maxHeight:"82vh",display:"flex",flexDirection:"column"}}>
              <div style={{padding:"11px 16px",borderBottom:`1px solid ${s.border}`,display:"flex",justifyContent:"space-between",alignItems:"center",background:s.bg3,flexShrink:0}}>
                <span style={{fontSize:12.5,fontWeight:600,fontFamily:"monospace",color:s.text,overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap",flex:1,marginRight:10}}>{selected}</span>
                <div style={{display:"flex",gap:8,flexShrink:0}}>
                  {fileContents[selected] && (
                    <button onClick={copy} style={{padding:"5px 12px",borderRadius:6,border:`1px solid ${s.border2}`,background:copied?"rgba(52,201,123,0.15)":s.bg4,color:copied?"#34c97b":s.text2,fontSize:12,cursor:"pointer",fontFamily:"inherit",fontWeight:500}}>
                      {copied?"✓ Copied!":"Copy"}
                    </button>
                  )}
                  <button onClick={()=>setSelected(null)} style={{padding:"5px 10px",borderRadius:6,border:`1px solid ${s.border}`,background:s.bg4,color:s.text3,fontSize:12,cursor:"pointer",fontFamily:"inherit"}}>✕</button>
                </div>
              </div>
              <div style={{flex:1,overflow:"auto",padding:16}}>
                {fileContents[selected]
                  ? <pre style={{margin:0,fontSize:11.5,lineHeight:1.65,color:s.text2,fontFamily:"monospace",whiteSpace:"pre-wrap",wordBreak:"break-word"}}>{fileContents[selected]}</pre>
                  : <div style={{textAlign:"center",padding:"40px 16px",color:s.text3}}>
                      <div style={{fontSize:36,marginBottom:14}}>⬇️</div>
                      <div style={{fontSize:14,fontWeight:500,color:s.text2,marginBottom:6}}>{files[selected]?.note}</div>
                      <div style={{fontSize:12}}>{files[selected]?.desc}</div>
                    </div>}
              </div>
            </div>
          )}
        </div>
      )}

      {/* STEPS */}
      {tab==="steps" && (
        <div style={{maxWidth:580}}>
          {steps.map((step,i)=>(
            <div key={i} style={{display:"flex",gap:14,marginBottom:4}}>
              <div style={{display:"flex",flexDirection:"column",alignItems:"center",flexShrink:0}}>
                <div style={{width:38,height:38,borderRadius:"50%",background:"#4f8ef7",display:"flex",alignItems:"center",justifyContent:"center",fontSize:18}}>{step.icon}</div>
                {i<steps.length-1 && <div style={{width:2,height:24,background:s.border,margin:"4px 0"}}/>}
              </div>
              <div style={{background:s.bg2,border:`1px solid ${s.border}`,borderRadius:10,padding:"13px 16px",flex:1,marginBottom:i<steps.length-1?4:0}}>
                <div style={{fontSize:13.5,fontWeight:600,color:s.text,marginBottom:4}}>Step {step.n}: {step.title}</div>
                <div style={{fontSize:13,color:s.text2,lineHeight:1.5}}>{step.body}</div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* CHECKLIST */}
      {tab==="checklist" && (
        <div style={{maxWidth:580}}>
          <div style={{background:s.bg2,border:`1px solid ${s.border}`,borderRadius:10,padding:"14px 18px",marginBottom:18,display:"flex",alignItems:"center",gap:16}}>
            <div style={{flex:1}}>
              <div style={{fontSize:13,color:s.text2,marginBottom:7}}>{done} of {total} tasks complete</div>
              <div style={{background:s.bg4,borderRadius:100,height:7,overflow:"hidden"}}>
                <div style={{height:"100%",background:done===total?"#34c97b":"#4f8ef7",borderRadius:100,width:`${Math.round((done/total)*100)}%`,transition:"width 0.3s"}}/>
              </div>
            </div>
            <div style={{fontSize:24,fontWeight:700,color:done===total?"#34c97b":"#4f8ef7",flexShrink:0}}>{Math.round((done/total)*100)}%</div>
          </div>
          {checklist.map((sec,si)=>(
            <div key={si} style={{marginBottom:14}}>
              <div style={{fontSize:13,fontWeight:600,color:s.text,marginBottom:8}}>{sec.title}</div>
              <div style={{background:s.bg2,border:`1px solid ${s.border}`,borderRadius:10,overflow:"hidden"}}>
                {sec.items.map((item,ii)=>{
                  const key=`${si}-${ii}`;
                  return(
                    <div key={ii} onClick={()=>setChecked(c=>({...c,[key]:!c[key]}))}
                      style={{display:"flex",alignItems:"center",gap:12,padding:"11px 16px",borderBottom:ii<sec.items.length-1?`1px solid ${s.border}`:"none",cursor:"pointer",background:checked[key]?"rgba(52,201,123,0.04)":"transparent",transition:"background 0.1s"}}>
                      <div style={{width:18,height:18,borderRadius:5,border:`2px solid ${checked[key]?"#34c97b":s.border2}`,background:checked[key]?"#34c97b":"transparent",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,transition:"all 0.15s"}}>
                        {checked[key] && <svg width="10" height="10" viewBox="0 0 24 24" fill="white"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>}
                      </div>
                      <span style={{fontSize:13,color:checked[key]?s.text3:s.text2,textDecoration:checked[key]?"line-through":"none"}}>{item}</span>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}                                    
                                                  
