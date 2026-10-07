#!/usr/bin/env bash
# Fails when two current ADRs share a number or an ADR sits outside the decisions folder.
set -euo pipefail

ADR_DIR="docs/architecture/decisions"

stray=$(find . -path ./.git -prune -o -path ./node_modules -prune -o -type f -name 'ADR-[0-9]*.md' -print \
  | grep -v "^\./${ADR_DIR}/" || true)
if [ -n "$stray" ]; then
  echo "ADRs must live in ${ADR_DIR}/ (superseded texts in ${ADR_DIR}/superseded/):"
  echo "$stray"
  exit 1
fi

dupes=$(find "$ADR_DIR" -maxdepth 1 -type f -name 'ADR-[0-9]*.md' -printf '%f\n' \
  | grep -oE '^ADR-[0-9]+' | sort | uniq -d)
if [ -n "$dupes" ]; then
  echo "Duplicate ADR numbers in ${ADR_DIR}/:"
  for n in $dupes; do ls "$ADR_DIR"/"$n"-*.md; done
  exit 1
fi

for f in "$ADR_DIR"/ADR-[0-9]*.md; do
  num=$(basename "$f" | grep -oE '^ADR-[0-9]+')
  if ! grep -m1 '^# ' "$f" | grep -q "^# ${num}:"; then
    echo "$f: first heading must start with '# ${num}:'"
    exit 1
  fi
done

echo "ADR numbering OK ($(ls "$ADR_DIR"/ADR-[0-9]*.md | wc -l) decisions)."
