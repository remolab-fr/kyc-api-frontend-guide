#!/usr/bin/env bash
set -euo pipefail

content_targets=("README.md" "LLM.txt" "src")
repo_targets=("README.md" "LLM.txt" "book.toml" ".github/workflows/pages.yml" "scripts" "src")
build_timestamp="${PUBLIC_GUIDE_BUILD_TIMESTAMP:-$(date -u '+%Y-%m-%dT%H:%M:%SZ')}"
build_commit="${PUBLIC_GUIDE_BUILD_COMMIT:-$(git rev-parse --short HEAD 2>/dev/null || echo unknown)}"

mdbook build
python3 scripts/stamp-build-metadata.py \
  --book-dir book \
  --timestamp "$build_timestamp" \
  --commit "$build_commit"
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
