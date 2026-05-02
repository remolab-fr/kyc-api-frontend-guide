# Read-Only Dashboard

## Use This When

Use this workflow when the first product goal is to show API status, user access,
latest evidence, or report information without editing a case.

## What You Will Build

You will build a dashboard that proves the API is reachable, the user can
authenticate, and read-only KYC information can be displayed safely.

## What Must Already Be True

- [Environment Configuration](../foundations/environment-config.md) is in place.
- [API Client](../foundations/api-client.md) is implemented.
- The app has a route or panel for diagnostics and read-only data.

## API Contract

Typical endpoints:

```text
GET /healthz
GET /readyz
GET /api/v1/kyc/search
GET /api/v1/kyc-cases/{case_id}
GET /api/v1/kyc-cases/{case_id}/reports/latest?view={view}
GET /api/v1/workflow/events?after_id={after_id}&limit={limit}
```

Choose only the endpoints needed for the dashboard.

## UI States

| Area | Required states |
|---|---|
| Diagnostics | Reachable, not reachable, ready, degraded. |
| Auth | Signed out, signed in, unauthorized. |
| Evidence | Empty, loading, success, partial evidence, error. |
| Report | No report, loading, snapshot available, restricted view. |
| Timeline | No events, polling, warning, error. |

## Implementation Steps

1. Add [Diagnostics](../foundations/diagnostics.md).
2. Add [Error States](../foundations/error-states.md).
3. Add [Quick Screening](../tasks/quick-screening.md) if dashboard users need
   lightweight evidence lookup.
4. Add [Report Snapshots](../tasks/report-snapshots.md) when the dashboard
   displays generated summaries.
5. Add [Workflow Events](../tasks/workflow-events.md) when active work is
   visible.

## Checkpoint

- A user can tell whether the API, readiness, and auth are working.
- Read-only views do not expose restricted compliance fields to customer-facing
  audiences.
- Support details preserve API request metadata when failures occur.

## Common Mistakes

- Starting with reports before diagnostics works.
- Rendering compliance report data in a general support dashboard.
- Polling workflow events after the dashboard is no longer visible.
- Treating read-only UI as permission enforcement.

## Related Pages

- [Diagnostics](../foundations/diagnostics.md)
- [Quick Screening](../tasks/quick-screening.md)
- [Report Snapshots](../tasks/report-snapshots.md)
- [Workflow Events](../tasks/workflow-events.md)
