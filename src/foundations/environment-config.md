# Environment Configuration

## Use This When

Use this page when wiring a frontend app to a real API environment.

## What You Will Build

You will define environment-specific public configuration for the browser app
and keep private values out of source code.

## What Must Already Be True

- The API owner has assigned an API base URL.
- The auth owner has configured a public browser client.
- The frontend origin is allowed by the API owner.

## API Contract

Before production wiring, get these values:

```text
KYC API base URL
Auth issuer URL
Public frontend client ID
Redirect URI
Post-logout redirect URI
Required API audience or scope
Allowed frontend origin
Support contact or escalation path
```

For a Vite application, public variables usually look like:

```text
VITE_KYC_API_BASE_URL=https://api.example.com
VITE_AUTH_ISSUER=https://identity.example.com
VITE_AUTH_CLIENT_ID=public-browser-client-id
VITE_AUTH_REDIRECT_URI=http://localhost:5173/auth/callback
VITE_AUTH_POST_LOGOUT_REDIRECT_URI=http://localhost:5173/
VITE_AUTH_AUDIENCE_SCOPE=api-audience-scope
```

Use the target application's naming convention when it differs from Vite.

## UI States

Configuration should support these states:

| State | Product behavior |
|---|---|
| Config valid | Enable diagnostics and sign-in. |
| API base URL missing | Show setup error before protected screens load. |
| Auth issuer missing | Disable sign-in and show setup guidance. |
| Origin not allowed | Diagnostics should point to CORS or origin allowlist. |

## Implementation Steps

1. Add a small config module at the frontend app boundary.
2. Read only public environment variables in browser code.
3. Validate required values at startup.
4. Fail clearly when a required value is missing.
5. Link config errors to the diagnostics screen.

## Checkpoint

- Local development can load public config.
- Production config can be supplied without changing source code.
- No private key, service credential, database URL, or long-lived token appears
  in the frontend bundle.

## Common Mistakes

- Treating public client IDs as secrets.
- Treating service credentials as public config.
- Committing `.env` files.
- Letting a missing config value produce a generic blank screen.

## Related Pages

- [Integration Boundary](integration-boundary.md)
- [Diagnostics](diagnostics.md)
- [Launch Checklist](../quality/launch-checklist.md)
