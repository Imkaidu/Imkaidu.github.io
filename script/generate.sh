#!/bin/bash
#
# Build one page into .html, .pdf and -slides.pdf.
#
# Every format is attempted, but a failure is no longer silent: a pandoc error
# used to leave the previously committed output in place with no warning, so a
# page could look rebuilt while its PDF was a stale copy. Each failure is now
# reported on stderr and the script exits 1 -- the stale file is NOT deleted
# (it may be the only copy of a committed output), so fix the cause and rebuild.

target="index"
if [ -n "$1" ]; then
  target=$1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${root}"

failed=0
fail() {
  echo "FAILED: ${target%.*}$1 -- the existing file, if any, is stale" >&2
  failed=1
}

# Web
# --wrap=none keeps one paragraph per source line, so a future content edit
# shows up as a small diff instead of a full reflow of the paragraph.
pandoc "${target}" \
    -o "${target%.*}.html" \
    --template "${root}/templates/default.html" \
    --highlight-style haddock \
    --standalone \
    --wrap=none \
    --toc \
    --toc-depth=3 \
    --css "/css/custom.css" \
    --katex || fail ".html"

# `nopdf: true` in a page's front matter skips the PDF and the slides, for a
# page whose source cannot yet be typeset (it must be left out explicitly, not
# fail silently -- see the header comment).
nopdf=0
if awk 'NR==1 && /^---/ {fm=1; next} fm && /^---/ {exit} fm && /^nopdf: *true/ {found=1; exit} END {exit !found}' "${target}"; then
  nopdf=1
fi
if [ "${nopdf}" -eq 1 ]; then
  echo "skipped PDF and slides for ${target} (nopdf: true)"
  exit "${failed}"
fi

# PDF
# Unicode character fallbacks are defined inline in templates/default.tex,
# not via -H here: that template has no $header-includes$ placeholder, so
# -H content is silently dropped for this build. See header/unicode-chars.tex.
pandoc "${target}" \
    -o "${target%.*}.pdf" \
    -H "${root}/header/latex.tex" \
    --resource-path="$(dirname "$target")" \
    --template="${root}/templates/default.tex" \
    --highlight-style haddock \
    --shift-heading=-1 || fail ".pdf"

# Slides
pandoc "${target}" \
    -t beamer \
    -s \
    --pdf-engine=pdflatex \
    -H "${root}/header/unicode-chars.tex" \
    --highlight-style haddock \
    --resource-path="$(dirname "$target")" \
    -o "${target%.*}-slides.pdf" || fail "-slides.pdf"

exit "${failed}"
