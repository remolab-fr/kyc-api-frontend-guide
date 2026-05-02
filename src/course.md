# Course Map

This course teaches frontend teams how to build regulated product workflows on
top of the KYC API.

The course is now organized as topic pages. You can read it from start to
finish, but you do not have to. Each page gives enough context to work on that
topic directly, then links to the pages that naturally come before or after it.

## What You Will Be Able To Build

After working through the course, you should be able to:

1. Configure a browser application without leaking secrets.
2. Build a typed TypeScript client for protected KYC API calls.
3. Diagnose connectivity, readiness, and authentication problems.
4. Render API errors as useful product states.
5. Build quick screening as evidence, not a final decision.
6. Create durable case workspaces.
7. Save one case section at a time.
8. Generate and read report snapshots.
9. Display workflow progress without treating events as the compliance archive.
10. Keep generated recommendations separate from human review decisions.
11. Adapt the same integration pattern to banks, fintechs, insurers, lenders,
    marketplaces, and other regulated products.

## Start Here

Use these pages first:

- [Big Picture](big-picture.md) explains the product architecture and the
  learning path.
- [Integration Boundary](foundations/integration-boundary.md) defines what the
  frontend should and should not know.
- [Environment Configuration](foundations/environment-config.md) lists the
  public configuration values a frontend app needs.
- [API Client](foundations/api-client.md) gives the reusable TypeScript request
  wrapper used by every screen.

## Choose A Workflow

If you are building a concrete product surface, start with one workflow:

| Goal | Start with |
|---|---|
| Show API status and user access | [Read-Only Dashboard](workflows/read-only-dashboard.md) |
| Collect user or applicant details | [Case Intake Form](workflows/case-intake-form.md) |
| Support analyst or reviewer work | [Reviewer Workspace](workflows/reviewer-workspace.md) |
| Prepare a regulated frontend for release | [Launch-Ready Frontend](workflows/launch-ready-frontend.md) |

Each workflow links to smaller task pages instead of repeating the same
implementation guidance.

## Topic Types

The course uses predictable topic types:

| Topic type | Purpose |
|---|---|
| Big picture | Explains the full system and how the pages fit together. |
| Workflow | Shows an end-to-end product path and links to task pages. |
| Foundation | Establishes a reusable boundary, type, client, or state model. |
| Task | Builds one API-backed feature. |
| Quality | Verifies accessibility, audit readiness, tests, and launch safety. |

## How To Use A Topic Page

Every implementation page follows the same rhythm:

1. **Use this when** tells you whether the page matches your problem.
2. **What you will build** defines the visible outcome.
3. **What must already be true** lists the prerequisites.
4. **API contract** names the endpoint or data shape.
5. **UI states** turns API behavior into product behavior.
6. **Implementation steps** gives the build sequence.
7. **Checkpoint** gives a clear stopping point.
8. **Common mistakes** prevents predictable integration bugs.
9. **Related pages** points to adjacent work.

This keeps each page useful when reached from search, a teammate's link, or an
LLM coding agent.

## Stable Implementation Order

When in doubt, build in this order:

```text
configuration -> API client -> diagnostics -> errors -> screening -> cases -> reports -> review
```

Do not build every screen at once. Finish one visible layer, run its checkpoint,
then move to the next layer.

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
