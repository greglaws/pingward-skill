# Pingward Plans & Pricing

View current plans programmatically: `GET https://api.pingward.com/api/billing/plans`

---

## Plan Comparison

| Feature | Free | Starter | Pro | Enterprise |
|---------|------|---------|-----|------------|
| **Monthly Price** | $0 | $29 | $99 | $299 |
| **Annual Price** | $0 | $278/yr | $950/yr | $2,870/yr |
| **Monitors** | 10 | 25 | 100 | Unlimited |
| **Checks/month** | 50,000 | 250,000 | 2,000,000 | 10,000,000+ |
| **Min check interval** | 5 minutes | 1 minute | 30 seconds | 10 seconds |
| **Team members** | 3 | 5 | 25 | Unlimited |
| **Data retention** | 7 days | 30 days | 90 days | 1 year |
| **SMS credits/month** | 0 | 50 | 500 | 2,000 |
| **Status pages** | No | Yes | Yes | Unlimited |
| **SSO/SAML** | No | No | No | Yes |
| **Custom CSS** | No | No | No | Yes |

---

## Feature Details by Plan

### Free Plan
- 10 monitors
- 50,000 checks/month
- 5-minute intervals
- Email alerts only
- 7-day history
- 3 team members

### Starter Plan — $29/month
- 25 monitors
- 250,000 checks/month
- 1-minute intervals
- Email + Slack + Webhook alerts
- 30-day history
- 5 team members
- 1 status page
- 50 SMS/month

### Pro Plan — $99/month (most popular)
- 100 monitors
- 2M checks/month
- 30-second intervals
- All alert channels
- 90-day history
- 25 team members
- 1 status page
- 500 SMS/month
- Priority support

### Enterprise Plan — $299/month
- Unlimited monitors
- 10M+ checks/month
- 10-second intervals
- All channels + webhooks
- 1-year history
- Unlimited team members
- Unlimited status pages
- 2,000 SMS/month
- SSO/SAML
- Custom CSS
- Dedicated support

---

## Upgrading

To upgrade via the API:

```bash
curl -X POST https://api.pingward.com/api/billing/checkout \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "starter",
    "successUrl": "https://pingward.com/settings?tab=billing&success=true",
    "cancelUrl": "https://pingward.com/settings?tab=billing"
  }'
```

This returns a Stripe Checkout URL. Open it in a browser to complete payment.

## Checking Usage

```bash
curl https://api.pingward.com/api/billing/usage \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns current usage against plan limits for test slots, executions, team members, and SMS credits.
