find . -maxdepth 4 -type f -name "*.md" -exec script/generate.sh {} \; > results.out
