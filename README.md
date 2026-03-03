# Pingward Agent Skill

[Pingward](https://pingward.com) is an API monitoring platform. This skill enables AI agents (Claude Code, Cursor, etc.) to autonomously set up and manage monitoring for your projects.

## What You Get

- **62 MCP tools** for monitoring, alerting, on-call, maintenance, and more
- **~80 REST API endpoints** for headless/programmatic access (no MCP required)
- **4 prompts** for common workflows (monitoring setup, audit, alerting, investigation)
- **7 monitor types**: HTTP, MCP Server, A2A Agent, GraphQL, gRPC, SSL Certificate, DNS Record
- **4 alert channels**: Email, Slack, SMS, Webhook

## Quick Start

### Option A: MCP (Recommended)

#### 1. Connect (no API key needed)

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

#### 2. Register

Use the `register` tool — it creates your account and returns an API key in one step.

#### 3. Set API Key & Reconnect

```bash
export PINGWARD_API_KEY="aw_your_key_here"
```

Update `.mcp.json` to include the key:

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

Restart your IDE session. All 62 tools are now available.

#### 4. Use It

Ask your AI agent to:

> "Set up monitoring for my API at https://api.example.com"

The agent will create HTTP monitors, SSL certificate checks, and DNS monitors using the MCP tools.

**One-line install (alternative):**

```bash
curl -fsSL https://raw.githubusercontent.com/greglaws/pingward-skill/main/install.sh | bash
```

### Option B: REST API (For CI/CD & Scripts)

Use the REST API directly — no MCP connection or IDE restart needed:

```bash
# Register and get API key
curl -X POST https://api.pingward.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"you@example.com","password":"SecureP@ss1","firstName":"Jane","lastName":"Smith"}'

# Create API key (use token from response)
curl -X POST https://api.pingward.com/api/auth/api-keys \
  -H "Authorization: Bearer YOUR_TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"agent-access","scopes":["read","write","delete","execute","integrations"]}'

export PINGWARD_API_KEY="aw_your_key_here"

# Create a monitor, set up alerts, check dashboard — all via curl
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" -H "X-Api-Key: $PINGWARD_API_KEY" \
  -d '{"name":"Health Check","testType":"Http","url":"https://api.example.com/health","frequencyMinutes":5,"regions":["*"]}'
```

See [references/api-reference.md](./references/api-reference.md) for the full endpoint reference.

## Documentation

- [SKILL.md](./SKILL.md) — Primary skill file with tool summary and workflows
- [references/api-reference.md](./references/api-reference.md) — REST API endpoints
- [references/mcp-tools.md](./references/mcp-tools.md) — All 62 MCP tools with parameters
- [references/onboarding-guide.md](./references/onboarding-guide.md) — Detailed setup walkthrough
- [references/plans-and-pricing.md](./references/plans-and-pricing.md) — Plan comparison

## Plans

| | Free | Starter | Pro | Enterprise |
|---|---|---|---|---|
| Price | $0 | $29/mo | $99/mo | $299/mo |
| Monitors | 10 | 25 | 100 | Unlimited |
| Min interval | 5 min | 1 min | 30 sec | 10 sec |

[View all plans](https://pingward.com/pricing)

## License

[MIT](./LICENSE)
