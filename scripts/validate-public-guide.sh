#!/usr/bin/env bash
set -euo pipefail

content_targets=("README.md" "LLM.txt" "src")
repo_targets=("README.md" "LLM.txt" "book.toml" ".github/workflows/pages.yml" "scripts" "src")

mdbook build
cp LLM.txt book/LLM.txt
cp LLM.txt book/llm.txt
touch book/.nojekyll

git diff --check

if grep -R -n -E '[[:blank:]]$' "${repo_targets[@]}"; then
  echo "Found trailing whitespace." >&2
  exit 1
fi

if grep -R -n -E 'ADHD|AHDH|attention disorder|neurodivergent|neurodivers' "${content_targets[@]}"; then
  echo "Found disallowed attention-related wording." >&2
  exit 1
fi

if grep -R -n -E 'BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|service[-_ ]?account key|DATABASE_URL=|PASSWORD=|SECRET=|TOKEN=|API_KEY=' "${content_targets[@]}"; then
  echo "Found secret-shaped content in public guide sources." >&2
  exit 1
fi

echo "Public guide validation passed."
