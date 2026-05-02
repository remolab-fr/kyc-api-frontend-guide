# Build Regulated Frontend Apps With The KYC API

This guide is for frontend teams building customer onboarding, due diligence,
case review, or compliance operations products on top of the KYC API.

It is intentionally written at the public integration layer. You do not need to
know how the platform is implemented internally. You need to know the contract:
how to authenticate a user, call the API safely, render evidence, guide a
reviewer through the right workflow, and adapt the same building blocks to your
own regulated product.

If you build for a bank, fintech, lender, insurer, marketplace, digital asset
service, payments provider, or regulated B2B platform, this tutorial gives you a
clean starting point.

## The Product You Are Building

The API gives your frontend five durable product primitives:

| Primitive | What it lets you build |
|---|---|
| Authenticated API access | A browser or app backend can call protected KYC endpoints with a short-lived user token. |
| Screening evidence | Your UI can show screening status, evidence status, limitations, and next steps. |
| Case workspace | Your product can create and update a durable review file. |
| Report snapshot | Your UI can generate and display stable report views for customers, partners, or internal operators. |
| Workflow visibility | Your app can show progress, warnings, and errors while long-running work is active. |

The important rule is simple: the frontend orchestrates the user experience; the
API owns the regulated workflow contract.

## What You Will Build

By the end of this tutorial, you will have a reusable frontend integration
pattern for:

1. Checking whether the API is reachable.
2. Calling protected endpoints with the current user's access token.
3. Handling validation, authentication, conflict, and service errors.
4. Running a quick screening search.
5. Creating a durable case.
6. Saving case sections.
7. Generating and reading report snapshots.
8. Polling workflow events.
9. Separating automated recommendations from human decisions.
10. Adapting the same API flow to different regulated industries.

## Public Integration Boundary

A strong API integration starts by drawing the right boundary.

Your frontend should know:

- Which base URL to call.
- How to get a user access token.
- Which endpoint creates, reads, or updates a workflow resource.
- Which response fields are safe to render.
- Which errors are recoverable by the user and which require support.

Your frontend should not know:

- Internal hosting or infrastructure choices.
- Internal storage design.
- Internal model, scoring, or routing implementation.
- Private service credentials.
- Operator-only tools.
- Secret-bearing smoke-test scripts.

That separation protects your users, your developers, and your compliance
process. It also makes the integration portable across regulated products.

## Values You Need From The API Owner

Before writing application code, ask the API owner for these values:

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

Keep them in environment variables:

```text
VITE_KYC_API_BASE_URL=https://api.example.com
VITE_AUTH_ISSUER=https://identity.example.com
VITE_AUTH_CLIENT_ID=public-browser-client-id
VITE_AUTH_REDIRECT_URI=http://localhost:5173/auth/callback
VITE_AUTH_POST_LOGOUT_REDIRECT_URI=http://localhost:5173/
VITE_AUTH_AUDIENCE_SCOPE=api-audience-scope
```

The browser must never receive private service credentials, private keys,
backend secrets, raw database URLs, or long-lived bearer credentials. If a value
cannot be safely pasted into a public browser bundle, it does not belong in the
frontend.

## Step 1: Create A Small API Client

Start with a small client that does four jobs well:

- Attach the current user's access token when available.
- Send JSON requests consistently.
- Parse the shared error envelope.
- Return typed responses to the rest of your app.

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

Now wrap `fetch`:

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

Create one client instance at the app boundary:

```ts
export const kycApi = new KycApiClient({
  baseUrl: import.meta.env.VITE_KYC_API_BASE_URL,
  getAccessToken
});
```

`getAccessToken` should come from your approved browser sign-in flow. For a
public frontend, that usually means authorization code with PKCE. The important
part is that your API client receives only the current user's short-lived access
token.

## Step 2: Make API Health Visible

Good frontend integrations make connectivity visible early. Add a diagnostics
screen before building complex product flows.

```ts
export type HealthResponse = {
  status: string;
};

export type ReadinessResponse = {
  status: string;
  checks?: Record<string, unknown>;
};

export async function loadApiDiagnostics(client: KycApiClient) {
  const [health, readiness] = await Promise.all([
    client.get<HealthResponse>("/healthz"),
    client.get<ReadinessResponse>("/readyz")
  ]);

  return { health, readiness };
}
```

Build the UI so a developer can answer four questions quickly:

- Can the browser reach the API?
- Is the API ready to handle work?
- Is the user signed in?
- Can a protected endpoint be called with the current token?

This one screen saves hours during integration because it separates network,
configuration, authentication, and product-flow issues.

## Step 3: Treat Errors As Product States

Regulated applications should not collapse every failure into "Something went
wrong." The API returns structured errors so the frontend can respond clearly.

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

Use this behavior in your UI:

| Status | Frontend response |
|---:|---|
| 400 | Show a field or form error. Use `details.field` when present. |
| 401 | Refresh login or redirect to sign in. |
| 404 | Show a missing resource state and route back to a safe page. |
| 409 | Offer to load the existing case or create a new external identifier. |
| 503 | Show degraded service, retry later, and include `request_id` in support details. |

Always include `request_id` in support handoffs. Never include access tokens,
identity documents, private keys, or raw regulated payloads in client logs.

## Step 4: Build Quick Screening

Quick screening is the lightweight entry point. Use it when an operator needs a
fast evidence pass before creating a full case.

```ts
export type KycSearchParams = {
  name: string;
  dateOfBirth?: string;
  nationality?: string;
  includeEvidenceSearch?: boolean;
  limit?: number;
};

export type KycSearchResponse = {
  principal: string;
  report: {
    report_id: string;
    generated_at: string;
    subject: {
      name: string;
      date_of_birth_supplied: boolean;
      nationality_supplied: boolean;
    };
    overall_assessment: {
      status: string;
      risk_level: string;
      summary: string;
    };
    local_sanctions_screening: {
      status: string;
      matches_count: number;
      source_versions: Array<{
        display_name: string;
        version_label: string;
        status: string;
      }>;
    };
    web_search_screening: {
      status: string;
      total_results: number;
      queries: Array<{
        category: string;
        status: string;
        failure_reason?: string | null;
      }>;
    };
    recommended_next_steps: string[];
    limitations: string[];
  };
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

Coach the user through the result:

- Show the subject and generation time.
- Show the overall status and risk level.
- Show screening status separately from evidence-search status.
- Show limitations near the summary.
- Show query-level failures when evidence is partial.
- Never turn quick screening into a final approval button.

The strongest UX pattern is an evidence card, not a binary verdict. Regulated
review depends on context, policy, and human accountability.

## Step 5: Create A Durable Case

Create a case when the workflow needs persistence: submitted identity details,
section updates, reviewer activity, report snapshots, or future refreshes.

```ts
export type KycCaseCreateInput = {
  kyc_case_id?: string | null;
  user_internal_id: string;
  agency_name: string;
  regulated_provider_name: string;
  programme_name: string;
  country_of_onboarding: string;
  relationship_type:
    | "NEW_ONBOARDING"
    | "KYC_REFRESH"
    | "LIMIT_INCREASE"
    | "REMEDIATION"
    | "REACTIVATION";
  user_type:
    | "INDIVIDUAL"
    | "SOLE_TRADER"
    | "LEGAL_REPRESENTATIVE"
    | "BENEFICIAL_OWNER";
  current_status:
    | "DRAFT"
    | "DOCUMENTS_SUBMITTED"
    | "EXTRACTION_IN_PROGRESS"
    | "EXTRACTION_FAILED"
    | "PENDING"
    | "PENDING_REVIEW"
    | "WAITING_FOR_CUSTOMER"
    | "ESCALATED"
    | "SUSPENDED";
  case_priority: "LOW" | "NORMAL" | "HIGH" | "URGENT";
  assigned_team: string;
  assigned_analyst_name?: string | null;
  assigned_analyst_email?: string | null;
  legal_first_name: string;
  legal_last_name: string;
};

export type KycCaseRecord = KycCaseCreateInput & {
  id: string;
  kyc_case_id: string;
  row_version: number;
  created_by: string;
  created_at: string;
  updated_at: string;
};

export async function createKycCase(
  client: KycApiClient,
  input: KycCaseCreateInput
) {
  return client.post<{ principal: string; case: KycCaseRecord }>(
    "/api/v1/kyc-cases",
    input
  );
}
```

Design the form with these rules:

- Let the API generate `kyc_case_id` unless your product already has a stable
  external case ID.
- Do not let users create final states directly.
- Treat duplicate external IDs as recoverable conflicts.
- Treat server-owned response fields as read-only.
- Keep personal data out of analytics and frontend debug logs.

## Step 6: Save Case Sections

Sections let the frontend update one part of the case file at a time. That keeps
forms smaller, autosave easier, and review screens easier to reason about.

```ts
export type KycSectionName =
  | "service_context"
  | "end_user_identity"
  | "contact_verification"
  | "identity_document_verification"
  | "address_verification"
  | "screening"
  | "risk_assessment"
  | "decision"
  | "user_facing_summary"
  | "restricted_compliance_notes";

export async function patchKycSection(
  client: KycApiClient,
  caseId: string,
  sectionName: KycSectionName,
  payload: Record<string, unknown>
) {
  return client.patch<{ principal: string; section: unknown }>(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/sections/${sectionName}`,
    { payload }
  );
}
```

Use section names as product modules:

| Section | Typical screen |
|---|---|
| `end_user_identity` | Identity details and subject profile. |
| `contact_verification` | Email, phone, and contact checks. |
| `identity_document_verification` | Document review status. |
| `address_verification` | Residence and proof-of-address status. |
| `screening` | Screening evidence and match review. |
| `risk_assessment` | Risk rationale and review notes. |
| `user_facing_summary` | Customer-safe explanation. |
| `restricted_compliance_notes` | Internal-only compliance notes. |

The frontend may hide or show sections by role, but backend authorization should
remain the enforcement point.

## Step 7: Generate Report Snapshots

Reports are generated as snapshots. A snapshot is a stable artifact: it has an
identifier, a view type, a hash, and the report payload returned to your UI.

```ts
export type ReportView = "compliance" | "provider_export" | "user_safe";

export async function generateEndUserReport(
  client: KycApiClient,
  caseId: string,
  view: ReportView
) {
  return client.post<{
    principal: string;
    cache_status: "HIT" | "MISS";
    report_snapshot_id: string;
    generated_at: string;
    input_fingerprint: string;
    snapshot_hash: string;
    view_type: "COMPLIANCE" | "PROVIDER_EXPORT" | "USER_SAFE";
    report: unknown;
  }>(`/api/v1/kyc-cases/${encodeURIComponent(caseId)}/reports/end-user-v1`, {
    view,
    generated_by: "frontend-webapp"
  });
}

export async function loadLatestReport(
  client: KycApiClient,
  caseId: string,
  view: ReportView
) {
  return client.get(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/reports/latest?view=${encodeURIComponent(view)}`
  );
}
```

Choose the report view deliberately:

| View | Use it for |
|---|---|
| `user_safe` | Customer portals and support experiences. |
| `provider_export` | Partner or regulated-provider handoff. |
| `compliance` | Authorized internal review workspaces. |

Show snapshot metadata in operator-facing screens:

- `cache_status`
- `report_snapshot_id`
- `snapshot_hash`
- `generated_at`
- `view_type`

Do not expose restricted notes, internal scoring details, or control logic in
customer-facing experiences.

## Step 8: Show Workflow Progress

Some operations take time. Use workflow events to keep users oriented while work
is active.

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

Polling guidance:

- Poll only while active work is visible.
- Start with `after_id=0`.
- Store `next_after_id` after each response.
- Merge events by `event.id`.
- Slow polling when the browser tab is hidden.
- Show warnings and errors as first-class UI states.

Workflow events are a progress feed. They are not the permanent record of the
case. Use the case, report, and audit surfaces for durable review evidence.

## Step 9: Keep Recommendations And Decisions Separate

Regulated products must distinguish generated recommendations from accountable
human decisions. Your UI should make that separation obvious.

```ts
export type ReviewDecisionOutcome =
  | "approved"
  | "rejected"
  | "needs_more_information"
  | "escalated";

export async function submitReviewDecision(
  client: KycApiClient,
  caseId: string,
  body: {
    proposal_id?: string | null;
    decision_outcome: ReviewDecisionOutcome;
    rationale: string;
    decision_payload?: Record<string, unknown>;
    corrections?: Array<Record<string, unknown>>;
  }
) {
  return client.post<{ principal: string; review_decision: unknown }>(
    `/api/v1/kyc-cases/${encodeURIComponent(caseId)}/review-decisions`,
    body
  );
}
```

A good review screen has three separate zones:

| Zone | Purpose |
|---|---|
| Evidence | What the API returned and what the reviewer should inspect. |
| Recommendation | Suggested outcome, rationale, and limitations. |
| Decision | The human action, rationale, and final submission control. |

Do not let an automated recommendation silently become the decision. Require a
clear reviewer action and rationale.

## Step 10: Adapt The API To Your Industry

The same API contract supports different regulated products. The vocabulary
changes, but the integration flow stays stable:

```text
sign in -> create or load case -> save sections -> review evidence -> generate report -> submit decision
```

| Product | How to shape the workflow |
|---|---|
| Bank account onboarding | Create a case after identity capture, save screening and risk sections, generate customer-safe and internal reports, submit the reviewer decision. |
| Lending application review | Attach screening and risk context to the credit workflow, surface warnings, and route uncertain files to manual review. |
| Insurance onboarding | Use quick screening at intake, create durable cases for higher-risk customers, and generate provider-facing summaries. |
| Marketplace seller verification | Create seller cases, save identity and screening sections, show progress events during review, and preserve report snapshots. |
| Periodic customer refresh | Load or create a refresh case, update changed sections, regenerate a report snapshot, and preserve prior evidence. |
| Customer support portal | Show only the customer-safe report view and hide internal evidence, scoring, and restricted notes. |

Build your app around reusable screens:

- Diagnostics
- Search
- Case detail
- Section editor
- Evidence panel
- Report viewer
- Workflow timeline
- Review decision panel

Those screens can be recomposed into many regulated products without changing
the core API client.

## Launch Checklist

Before moving from prototype to production, confirm:

- The API base URL is environment-specific.
- The frontend origin is allowed by the API owner.
- Browser authentication uses a public client flow.
- No private service credential is shipped to the browser.
- Protected requests send `Authorization: Bearer <access_token>`.
- Errors display useful user states and preserve `request_id` for support.
- Quick screening is not presented as final approval.
- Customer screens use customer-safe report views.
- Internal-only sections are hidden from customer-facing routes.
- Human review actions require explicit rationale.
- Personal and regulated data are excluded from analytics and client logs.

## The Core Pattern

When in doubt, return to this integration shape:

```text
configure -> authenticate -> call -> validate -> render -> preserve request_id -> guide the next regulated action
```

That is the frontend discipline that keeps API integrations maintainable across
teams, jurisdictions, and regulated products.
