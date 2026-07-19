# Monetization Playbook

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
15-min call: [CALENDAR_LINK]
