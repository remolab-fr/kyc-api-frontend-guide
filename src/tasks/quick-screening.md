# Quick Screening

## Use This When

Use this page when an operator needs a lightweight evidence check before opening
or updating a durable case.

## What You Will Build

You will build a search form and results view that presents screening evidence,
limitations, and next steps without presenting the result as final approval.

## What Must Already Be True

- [API Client](../foundations/api-client.md) is implemented.
- [Error States](../foundations/error-states.md) are mapped.
- The user can authenticate for protected API calls.

## API Contract

Endpoint:

```text
GET /api/v1/kyc/search
```

Request query:

```text
name={name}
date_of_birth={date_of_birth}
nationality={nationality}
include_web_search={true_or_false}
limit={limit}
```

Only `name` is required.

TypeScript shape:

```ts
export type KycSearchParams = {
  name: string;
  dateOfBirth?: string;
  nationality?: string;
  includeEvidenceSearch?: boolean;
  limit?: number;
};

export async function searchKyc(client: KycApiClient, params: KycSearchParams) {
  const query = new URLSearchParams({
    name: params.name,
    include_web_search: String(params.includeEvidenceSearch ?? true),
    limit: String(params.limit ?? 5)
  });

  if (params.dateOfBirth) {
    query.set("date_of_birth", params.dateOfBirth);
  }

  if (params.nationality) {
    query.set("nationality", params.nationality);
  }

  return client.get<KycSearchResponse>(`/api/v1/kyc/search?${query}`);
}
```

Render these response areas:

- Subject and generated timestamp.
- Overall status and risk level.
- Local sanctions screening status and source versions.
- Evidence-search status, result counts, and query-level failures.
- Recommended next steps.
- Limitations.

## UI States

| State | Product behavior |
|---|---|
| Empty | Show a short form with required `name`. |
| Loading | Disable submit and show that screening is running. |
| Success | Render evidence, limitations, and next steps. |
| Partial evidence | Show degraded query/source information clearly. |
| Validation error | Put the message near the relevant input. |
| Auth error | Ask the user to sign in again. |

## Implementation Steps

1. Build a small form with name, optional date of birth, optional nationality,
   evidence-search toggle, and result limit.
2. Validate name before calling the API.
3. Call `searchKyc` through the shared client.
4. Render screening status and evidence-search status separately.
5. Put limitations close to the summary.
6. Offer a next action such as creating or opening a durable case.

## Checkpoint

- A user can understand what was checked, what was degraded, and what should
  happen next.
- No quick-screening result is labeled as final approval.

## Common Mistakes

- Converting risk level directly into an approval button.
- Hiding partial evidence failures.
- Dropping limitations below the fold where reviewers miss them.
- Logging raw search payloads to analytics.

## Related Pages

- [Case Intake Form](../workflows/case-intake-form.md)
- [Create Durable Cases](create-durable-cases.md)
- [Human Review Decisions](human-review-decisions.md)
