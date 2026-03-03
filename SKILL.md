---
name: Pingward
description: >
  Set up API monitoring, uptime checks, SSL certificate monitoring, DNS monitoring,
  heartbeat monitors, alerting, on-call schedules, and status pages using Pingward.
  Activates on: monitoring, uptime, health check, endpoint monitoring, API monitoring,
  alerting, on-call, status page, heartbeat, SSL certificate, DNS monitoring, pingward.
version: 1.0.0
openclaw:
  name: pingward
  category: devops
  tags: [monitoring, uptime, api, alerting, observability, mcp]
---

# Pingward — API Monitoring Skill

Pingward is an API monitoring platform that checks HTTP endpoints, MCP servers, A2A agents, GraphQL APIs, gRPC services, SSL certificates, and DNS records. It detects issues, classifies them by type and severity, and alerts you via Email, Slack, SMS, or Webhook.

## Quick Start

### Step 1: Connect MCP (no API key needed)

Add to your project's `.mcp.json`:

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

Restart your IDE session to connect.

### Step 2: Register (or Login)

Use the `register` tool with your email, password, name, and organization:

> "Register me on Pingward with email user@example.com"

Or if you already have an account, use the `login` tool.

Both return an API key. Set it as the `PINGWARD_API_KEY` environment variable:

```bash
export PINGWARD_API_KEY="aw_your_key_here"
```

Then update `.mcp.json` to include the key and restart:

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

### Step 3: Use It

All 62 tools are now available. Ask:

> "Set up monitoring for my API at https://api.example.com"

The agent will create HTTP monitors, SSL certificate checks, DNS monitors, alerting integrations, and routing rules.

## REST API (Fallback)

If MCP tools are not available (e.g., CI/CD, headless environments), use the REST API directly. The API key works with both `X-Api-Key` header and `Authorization: Bearer` header.

```bash
# List monitors
curl https://api.pingward.com/api/tests -H "X-Api-Key: $PINGWARD_API_KEY"

# Create an HTTP monitor
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"Health Check","testType":"Http","httpMethod":"GET","url":"https://api.example.com/health","frequencyMinutes":5,"regions":["*"]}'

# Create an email integration
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"type":"Email","name":"Alerts","config":{"defaultRecipients":["team@example.com"]}}'

# Dashboard summary
curl https://api.pingward.com/api/dashboard/summary -H "X-Api-Key: $PINGWARD_API_KEY"
```

See `references/api-reference.md` for the full endpoint reference (~80 endpoints with curl examples).

**When to use REST vs MCP:**
- **Use REST (curl)** for CI/CD scripts, headless environments, or programmatic access
- **Use MCP tools** for interactive agent workflows (richer context, prompts, streaming)

## Using MCP Tools

Once connected with an API key, you have access to 62 tools and 4 prompts. Here are the most common workflows:

### Monitor an API

1. Use `create_http_test` to create a monitor for each endpoint
2. Use `create_ssl_test` to monitor SSL certificate expiry
3. Use `create_dns_test` to verify DNS resolution
4. Use `run_test` to execute a test immediately and verify it works

### Set Up Alerting

1. Use `create_integration` to add a notification channel (Email, Slack, SMS, Webhook)
2. Use `test_integration` to verify it works
3. Use `create_routing_rule` to route alerts by severity or error type
4. Use `create_escalation_policy` for multi-tier escalation

### Monitor Cron Jobs & Background Tasks

1. Use `create_heartbeat_monitor` to get a ping URL
2. Add the ping URL to your cron job / task scheduler
3. If pings stop arriving, an alert fires

### Investigate Issues

1. Use `list_issues` to see active issues
2. Use `get_issue` for full details and activity log
3. Use `get_issue_failed_results` for request/response data
4. Use `acknowledge_issue` or `resolve_issue` to manage lifecycle

### Schedule Maintenance

1. Use `create_maintenance_window` to suppress alerts during deploys
2. Choose `SuppressIssues` (keep testing) or `PauseExecution` (stop tests)

### Review Performance

1. Use `get_dashboard_summary` for a system overview
2. Use `get_performance_dashboard` for baselines and degradation events
3. Use `get_test_availability` for uptime percentage over N days

## Tool Summary

| Category | Tools | Key Tools |
|----------|-------|-----------|
| Onboarding | 3 | `register`, `login`, `get_plans` |
| Tests | 13 | `create_http_test`, `create_ssl_test`, `create_dns_test`, `run_test`, `list_tests` |
| Heartbeats | 8 | `create_heartbeat_monitor`, `list_heartbeat_monitors`, `pause_heartbeat_monitor` |
| Issues | 6 | `list_issues`, `get_issue`, `acknowledge_issue`, `resolve_issue` |
| Integrations | 4 | `create_integration`, `test_integration`, `list_integrations` |
| Routing | 5 | `create_routing_rule`, `toggle_routing_rule`, `list_routing_rules` |
| Escalation | 4 | `create_escalation_policy`, `list_escalation_policies` |
| On-Call | 7 | `create_on_call_schedule`, `create_on_call_override` |
| Maintenance | 4 | `create_maintenance_window`, `list_maintenance_windows` |
| Dashboard | 2 | `get_dashboard_summary`, `get_performance_dashboard` |
| Settings | 3 | `get_severity_config`, `update_severity_config` |
| Regions | 1 | `list_regions` |
| Feedback | 2 | `submit_feedback`, `submit_feature_request` |

## Prompts

| Prompt | Description |
|--------|-------------|
| `create_monitoring_for_api` | Generate a comprehensive monitoring plan for an API (pass `baseUrl`) |
| `audit_monitoring` | Audit existing monitoring config and suggest improvements |
| `setup_alerting_pipeline` | Step-by-step guide to set up integrations + routing + escalation |
| `investigate_issue` | Step-by-step investigation guide for a specific issue (pass `issueId`) |

## Plans

| Feature | Free | Starter ($29/mo) | Pro ($99/mo) | Enterprise ($299/mo) |
|---------|------|-------------------|--------------|----------------------|
| Monitors | 10 | 25 | 100 | Unlimited |
| Checks/month | 50K | 250K | 2M | 10M+ |
| Min interval | 5 min | 1 min | 30 sec | 10 sec |
| History | 7 days | 30 days | 90 days | 1 year |
| Team members | 3 | 5 | 25 | Unlimited |
| SMS/month | 0 | 50 | 500 | 2,000 |
| Status pages | No | Yes | Yes | Unlimited |
| SSO | No | No | No | Yes |

Use the `get_plans` tool or `GET https://api.pingward.com/api/billing/plans` for details.

## Feedback

Use `submit_feedback` or `submit_feature_request` MCP tools to send feedback directly to the Pingward team.

## Reference Docs

For detailed documentation, see the `references/` directory:
- `references/api-reference.md` — REST API endpoints
- `references/mcp-tools.md` — All MCP tools with full parameter docs
- `references/onboarding-guide.md` — Detailed setup walkthrough
- `references/plans-and-pricing.md` — Plan comparison
