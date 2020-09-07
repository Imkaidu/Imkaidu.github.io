#!/bin/bash

target="index"
if [ -n "$1" ]; then
  target=$1
fi

root="/Users/uqkdu1/Dropbox/Imkaidu.github.io"

cd "${root}"

# Web
pandoc "${target}" \
    -o "${target%.*}.html" \
    --template default.html \
    --highlight-style haddock \
    --standalone \
    --toc \
    --toc-depth=3 \
    --css "/css/custom.css" \
    --katex

# PDF
pandoc "${target}" \
    -o "${target%.*}.pdf" \
    -H "${root}/header/latex.tex" \
    --resource-path="$(dirname "$target")" \
    --template default.tex \
    --highlight-style haddock \
    --shift-heading=-1

# Slides
pandoc "${target}" \
    -t beamer \
    -s \
    --pdf-engine=pdflatex \
    --highlight-style haddock \
    --resource-path="$(dirname "$target")" \
    -o "${target%.*}-slides.pdf" \