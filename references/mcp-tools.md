# Pingward MCP Tools Reference

MCP endpoint: `https://mcp.pingward.com/mcp`
Authentication: `X-Api-Key` header with your Pingward API key.

Total: 56 tools, 4 prompts.

---

## Test Monitoring (13 tools)

### list_tests
List monitoring tests with optional filtering.
- `status` (string, optional): Active, Paused, Disabled
- `testType` (string, optional): Http, McpServer, A2aAgent, GraphQl, Grpc, SslCertificate, DnsRecord
- `tag` (string, optional): Filter by tag
- `search` (string, optional): Search by name or URL

### create_http_test
Create an HTTP monitoring test.
- `name` (string, required): Test name
- `url` (string, required): URL to monitor
- `httpMethod` (string, optional): GET, POST, PUT, DELETE, PATCH, HEAD (default: GET)
- `frequencyMinutes` (int, optional): 1-1440 (default: 5)
- `expectedStatusCode` (int, optional): Expected status code (e.g. 200)
- `maxResponseTimeMs` (int, optional): Max acceptable response time
- `tags` (string, optional): Comma-separated tags
- `importance` (string, optional): Production, Staging, Development (default: Production)
- `regions` (string, optional): Comma-separated regions or '*' for all (default: '*')

### create_ssl_test
Create an SSL certificate expiry monitor.
- `name` (string, required): Monitor name
- `hostname` (string, required): Hostname to check
- `port` (int, optional): Port (default: 443)
- `warningDays` (int, optional): Warn N days before expiry (default: 30)
- `frequencyMinutes` (int, optional): Check frequency (default: 1440)
- `regions` (string, optional): Regions or '*' (default: '*')

### create_dns_test
Create a DNS record monitor.
- `name` (string, required): Monitor name
- `hostname` (string, required): Hostname to check
- `recordType` (string, optional): A, AAAA, CNAME, MX, TXT, NS (default: A)
- `expectedValue` (string, optional): Expected value
- `frequencyMinutes` (int, optional): Check frequency (default: 60)
- `regions` (string, optional): Regions or '*' (default: '*')

### update_test
Update a test's configuration.
- `testId` (string, required): Test ID (GUID)
- `name`, `url`, `frequencyMinutes`, `importance`, `tags` (all optional)

### delete_test
Delete a test permanently.
- `testId` (string, required): Test ID (GUID)

### run_test
Execute a test immediately and return results.
- `testId` (string, required): Test ID (GUID)

### pause_test / resume_test
Pause or resume a test.
- `testId` (string, required): Test ID (GUID)

### get_test_results
Get recent execution results.
- `testId` (string, required): Test ID (GUID)
- `limit` (int, optional): 1-100 (default: 10)

### get_test_baseline
Get performance baselines (P50/P95/P99 response times, success rates).
- `testId` (string, required): Test ID (GUID)

### get_test_degradations
Get active performance degradation events.
- `testId` (string, required): Test ID (GUID)

### get_test_availability
Get uptime availability over N days.
- `testId` (string, required): Test ID (GUID)
- `days` (int, optional): Number of days (default: 30)

---

## Heartbeat Monitors (8 tools)

### list_heartbeat_monitors
List all heartbeat monitors.
- `status` (string, optional): Waiting, Healthy, Overdue, Missing

### create_heartbeat_monitor
Create a heartbeat (dead-man-switch) monitor. Returns a ping URL.
- `name` (string, required): Monitor name
- `expectedIntervalMinutes` (int, optional): 1-1440 (default: 5)
- `gracePeriodMinutes` (int, optional): 0-60 (default: 5)
- `tags` (string, optional): Tags

### update_heartbeat_monitor
Update a heartbeat monitor.
- `monitorId` (string, required): Monitor ID (GUID)
- `name`, `expectedIntervalMinutes`, `gracePeriodMinutes`, `tags` (all optional)

### delete_heartbeat_monitor
Delete a heartbeat monitor.
- `monitorId` (string, required): Monitor ID (GUID)

### pause_heartbeat_monitor / resume_heartbeat_monitor
Pause or resume alerting.
- `monitorId` (string, required): Monitor ID (GUID)

### get_heartbeat_pings
Get recent pings received.
- `monitorId` (string, required): Monitor ID (GUID)
- `limit` (int, optional): 1-100 (default: 20)

### get_heartbeat_events
Get status change history.
- `monitorId` (string, required): Monitor ID (GUID)
- `limit` (int, optional): 1-100 (default: 20)

---

## Issues (6 tools)

### list_issues
List issues with optional filtering.
- `status` (string, optional): Open, Acknowledged, Resolved, Pending
- `limit` (int, optional): 1-50 (default: 50)

### get_issue
Get full issue details.
- `issueId` (string, required): Issue ID (GUID)

### get_issue_failed_results
Get failed test results that triggered this issue.
- `issueId` (string, required): Issue ID (GUID)
- `limit` (int, optional): 1-50 (default: 10)

### acknowledge_issue
Acknowledge an issue (pauses escalation).
- `issueId` (string, required): Issue ID (GUID)
- `note` (string, optional): Note for activity log

### resolve_issue
Resolve an issue.
- `issueId` (string, required): Issue ID (GUID)
- `rootCause` (string, optional): Root cause description
- `postMortemNotes` (string, optional): Postmortem notes

### add_issue_note
Add a note to an issue's activity log.
- `issueId` (string, required): Issue ID (GUID)
- `note` (string, required): Note text

---

## Integrations (4 tools)

### list_integrations
List all alert integrations.

### create_integration
Create an integration. Config depends on type:
- Email: `{"smtpHost", "smtpPort", "fromAddress", "toAddresses"}`
- Slack: `{"webhookUrl", "channel"}`
- SMS: `{"toNumbers"}`
- Webhook: `{"url", "secretKey"}`

Parameters:
- `name` (string, required)
- `type` (string, required): Email, Slack, Sms, Webhook
- `config` (string, required): JSON config

### delete_integration
Delete an integration.
- `integrationId` (string, required): Integration ID (GUID)

### test_integration
Send a test notification.
- `integrationId` (string, required): Integration ID (GUID)

---

## Routing Rules (5 tools)

### list_routing_rules
List all notification routing rules.

### create_routing_rule
Create a routing rule.
- `name` (string, required)
- `conditions` (string, required): JSON `{"severities": [], "errorCategories": [], "testIds": [], "tags": []}`
- `actions` (string, required): JSON array `[{"integrationId": "guid"}]`
- `priority` (int, optional): Lower = higher priority (default: 0)
- `escalationPolicyId` (string, optional): Escalation policy to trigger
- `renotifyAfterMinutes` (int, optional)
- `escalationAfterMinutes` (int, optional)
- `autoAcknowledgeAfterHours` (int, optional)

### update_routing_rule
Update a routing rule. Same optional params as create.
- `ruleId` (string, required)

### delete_routing_rule
Delete a routing rule.
- `ruleId` (string, required)

### toggle_routing_rule
Enable or disable a rule.
- `ruleId` (string, required)
- `enabled` (bool, required)

---

## Escalation Policies (4 tools)

### list_escalation_policies
List all escalation policies.

### create_escalation_policy
Create a policy with tiers.
- `name` (string, required)
- `tiers` (string, required): JSON `[{"level": 0, "timeoutMinutes": 15, "targets": [{"type": "integration", "id": "guid"}]}]`
- `repeatBehavior` (string, optional): Stop, RepeatLast, RepeatAll (default: Stop)
- `description` (string, optional)

### update_escalation_policy
Update a policy.
- `policyId` (string, required)
- `name`, `description`, `tiers`, `repeatBehavior` (all optional)

### delete_escalation_policy
Delete a policy.
- `policyId` (string, required)

---

## On-Call Schedules (7 tools)

### list_on_call_schedules
List all on-call schedules.

### get_on_call_schedule
Get schedule details with overrides and rotation config.
- `scheduleId` (string, required)

### create_on_call_schedule
Create an on-call schedule.
- `name` (string, required)
- `rotationConfig` (string, required): JSON `{"type": "weekly", "handoffTime": "09:00", "handoffDay": "Monday", "participants": [{"userId": "...", "name": "..."}]}`
- `timezone` (string, optional): e.g. 'America/New_York' (default: UTC)
- `description` (string, optional)

### update_on_call_schedule
Update a schedule.
- `scheduleId` (string, required)
- `name`, `timezone`, `description`, `rotationConfig` (all optional)

### delete_on_call_schedule
Delete a schedule and all overrides.
- `scheduleId` (string, required)

### create_on_call_override
Create a temporary override.
- `scheduleId` (string, required)
- `overrideUserId` (string, required): User taking over
- `startTime` (string, required): ISO 8601
- `endTime` (string, required): ISO 8601
- `originalUserId` (string, optional)
- `reason` (string, optional)

### delete_on_call_override
Remove an override.
- `overrideId` (string, required)

---

## Maintenance Windows (4 tools)

### list_maintenance_windows
List all maintenance windows.

### create_maintenance_window
Create a maintenance window.
- `name` (string, required)
- `startTime` (string, required): ISO 8601
- `endTime` (string, required): ISO 8601
- `behavior` (string, optional): SuppressIssues, PauseExecution (default: SuppressIssues)
- `scope` (string, optional): AllTests, SpecificTests, TaggedTests (default: AllTests)
- `scopeConfig` (string, optional): JSON array of test IDs or tags
- `recurrenceType` (string, optional): OneTime, Daily, Weekly (default: OneTime)
- `description` (string, optional)

### update_maintenance_window
Update a window.
- `windowId` (string, required)
- All creation params optional

### delete_maintenance_window
Delete a window.
- `windowId` (string, required)

---

## Dashboard (2 tools)

### get_dashboard_summary
System overview: monitor counts, active issues, maintenance windows.

### get_performance_dashboard
Performance baselines and active degradation events.

---

## Settings (3 tools)

### get_severity_config
Get error-category-to-severity mappings.

### update_severity_config
Update mappings.
- `mappings` (string, required): JSON `{"ServiceUnavailable": "Critical", "SlowResponse": "High"}`

### reset_severity_config
Reset to defaults.

---

## Regions (1 tool)

### list_regions
List available monitoring regions and their status.

---

## Feedback (2 tools)

### submit_feedback
Submit feedback to the Pingward team.
- `category` (string, required): Bug, FeatureRequest, General
- `description` (string, required): Feedback details

### submit_feature_request
Submit a feature request (convenience wrapper).
- `title` (string, required): Feature title
- `description` (string, required): Feature description
- `useCase` (string, required): Why this feature would be useful

---

## Prompts (4)

### create_monitoring_for_api
Generate a monitoring plan for an API.
- `baseUrl` (string, required): API base URL
- `apiDescription` (string, optional): Description of the API

### audit_monitoring
Audit monitoring config and suggest improvements.

### setup_alerting_pipeline
Guide to set up integrations, escalation, and routing.
- `integrationTypes` (string, optional): e.g. 'Slack,Email'

### investigate_issue
Step-by-step issue investigation guide.
- `issueId` (string, required): Issue ID
