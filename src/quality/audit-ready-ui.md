# Audit-Ready UI

## Use This When

Use this page when the frontend displays regulated evidence, reports, restricted
sections, recommendations, or decisions.

## What You Will Build

You will make the UI clear about what is evidence, what is generated guidance,
what is a human decision, and what is safe for each audience.

## What Must Already Be True

- The product has identified customer-facing and reviewer-facing routes.
- Report view types are understood.
- Role-based visibility has been designed for the frontend.

## UI Contract

| Concept | UI rule |
|---|---|
| Evidence | Show source, status, limitations, and next steps. |
| Recommendation | Present as guidance, not final action. |
| Human decision | Require explicit reviewer choice and rationale. |
| Report snapshot | Preserve view type, generated timestamp, snapshot ID, and hash where appropriate. |
| Customer-safe view | Hide restricted notes, internal scoring, and compliance-only details. |
| Restricted section | Hide from customer routes and rely on backend authorization for enforcement. |

## Implementation Steps

1. Use separate components for evidence, recommendation, decision, and report
   snapshot metadata.
2. Display report view type in reviewer-facing report screens.
3. Keep customer-safe report rendering separate from compliance report
   rendering.
4. Show limitations close to screening summaries.
5. Require rationale before decision submission.
6. Exclude personal and regulated data from analytics and client logs.

## Checkpoint

- A reviewer can tell the difference between evidence, recommendation, and
  decision.
- Customer routes render only customer-safe report information.
- Restricted notes do not appear in customer-facing components.

## Common Mistakes

- Reusing one report component for every audience.
- Putting the final decision button inside the recommendation component.
- Hiding limitations in a secondary tab.
- Logging raw regulated payloads during debugging.

## Related Pages

- [Report Snapshots](../tasks/report-snapshots.md)
- [Human Review Decisions](../tasks/human-review-decisions.md)
- [Launch Checklist](launch-checklist.md)
