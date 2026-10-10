#!/usr/bin/env bash
# Per package repo: merge other local branches into main, push, create the GitHub
# repo if there is no origin, and make it public. Log: tools/push_all.log
# Usage: tools/push_all.sh [--commit] [pkg ...]
#   --commit  commit uncommitted changes ("Update <pkg>") before merging/pushing
cd "$(dirname "$0")/.." || exit 1
export GIT_TERMINAL_PROMPT=0
OWNER=ArAd1Beyranvand
# Merged into iranshahr_plate (no repo/pub of their own) plus the demo app.
SKIP=" plate_number_holder kazakhstan_plate turkmenistan_plate uzbekistan_plate "
LOG=tools/push_all.log
COMMIT=0
[ "$1" = "--commit" ] && { COMMIT=1; shift; }
pkgs=("$@")
[ ${#pkgs[@]} -eq 0 ] && pkgs=($(for d in */; do d=${d%/}; [ -f "$d/pubspec.yaml" ] && echo "$d"; done))

: > "$LOG"
say(){ echo "$*" | tee -a "$LOG"; }
res=()

for d in "${pkgs[@]}"; do
  say ""; say "=== $d"
  case "$SKIP" in *" $d "*) say "skip (excluded)"; res+=("$d|skipped"); continue;; esac
  if [ ! -e "$d/.git" ]; then say "no git repo (run git init first)"; res+=("$d|NO GIT"); continue; fi
  g=(git -C "$d")

  if [ -n "$("${g[@]}" status --short)" ]; then
    if [ $COMMIT -eq 1 ]; then
      "${g[@]}" add -A && "${g[@]}" commit -qm "Update $d" && say "committed local changes"
    else
      say "uncommitted changes, not committing (use --commit)"
    fi
  fi

  cur=$("${g[@]}" branch --show-current)
  if ! "${g[@]}" show-ref -q --verify refs/heads/main; then
    if [ "$cur" = master ]; then "${g[@]}" branch -m master main && say "renamed master -> main"
    else say "no main branch (on $cur), skipping"; res+=("$d|no main"); continue; fi
  fi
  if [ "$cur" != main ] && ! "${g[@]}" checkout -q main; then
    say "cannot checkout main (dirty tree?)"; res+=("$d|checkout failed"); continue
  fi

  bad=0
  for b in $("${g[@]}" for-each-ref --format='%(refname:short)' refs/heads | grep -vx main); do
    if [ "$("${g[@]}" rev-list --count main..$b)" -gt 0 ]; then
      if "${g[@]}" merge -q --no-edit "$b" >>"$LOG" 2>&1; then say "merged $b into main"
      else "${g[@]}" merge --abort; say "MERGE CONFLICT with $b, aborted"; bad=1; fi
    fi
  done
  [ $bad -eq 1 ] && { res+=("$d|merge conflict"); continue; }

  if "${g[@]}" remote get-url origin >/dev/null 2>&1; then
    slug=$("${g[@]}" remote get-url origin | sed -E 's#(\.git)?/?$##; s#.*github.com[:/]##')
  else
    slug="$OWNER/$d"
    "${g[@]}" remote add origin "https://github.com/$slug.git"
    say "added origin $slug"
  fi

  if gh repo view "$slug" >/dev/null 2>&1; then
    say "github repo exists: $slug"
  elif gh repo create "$slug" --public >>"$LOG" 2>&1; then
    say "created github repo: $slug"
  else
    res+=("$d|create FAILED"); say "gh repo create failed (see log)"; continue
  fi

  "${g[@]}" config http.postBuffer 524288000
  ok=0
  for try in 1 2 3; do
    if "${g[@]}" push -u origin main >>"$LOG" 2>&1; then ok=1; break; fi
    say "push attempt $try failed"; sleep 3
  done
  [ $ok -eq 1 ] || { res+=("$d|push FAILED"); say "push failed (see log)"; continue; }
  say "pushed main"

  if [ "$(gh repo view "$slug" --json isPrivate -q .isPrivate 2>>"$LOG")" = true ]; then
    if gh repo edit "$slug" --visibility public >>"$LOG" 2>&1; then say "made public: $slug"; res+=("$d|pushed+made public")
    else res+=("$d|visibility FAILED"); say "could not set public: $slug"; fi
  else
    say "already public: $slug"; res+=("$d|pushed (public)")
  fi
done

say ""; say "=== SUMMARY"
for r in "${res[@]}"; do printf '%-40s %s\n' "${r%%|*}" "${r#*|}" | tee -a "$LOG"; done
