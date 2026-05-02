# Launch-Ready Frontend

## Use This When

Use this workflow when a prototype is moving toward production use in a
regulated product.

## What You Will Build

You will turn a working integration into a launch-ready frontend by checking
configuration, security boundaries, accessible states, audit readiness, tests,
and release assumptions.

## What Must Already Be True

- The main product workflow is implemented.
- The app can call the API in at least one non-production environment.
- Auth, CORS or origin allowlist, and protected endpoint access can be verified.

## API Contract

The launch gate should cover every endpoint your product calls, especially:

```text
GET /healthz
GET /readyz
GET /api/v1/kyc/search
POST /api/v1/kyc-cases
PATCH /api/v1/kyc-cases/{case_id}/sections/{section_name}
POST /api/v1/kyc-cases/{case_id}/reports/end-user-v1
GET /api/v1/kyc-cases/{case_id}/reports/latest?view={view}
POST /api/v1/kyc-cases/{case_id}/review-decisions
```

## UI States

Launch-ready means every critical flow has:

- Empty state.
- Loading state.
- Success state.
- Validation error state.
- Auth or permission error state.
- Conflict state where relevant.
- Retry or support handoff state when relevant.

## Implementation Steps

1. Run [Accessible Product States](../quality/accessible-product-states.md).
2. Run [Audit-Ready UI](../quality/audit-ready-ui.md).
3. Run [Testing Checklist](../quality/testing-checklist.md).
4. Run [Launch Checklist](../quality/launch-checklist.md).
5. Verify production configuration outside the source tree.
6. Confirm support handoff includes request metadata without exposing secrets.

## Checkpoint

- The app has a verified path for diagnostics, auth, validation errors,
  conflicts, screening, case creation, section save, report generation, workflow
  progress, and review decision submission.

## Common Mistakes

- Calling a prototype launch-ready because the happy path works once.
- Skipping customer-safe report verification.
- Leaving private values in public environment examples.
- Not testing duplicate external IDs or expired-token behavior.

## Related Pages

- [Accessible Product States](../quality/accessible-product-states.md)
- [Audit-Ready UI](../quality/audit-ready-ui.md)
- [Testing Checklist](../quality/testing-checklist.md)
- [Launch Checklist](../quality/launch-checklist.md)
