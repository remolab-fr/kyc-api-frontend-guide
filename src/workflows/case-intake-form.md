# Case Intake Form

## Use This When

Use this workflow when the frontend collects applicant, customer, borrower,
seller, or policyholder details and creates a durable case.

## What You Will Build

You will build intake that validates input, optionally runs quick screening,
creates a durable case, and routes the user to a case workspace.

## What Must Already Be True

- The app has browser-safe auth.
- The shared [API Client](../foundations/api-client.md) exists.
- Required public configuration is available.

## API Contract

Typical endpoints:

```text
GET /api/v1/kyc/search
POST /api/v1/kyc-cases
PATCH /api/v1/kyc-cases/{case_id}/sections/{section_name}
```

Use quick screening before case creation only when it helps the product flow.

## UI States

| Area | Required states |
|---|---|
| Form | Empty, invalid, ready, submitting. |
| Screening | Not run, running, evidence available, partial evidence. |
| Case creation | Saving, created, duplicate external ID, validation error. |
| Navigation | Stay on form for fixable errors, route to workspace on success. |

## Implementation Steps

1. Add [Error States](../foundations/error-states.md).
2. Add [Quick Screening](../tasks/quick-screening.md) when intake needs a first
   evidence pass.
3. Add [Create Durable Cases](../tasks/create-durable-cases.md).
4. Add [Case Sections](../tasks/case-sections.md) if intake saves additional
   sections after the case exists.
5. Run [Accessible Product States](../quality/accessible-product-states.md) for
   form labels, validation, keyboard behavior, and focus handling.

## Checkpoint

- Missing or invalid input is caught before submit when possible.
- API validation errors map back to the form.
- Duplicate external case IDs show a recovery path.
- Successful creation moves the user to the case workspace.

## Common Mistakes

- Saving a durable case before the user has entered required identity context.
- Treating a quick screening result as the final intake decision.
- Losing form state when the API returns a validation error.
- Requiring an external case ID when the API can generate one safely.

## Related Pages

- [Quick Screening](../tasks/quick-screening.md)
- [Create Durable Cases](../tasks/create-durable-cases.md)
- [Case Sections](../tasks/case-sections.md)
- [Testing Checklist](../quality/testing-checklist.md)
