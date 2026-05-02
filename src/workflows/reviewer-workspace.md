# Reviewer Workspace

## Use This When

Use this workflow when analysts or authorized reviewers need to inspect a case,
save sections, read reports, track progress, and submit decisions.

## What You Will Build

You will build the primary regulated review surface: case detail, section
editing, evidence panels, reports, workflow timeline, and decision submission.

## What Must Already Be True

- A durable case can be created or loaded.
- The user is authenticated and authorized for reviewer work.
- Customer-facing and reviewer-facing routes are separated.

## API Contract

Typical endpoints:

```text
GET /api/v1/kyc-cases/{case_id}
PATCH /api/v1/kyc-cases/{case_id}/sections/{section_name}
POST /api/v1/kyc-cases/{case_id}/reports/end-user-v1
GET /api/v1/kyc-cases/{case_id}/reports/latest?view={view}
GET /api/v1/workflow/events?after_id={after_id}&limit={limit}
POST /api/v1/kyc-cases/{case_id}/review-decisions
```

## UI States

| Area | Required states |
|---|---|
| Case detail | Loading, found, missing, unauthorized. |
| Sections | Clean, dirty, saving, saved, validation error. |
| Evidence | Available, partial, unavailable, restricted. |
| Reports | No snapshot, generating, cache hit, cache miss, restricted. |
| Events | Polling, idle, warning, error. |
| Decision | Not ready, rationale required, submitting, submitted. |

## Implementation Steps

1. Load the case and render server-owned fields as read-only.
2. Add [Case Sections](../tasks/case-sections.md).
3. Add evidence panels from [Quick Screening](../tasks/quick-screening.md) or
   saved screening sections.
4. Add [Report Snapshots](../tasks/report-snapshots.md).
5. Add [Workflow Events](../tasks/workflow-events.md).
6. Add [Human Review Decisions](../tasks/human-review-decisions.md).
7. Run [Audit-Ready UI](../quality/audit-ready-ui.md) before launch.

## Checkpoint

- Reviewers can understand evidence, reports, workflow progress, and required
  decisions without mixing them together.
- Recommendations and human decisions are visually separate.
- Restricted sections do not appear in customer-facing routes.

## Common Mistakes

- Putting every case field into one large form.
- Hiding report view type or snapshot metadata from reviewers.
- Letting the decision button submit without rationale.
- Showing generated recommendations as if they were decisions.

## Related Pages

- [Case Sections](../tasks/case-sections.md)
- [Report Snapshots](../tasks/report-snapshots.md)
- [Workflow Events](../tasks/workflow-events.md)
- [Human Review Decisions](../tasks/human-review-decisions.md)
