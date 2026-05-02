# Error States

## Use This When

Use this page when turning API failures into clear UI behavior.

## What You Will Build

You will map structured API errors to validation messages, auth recovery,
missing-resource screens, conflict resolution, retry states, and support
handoff.

## What Must Already Be True

- The shared [API Client](api-client.md) throws `KycApiError`.
- The UI has a place to render field, form, page, and support messages.

## API Contract

Preserve these fields when the API returns them:

```text
status
code
message
developer_message
category
request_id
trace_id
retryable
details
```

Useful guards:

```ts
export function isValidationError(error: unknown): error is KycApiError {
  return error instanceof KycApiError && error.status === 400;
}

export function isUnauthorized(error: unknown): error is KycApiError {
  return error instanceof KycApiError && error.status === 401;
}

export function isConflict(error: unknown): error is KycApiError {
  return error instanceof KycApiError && error.status === 409;
}

export function isRetryableServiceError(error: unknown): error is KycApiError {
  return error instanceof KycApiError && error.retryable;
}
```

## UI States

| Status | UI behavior |
|---:|---|
| 400 | Show field or form validation. Use `details.field` when present. |
| 401 | Refresh login or redirect to sign in. |
| 404 | Show missing resource state and route back to a safe page. |
| 409 | Offer to load the existing case or create a new external identifier. |
| 503 | Show degraded service, retry later, and include `request_id` in support details. |

## Implementation Steps

1. Create one error-to-UI mapping module.
2. Render field errors near the relevant form inputs.
3. Render auth failures as sign-in recovery, not data-entry mistakes.
4. Render conflicts as recoverable choices.
5. Render retryable failures with retry and support handoff.

## Checkpoint

- Field errors appear near the relevant input.
- Authentication errors do not look like validation errors.
- Conflict errors give the operator a recoverable path.
- Support details include `request_id` when the API provides it.

## Common Mistakes

- Collapsing all failures into "Something went wrong."
- Hiding developer context that support needs.
- Showing developer-only messages to customers.
- Retrying non-idempotent actions without user intent.

## Related Pages

- [API Client](api-client.md)
- [Accessible Product States](../quality/accessible-product-states.md)
- [Testing Checklist](../quality/testing-checklist.md)
