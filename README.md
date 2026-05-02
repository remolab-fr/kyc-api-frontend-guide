# KYC API Frontend Guide

A public mdBook course for frontend engineers building regulated onboarding,
due diligence, case review, customer refresh, and compliance operations
applications on top of the KYC API.

The guide is organized as topic-based documentation: every page can work as a
direct entry point while still supporting a complete course path.

## Read The Course

The course is published at:

https://remolab-fr.github.io/kyc-api-frontend-guide/

## For LLM Coding Agents

Use [`LLM.txt`](./LLM.txt) as the machine-readable implementation contract. It
contains the endpoint plan, security rules, TypeScript client shape, UI feature
scope, verification checklist, and done definition for autonomous frontend
implementation work.

The public site also serves the same contract at:

- `https://remolab-fr.github.io/kyc-api-frontend-guide/LLM.txt`
- `https://remolab-fr.github.io/kyc-api-frontend-guide/llm.txt`

## Local Development

Install mdBook, then run:

```bash
mdbook serve --open
```

Build the static site:

```bash
mdbook build
```

Run the same local validation used by CI:

```bash
bash scripts/validate-public-guide.sh
```

The generated `book/` directory is ignored and should not be committed.

## Content Structure

- `src/course.md` is the course map.
- `src/big-picture.md` explains the overall product model.
- `src/workflows/` contains end-to-end product paths.
- `src/foundations/` contains reusable API, auth, config, error, and vocabulary contracts.
- `src/tasks/` contains focused implementation topics.
- `src/quality/` contains accessibility, audit, test, and launch gates.
- `LLM.txt` is the root machine-readable implementation contract.

## Public-Safe Boundary

This repository is public. Do not commit:

- Service-account keys.
- Private keys.
- Access tokens.
- Database URLs.
- Backend provider secrets.
- Private deployment values.
- Raw regulated customer data.

Use placeholders in examples and keep deployment-specific values in the target
application environment.
