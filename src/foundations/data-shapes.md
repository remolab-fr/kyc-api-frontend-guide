# Data Shapes And Vocabulary

## Use This When

Use this page when naming types, UI labels, route names, or documentation in a
frontend implementation.

## What You Will Build

You will keep product language consistent across code, screens, support
handoff, and tests.

## What Must Already Be True

- You have read the [Big Picture](../big-picture.md).
- You know which workflow the frontend will support first.

## Vocabulary

| Term | Meaning |
|---|---|
| API client | The frontend module that wraps `fetch`, attaches tokens, and parses errors. |
| Diagnostics | Health, readiness, and authenticated access checks. |
| Quick screening | A lightweight evidence search. It is not a final approval. |
| Case | A durable review file for one customer, seller, borrower, policyholder, or subject. |
| Section | One named part of a case file, saved independently. |
| Report snapshot | A generated report artifact with ID, hash, view, timestamp, and payload. |
| Workflow event | A progress event for active work. It is not the permanent compliance archive. |
| Recommendation | Generated or assisted guidance shown to a reviewer. |
| Decision | The accountable human action submitted by an authorized reviewer. |

The API uses technical parameter names such as `include_web_search`. Your UI can
label the same control "evidence search" if that is clearer for users.

## UI States

Vocabulary should make state obvious:

| State | Preferred language |
|---|---|
| Evidence only | "Screening evidence" or "evidence search result". |
| Human action required | "Reviewer decision required". |
| Customer-safe report | "Customer summary" or product-specific equivalent. |
| Restricted data | "Internal review only" or role-specific label. |

## Implementation Steps

1. Create shared TypeScript types for API concepts.
2. Use product labels in the UI while preserving API field names in client code.
3. Keep recommendations, decisions, reports, and events as separate types.
4. Add test fixtures using the same vocabulary as the UI.

## Checkpoint

- A teammate can read a screen, test, or type name and know whether it is
  evidence, a recommendation, a decision, an event, or a report snapshot.

## Common Mistakes

- Calling a quick screening result "approved".
- Treating workflow events as the audit archive.
- Mixing customer-safe and compliance report views in one component.
- Using different names for the same concept in code and UI.

## Related Pages

- [Quick Screening](../tasks/quick-screening.md)
- [Report Snapshots](../tasks/report-snapshots.md)
- [Human Review Decisions](../tasks/human-review-decisions.md)
