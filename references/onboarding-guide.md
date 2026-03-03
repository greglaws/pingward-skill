# Pingward Onboarding Guide

This guide walks through setting up Pingward from scratch using the REST API (curl). Every step works headlessly without requiring an IDE restart. MCP connection is an optional final step for ongoing management.

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
  -d '{"name": "agent-access", "scopes": ["read", "write", "delete", "execute", "integrations"]}'
```

The response includes a `key` field in the format `aw_XXXXXXXX_XXXXXXXX`. Save it immediately — it cannot be retrieved again.

Set it as an environment variable for the rest of this guide:

```bash
export PINGWARD_API_KEY="aw_your_key_here"
```

**Available scopes:** `read`, `write`, `delete`, `execute`, `integrations`, `team`, `billing`. The scopes above cover all monitoring and alerting operations.

---

## 3. Create Monitors

### HTTP Health Check

```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "API Health Check",
    "testType": "Http",
    "httpMethod": "GET",
    "url": "https://api.example.com/health",
    "frequencyMinutes": 5,
    "regions": ["*"],
    "importance": "Production",
    "assertions": [
      {"type": "StatusCode", "operator": "Equals", "value": "200"},
      {"type": "ResponseTime", "operator": "LessThan", "value": "3000"}
    ]
  }'
```

Save the `id` from the response — you'll need it for verification.

### SSL Certificate Monitor

```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "API SSL Certificate",
    "testType": "SslCertificate",
    "url": "api.example.com",
    "frequencyMinutes": 1440,
    "regions": ["*"],
    "protocolConfig": "{\"hostname\": \"api.example.com\", \"warningDaysBeforeExpiry\": 30, \"criticalDaysBeforeExpiry\": 7}"
  }'
```

### DNS Record Monitor

```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "API DNS Resolution",
    "testType": "DnsRecord",
    "url": "api.example.com",
    "frequencyMinutes": 60,
    "regions": ["*"],
    "protocolConfig": "{\"hostname\": \"api.example.com\", \"recordType\": \"A\"}"
  }'
```

### Verify a Monitor

Run a test immediately to confirm it works:

```bash
curl -X POST https://api.pingward.com/api/tests/TEST_ID/run \
  -H "X-Api-Key: $PINGWARD_API_KEY"
```

The response includes the full request/response details and assertion results.

---

## 4. Set Up Alerting

### Create an Integration

**Email:**
```bash
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "type": "Email",
    "name": "Team Email Alerts",
    "config": {"defaultRecipients": ["team@example.com", "oncall@example.com"]}
  }'
```

**Webhook (e.g., PagerDuty):**
```bash
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "type": "Webhook",
    "name": "PagerDuty",
    "config": {"url": "https://events.pagerduty.com/integration/KEY/enqueue"}
  }'
```

**Slack (webhook):**
```bash
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "type": "Slack",
    "name": "Engineering Slack",
    "config": {"webhookUrl": "https://hooks.slack.com/services/...", "channel": "#alerts"}
  }'
```

Save each integration's `id` from the response.

### Test the Integration

```bash
curl -X POST https://api.pingward.com/api/integrations/INTEGRATION_ID/test \
  -H "X-Api-Key: $PINGWARD_API_KEY"
```

### Create Routing Rules

Routing rules determine which integrations are notified for which alerts. Lower priority number = higher precedence.

**Critical + High severity alerts:**
```bash
curl -X POST https://api.pingward.com/api/routing-rules \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "Critical & High alerts",
    "priority": 0,
    "conditions": {"severities": ["Critical", "High"]},
    "actions": [{"integrationId": "EMAIL_INTEGRATION_ID"}]
  }'
```

**Medium severity alerts:**
```bash
curl -X POST https://api.pingward.com/api/routing-rules \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "Medium alerts",
    "priority": 1,
    "conditions": {"severities": ["Medium"]},
    "actions": [{"integrationId": "EMAIL_INTEGRATION_ID"}]
  }'
```

### Create an Escalation Policy

Escalation policies define multi-tier alerting (e.g., email first, then SMS after 15 minutes).

```bash
curl -X POST https://api.pingward.com/api/escalation-policies \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "Infrastructure Escalation",
    "tiers": [
      {"level": 0, "timeoutMinutes": 15, "targets": [{"type": "integration", "id": "EMAIL_INTEGRATION_ID"}]},
      {"level": 1, "timeoutMinutes": 30, "targets": [{"type": "integration", "id": "EMAIL_INTEGRATION_ID"}, {"type": "integration", "id": "SLACK_INTEGRATION_ID"}]}
    ],
    "repeatBehavior": "RepeatLast"
  }'
```

Then link the escalation policy to a routing rule by including `"escalationPolicyId"` when creating or updating a routing rule.

---

## 5. Monitor Background Jobs

Create a heartbeat monitor for cron jobs, scheduled tasks, or any periodic process:

```bash
curl -X POST https://api.pingward.com/api/heartbeat-monitors \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{
    "name": "Nightly backup job",
    "expectedIntervalMinutes": 1440,
    "gracePeriodMinutes": 30
  }'
```

The response includes a `pingUrl`. Add a call to this URL at the end of your job:

```bash
# At the end of your cron job
curl -s "$PING_URL" > /dev/null
```

If the ping doesn't arrive within the expected interval + grace period, an alert fires.

---

## 6. Review Your Setup

Get a full dashboard summary:

```bash
curl https://api.pingward.com/api/dashboard/summary \
  -H "X-Api-Key: $PINGWARD_API_KEY"
```

This shows:
- Total monitors, passing/failing/paused counts
- Overall availability percentage
- Active issues and incidents
- On-call status
- Active maintenance windows

List all routing rules to verify alerting config:

```bash
curl https://api.pingward.com/api/routing-rules \
  -H "X-Api-Key: $PINGWARD_API_KEY"
```

---

## 7. Connect MCP for Ongoing Management (Optional)

Once your initial setup is complete, you can connect the MCP server for richer agent-driven management. This requires an IDE restart after adding the config.

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

After adding the config, restart your IDE session. You'll then have access to 59 MCP tools and 4 prompts for managing monitors, issues, alerting, on-call, and more.

### Direct API Access

You can also use the API key directly in any HTTP client:

```bash
curl https://api.pingward.com/api/tests \
  -H "X-Api-Key: $PINGWARD_API_KEY"
```

---

## Next Steps

- **Performance baselines**: After 24 hours of data, check `GET /api/dashboard/performance` for P50/P95/P99 response times
- **Escalation policies**: Create multi-tier alerting (e.g., email first, then SMS after 15 min)
- **On-call schedules**: Set up team rotation via `POST /api/on-call-schedules`
- **Maintenance windows**: Suppress alerts during deploys via `POST /api/maintenance-windows`
- **Severity tuning**: Customize error-to-severity mapping via `PUT /api/settings/severity`
- **Upgrade**: View plans at `GET /api/billing/plans` or at https://pingward.com/pricing
