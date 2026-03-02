# Pingward REST API Reference

Base URL: `https://api.pingward.com`

All authenticated endpoints require either:
- `Authorization: Bearer <JWT_TOKEN>` (from login/register)
- `X-Api-Key: <API_KEY>` (for programmatic access)

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
Authorization: Bearer <token>
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
Authorization: Bearer <token>
```

**Body:**
```json
{
  "name": "string (required)",
  "scopes": ["read", "write"]
}
```

**Response (200):**
```json
{
  "key": "aw_XXXXXXXX_XXXXXXXX (shown only once)",
  "name": "string",
  "scopes": ["read", "write"],
  "message": "Save this key securely. It will not be shown again."
}
```

### List API Keys

```
GET /api/auth/api-keys
Authorization: Bearer <token>
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
Authorization: Bearer <token>
```

**Response:** 204 No Content

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
    "features": ["10 monitors", "50,000 checks/month", ...],
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
Authorization: Bearer <token>
```

### Create Checkout Session

```
POST /api/billing/checkout
Authorization: Bearer <token>
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
Authorization: Bearer <token>
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
