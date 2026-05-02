# Create Durable Cases

## Use This When

Use this page when a workflow needs persistence, reviewer activity, report
snapshots, future refreshes, or customer support handoff.

## What You Will Build

You will build case creation that routes the user into a durable case workspace.

## What Must Already Be True

- [API Client](../foundations/api-client.md) is implemented.
- Form validation and [Error States](../foundations/error-states.md) are ready.
- The product has a route for a case workspace or case detail page.

## API Contract

Endpoint:

```text
POST /api/v1/kyc-cases
```

Minimal frontend input shape:

```ts
export type KycCaseCreateInput = {
  kyc_case_id?: string | null;
  user_internal_id: string;
  agency_name: string;
  regulated_provider_name: string;
  programme_name: string;
  country_of_onboarding: string;
  relationship_type:
    | "NEW_ONBOARDING"
    | "KYC_REFRESH"
    | "LIMIT_INCREASE"
    | "REMEDIATION"
    | "REACTIVATION";
  user_type:
    | "INDIVIDUAL"
    | "SOLE_TRADER"
    | "LEGAL_REPRESENTATIVE"
    | "BENEFICIAL_OWNER";
  current_status:
    | "DRAFT"
    | "DOCUMENTS_SUBMITTED"
    | "EXTRACTION_IN_PROGRESS"
    | "EXTRACTION_FAILED"
    | "PENDING"
    | "PENDING_REVIEW"
    | "WAITING_FOR_CUSTOMER"
    | "ESCALATED"
    | "SUSPENDED";
  case_priority: "LOW" | "NORMAL" | "HIGH" | "URGENT";
  assigned_team: string;
  assigned_analyst_name?: string | null;
  assigned_analyst_email?: string | null;
  legal_first_name: string;
  legal_last_name: string;
};

export async function createKycCase(
  client: KycApiClient,
  input: KycCaseCreateInput
) {
  return client.post<{ principal: string; case: KycCaseRecord }>(
    "/api/v1/kyc-cases",
    input
  );
}
```

## UI States

| State | Product behavior |
|---|---|
| Draft | Let the user enter required case fields. |
| Saving | Disable duplicate submit and show progress. |
| Created | Route to the case workspace. |
| Conflict | Offer to load the existing case or use a new external ID. |
| Validation error | Show field-level guidance. |
| Server-owned fields | Display as read-only after creation. |

## Implementation Steps

1. Let the API generate `kyc_case_id` unless your product owns a stable external
   case ID.
2. Keep final statuses out of the creation form.
3. Validate required fields before submit.
4. Submit through `createKycCase`.
5. On success, navigate to the case workspace.
6. On duplicate external ID, show a recoverable conflict state.

## Checkpoint

- Creating a case routes the user into a case workspace.
- Server-owned fields are displayed but not edited.
- A duplicate external ID shows a conflict path, not a crash.

## Common Mistakes

- Allowing users to create final states directly.
- Treating server-owned fields as editable inputs.
- Creating a new case for every quick screening result.
- Losing the API `request_id` on conflict or validation failures.

## Related Pages

- [Case Intake Form](../workflows/case-intake-form.md)
- [Case Sections](case-sections.md)
- [Report Snapshots](report-snapshots.md)
