#!/bin/bash
#
# Rebuild every published page. Exclusions matter: this globs *.md, so without
# them it would render the repo's own documentation into public pages at the
# site root (AGENTS.html, CLAUDE.html) and leave build artefacts inside the
# untracked private/ notes directory.
#
# Add a page here only if it is meant to be public.

find . -maxdepth 4 -type f -name "*.md" \
  -not -path "./private/*" \
  -not -name "AGENTS.md" \
  -not -name "CLAUDE.md" \
  -not -name "README.md" \
  -exec script/generate.sh {} \; > results.out
