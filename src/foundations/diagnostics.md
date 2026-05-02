# Diagnostics

## Use This When

Use this page before building product screens or when an integration fails in a
new environment.

## What You Will Build

You will build a diagnostics screen that separates API reachability, readiness,
and authentication problems.

## What Must Already Be True

- Public API base URL is configured.
- The shared [API Client](api-client.md) exists.
- The application can tell whether a user is signed in.

## API Contract

Public operational endpoints:

```text
GET /healthz
GET /readyz
```

Suggested response types:

```ts
export type HealthResponse = {
  status: string;
};

export type ReadinessResponse = {
  status: string;
  checks?: Record<string, unknown>;
};
```

Load public diagnostics:

```ts
export async function loadApiDiagnostics(client: KycApiClient) {
  const [health, readiness] = await Promise.all([
    client.get<HealthResponse>("/healthz"),
    client.get<ReadinessResponse>("/readyz")
  ]);

  return { health, readiness };
}
```

After sign-in, verify one protected endpoint that matches the product you are
building.

## UI States

| State | Meaning | User action |
|---|---|---|
| Reachable | Browser can call public API endpoints. | Continue setup. |
| Not reachable | Network, base URL, CORS, or DNS may be wrong. | Check API base URL and frontend origin. |
| Ready | API reports it can handle work. | Continue product flow. |
| Degraded | API is reachable but not fully ready. | Show diagnostics and retry later. |
| Authenticated | User token is present and accepted. | Enable protected flows. |
| Unauthorized | Token is missing, expired, or invalid. | Sign in again. |

## Implementation Steps

1. Add a diagnostics route or admin-only panel.
2. Call `/healthz` and `/readyz` without requiring sign-in.
3. Show configuration, reachability, readiness, and auth as separate rows.
4. After sign-in, call one protected endpoint and show whether the token works.
5. Include `request_id` when a protected diagnostic request fails.

## Checkpoint

- A developer can diagnose base URL, readiness, and auth problems without
  opening browser devtools.
- The diagnostics page does not expose private credentials or regulated data.

## Common Mistakes

- Hiding diagnostics behind the same auth problem being diagnosed.
- Calling only protected endpoints and missing CORS or readiness failures.
- Showing raw tokens in debug output.
- Treating degraded readiness as a user input error.

## Related Pages

- [Environment Configuration](environment-config.md)
- [Error States](error-states.md)
- [Read-Only Dashboard](../workflows/read-only-dashboard.md)
