#!/usr/bin/env bash
# Pre-publish check for packages that are public on GitHub (per push_all.sh's
# last run, re-verified with gh). For each: `flutter pub publish --dry-run` and
# pana's pub-points score. Everything goes into one file, summary on top.
# Nothing is published.
# Usage: tools/prepublish_all.sh [pkg ...]   (default: all packages, alphabetical)
cd "$(dirname "$0")/.." || exit 1
OUT=tools/prepublish_report.txt
LOG=tools/push_all.log
# Merged into iranshahr_plate; not published on their own.
SKIP=" kazakhstan_plate turkmenistan_plate uzbekistan_plate plate_number_holder "

pkgs=("$@")
if [ ${#pkgs[@]} -eq 0 ]; then
  # Every package directory, alphabetical; publish_to: none and non-public
  # repos are filtered out below.
  for f in */pubspec.yaml; do pkgs+=("${f%/pubspec.yaml}"); done
fi

if command -v pana >/dev/null 2>&1; then PANA=(pana)
elif dart pub global list 2>/dev/null | grep -q '^pana '; then PANA=(dart pub global run pana)
else PANA=(); echo "pana not found (dart pub global activate pana): scores will be n/a"; fi

# 0 = public or unknown, 1 = private/missing. A network hiccup must not read as
# "private": retry gh, fall back to plain HTTP, and when both fail run the check.
is_public(){
  local slug v code i
  slug=$(git -C "$1" remote get-url origin 2>/dev/null | sed -E 's#(\.git)?/?$##; s#.*github.com[:/]##')
  [ -n "$slug" ] || return 1
  for i in 1 2 3; do
    v=$(gh repo view "$slug" --json isPrivate -q .isPrivate 2>/dev/null)
    case "$v" in false) return 0;; true) return 1;; esac
  done
  for i in 1 2 3; do
    code=$(curl -s -o /dev/null -w '%{http_code}' "https://github.com/$slug")
    case "$code" in 200) return 0;; 404) return 1;; esac
  done
  return 0
}

body=$(mktemp); sum=$(mktemp)
for d in "${pkgs[@]}"; do
  case "$SKIP" in *" $d "*) continue;; esac
  [ -f "$d/pubspec.yaml" ] || continue
  if grep -qE '^publish_to:[[:space:]]*.?none' "$d/pubspec.yaml"; then
    printf '%-40s %s\n' "$d" "publish_to: none, skipped" >> "$sum"; continue
  fi
  if ! is_public "$d"; then printf '%-40s %s\n' "$d" "not public on GitHub, skipped" >> "$sum"; continue; fi
  echo "running: $d"
  { echo; echo "################ $d ################"; echo "--- flutter pub publish --dry-run"; } >> "$body"
  (cd "$d" && flutter pub publish --dry-run >> "$body" 2>&1)
  rc=$?
  case $rc in 0) s="OK";; 65) s="WARNINGS";; *) s="ERRORS(exit $rc)";; esac

  score="n/a"
  if [ ${#PANA[@]} -gt 0 ]; then
    echo "--- pana" >> "$body"
    rep=$(mktemp)
    "${PANA[@]}" --no-warning "$d" > "$rep" 2>>"$body"
    cat "$rep" >> "$body"
    score=$(sed -n 's/^Points: \([0-9]*\/[0-9]*\)\..*/\1/p' "$rep" | tail -1)
    [ -n "$score" ] || score="n/a (pana failed, see report)"
    rm -f "$rep"
  fi
  printf '%-40s dry-run: %-16s points: %s\n' "$d" "$s" "$score" >> "$sum"
  echo "  $s, $score"
done

{
  echo "Pre-publish report $(date)"
  echo
  echo "SUMMARY"
  cat "$sum"
  cat "$body"
} > "$OUT"
rm -f "$body" "$sum"
echo "Saved: $OUT"
