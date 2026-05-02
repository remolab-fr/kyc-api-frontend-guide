# Human Review Decisions

## Use This When

Use this page when an authorized reviewer must make an accountable decision.

## What You Will Build

You will build a review panel that separates evidence, generated
recommendations, and the human decision.

## What Must Already Be True

- A durable case exists.
- Evidence and reports are visible to the reviewer.
- The reviewer is authorized to submit decisions.

## API Contract

Endpoint:

```text
POST /api/v1/kyc-cases/{case_id}/review-decisions
```

Allowed decision outcomes:

```text
approved
rejected
needs_more_information
escalated
```

TypeScript helper:

```ts
export type ReviewDecisionOutcome =
  | "approved"
  | "rejected"
  | "needs_more_information"
  | "escalated";

export async function submitReviewDecision(
  client: KycApiClient,
  caseId: string,
  body: {
    proposal_id?: string | null;
    decision_outcome: ReviewDecisionOutcome;
    rationale: string;
    decision_payload?: Record<string, unknown>;
    corrections?: Array<Record<string, unknown>>;
  }
) {
  return client.post<{ principal: string; review_decision: unknown }>(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/review-decisions`,
    body
  );
}
```

## UI States

A good review screen has three zones:

| Zone | Purpose |
|---|---|
| Evidence | What the API returned and what the reviewer should inspect. |
| Recommendation | Suggested outcome, rationale, and limitations. |
| Decision | The human action, rationale, and final submission control. |

Decision form states:

- No decision selected.
- Decision selected but rationale missing.
- Ready to submit.
- Submitting.
- Submitted.
- Authorization or validation error.

## Implementation Steps

1. Show evidence first.
2. Show recommendations in a visually separate area.
3. Require explicit reviewer outcome selection.
4. Require rationale before submit.
5. Disable final submit while save or report operations are pending.
6. Treat `needs_more_information` as workflow state, not a technical error.

## Checkpoint

- Recommendation and decision are visually separate.
- The final decision requires a reviewer action.
- The decision form requires rationale.
- `needs_more_information` is treated as workflow state, not a technical error.

## Common Mistakes

- Combining recommendation and decision into one button.
- Letting an empty rationale through.
- Enabling final submit while other case saves are pending.
- Presenting generated text as the accountable decision.

## Related Pages

- [Reviewer Workspace](../workflows/reviewer-workspace.md)
- [Audit-Ready UI](../quality/audit-ready-ui.md)
- [Launch Checklist](../quality/launch-checklist.md)
