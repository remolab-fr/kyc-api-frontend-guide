# Testing Checklist

## Use This When

Use this page when adding automated tests or preparing a release branch.

## What You Will Build

You will verify the integration with tests that cover the product states a
regulated frontend depends on.

## What Must Already Be True

- The target repository has a test runner or component testing strategy.
- API calls are routed through the shared client.
- External API calls can be mocked or tested against a controlled environment.

## Test Contract

Run the target repository's actual commands. Prefer:

```bash
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

If the repository uses npm, yarn, bun, or another tool, use that instead.

## Minimum Verification Scenarios

1. Public health endpoint renders reachable state.
2. Public readiness endpoint renders ready or degraded state.
3. Protected request without token redirects or shows sign-in state.
4. Quick screening form validates missing or short name.
5. Quick screening success renders evidence and limitations.
6. API validation error maps to form error.
7. API 401 maps to auth recovery.
8. API 409 maps to conflict UI.
9. Case creation success routes to case workspace.
10. Section save updates UI without losing unsaved form state.
11. Report generation shows `HIT` or `MISS` cache status.
12. Workflow polling merges events without duplicates.
13. Review decision requires rationale.
14. Customer route does not render compliance-only fields.

## Implementation Steps

1. Add unit tests for API client error parsing.
2. Add component tests for form validation and error rendering.
3. Add route or integration tests for diagnostics and auth recovery.
4. Add workflow tests for case creation, section save, report generation, and
   review decision.
5. Add customer-route tests that assert restricted fields are absent.

## Checkpoint

- The happy path and the main failure paths are covered.
- Tests assert visible product behavior, not only function calls.
- Test fixtures do not contain real customer data or secrets.

## Common Mistakes

- Mocking the API client so heavily that error parsing is never tested.
- Testing only the success path.
- Forgetting customer-safe report assertions.
- Leaving real regulated payloads in snapshots or fixtures.

## Related Pages

- [API Client](../foundations/api-client.md)
- [Error States](../foundations/error-states.md)
- [Launch Checklist](launch-checklist.md)
