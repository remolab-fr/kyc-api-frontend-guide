# KYC API Frontend Guide

This public course helps frontend teams build regulated onboarding, due
diligence, case review, customer refresh, and compliance operations products on
top of the KYC API.

The course is written for implementation. It teaches the browser-safe API
contract, the screens to build, the product states to handle, and the security
boundaries a frontend team must preserve.

The structure is deliberately incremental: each topic has one job, one visible
outcome, and a checkpoint before the next topic. You can follow the course from
the beginning, or you can enter through the page that matches the screen you are
building today.

## Who This Is For

- Frontend engineers integrating a KYC or due diligence API.
- Product engineers building onboarding or review workflows.
- Technical leads coaching a team through regulated API integration.
- LLM coding agents that need a precise implementation contract.

## What You Will Learn

- How the frontend-facing API capabilities fit together.
- How to configure the API boundary without leaking secrets.
- How to build a typed API client.
- How to add diagnostics before product screens.
- How to treat API errors as product states.
- How to render quick screening evidence.
- How to create and update durable case workspaces.
- How to generate report snapshots.
- How to poll workflow events.
- How to keep recommendations separate from human decisions.
- How to adapt the same integration pattern to banks, fintechs, insurers,
  marketplaces, lenders, and other regulated products.

## How The Course Is Organized

- [Course Map](course.md) gives the recommended learning path.
- [Big Picture](big-picture.md) explains the system model.
- Workflow pages show complete product paths.
- Foundation pages define reusable contracts.
- Task pages build one API-backed feature at a time.
- Quality pages verify accessibility, audit readiness, tests, and launch safety.

## Public-Safe Scope

This guide intentionally avoids internal implementation details. It focuses on
the public frontend contract: endpoints, request shapes, response states,
security rules, and user experience patterns.

For autonomous implementation, see the [LLM Coder Agent Contract](llm-agent-contract.md).
