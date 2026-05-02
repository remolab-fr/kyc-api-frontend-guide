# API Client

## Use This When

Use this page when adding the first real API calls to a frontend application.

## What You Will Build

You will build one small TypeScript API client that attaches user tokens,
parses JSON, and converts non-2xx responses into structured errors.

## What Must Already Be True

- Public API configuration is available.
- The application can provide the current user's access token or `null`.
- The frontend has a place for shared API modules.

## API Contract

Protected API calls send:

```text
Authorization: Bearer <access_token>
```

The token must come from the current user's browser sign-in flow, normally
authorization code with PKCE or an equivalent repository-provided pattern.

## Implementation Steps

Start with one client that is independent from UI components:

```ts
export type KycApiClientOptions = {
  baseUrl: string;
  getAccessToken: () => Promise<string | null>;
};

export type KycApiErrorBody = {
  code: string;
  message: string;
  developer_message?: string;
  category?: string;
  http_status?: number;
  request_id?: string;
  trace_id?: string;
  retryable?: boolean;
  docs_url?: string;
  details?: Record<string, unknown>;
};

export class KycApiError extends Error {
  readonly developerMessage?: string;
  readonly category?: string;
  readonly requestId?: string;
  readonly traceId?: string;
  readonly retryable: boolean;
  readonly details?: Record<string, unknown>;

  constructor(
    message: string,
    readonly status: number,
    readonly code?: string,
    readonly responseBody?: unknown
  ) {
    super(message);

    const body = (responseBody as { error?: KycApiErrorBody } | null)?.error;
    this.developerMessage = body?.developer_message;
    this.category = body?.category;
    this.requestId = body?.request_id;
    this.traceId = body?.trace_id;
    this.retryable = body?.retryable ?? false;
    this.details = body?.details;
  }

  get field(): string | undefined {
    return typeof this.details?.field === "string" ? this.details.field : undefined;
  }
}
```

Wrap `fetch` once:

```ts
export class KycApiClient {
  constructor(private readonly options: KycApiClientOptions) {}

  get<T>(path: string): Promise<T> {
    return this.request<T>("GET", path);
  }

  post<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>("POST", path, body);
  }

  patch<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>("PATCH", path, body);
  }

  private async request<T>(
    method: "GET" | "POST" | "PATCH",
    path: string,
    body?: unknown
  ): Promise<T> {
    const token = await this.options.getAccessToken();
    const response = await fetch(new URL(path, this.options.baseUrl), {
      method,
      headers: {
        Accept: "application/json",
        ...(body ? { "Content-Type": "application/json" } : {}),
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      body: body ? JSON.stringify(body) : undefined
    });

    const text = await response.text();
    const parsed = text ? JSON.parse(text) : null;

    if (!response.ok) {
      throw new KycApiError(
        parsed?.error?.message ?? `KYC API returned HTTP ${response.status}`,
        response.status,
        parsed?.error?.code,
        parsed
      );
    }

    return parsed as T;
  }
}
```

Create the instance at the app boundary:

```ts
export const kycApi = new KycApiClient({
  baseUrl: import.meta.env.VITE_KYC_API_BASE_URL,
  getAccessToken
});
```

## UI States

The API client should make these states easy to render:

| State | Source |
|---|---|
| Loading | The request promise is pending. |
| Success | The typed response is returned. |
| Validation error | `KycApiError.status === 400`. |
| Auth error | `KycApiError.status === 401`. |
| Conflict | `KycApiError.status === 409`. |
| Retry later | `KycApiError.retryable === true`. |

## Checkpoint

- All API calls use the same client.
- Protected requests attach `Authorization: Bearer <access_token>`.
- Non-2xx responses throw `KycApiError`.
- `request_id` is available for support handoff.

## Common Mistakes

- Creating one `fetch` wrapper per screen.
- Dropping `request_id` from errors.
- Assuming every response body is valid JSON without reading the response text.
- Retrying compliance-changing mutations blindly.

## Related Pages

- [Environment Configuration](environment-config.md)
- [Error States](error-states.md)
- [Testing Checklist](../quality/testing-checklist.md)
