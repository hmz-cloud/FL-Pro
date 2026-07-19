#!/usr/bin/env node
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

createTenant(args).catch(err => { console.error(err.message); process.exit(1); });
