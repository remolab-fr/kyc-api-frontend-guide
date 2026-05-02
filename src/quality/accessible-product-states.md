# Accessible Product States

## Use This When

Use this page when building or reviewing any screen that calls the KYC API.

## What You Will Build

You will make every visible API-backed state understandable, keyboard reachable,
and screen-reader friendly.

## What Must Already Be True

- The screen has a clear user goal.
- The API client and error mapping exist.
- The product owner knows which roles can use the screen.

## UI State Contract

Every critical surface should handle:

| State | Requirement |
|---|---|
| Empty | Explain what the user can do next. |
| Loading | Show progress without moving layout unexpectedly. |
| Success | Show the result and the next safe action. |
| Validation error | Put the message near the input. |
| Auth error | Show sign-in recovery. |
| Permission error | Explain that access is restricted. |
| Conflict | Offer a recoverable choice. |
| Retryable service failure | Show retry and support handoff. |

## Implementation Steps

1. Use semantic HTML for forms, tables, lists, and status regions.
2. Label every input.
3. Keep keyboard focus visible.
4. Move focus intentionally after route changes, modal opens, and form errors.
5. Do not use color alone to communicate risk, status, or severity.
6. Keep long operations from blocking unrelated navigation.
7. Preserve API `request_id` in support details when available.

## Checkpoint

- A user can complete the screen with a keyboard.
- Errors are readable without relying on color.
- Loading, empty, success, and error states are all visible in tests or manual
  review.

## Common Mistakes

- Building only the success state.
- Showing validation errors in a global toast with no field association.
- Moving focus unpredictably after save.
- Hiding retryable failures behind generic copy.

## Related Pages

- [Error States](../foundations/error-states.md)
- [Testing Checklist](testing-checklist.md)
- [Launch-Ready Frontend](../workflows/launch-ready-frontend.md)
