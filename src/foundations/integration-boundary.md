# Integration Boundary

## Use This When

Use this page before writing API calls, auth wiring, or UI screens.

## What You Will Build

You will define the browser-safe boundary for a frontend integration with the
KYC API.

## What Must Already Be True

- You know which frontend application will call the API.
- You can get public configuration from the API owner.
- You have a user sign-in strategy or a plan to add one.

## API Contract

The frontend can rely on public API endpoints and response contracts. It should
not depend on internal hosting, storage, scoring, routing, or operator tooling.

The browser may contain:

- Public API base URL.
- Public auth issuer URL.
- Public frontend auth client ID.
- Redirect URI.
- Post-logout redirect URI.
- Required API audience or scope when provided.

The browser must never contain:

- Service-account keys.
- Private keys.
- Backend secrets.
- Database URLs.
- Token-introspection credentials.
- Long-lived bearer credentials.
- Provider credentials.

## UI States

The boundary should show up in the product:

| State | Product behavior |
|---|---|
| Missing public config | Stop startup or show setup diagnostics. |
| Missing user token | Show sign-in state. |
| Unauthorized request | Recover auth or send the user to sign in. |
| Support handoff | Preserve API `request_id` and `trace_id` when present. |

## Implementation Steps

1. List every runtime value the frontend needs.
2. Classify each value as public browser config or server-side secret.
3. Add startup validation for required public values.
4. Route all protected calls through one API client.
5. Preserve structured API error metadata for support.

## Checkpoint

- Environment files do not contain private credentials.
- Protected calls use the current user's bearer token.
- UI copy does not promise that screening evidence equals final approval.

## Common Mistakes

- Reusing a machine-to-machine credential in browser code.
- Logging access tokens or regulated payloads.
- Hardcoding deployment-specific values in reusable source.
- Exposing operator-only endpoints to ordinary end users.

## Related Pages

- [Environment Configuration](environment-config.md)
- [API Client](api-client.md)
- [Diagnostics](diagnostics.md)
- [Audit-Ready UI](../quality/audit-ready-ui.md)
