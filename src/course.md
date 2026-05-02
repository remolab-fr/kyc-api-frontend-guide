# Build Regulated Frontend Apps With The KYC API

This course teaches frontend developers how to build real regulated product
workflows on top of the KYC API.

It is written for implementation, not theory. You will build the integration
the way a production team should build it: start with configuration and
diagnostics, add a small typed API client, handle errors as product states, then
compose screening, case management, reports, workflow visibility, and human
review into reusable screens.

The course stays at the public API boundary. You do not need to know how the
platform is implemented internally. You need to know the contract your frontend
can rely on.

## Learning Outcomes

After completing this course, you should be able to:

1. Configure a frontend application for the KYC API without leaking secrets.
2. Build a small TypeScript API client that attaches user tokens and parses
   structured errors.
3. Add an API diagnostics screen that separates connectivity, readiness, and
   authentication problems.
4. Build a quick screening experience that presents evidence without pretending
   to make a final decision.
5. Create a durable case workspace for regulated review.
6. Save case sections one at a time.
7. Generate and display report snapshots with the correct view for the audience.
8. Poll workflow events while work is active.
9. Keep generated recommendations visibly separate from human decisions.
10. Adapt the same integration pattern to onboarding, refresh, lending,
    insurance, marketplace, and support workflows.

## The Mental Model

Think of the KYC API as six frontend-facing capabilities.

| Capability | Frontend responsibility | API responsibility |
|---|---|---|
| Access | Sign in the user and send a short-lived bearer token. | Validate the token and authorize protected requests. |
| Diagnostics | Show whether the API is reachable and ready. | Expose public health and readiness endpoints. |
| Screening evidence | Collect search input and render evidence clearly. | Return screening status, evidence status, limitations, and next steps. |
| Case workspace | Let operators create and update a review file. | Persist durable case records and section updates. |
| Report snapshots | Request the correct report view and display it safely. | Generate immutable report artifacts with snapshot metadata. |
| Human review | Require reviewer action and rationale. | Record accountable review decisions. |

The frontend orchestrates the experience. The API owns the regulated workflow
contract.

## Vocabulary Used In This Course

Use these terms consistently in your code, UI, and documentation.

| Term | Meaning |
|---|---|
| API client | The small frontend module that wraps `fetch`, attaches tokens, and parses errors. |
| Diagnostics | Public health/readiness checks plus authenticated access checks. |
| Quick screening | A lightweight evidence search. It is not a final approval. |
| Case | A durable review file for one customer, seller, borrower, policyholder, or subject. |
| Section | One named part of a case file, saved independently. |
| Report snapshot | A generated report artifact with ID, hash, view, timestamp, and payload. |
| Workflow event | A progress event for active work. It is not the permanent compliance archive. |
| Recommendation | Generated or assisted guidance shown to a reviewer. |
| Decision | The accountable human action submitted by an authorized reviewer. |

The API uses some technical parameter names, such as `include_web_search`. Your
UI can label the same control "evidence search" if that is clearer for users.

## Prerequisites

Before implementation, get these values from the API owner:

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

Use the target application's environment convention. In a Vite application, the
public variables usually look like this:

```text
VITE_KYC_API_BASE_URL=https://api.example.com
VITE_AUTH_ISSUER=https://identity.example.com
VITE_AUTH_CLIENT_ID=public-browser-client-id
VITE_AUTH_REDIRECT_URI=http://localhost:5173/auth/callback
VITE_AUTH_POST_LOGOUT_REDIRECT_URI=http://localhost:5173/
VITE_AUTH_AUDIENCE_SCOPE=api-audience-scope
```

Never ship private credentials to the browser. The frontend may contain public
configuration. It must not contain service credentials, private keys, backend
secrets, database URLs, provider credentials, or long-lived bearer tokens.

## Course Path

Build the integration in this order:

1. Draw the public integration boundary.
2. Create a typed API client.
3. Add diagnostics.
4. Treat API errors as product states.
5. Build quick screening.
6. Create durable cases.
7. Save case sections.
8. Generate report snapshots.
9. Poll workflow events.
10. Submit human review decisions.
11. Adapt the flow to your product.
12. Run the launch checklist.

Each module has a practical checkpoint. Do not skip the checkpoints; they catch
integration mistakes before they become product bugs.

## How To Use This Course

Use the course as a sequence of small implementation loops:

1. Read the goal of the module.
2. Copy or adapt the code shape.
3. Build the smallest visible screen or client method.
4. Run the checkpoint.
5. Stop or continue to the next module.

Do not try to build every screen at once. The fastest path is one stable layer
at a time:

```text
configuration -> API client -> diagnostics -> errors -> screening -> cases -> reports -> review
```

Each module has one main job. If you lose context, return to the module title,
the checkpoint, and the final teaching pattern at the end of the course.

## Module 1: Draw The Integration Boundary

A strong frontend integration starts by deciding what the frontend should know.

Your frontend should know:

- Which base URL to call.
- How to get the current user's access token.
- Which endpoints create, read, or update workflow resources.
- Which response fields are safe to render.
- Which errors are recoverable by the user.
- Which errors require support handoff.

Your frontend should not know:

- Internal hosting choices.
- Internal storage design.
- Internal model, scoring, or routing implementation.
- Private service credentials.
- Operator-only tools.
- Secret-bearing smoke-test scripts.

Checkpoint:

- You can explain which values are public configuration and which values must
  stay server-side.
- Your environment files do not contain private credentials.
- Your UI language does not promise that quick screening equals final approval.

## Module 2: Create The API Client

Start with one small API client. Keep it independent from UI components so every
screen uses the same request, auth, and error behavior.

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

Create one instance at the app boundary:

```ts
export const kycApi = new KycApiClient({
  baseUrl: import.meta.env.VITE_KYC_API_BASE_URL,
  getAccessToken
});
```

Checkpoint:

- All API calls use the same client.
- Protected requests attach `Authorization: Bearer <access_token>`.
- Non-2xx responses throw `KycApiError`.
- `request_id` is available for support handoff.

## Module 3: Add Diagnostics First

Add a diagnostics screen before building product screens. It should answer four
questions:

- Can the browser reach the API?
- Is the API ready to handle work?
- Is the user signed in?
- Can a protected endpoint be called with the current token?

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

Suggested UI states:

| State | Meaning | User action |
|---|---|---|
| Reachable | Browser can call public API endpoints. | Continue setup. |
| Not reachable | Network, base URL, CORS, or DNS may be wrong. | Check API base URL and frontend origin. |
| Ready | API reports it can handle work. | Continue product flow. |
| Degraded | API is reachable but not fully ready. | Show diagnostics and retry later. |
| Authenticated | User token is present and accepted. | Enable protected flows. |
| Unauthorized | Token is missing, expired, or invalid. | Sign in again. |

Checkpoint:

- A developer can diagnose base URL, readiness, and auth problems without
  opening browser devtools.

## Module 4: Treat Errors As Product States

Regulated applications should not collapse every API failure into "Something
went wrong." Structured errors are part of the product contract.

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

Use the status to drive clear UI behavior:

| Status | UI behavior |
|---:|---|
| 400 | Show field or form validation. Use `details.field` when present. |
| 401 | Refresh login or redirect to sign in. |
| 404 | Show missing resource state and route back to a safe page. |
| 409 | Offer to load the existing case or create a new external identifier. |
| 503 | Show degraded service, retry later, and include `request_id` in support details. |

Checkpoint:

- Field errors appear near the relevant form input.
- Authentication errors do not look like data-entry errors.
- Conflict errors give the operator a recoverable path.
- Support details include `request_id`.

## Module 5: Build Quick Screening

Quick screening is the lightweight evidence flow. Use it when an operator needs
a first pass before opening a durable case.

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

Teach the UI to present evidence, not a verdict:

- Show the subject and generated timestamp.
- Show overall status and risk level.
- Show screening status separately from evidence-search status.
- Show limitations near the summary.
- Show query-level failures when evidence is partial.
- Never turn quick screening into a final approval action.

Checkpoint:

- A user can understand what was checked, what was degraded, and what should
  happen next.
- No quick-screening result is labeled as final approval.

## Module 6: Create Durable Cases

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

Form rules:

- Let the API generate `kyc_case_id` unless your product owns a stable external
  case ID.
- Do not let users create final states directly.
- Treat duplicate external IDs as recoverable conflicts.
- Treat server-owned response fields as read-only.
- Keep personal data out of analytics and frontend debug logs.

Checkpoint:

- Creating a case routes the user into a case workspace.
- Server-owned fields are displayed but not edited.
- A duplicate external ID shows a conflict path, not a crash.

## Module 7: Save Case Sections

Sections let the frontend update one part of the case file at a time. They make
forms smaller, autosave safer, and review screens easier to reason about.

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

Checkpoint:

- A section save updates only that part of the case.
- Restricted sections are hidden from customer-facing routes.
- Frontend role gating improves usability, while backend authorization remains
  the enforcement point.

## Module 8: Generate Report Snapshots

Reports are generated as snapshots. A snapshot is a stable artifact with an ID,
view type, hash, timestamp, and report payload.

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

Checkpoint:

- Customer routes use `user_safe`.
- Internal review routes can show snapshot metadata.
- Restricted notes, internal scoring details, and control logic do not appear
  in customer-facing experiences.

## Module 9: Show Workflow Progress

Some operations take time. Workflow events keep users oriented while work is
active.

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

Checkpoint:

- Event polling does not create duplicates.
- Warning and error events are visible.
- The UI treats workflow events as progress, not permanent compliance history.

## Module 10: Submit Human Review Decisions

Regulated products must distinguish generated recommendations from accountable
human decisions.

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

A good review screen has three zones:

| Zone | Purpose |
|---|---|
| Evidence | What the API returned and what the reviewer should inspect. |
| Recommendation | Suggested outcome, rationale, and limitations. |
| Decision | The human action, rationale, and final submission control. |

Checkpoint:

- Recommendation and decision are visually separate.
- The final decision requires a reviewer action.
- The decision form requires rationale.
- `needs_more_information` is treated as workflow state, not a technical error.

## Module 11: Adapt The Flow To Your Product

The vocabulary changes by industry, but the integration flow stays stable:

```text
configure -> authenticate -> call -> validate -> render -> preserve request_id -> guide the next regulated action
```

| Product | How to shape the workflow |
|---|---|
| Bank account onboarding | Create a case after identity capture, save screening and risk sections, generate customer-safe and internal reports, submit the reviewer decision. |
| Lending application review | Attach screening and risk context to the credit workflow, surface warnings, and route uncertain files to manual review. |
| Insurance onboarding | Use quick screening at intake, create durable cases for higher-risk customers, and generate provider-facing summaries. |
| Marketplace seller verification | Create seller cases, save identity and screening sections, show progress events during review, and preserve report snapshots. |
| Periodic customer refresh | Load or create a refresh case, update changed sections, regenerate a report snapshot, and preserve prior evidence. |
| Customer support portal | Show only the customer-safe report view and hide internal evidence, scoring, and restricted notes. |

Reusable screens:

- Diagnostics
- Search
- Case detail
- Section editor
- Evidence panel
- Report viewer
- Workflow timeline
- Review decision panel

Checkpoint:

- Your product uses domain-specific labels, but the underlying API flow remains
  consistent.

## Module 12: Launch Checklist

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
- The application has tests for diagnostics, auth failures, validation errors,
  conflict errors, quick screening, case creation, report generation, workflow
  polling, and review decision submission.

## Final Teaching Pattern

Use this sequence when coaching a frontend team:

1. Prove the API is reachable.
2. Prove authentication works.
3. Prove structured errors are useful.
4. Render evidence without making a decision.
5. Persist the case.
6. Save one section at a time.
7. Generate the right report view.
8. Show progress while work is active.
9. Require an accountable human decision.
10. Verify the customer-facing view hides restricted data.

That sequence turns an API integration into a reliable product workflow.
