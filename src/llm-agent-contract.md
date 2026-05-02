# LLM Coder Agent Contract

The repository includes a root [`LLM.txt`](LLM.txt) file for coding agents.
It is a plain-text implementation contract that describes:

- Mission and operating mode.
- Security rules.
- Required configuration inputs.
- API endpoint contracts.
- TypeScript client shape.
- Error handling.
- Feature plan.
- Testing and verification.
- Forbidden shortcuts.
- Done definition.

Use it when asking an autonomous coding agent to implement a frontend
application against the KYC API.

## Course Pages For Agents

Use these pages to orient an implementation:

- [Course Map](course.md) for the stable build order.
- [Big Picture](big-picture.md) for the product architecture.
- [Integration Boundary](foundations/integration-boundary.md) for browser-safe
  security rules.
- [API Client](foundations/api-client.md) for the shared request wrapper.
- [Error States](foundations/error-states.md) for UI failure handling.
- [Testing Checklist](quality/testing-checklist.md) for verification scenarios.
- [Launch Checklist](quality/launch-checklist.md) for final release gates.
