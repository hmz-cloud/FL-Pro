// FleetOps Pro — Stripe Webhook Handler
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
}
