# Report Snapshots

## Use This When

Use this page when the frontend needs generated reports for customers,
partners, providers, or internal reviewers.

## What You Will Build

You will generate and read report snapshots with the correct view for the
audience.

## What Must Already Be True

- A durable case exists.
- The user is authorized for the requested report view.
- Customer-facing and internal routes are separated.

## API Contract

Generate:

```text
POST /api/v1/kyc-cases/{case_id}/reports/end-user-v1
```

Read latest:

```text
GET /api/v1/kyc-cases/{case_id}/reports/latest?view={view}
```

Allowed views:

```text
user_safe
provider_export
compliance
```

TypeScript helpers:

```ts
export type ReportView = "compliance" | "provider_export" | "user_safe";

export async function generateEndUserReport(
  client: KycApiClient,
  caseId: string,
  view: ReportView
) {
  return client.post<{
    principal: string;
    cache_status: "HIT" | "MISS";
    report_snapshot_id: string;
    generated_at: string;
    input_fingerprint: string;
    snapshot_hash: string;
    view_type: "COMPLIANCE" | "PROVIDER_EXPORT" | "USER_SAFE";
    report: unknown;
  }>(`/api/v1/kyc-cases/${encodeURIComponent(caseId)}/reports/end-user-v1`, {
    view,
    generated_by: "frontend-webapp"
  });
}

export async function loadLatestReport(
  client: KycApiClient,
  caseId: string,
  view: ReportView
) {
  return client.get(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/reports/latest?view=${encodeURIComponent(view)}`
  );
}
```

## UI States

| View | Use it for |
|---|---|
| `user_safe` | Customer portals and support experiences. |
| `provider_export` | Partner or regulated-provider handoff. |
| `compliance` | Authorized internal review workspaces. |

Show snapshot metadata in operator-facing screens:

- `cache_status`
- `report_snapshot_id`
- `snapshot_hash`
- `generated_at`
- `view_type`

## Implementation Steps

1. Choose report view based on route and role.
2. Generate a report snapshot only when the user requests or workflow requires
   it.
3. Display customer-safe reports in customer-facing routes.
4. Display snapshot metadata in internal operator routes.
5. Do not render restricted notes in customer-facing routes.

## Checkpoint

- Customer routes use `user_safe`.
- Internal review routes can show snapshot metadata.
- Restricted notes, internal scoring details, and control logic do not appear
  in customer-facing experiences.

## Common Mistakes

- Using one report view everywhere.
- Rendering compliance payloads in customer support routes.
- Hiding snapshot metadata that operators need for support.
- Regenerating reports on every page load.

## Related Pages

- [Reviewer Workspace](../workflows/reviewer-workspace.md)
- [Audit-Ready UI](../quality/audit-ready-ui.md)
- [Launch Checklist](../quality/launch-checklist.md)
