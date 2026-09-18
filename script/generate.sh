#!/bin/bash

target="index"
if [ -n "$1" ]; then
  target=$1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${root}"

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
    --katex

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
    --shift-heading=-1

# Slides
pandoc "${target}" \
    -t beamer \
    -s \
    --pdf-engine=pdflatex \
    -H "${root}/header/unicode-chars.tex" \
    --highlight-style haddock \
    --resource-path="$(dirname "$target")" \
    -o "${target%.*}-slides.pdf"