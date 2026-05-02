# Workflow Events

## Use This When

Use this page when the frontend needs to show progress while work is active.

## What You Will Build

You will poll workflow events, merge them without duplicates, and display
warnings and errors clearly.

## What Must Already Be True

- [API Client](../foundations/api-client.md) is implemented.
- The UI has a timeline, activity panel, or progress region.
- The product knows when active work is visible.

## API Contract

Endpoint:

```text
GET /api/v1/workflow/events?after_id={after_id}&limit={limit}
```

Response shape:

```ts
export type WorkflowEvent = {
  id: number;
  timestamp: string;
  level: "info" | "warning" | "error";
  stage: string;
  message: string;
  metadata: Record<string, unknown>;
};

export async function loadWorkflowEvents(client: KycApiClient, afterId: number) {
  return client.get<{
    principal: string;
    events: WorkflowEvent[];
    next_after_id: number;
  }>(`/api/v1/workflow/events?after_id=${afterId}&limit=100`);
}
```

## UI States

| State | Product behavior |
|---|---|
| No events | Show a calm empty timeline. |
| Polling | Show progress without blocking unrelated work. |
| Warning event | Highlight and explain the warning. |
| Error event | Show failure state and support details when available. |
| Tab hidden | Slow or pause polling. |

## Implementation Steps

1. Start with `after_id=0`.
2. Store `next_after_id` after each response.
3. Merge events by `event.id`.
4. Poll only while active work is visible.
5. Slow or stop polling when the browser tab is hidden.
6. Show warning and error events as first-class UI states.

## Checkpoint

- Event polling does not create duplicates.
- Warning and error events are visible.
- The UI treats workflow events as progress, not permanent compliance history.

## Common Mistakes

- Polling forever after the user leaves the page.
- Appending duplicate events.
- Treating workflow events as the audit archive.
- Hiding warning and error events in a collapsed debug panel.

## Related Pages

- [Reviewer Workspace](../workflows/reviewer-workspace.md)
- [Accessible Product States](../quality/accessible-product-states.md)
- [Testing Checklist](../quality/testing-checklist.md)
