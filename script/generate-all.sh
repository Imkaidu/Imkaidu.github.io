#!/bin/bash
#
# Rebuild every published page, then the blog index, feed and sitemap.
#
# Exclusions matter: this globs *.md, so without them it would render the
# repo's own documentation into public pages at the site root (AGENTS.html,
# CLAUDE.html) and leave build artefacts inside the untracked private/ notes
# directory.
#
# Add a page here only if it is meant to be public.
#
# Full output goes to results.out (untracked). Failures are also printed here
# and the script exits 1 if any page or the index step failed, so a broken
# build cannot be mistaken for a clean one before `git push`.

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1

: > results.out
failures=0

# Index/feed/sitemap first: blog/blog.md is itself one of the pages built below.
if ! python3 script/build-index.py >> results.out 2>&1; then
  echo "FAILED: script/build-index.py (see results.out)" >&2
  failures=$((failures + 1))
fi

while IFS= read -r -d '' md; do
  if ! script/generate.sh "$md" >> results.out 2>&1; then
    echo "FAILED: $md (see results.out)" >&2
    failures=$((failures + 1))
  fi
done < <(find . -maxdepth 4 -type f -name "*.md" \
  -not -path "./private/*" \
  -not -name "AGENTS.md" \
  -not -name "CLAUDE.md" \
  -not -name "README.md" \
  -print0)

if [ "${failures}" -gt 0 ]; then
  echo "${failures} build step(s) failed -- do not push until fixed." >&2
  exit 1
fi
echo "All pages built; index, feed and sitemap up to date."
