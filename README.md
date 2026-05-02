# KYC API Frontend Guide

A public mdBook course for frontend engineers building regulated onboarding,
due diligence, case review, customer refresh, and compliance operations
applications on top of the KYC API.

## Read The Course

After GitHub Pages is enabled for this repository, the course is published at:

https://remolab-fr.github.io/kyc-api-frontend-guide/

## For LLM Coding Agents

Use [`LLM.txt`](./LLM.txt) as the machine-readable implementation contract. It
contains the endpoint plan, security rules, TypeScript client shape, UI feature
scope, verification checklist, and done definition for autonomous frontend
implementation work.

## Local Development

Install mdBook, then run:

```bash
mdbook serve --open
```

Build the static site:

```bash
mdbook build
```

The generated `book/` directory is ignored and should not be committed.

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
