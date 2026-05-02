# Case Sections

## Use This When

Use this page when a case workspace needs to save one part of a case at a time.

## What You Will Build

You will build section updates for smaller forms, safer autosave, and clearer
review screens.

## What Must Already Be True

- A durable case exists.
- The UI knows the current `case_id`.
- The product can decide which sections are visible to each role.

## API Contract

Endpoint:

```text
PATCH /api/v1/kyc-cases/{case_id}/sections/{section_name}
```

Body:

```json
{
  "payload": {}
}
```

Common section names:

```ts
export type KycSectionName =
  | "service_context"
  | "end_user_identity"
  | "contact_verification"
  | "identity_document_verification"
  | "address_verification"
  | "screening"
  | "risk_assessment"
  | "decision"
  | "user_facing_summary"
  | "restricted_compliance_notes";

export async function patchKycSection(
  client: KycApiClient,
  caseId: string,
  sectionName: KycSectionName,
  payload: Record<string, unknown>
) {
  return client.patch<{ principal: string; section: unknown }>(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/sections/${sectionName}`,
    { payload }
  );
}
```

## UI States

| Section | Typical screen |
|---|---|
| `end_user_identity` | Identity details and subject profile. |
| `contact_verification` | Email, phone, and contact checks. |
| `identity_document_verification` | Document review status. |
| `address_verification` | Residence and proof-of-address status. |
| `screening` | Screening evidence and match review. |
| `risk_assessment` | Risk rationale and review notes. |
| `user_facing_summary` | Customer-safe explanation. |
| `restricted_compliance_notes` | Internal-only compliance notes. |

## Implementation Steps

1. Split the case workspace into section components.
2. Give each section its own draft, saving, saved, and error states.
3. Save one section at a time.
4. Refresh the case or section data after a successful save.
5. Hide restricted sections from customer-facing routes.
6. Keep backend authorization as the enforcement point.

## Checkpoint

- A section save updates only that part of the case.
- Restricted sections are hidden from customer-facing routes.
- Frontend role gating improves usability, while backend authorization remains
  the enforcement point.

## Common Mistakes

- Submitting the entire case for every small edit.
- Assuming hidden frontend fields are a security control.
- Saving restricted notes from customer routes.
- Losing unsaved form state after a section error.

## Related Pages

- [Reviewer Workspace](../workflows/reviewer-workspace.md)
- [Audit-Ready UI](../quality/audit-ready-ui.md)
- [Testing Checklist](../quality/testing-checklist.md)
