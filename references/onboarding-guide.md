# Pingward Onboarding Guide

This guide walks through setting up Pingward from scratch. The primary path uses MCP tools — no curl or manual API calls needed. A REST API alternative is included at the bottom for CI/CD and headless use cases.

---

## 1. Connect MCP (No API Key Needed)

Add the Pingward MCP server to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "pingward": {
      "type": "url",
      "url": "https://mcp.pingward.com/mcp"
    }
  }
}
```

Restart your IDE session. The `register`, `login`, and `get_plans` tools are now available without authentication.

---

## 2. Register Your Account

Use the `register` MCP tool:

- `email` — your email address
- `password` — 8+ characters, uppercase, lowercase, digit, special character
- `firstName`, `lastName` — your name
- `organizationName` (optional) — defaults to "FirstName's Organization"

The tool creates your account AND generates an API key in one step. Save the returned API key — it cannot be retrieved again.

Already have an account? Use the `login` tool with your email and password instead.

**Compare plans first?** Use the `get_plans` tool to see pricing and limits before registering.

---

## 3. Set API Key & Reconnect

Set the API key as an environment variable:

```bash
export PINGWARD_API_KEY="aw_your_key_here"
```

Update `.mcp.json` to include authentication:

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

Restart your IDE session. All 62 tools and 4 prompts are now available.

---

## 4. Create Monitors

### HTTP Health Check

Use `create_http_test`:
- `name`: "API Health Check"
- `url`: "https://api.example.com/health"
- `frequencyMinutes`: 5
- `expectedStatusCode`: 200

### SSL Certificate Monitor

Use `create_ssl_test`:
- `name`: "API SSL Certificate"
- `hostname`: "api.example.com"
- `warningDays`: 30

### DNS Record Monitor

Use `create_dns_test`:
- `name`: "API DNS Resolution"
- `hostname`: "api.example.com"
- `recordType`: "A"

### Verify a Monitor

Use `run_test` with the test ID to execute immediately and confirm it works.

---

## 5. Set Up Alerting

### Create an Integration

Use `create_integration`:

**Email:**
- `name`: "Team Email Alerts"
- `type`: "Email"
- `config`: `{"defaultRecipients": ["team@example.com"]}`

**Slack:**
- `name`: "Engineering Slack"
- `type`: "Slack"
- `config`: `{"webhookUrl": "https://hooks.slack.com/services/...", "channel": "#alerts"}`

**Webhook (e.g., PagerDuty):**
- `name`: "PagerDuty"
- `type`: "Webhook"
- `config`: `{"url": "https://events.pagerduty.com/integration/KEY/enqueue"}`

### Test the Integration

Use `test_integration` with the integration ID to send a test notification.

### Create Routing Rules

Use `create_routing_rule` to route alerts by severity:

**Critical + High severity:**
- `name`: "Critical & High alerts"
- `priority`: 0
- `conditions`: `{"severities": ["Critical", "High"]}`
- `actions`: `[{"integrationId": "EMAIL_INTEGRATION_ID"}]`

**Medium severity:**
- `name`: "Medium alerts"
- `priority`: 1
- `conditions`: `{"severities": ["Medium"]}`
- `actions`: `[{"integrationId": "EMAIL_INTEGRATION_ID"}]`

### Create an Escalation Policy

Use `create_escalation_policy`:
- `name`: "Infrastructure Escalation"
- `tiers`: `[{"level": 0, "timeoutMinutes": 15, "targets": [{"type": "integration", "id": "EMAIL_ID"}]}, {"level": 1, "timeoutMinutes": 30, "targets": [{"type": "integration", "id": "SLACK_ID"}]}]`
- `repeatBehavior`: "RepeatLast"

Link the escalation policy to a routing rule by including `escalationPolicyId` when creating or updating a routing rule.

---

## 6. Monitor Background Jobs

Use `create_heartbeat_monitor`:
- `name`: "Nightly backup job"
- `expectedIntervalMinutes`: 1440
- `gracePeriodMinutes`: 30

The response includes a `pingUrl`. Add a call to this URL at the end of your job:

```bash
curl -s "$PING_URL" > /dev/null
```

If the ping doesn't arrive within the expected interval + grace period, an alert fires.

---

## 7. Review Your Setup

Use `get_dashboard_summary` for a full overview:
- Total monitors, passing/failing/paused counts
- Active issues and incidents
- Active maintenance windows

Use `get_performance_dashboard` for response time baselines (available after 24 hours of data).

---

## REST API Alternative

For CI/CD, scripts, or environments where MCP isn't available, use the REST API directly. All examples below use curl with the `X-Api-Key` header.

### Register & Get API Key

```bash
# Register
curl -X POST https://api.pingward.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "you@example.com",
    "password": "YourSecureP@ss1",
    "firstName": "Jane",
    "lastName": "Smith",
    "organizationName": "Acme Corp"
  }'

# Create API key (use token from register response)
curl -X POST https://api.pingward.com/api/auth/api-keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "agent-access", "scopes": ["read", "write", "delete", "execute", "integrations"]}'

export PINGWARD_API_KEY="aw_your_key_here"
```

### Create Monitors

```bash
# HTTP monitor
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"API Health","testType":"Http","httpMethod":"GET","url":"https://api.example.com/health","frequencyMinutes":5,"regions":["*"]}'

# SSL monitor
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"API SSL","testType":"SslCertificate","url":"api.example.com","frequencyMinutes":1440,"regions":["*"],"protocolConfig":"{\"hostname\":\"api.example.com\",\"warningDaysBeforeExpiry\":30}"}'

# DNS monitor
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"API DNS","testType":"DnsRecord","url":"api.example.com","frequencyMinutes":60,"regions":["*"],"protocolConfig":"{\"hostname\":\"api.example.com\",\"recordType\":\"A\"}"}'
```

### Set Up Alerting

```bash
# Email integration
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"type":"Email","name":"Team Alerts","config":{"defaultRecipients":["team@example.com"]}}'

# Routing rule
curl -X POST https://api.pingward.com/api/routing-rules \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"Critical alerts","priority":0,"conditions":{"severities":["Critical","High"]},"actions":[{"integrationId":"INTEGRATION_ID"}]}'
```

### Dashboard

```bash
curl https://api.pingward.com/api/dashboard/summary -H "X-Api-Key: $PINGWARD_API_KEY"
```

See `references/api-reference.md` for the full endpoint reference (~110 endpoints).

---

## Next Steps

- **Performance baselines**: After 24 hours of data, use `get_performance_dashboard` for P50/P95/P99 response times
- **Escalation policies**: Create multi-tier alerting with `create_escalation_policy`
- **On-call schedules**: Set up team rotation with `create_on_call_schedule`
- **Maintenance windows**: Suppress alerts during deploys with `create_maintenance_window`
- **Severity tuning**: Customize error-to-severity mapping with `update_severity_config`
- **Upgrade**: Use `get_plans` to compare plans or visit https://pingward.com/pricing
