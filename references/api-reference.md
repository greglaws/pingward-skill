# Pingward REST API Reference

Base URL: `https://api.pingward.com`

All authenticated endpoints require either:
- `Authorization: Bearer <JWT_TOKEN>` (from login/register)
- `X-Api-Key: <API_KEY>` (for programmatic access)
- `Authorization: Bearer <API_KEY>` (alternative API key format)

---

## Authentication

### Register

```
POST /api/auth/register
```

**Body:**
```json
{
  "email": "string (required)",
  "password": "string (required, 8+ chars, upper+lower+digit+special)",
  "firstName": "string (required)",
  "lastName": "string (required)",
  "organizationName": "string (optional)"
}
```

**curl:**
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

**Response (200):**
```json
{
  "succeeded": true,
  "token": "eyJhbG...",
  "user": {
    "id": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string"
  },
  "tenant": {
    "id": "guid",
    "name": "string",
    "slug": "string",
    "plan": "Free"
  }
}
```

### Login

```
POST /api/auth/login
```

**Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response:** Same as Register.

### Get Current User

```
GET /api/auth/me
```

**Response (200):**
```json
{
  "user": { "id", "email", "firstName", "lastName" },
  "currentTenant": { "id", "name", "slug", "plan" },
  "role": "Owner|Admin|Member|Viewer",
  "tenants": [...],
  "isPlatformAdmin": false
}
```

---

## API Keys

### Create API Key

```
POST /api/auth/api-keys
```

**Body:**
```json
{
  "name": "string (required)",
  "scopes": ["read", "write", "delete", "execute", "integrations"]
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/auth/api-keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "agent-access", "scopes": ["read", "write", "delete", "execute", "integrations"]}'
```

**Response (200):**
```json
{
  "key": "aw_XXXXXXXX_XXXXXXXX (shown only once)",
  "name": "string",
  "scopes": ["read", "write", "delete", "execute", "integrations"],
  "message": "Save this key securely. It will not be shown again."
}
```

### List API Keys

```
GET /api/auth/api-keys
```

**Response (200):**
```json
[
  {
    "id": "guid",
    "name": "string",
    "keyPrefix": "aw_XXXXXXXX",
    "isActive": true,
    "lastUsedAt": "datetime|null",
    "expiresAt": "datetime|null",
    "createdAt": "datetime"
  }
]
```

### Delete API Key

```
DELETE /api/auth/api-keys/{id}
```

**Response:** 204 No Content

### API Key Scopes

| Scope | Access |
|-------|--------|
| `read` | Read resources (tests, issues, dashboard, etc.) |
| `write` | Create and update resources |
| `delete` | Delete resources |
| `execute` | Run tests manually |
| `integrations` | Manage alert integrations |
| `team` | Manage team members |
| `billing` | Access billing information |

Scope requirements by controller:

| Controller | Required Scopes |
|-----------|----------------|
| Tests (GET) | `read` |
| Tests (POST/PUT) | `write` |
| Tests (DELETE) | `delete` |
| Tests (run) | `execute` |
| Heartbeat Monitors (GET) | `read` |
| Heartbeat Monitors (POST/PUT) | `write` |
| Heartbeat Monitors (DELETE) | `delete` |
| Integrations | `integrations` |
| Routing Rules | `write` |
| Regions | `read` |
| Issues, Dashboard, Escalation, On-Call, Maintenance, Settings | Any authenticated (no scope check) |

---

## Tests

### List Tests

```
GET /api/tests
```

**Query parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status: `Active`, `Paused`, `Disabled` |
| `testType` | string | Filter by type: `Http`, `McpServer`, `A2aAgent`, `GraphQl`, `Grpc`, `SslCertificate`, `DnsRecord` |
| `tag` | string | Filter by tag |
| `search` | string | Search by name or URL |
| `limit` | int | Page size (for pagination) |
| `offset` | int | Page offset |

**curl:**
```bash
curl https://api.pingward.com/api/tests \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):** `TestResponse[]` or `PaginatedListResponse<TestResponse>` (when limit/offset used)

### Get Test

```
GET /api/tests/{id}
```

**curl:**
```bash
curl https://api.pingward.com/api/tests/TEST_ID \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
{
  "id": "guid",
  "name": "string",
  "description": "string|null",
  "tags": [],
  "testType": "Http",
  "protocolConfig": {},
  "httpMethod": "GET",
  "url": "string",
  "hostHeader": "string|null",
  "headers": {},
  "body": "string|null",
  "bodyType": "string|null",
  "timeoutMs": 30000,
  "authType": "None",
  "assertions": [],
  "frequencyMinutes": 5,
  "timezone": "string|null",
  "activeHoursStart": "string|null",
  "activeHoursEnd": "string|null",
  "regions": ["*"],
  "status": "Active",
  "importance": "Production",
  "lastRunAt": "datetime|null",
  "lastRunSuccess": "bool|null",
  "sanitizationMode": "string",
  "incidentThresholdCount": 1,
  "recoveryThresholdCount": 1,
  "degradationConfig": {},
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Create Test

```
POST /api/tests
```

**Body (HTTP test):**
```json
{
  "name": "string (required)",
  "description": "string (optional, max 1000)",
  "tags": ["string"],
  "testType": "Http",
  "httpMethod": "GET",
  "url": "https://api.example.com/health",
  "headers": { "Accept": "application/json" },
  "body": "string (optional, for POST/PUT)",
  "bodyType": "string (optional)",
  "timeoutMs": 30000,
  "authType": "None",
  "assertions": [
    { "type": "StatusCode", "operator": "Equals", "value": "200" },
    { "type": "ResponseTime", "operator": "LessThan", "value": "3000" }
  ],
  "frequencyMinutes": 5,
  "regions": ["*"],
  "importance": "Production",
  "incidentThresholdCount": 1,
  "recoveryThresholdCount": 1
}
```

**curl (HTTP health check):**
```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
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

**curl (SSL certificate monitor):**
```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "API SSL Certificate",
    "testType": "SslCertificate",
    "url": "api.example.com",
    "frequencyMinutes": 1440,
    "regions": ["*"],
    "protocolConfig": "{\"hostname\": \"api.example.com\", \"warningDaysBeforeExpiry\": 30, \"criticalDaysBeforeExpiry\": 7}"
  }'
```

**curl (DNS record monitor):**
```bash
curl -X POST https://api.pingward.com/api/tests \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "API DNS Resolution",
    "testType": "DnsRecord",
    "url": "api.example.com",
    "frequencyMinutes": 60,
    "regions": ["*"],
    "protocolConfig": "{\"hostname\": \"api.example.com\", \"recordType\": \"A\"}"
  }'
```

**Response (201):** `TestResponse`

### Update Test

```
PUT /api/tests/{id}
```

**Body:** Same fields as Create, all optional.

**curl:**
```bash
curl -X PUT https://api.pingward.com/api/tests/TEST_ID \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{"frequencyMinutes": 1, "name": "Updated Name"}'
```

**Response (200):** `TestResponse`

### Delete Test

```
DELETE /api/tests/{id}
```

**Response:** 204 No Content

### Clone Test

```
POST /api/tests/{id}/clone
```

Creates a copy of the test with a "(Copy)" suffix in the name.

**Response (201):** `TestResponse`

### Run Test

```
POST /api/tests/{id}/run
```

Executes the test immediately and returns the result.

**curl:**
```bash
curl -X POST https://api.pingward.com/api/tests/TEST_ID/run \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):** `TestResultDetailResponse` (includes request/response details, assertion results)

### Pause Test

```
POST /api/tests/{id}/pause
```

**Response (200):** `{ "message": "Test paused" }`

### Resume Test

```
POST /api/tests/{id}/resume
```

**Response (200):** `{ "message": "Test resumed" }`

### Get Test Results

```
GET /api/tests/{id}/results
```

**Query parameters:**
| Parameter | Type | Default |
|-----------|------|---------|
| `limit` | int | 10 |
| `offset` | int | 0 |

**Response (200):**
```json
[
  {
    "id": "guid",
    "testId": "guid",
    "success": true,
    "statusCode": 200,
    "responseTimeMs": 142,
    "errorCategory": "string|null",
    "errorMessage": "string|null",
    "severity": "string|null",
    "region": "string|null",
    "executedAt": "datetime"
  }
]
```

### Get Test Baseline

```
GET /api/tests/{id}/baseline
```

Performance baselines (P50/P95/P99 response times, success rates) over 7-day and 30-day windows.

**Response (200):**
```json
{
  "testId": "guid",
  "baseline7d_P50": 120,
  "baseline7d_P95": 350,
  "baseline7d_P99": 800,
  "baseline7d_Mean": 165,
  "baseline30d_P50": 125,
  "baseline30d_P95": 380,
  "baseline30d_P99": 850,
  "baseline30d_Mean": 172,
  "successRate7d": 99.8,
  "successRate30d": 99.5,
  "lastCalculated": "datetime"
}
```

### Get Test Degradations

```
GET /api/tests/{id}/degradations
```

Active performance degradation events for this test.

**Response (200):**
```json
[
  {
    "id": "guid",
    "testId": "guid",
    "testName": "string",
    "type": "string",
    "severity": "string",
    "currentValue": 500,
    "expectedValue": 200,
    "deviationPercent": 150,
    "firstDetected": "datetime",
    "lastDetected": "datetime",
    "resolvedAt": "datetime|null",
    "alertSent": true
  }
]
```

---

## Heartbeat Monitors

### List Heartbeat Monitors

```
GET /api/heartbeat-monitors
```

**Query parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | `Waiting`, `Healthy`, `Overdue`, `Missing` |
| `search` | string | Search by name |
| `limit` | int | Page size |
| `offset` | int | Page offset |

**curl:**
```bash
curl https://api.pingward.com/api/heartbeat-monitors \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):** `HeartbeatMonitorResponse[]` or `PaginatedListResponse<HeartbeatMonitorResponse>`

### Get Heartbeat Monitor

```
GET /api/heartbeat-monitors/{id}
```

**Response (200):**
```json
{
  "id": "guid",
  "name": "string",
  "pingKey": "string",
  "pingUrl": "https://api.pingward.com/ping/PING_KEY",
  "status": "Waiting|Healthy|Overdue|Missing",
  "expectedIntervalMinutes": 5,
  "gracePeriodMinutes": 5,
  "lastPingAt": "datetime|null",
  "nextExpectedAt": "datetime|null",
  "isPaused": false,
  "tags": [],
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Create Heartbeat Monitor

```
POST /api/heartbeat-monitors
```

**Body:**
```json
{
  "name": "string (required, max 255)",
  "expectedIntervalMinutes": 5,
  "gracePeriodMinutes": 5,
  "tags": ["string"]
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/heartbeat-monitors \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "Nightly backup job",
    "expectedIntervalMinutes": 1440,
    "gracePeriodMinutes": 30
  }'
```

**Response (201):** `HeartbeatMonitorResponse` (includes `pingUrl` — add this to your cron job)

### Update Heartbeat Monitor

```
PUT /api/heartbeat-monitors/{id}
```

**Body:** Same fields as Create, all optional.

**Response (200):** `HeartbeatMonitorResponse`

### Delete Heartbeat Monitor

```
DELETE /api/heartbeat-monitors/{id}
```

**Response:** 204 No Content

### Pause Heartbeat Monitor

```
POST /api/heartbeat-monitors/{id}/pause
```

**Response (200):** `HeartbeatMonitorResponse`

### Resume Heartbeat Monitor

```
POST /api/heartbeat-monitors/{id}/resume
```

**Response (200):** `HeartbeatMonitorResponse`

### Get Heartbeat Pings

```
GET /api/heartbeat-monitors/{id}/pings
```

**Query parameters:** `limit` (default: 20), `offset`

**Response (200):**
```json
[
  {
    "id": "guid",
    "receivedAt": "datetime",
    "payload": "string|null",
    "sourceIp": "string|null",
    "userAgent": "string|null"
  }
]
```

### Get Heartbeat Events

```
GET /api/heartbeat-monitors/{id}/events
```

Status change history (e.g., Healthy → Overdue → Missing → Healthy).

**Query parameters:** `limit` (default: 20), `offset`

**Response (200):**
```json
[
  {
    "id": "guid",
    "eventType": "string",
    "fromStatus": "string|null",
    "toStatus": "string",
    "occurredAt": "datetime",
    "details": "string|null"
  }
]
```

### Send Heartbeat Ping (Public)

```
POST /ping/{pingKey}
GET /ping/{pingKey}
```

No authentication required. Rate limited.

**curl:**
```bash
curl -s https://api.pingward.com/ping/YOUR_PING_KEY
```

**Response (200):**
```json
{
  "status": "ok",
  "receivedAt": "datetime",
  "monitorName": "string"
}
```

---

## Issues

### List Issues

```
GET /api/issues
```

**Query parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | `Open`, `Acknowledged`, `Resolved`, `Pending` |

**curl:**
```bash
curl https://api.pingward.com/api/issues?status=Open \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):** `IssueResponse[]`

### Get Active Issues

```
GET /api/issues/active
```

Returns only open and acknowledged issues.

**Response (200):** `IssueResponse[]`

### Get Issue

```
GET /api/issues/{id}
```

**Response (200):**
```json
{
  "id": "guid",
  "testId": "guid|null",
  "testName": "string|null",
  "errorCategory": "string",
  "errorSignature": "string",
  "severity": "Critical|High|Medium|Low",
  "status": "Open|Acknowledged|Resolved|Pending",
  "firstSeenAt": "datetime",
  "lastSeenAt": "datetime",
  "resolvedAt": "datetime|null",
  "acknowledgedAt": "datetime|null",
  "acknowledgedBy": "string|null",
  "occurrenceCount": 5,
  "escalationPolicyId": "guid|null",
  "escalationPolicyName": "string|null",
  "currentEscalationLevel": 0,
  "nextEscalationAt": "datetime|null",
  "resolvedBy": "string|null",
  "rootCause": "string|null",
  "postMortemNotes": "string|null",
  "isManual": false,
  "title": "string|null",
  "description": "string|null",
  "activityLog": [],
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Get Issue Failed Results

```
GET /api/issues/{id}/failed-results
```

Returns the failing test execution details that triggered this issue.

**Query parameters:** `limit` (default: 10)

**Response (200):** `TestResultDetailResponse[]`

### Create Issue (Manual)

```
POST /api/issues
```

**Body:**
```json
{
  "title": "string (required, max 500)",
  "description": "string (optional, max 5000)",
  "severity": "Critical|High|Medium|Low (required)",
  "escalationPolicyId": "guid (optional)"
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/issues \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "title": "Deployment issue - elevated error rate",
    "severity": "High"
  }'
```

**Response (201):** `IssueResponse`

### Acknowledge Issue

```
POST /api/issues/{id}/acknowledge
```

Pauses escalation for this issue.

**Body (optional):**
```json
{
  "acknowledgedBy": "string",
  "note": "string"
}
```

**Response (200):** `IssueResponse`

### Resolve Issue

```
POST /api/issues/{id}/resolve
```

**Body (optional):**
```json
{
  "rootCause": "string (max 2000)",
  "postMortemNotes": "string (max 10000)",
  "message": "string"
}
```

**Response (200):** `IssueResponse`

### Add Note to Issue

```
POST /api/issues/{id}/notes
```

**Body:**
```json
{
  "user": "string (required)",
  "message": "string (required)"
}
```

**Response (200):** `IssueResponse`

---

## Integrations

**Required scope:** `integrations`

### List Integrations

```
GET /api/integrations
```

**curl:**
```bash
curl https://api.pingward.com/api/integrations \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
[
  {
    "id": "guid",
    "type": "Email|Slack|Sms|Webhook",
    "name": "string",
    "isActive": true,
    "lastUsedAt": "datetime|null",
    "lastError": "string|null",
    "createdAt": "datetime",
    "updatedAt": "datetime"
  }
]
```

### Get Integration

```
GET /api/integrations/{id}
```

Returns full integration details including config (sensitive fields masked).

**Response (200):** `IntegrationDetailResponse` (extends `IntegrationResponse` with `config` field)

### Create Integration

```
POST /api/integrations
```

**Body:**
```json
{
  "type": "Email|Slack|Sms|Webhook (required)",
  "name": "string (required, max 255)",
  "config": { ... }
}
```

Config depends on integration type:

**Email (platform-managed):**
```json
{
  "type": "Email",
  "name": "Team Email Alerts",
  "config": {
    "defaultRecipients": ["team@example.com", "oncall@example.com"]
  }
}
```

**Slack (webhook):**
```json
{
  "type": "Slack",
  "name": "Engineering Slack",
  "config": {
    "webhookUrl": "https://hooks.slack.com/services/...",
    "channel": "#alerts"
  }
}
```

**SMS:**
```json
{
  "type": "Sms",
  "name": "On-Call SMS",
  "config": {
    "toNumbers": ["+15551234567"]
  }
}
```

**Webhook:**
```json
{
  "type": "Webhook",
  "name": "PagerDuty Webhook",
  "config": {
    "url": "https://events.pagerduty.com/integration/...",
    "secretKey": "optional-hmac-signing-key",
    "httpMethod": "POST"
  }
}
```

**curl (email integration):**
```bash
curl -X POST https://api.pingward.com/api/integrations \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "type": "Email",
    "name": "Team Email Alerts",
    "config": {"defaultRecipients": ["team@example.com"]}
  }'
```

**Response (201):** `IntegrationResponse`

### Update Integration

```
PUT /api/integrations/{id}
```

**Body:** `name`, `isActive`, `config` — all optional.

**Response (200):** `IntegrationResponse`

### Delete Integration

```
DELETE /api/integrations/{id}
```

**Response:** 204 No Content

### Test Integration

```
POST /api/integrations/{id}/test
```

Sends a test notification to verify the integration works.

**curl:**
```bash
curl -X POST https://api.pingward.com/api/integrations/INTEGRATION_ID/test \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
{
  "success": true,
  "error": "string|null"
}
```

---

## Routing Rules

**Required scope:** `write`

### List Routing Rules

```
GET /api/routing-rules
```

**curl:**
```bash
curl https://api.pingward.com/api/routing-rules \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
[
  {
    "id": "guid",
    "name": "string",
    "isActive": true,
    "priority": 0,
    "conditions": { "severities": [], "errorCategories": [], "testIds": [], "tags": [] },
    "actions": [
      { "integrationId": "guid", "integrationName": "string", "integrationType": "string" }
    ],
    "hasDeletedIntegrations": false,
    "escalationPolicyId": "guid|null",
    "escalationPolicyName": "string|null",
    "createdAt": "datetime",
    "updatedAt": "datetime"
  }
]
```

### Get Routing Rule

```
GET /api/routing-rules/{id}
```

**Response (200):** `RoutingRuleResponse`

### Create Routing Rule

```
POST /api/routing-rules
```

**Body:**
```json
{
  "name": "string (required)",
  "priority": 0,
  "conditions": {
    "severities": ["Critical", "High"],
    "errorCategories": ["ServiceUnavailable", "ConnectionError"],
    "testIds": ["guid"],
    "tags": ["production"]
  },
  "actions": [
    { "integrationId": "INTEGRATION_GUID" }
  ],
  "escalationPolicyId": "guid (optional)"
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/routing-rules \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "Critical alerts to email",
    "priority": 0,
    "conditions": {"severities": ["Critical", "High"]},
    "actions": [{"integrationId": "INTEGRATION_ID"}],
    "escalationPolicyId": "POLICY_ID"
  }'
```

**Response (201):** `RoutingRuleResponse`

### Update Routing Rule

```
PUT /api/routing-rules/{id}
```

**Body:** Same fields as Create, all optional.

**Response (200):** `RoutingRuleResponse`

### Delete Routing Rule

```
DELETE /api/routing-rules/{id}
```

**Response:** 204 No Content

### Update Routing Rule Priority

```
PATCH /api/routing-rules/{id}/priority
```

**Body:**
```json
{
  "priority": 1
}
```

**Response (200):** `RoutingRuleResponse`

### Toggle Routing Rule

```
POST /api/routing-rules/{id}/toggle
```

Enables or disables the routing rule.

**Response (200):** `RoutingRuleResponse`

---

## Escalation Policies

### List Escalation Policies

```
GET /api/escalation-policies
```

**curl:**
```bash
curl https://api.pingward.com/api/escalation-policies \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
[
  {
    "id": "guid",
    "name": "string",
    "description": "string|null",
    "isActive": true,
    "tiers": [
      {
        "level": 0,
        "timeoutMinutes": 15,
        "targets": [
          { "type": "integration", "id": "guid" }
        ]
      }
    ],
    "repeatBehavior": "Stop|RepeatLast|RepeatAll",
    "createdAt": "datetime",
    "updatedAt": "datetime"
  }
]
```

### Get Escalation Policy

```
GET /api/escalation-policies/{id}
```

**Response (200):** `EscalationPolicyResponse`

### Create Escalation Policy

```
POST /api/escalation-policies
```

**Body:**
```json
{
  "name": "string (required, max 255)",
  "description": "string (optional, max 1000)",
  "tiers": [
    {
      "level": 0,
      "timeoutMinutes": 15,
      "targets": [{ "type": "integration", "id": "INTEGRATION_GUID" }]
    },
    {
      "level": 1,
      "timeoutMinutes": 30,
      "targets": [
        { "type": "integration", "id": "EMAIL_INTEGRATION_GUID" },
        { "type": "integration", "id": "SLACK_INTEGRATION_GUID" }
      ]
    }
  ],
  "repeatBehavior": "RepeatLast"
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/escalation-policies \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "Infrastructure Escalation",
    "tiers": [
      {"level": 0, "timeoutMinutes": 15, "targets": [{"type": "integration", "id": "EMAIL_ID"}]},
      {"level": 1, "timeoutMinutes": 30, "targets": [{"type": "integration", "id": "EMAIL_ID"}, {"type": "integration", "id": "SLACK_ID"}]}
    ],
    "repeatBehavior": "RepeatLast"
  }'
```

**Response (201):** `EscalationPolicyResponse`

### Update Escalation Policy

```
PUT /api/escalation-policies/{id}
```

**Body:** `name`, `description`, `isActive`, `tiers`, `repeatBehavior` — all optional.

**Response (200):** `EscalationPolicyResponse`

### Delete Escalation Policy

```
DELETE /api/escalation-policies/{id}
```

**Response:** 204 No Content

---

## On-Call Schedules

### List On-Call Schedules

```
GET /api/on-call-schedules
```

**Response (200):**
```json
[
  {
    "id": "guid",
    "name": "string",
    "description": "string|null",
    "timezone": "UTC",
    "rotationConfig": {},
    "currentOnCallUserId": "guid|null",
    "createdAt": "datetime",
    "updatedAt": "datetime"
  }
]
```

### Get On-Call Schedule

```
GET /api/on-call-schedules/{id}
```

Returns full details with overrides.

**Response (200):** `OnCallScheduleDetailResponse` (includes `overrides[]`)

### Get Current On-Call

```
GET /api/on-call-schedules/{id}/current
```

**Response (200):**
```json
{
  "userId": "guid|null",
  "scheduleId": "guid",
  "timestamp": "datetime"
}
```

### Get On-Call Timeline

```
GET /api/on-call-schedules/{id}/timeline
```

**Query parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `from` | datetime | Start of range (ISO 8601) |
| `to` | datetime | End of range (ISO 8601) |

**Response (200):**
```json
[
  {
    "userId": "guid",
    "startTime": "datetime",
    "endTime": "datetime",
    "isOverride": false
  }
]
```

### Create On-Call Schedule

```
POST /api/on-call-schedules
```

**Body:**
```json
{
  "name": "string (required, max 255)",
  "description": "string (optional, max 1000)",
  "timezone": "America/New_York",
  "rotationConfig": {
    "type": "weekly",
    "handoffTime": "09:00",
    "handoffDay": "Monday",
    "participants": [
      { "userId": "guid", "name": "Jane Smith" }
    ]
  }
}
```

**Response (201):** `OnCallScheduleResponse`

### Update On-Call Schedule

```
PUT /api/on-call-schedules/{id}
```

**Body:** `name`, `description`, `timezone`, `rotationConfig` — all optional.

**Response (200):** `OnCallScheduleResponse`

### Delete On-Call Schedule

```
DELETE /api/on-call-schedules/{id}
```

Deletes the schedule and all its overrides.

**Response:** 204 No Content

### Create On-Call Override

```
POST /api/on-call-schedules/{id}/overrides
```

**Body:**
```json
{
  "overrideUserId": "guid (required)",
  "originalUserId": "guid (optional)",
  "startTime": "2025-03-15T09:00:00Z (required)",
  "endTime": "2025-03-16T09:00:00Z (required)",
  "reason": "string (optional, max 500)"
}
```

**Response (201):** `OnCallOverrideResponse`

### Delete On-Call Override

```
DELETE /api/on-call-schedules/{scheduleId}/overrides/{overrideId}
```

**Response:** 204 No Content

---

## Maintenance Windows

### List Maintenance Windows

```
GET /api/maintenance-windows
```

**curl:**
```bash
curl https://api.pingward.com/api/maintenance-windows \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):** `MaintenanceWindowListResponse` (contains `windows[]`)

### Get Maintenance Window

```
GET /api/maintenance-windows/{id}
```

**Response (200):** `MaintenanceWindowDto`

### Create Maintenance Window

```
POST /api/maintenance-windows
```

**Body:**
```json
{
  "name": "string (required)",
  "description": "string (optional)",
  "startTime": "2025-03-15T02:00:00Z (required)",
  "endTime": "2025-03-15T04:00:00Z (required)",
  "recurrenceType": "OneTime|Daily|Weekly",
  "behavior": "SuppressIssues|PauseExecution",
  "scope": "AllTests|SpecificTests|TaggedTests",
  "scopeConfig": {}
}
```

**curl:**
```bash
curl -X POST https://api.pingward.com/api/maintenance-windows \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_API_KEY" \
  -d '{
    "name": "Weekly deploy window",
    "startTime": "2025-03-15T02:00:00Z",
    "endTime": "2025-03-15T04:00:00Z",
    "behavior": "SuppressIssues",
    "scope": "AllTests",
    "recurrenceType": "Weekly"
  }'
```

**Response (201):** `MaintenanceWindowDto`

### Update Maintenance Window

```
PUT /api/maintenance-windows/{id}
```

**Body:** Same fields as Create, all optional.

**Response (200):** `MaintenanceWindowDto`

### Delete Maintenance Window

```
DELETE /api/maintenance-windows/{id}
```

**Response:** 204 No Content

---

## Dashboard

### Get Dashboard Summary

```
GET /api/dashboard/summary
```

System overview: monitor counts, active issues, incidents, on-call status, maintenance windows.

**curl:**
```bash
curl https://api.pingward.com/api/dashboard/summary \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
{
  "totalMonitors": 15,
  "passingMonitors": 13,
  "failingMonitors": 1,
  "pausedMonitors": 1,
  "overallAvailability": 99.5,
  "availabilityNines": "2N",
  "apiMonitors": { "total": 10, "passing": 9, "failing": 1, "paused": 0 },
  "heartbeats": { "total": 3, "healthy": 2, "overdue": 1, "missing": 0, "paused": 0 },
  "sslCertificates": 1,
  "dnsRecords": 1,
  "openIssues": 2,
  "acknowledgedIssues": 1,
  "activeIssues": [
    { "id": "guid", "testName": "string", "errorCategory": "string", "severity": "High", "durationMinutes": 45 }
  ],
  "activeIncidentCount": 0,
  "activeIncidents": [],
  "onCallStatus": [
    { "scheduleId": "guid", "scheduleName": "string", "onCallUserName": "string" }
  ],
  "activeMaintenanceWindows": []
}
```

### Get Availability

```
GET /api/dashboard/availability
```

**Query parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `testId` | guid | Yes | Test to check |
| `days` | int | No | Period (default: 30) |

**Response (200):**
```json
{
  "testId": "guid",
  "testName": "string",
  "periodDays": 30,
  "totalChecks": 8640,
  "successfulChecks": 8620,
  "failedChecks": 20,
  "availabilityPercent": 99.77,
  "nines": "2N",
  "estimatedDowntimeMinutes": 100
}
```

### Get Performance Dashboard

```
GET /api/dashboard/performance
```

Performance baselines and active degradation events across all tests.

**Response (200):**
```json
{
  "baselines": [],
  "activeDegradations": [],
  "overallStats": {
    "totalTests": 10,
    "testsWithBaselines": 8,
    "activeDegradations": 1,
    "averageSuccessRate7d": 99.5,
    "averageP95_7d": 350
  }
}
```

---

## Settings

### Get Severity Config

```
GET /api/settings/severity
```

Returns the error-category-to-severity mapping.

**Response (200):**
```json
{
  "categoryMappings": {
    "ServiceUnavailable": "Critical",
    "ConnectionError": "High",
    "SlowResponse": "Medium",
    "UnexpectedContent": "Low"
  }
}
```

### Update Severity Config

```
PUT /api/settings/severity
```

**Body:**
```json
{
  "categoryMappings": {
    "ServiceUnavailable": "Critical",
    "ConnectionError": "Critical",
    "SlowResponse": "High"
  }
}
```

**Response (200):** `SeverityConfigResponse`

### Reset Severity Config

```
POST /api/settings/severity/reset
```

Resets to default mappings.

**Response (200):** `SeverityConfigResponse`

### Get Error Categories

```
GET /api/settings/severity/categories
```

Lists all available error categories and their default severities.

**Response (200):**
```json
[
  {
    "name": "ServiceUnavailable",
    "defaultSeverity": "Critical",
    "description": "string",
    "category": "string|null"
  }
]
```

### Get Importance Levels

```
GET /api/settings/severity/importance-levels
```

Lists importance levels and their maximum severity caps.

**Response (200):**
```json
[
  {
    "name": "Production",
    "maxSeverity": "Critical",
    "description": "string"
  }
]
```

---

## Regions

### List Regions

```
GET /api/regions
```

**curl:**
```bash
curl https://api.pingward.com/api/regions \
  -H "X-Api-Key: YOUR_API_KEY"
```

**Response (200):**
```json
{
  "regions": [
    {
      "code": "eastus",
      "label": "East US",
      "location": "Virginia, USA",
      "onlineWorkerCount": 1,
      "totalWorkerCount": 1,
      "isAvailable": true,
      "activeTestCount": 15
    }
  ],
  "allRegionsSupported": true,
  "recommendedRegion": "eastus"
}
```

---

## Billing

### Get Available Plans (Public)

```
GET /api/billing/plans
```

**Response (200):**
```json
[
  {
    "id": "free|starter|pro|enterprise",
    "name": "string",
    "monthlyPrice": 0,
    "annualPrice": 0,
    "isPopular": false,
    "features": ["10 monitors", "50,000 checks/month"],
    "limits": {
      "maxTestSlots": 10,
      "maxExecutionsPerMonth": 50000,
      "maxTeamMembers": 3,
      "minIntervalMinutes": 5,
      "smsCreditsPerMonth": 0,
      "dataRetentionDays": 7,
      "allowStatusPages": false,
      "allowSso": false
    }
  }
]
```

### Get Usage Summary

```
GET /api/billing/usage
```

Returns current billing period usage.

### Create Checkout Session

```
POST /api/billing/checkout
```

**Body:**
```json
{
  "plan": "starter|pro|enterprise",
  "successUrl": "https://pingward.com/settings?tab=billing&success=true",
  "cancelUrl": "https://pingward.com/settings?tab=billing"
}
```

**Response (200):**
```json
{
  "url": "https://checkout.stripe.com/..."
}
```

---

## Feedback

### Submit Feedback

```
POST /api/feedback
```

**Body:**
```json
{
  "category": "Bug|FeatureRequest|General",
  "description": "string (required, max 5000 chars)"
}
```

**Response (200):**
```json
{
  "id": "guid",
  "category": "string",
  "description": "string",
  "createdAt": "datetime"
}
```

---

## Rate Limits

| Endpoint Group | Limit |
|----------------|-------|
| Global | 100 requests/min per IP |
| Auth (`/api/auth/register`, `/api/auth/login`) | 10 requests/min per IP |
| API (with API key) | 300 requests/min per tenant |
| Public endpoints | 30 requests/min per IP |

Rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "error": "Human-readable error message"
}
```

Common HTTP status codes:
| Code | Meaning |
|------|---------|
| 400 | Bad request (validation error) |
| 401 | Unauthorized (missing/invalid auth) |
| 403 | Forbidden (insufficient scope or role) |
| 404 | Resource not found |
| 409 | Conflict (duplicate, race condition) |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
