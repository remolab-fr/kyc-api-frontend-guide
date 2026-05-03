# Launch Checklist

## Use This When

Use this page before moving from prototype to production or before asking a
regulated team to rely on the frontend.

## What You Will Build

You will complete the final release check for configuration, auth, security
boundaries, product states, tests, and support handoff.

## What Must Already Be True

- The main workflow has been implemented.
- Tests have been added for critical states.
- A non-production environment can call the API.

## Launch Gate

Confirm:

- The API base URL is environment-specific.
- The frontend origin is allowed by the API owner.
- Browser authentication uses a public client flow.
- No private service credential is shipped to the browser.
- Protected requests send `Authorization: Bearer <access_token>`.
- Errors display useful user states and preserve `request_id` for support.
- Developer diagnostics show backend `release` and failed readiness checks.
- Request and response types are generated from, or manually reviewed against,
  the checked OpenAPI contract.
- Quick screening is not presented as final approval.
- Customer screens use customer-safe report views.
- Internal-only sections are hidden from customer-facing routes.
- Human review actions require explicit rationale.
- Human follow-up uses `needs_more_information`; the case workspace should then
  watch `WAITING_FOR_CUSTOMER` as the resulting case status.
- Personal and regulated data are excluded from analytics and client logs.
- The application has tests for diagnostics, auth failures, validation errors,
  conflict errors, quick screening, case creation, report generation, workflow
  polling, and review decision submission.

## Implementation Steps

1. Run local type, lint, test, and build commands.
2. Verify auth and protected endpoint access in the target environment.
3. Verify report view permissions.
4. Review browser bundle and environment files for private values.
5. Confirm support handoff includes API request metadata.
6. Document any environment-specific values outside the source tree.

## Checkpoint

- A reviewer can trace each critical product state to a screen and a test.
- No secret or private credential is present in public source.
- Any unverified production dependency is documented before launch.

## Common Mistakes

- Treating a passing build as a complete launch gate.
- Skipping expired-token and duplicate-case tests.
- Relying on frontend visibility as the only protection for restricted fields.
- Claiming production readiness before CORS, auth claims, and protected endpoint
  access have been verified.

## Related Pages

- [Launch-Ready Frontend](../workflows/launch-ready-frontend.md)
- [Testing Checklist](testing-checklist.md)
- [Audit-Ready UI](audit-ready-ui.md)
