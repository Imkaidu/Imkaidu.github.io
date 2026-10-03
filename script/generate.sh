#!/bin/bash
#
# Build one page into .html and .pdf, and -slides.pdf only when asked.
#
# Every format is attempted, but a failure is no longer silent: a pandoc error
# used to leave the previously committed output in place with no warning, so a
# page could look rebuilt while its PDF was a stale copy. Each failure is now
# reported on stderr and the script exits 1 -- the stale file is NOT deleted
# (it may be the only copy of a committed output), so fix the cause and rebuild.
#
# Front-matter switches (read from the page's own YAML block):
#   slides: true   also build <page>-slides.pdf (off by default: a beamer deck
#                  of a blog post or CV page is rarely wanted and bloats the repo)
#   nopdf: true    skip the PDF (and slides) for a page that cannot be typeset

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

# frontmatter_flag NAME -> exit 0 if the page's YAML front matter has `NAME: true`.
frontmatter_flag() {
  awk -v key="$1" '
    NR==1 && /^---/ {fm=1; next}
    fm && /^---/ {exit}
    fm && $0 ~ "^" key ": *true" {found=1; exit}
    END {exit !found}' "${target}"
}

# Canonical URL for <link rel=canonical> and og:url (absolute by requirement).
rel="${target#./}"
if [ "${rel}" = "index.md" ]; then
  url="https://imkaidu.net/"
else
  url="https://imkaidu.net/${rel%.*}.html"
fi

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
    -V "url=${url}" \
    --katex || fail ".html"

if frontmatter_flag nopdf; then
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

# Slides (opt-in)
if frontmatter_flag slides; then
  pandoc "${target}" \
      -t beamer \
      -s \
      --pdf-engine=pdflatex \
      -H "${root}/header/unicode-chars.tex" \
      --highlight-style haddock \
      --resource-path="$(dirname "$target")" \
      -o "${target%.*}-slides.pdf" || fail "-slides.pdf"
fi

exit "${failed}"
