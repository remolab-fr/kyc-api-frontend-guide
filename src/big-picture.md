# Big Picture

## Use This When

Use this page when you need the overall map before choosing an implementation
topic.

## What You Will Build

You will build a frontend that turns the KYC API into regulated product
workflows: diagnostics, screening, cases, section updates, reports, workflow
progress, and human review.

## What Must Already Be True

- You are building a browser or web application.
- The API owner can provide public frontend configuration.
- The target product has a sign-in flow or can add one.

## Mental Model

Think of the KYC API as six frontend-facing capabilities.

| Capability | Frontend responsibility | API responsibility |
|---|---|---|
| Access | Sign in the user and send a short-lived bearer token. | Validate the token and authorize protected requests. |
| Diagnostics | Show whether the API is reachable and ready. | Expose health and readiness endpoints. |
| Screening evidence | Collect search input and render evidence clearly. | Return screening status, evidence status, limitations, and next steps. |
| Case workspace | Let operators create and update a review file. | Persist durable case records and section updates. |
| Report snapshots | Request the correct report view and display it safely. | Generate immutable report artifacts with snapshot metadata. |
| Human review | Require reviewer action and rationale. | Record accountable review decisions. |

The frontend orchestrates the experience. The API owns the regulated workflow
contract.

## Course Path

The stable learning path is:

1. Draw the [Integration Boundary](foundations/integration-boundary.md).
2. Configure the [Environment](foundations/environment-config.md).
3. Build the [API Client](foundations/api-client.md).
4. Add [Diagnostics](foundations/diagnostics.md).
5. Convert failures into [Error States](foundations/error-states.md).
6. Build [Quick Screening](tasks/quick-screening.md).
7. Create [Durable Cases](tasks/create-durable-cases.md).
8. Save [Case Sections](tasks/case-sections.md).
9. Generate [Report Snapshots](tasks/report-snapshots.md).
10. Display [Workflow Events](tasks/workflow-events.md).
11. Submit [Human Review Decisions](tasks/human-review-decisions.md).
12. Run the [Launch Checklist](quality/launch-checklist.md).

## Checkpoint

You are ready to start implementation when you can explain:

- Which values are public browser configuration.
- Which credentials must never reach the browser.
- Which page owns diagnostics, errors, screening, cases, reports, and review.
- Which workflow you are building first.

## Common Mistakes

- Building product screens before diagnostics.
- Treating quick screening as final approval.
- Mixing generated recommendations with human decisions.
- Showing compliance-only report data on customer-facing routes.
- Letting every screen invent its own API request logic.

## Related Pages

- [Course Map](course.md)
- [Read-Only Dashboard](workflows/read-only-dashboard.md)
- [Case Intake Form](workflows/case-intake-form.md)
- [Reviewer Workspace](workflows/reviewer-workspace.md)
- [LLM Coder Agent Contract](llm-agent-contract.md)
