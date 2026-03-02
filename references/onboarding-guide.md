# Pingward Onboarding Guide

This guide walks through setting up Pingward from scratch: account creation, API key setup, MCP connection, creating your first monitor, and configuring alerts.

---

## 1. Create an Account

Register via the REST API:

```bash
curl -X POST https://api.pingward.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "you@example.com",
    "password": "YourSecureP@ss1",
    "firstName": "Jane",
    "lastName": "Smith",
    "organizationName": "Acme Corp"
  }'
```

Password requirements: 8+ characters, uppercase, lowercase, digit, and special character.

Save the `token` from the response — you'll need it to create an API key.

---

## 2. Create an API Key

```bash
curl -X POST https://api.pingward.com/api/auth/api-keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "agent-access", "scopes": ["read", "write"]}'
```

The response includes a `key` field in the format `aw_XXXXXXXX_XXXXXXXX`. Save it immediately — it cannot be retrieved again.

Set it as an environment variable:

```bash
export PINGWARD_API_KEY="aw_your_key_here"
```

---

## 3. Connect via MCP

### Claude Code

Add to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "pingward": {
      "type": "url",
      "url": "https://mcp.pingward.com/mcp",
      "headers": {
        "X-Api-Key": "${PINGWARD_API_KEY}"
      }
    }
  }
}
```

### Cursor

Add to `.cursor-plugin/plugin.json` or configure in Cursor settings:

```json
{
  "mcpServers": {
    "pingward": {
      "type": "url",
      "url": "https://mcp.pingward.com/mcp",
      "headers": {
        "X-Api-Key": "${PINGWARD_API_KEY}"
      }
    }
  }
}
```

### Direct API

Use the API key in the `X-Api-Key` header:

```bash
curl https://api.pingward.com/api/auth/me \
  -H "X-Api-Key: aw_your_key_here"
```

---

## 4. Create Your First Monitor

Using the `create_http_test` MCP tool:

- **name**: "API Health Check"
- **url**: "https://api.example.com/health"
- **frequencyMinutes**: 5
- **expectedStatusCode**: 200
- **maxResponseTimeMs**: 3000
- **regions**: "*" (all regions)

This creates a monitor that checks your health endpoint every 5 minutes from all available regions, expecting a 200 response within 3 seconds.

### Run it immediately

Use `run_test` with the returned test ID to verify it works before waiting for the next scheduled execution.

### Add SSL monitoring

Use `create_ssl_test`:
- **name**: "API SSL Certificate"
- **hostname**: "api.example.com"
- **warningDays**: 30

### Add DNS monitoring

Use `create_dns_test`:
- **name**: "API DNS Resolution"
- **hostname**: "api.example.com"
- **recordType**: "A"

---

## 5. Set Up Alerting

### Create an integration

Use `create_integration`:

**Slack example:**
- **name**: "Engineering Slack"
- **type**: "Slack"
- **config**: `{"webhookUrl": "https://hooks.slack.com/services/...", "channel": "#alerts"}`

**Email example:**
- **name**: "Team Email"
- **type**: "Email"
- **config**: `{"smtpHost": "smtp.gmail.com", "smtpPort": 587, "fromAddress": "alerts@example.com", "toAddresses": ["team@example.com"]}`

**Webhook example:**
- **name**: "PagerDuty Webhook"
- **type**: "Webhook"
- **config**: `{"url": "https://events.pagerduty.com/integration/...", "secretKey": "optional-hmac-key"}`

### Test the integration

Use `test_integration` to send a test notification and confirm delivery.

### Create a routing rule

Use `create_routing_rule`:
- **name**: "Critical alerts to Slack"
- **conditions**: `{"severities": ["Critical", "High"]}`
- **actions**: `[{"integrationId": "INTEGRATION_ID"}]`

---

## 6. Monitor Background Jobs

Use `create_heartbeat_monitor` for cron jobs, scheduled tasks, or any periodic process:

- **name**: "Nightly backup job"
- **expectedIntervalMinutes**: 1440 (24 hours)
- **gracePeriodMinutes**: 30

The response includes a `pingUrl`. Add a call to this URL at the end of your job:

```bash
# At the end of your cron job
curl -s "$PING_URL" > /dev/null
```

If the ping doesn't arrive within the expected interval + grace period, an alert fires.

---

## 7. Review Your Setup

Use `get_dashboard_summary` to see a system overview of all monitors, active issues, and maintenance windows.

Use the `audit_monitoring` prompt for an automated audit of your monitoring configuration with improvement suggestions.

---

## Next Steps

- **Performance baselines**: After 24 hours of data, use `get_performance_dashboard` to see P50/P95/P99 response times
- **Escalation policies**: Use `create_escalation_policy` for multi-tier alerting (e.g., Slack first, then SMS after 15 min)
- **On-call schedules**: Use `create_on_call_schedule` for team rotation
- **Maintenance windows**: Use `create_maintenance_window` before deployments to suppress false alerts
- **Upgrade**: View plans at `GET /api/billing/plans` or at https://pingward.com/pricing
