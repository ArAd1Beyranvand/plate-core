#!/usr/bin/env bash
# Per package: git repo? GitHub repo exists? HEAD pushed? published on pub.dev?
# Verbose: logs every check as it runs, then prints a summary table.
cd "$(dirname "$0")/.." || exit 1
export GIT_TERMINAL_PROMPT=0
G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'
log(){ printf "  ${D}%s${N}\n" "$*"; }
cell(){ printf "%s%-9s%s" "$1" "$2" "$N"; }

rows=()
total=$(ls -d */ | while read -r d; do [ -f "$d/pubspec.yaml" ] && echo; done | wc -l)
i=0
for d in */; do
  d=${d%/}; [ -f "$d/pubspec.yaml" ] || continue
  i=$((i+1))
  name=$(sed -n 's/^name:[[:space:]]*//p' "$d/pubspec.yaml" | head -1)
  ver=$(sed -n 's/^version:[[:space:]]*//p' "$d/pubspec.yaml" | head -1)
  printf "\n${B}[%d/%d] %s${N} (pkg=%s, local version=%s)\n" "$i" "$total" "$d" "$name" "$ver"
  lg=no; gh=no; pushed=no; pub=no; notes=""

  if [ -e "$d/.git" ]; then
    lg=yes; log "local git repo: yes ($(git -C "$d" branch --show-current), $(git -C "$d" rev-list --count HEAD 2>/dev/null || echo 0) commits)"
    url=$(git -C "$d" remote get-url origin 2>/dev/null)
    if [ -z "$url" ]; then
      log "origin: none"; notes="no origin"
    else
      log "origin: $url"
      log "running: git ls-remote $url HEAD"
      remote_head=$(git ls-remote "$url" HEAD 2>&1)
      rc=$?
      if [ $rc -eq 0 ] && [ -n "$remote_head" ]; then
        remote_head=${remote_head%%$'\t'*}
        gh=yes; log "github repo: exists, remote HEAD=${remote_head:0:8}"
        local_head=$(git -C "$d" rev-parse HEAD 2>/dev/null)
        log "local HEAD=${local_head:0:8}"
        if [ "$local_head" = "$remote_head" ]; then
          pushed=yes; log "pushed: up to date"
        elif git -C "$d" cat-file -e "$remote_head" 2>/dev/null; then
          n=$(git -C "$d" rev-list --count "$remote_head..HEAD"); pushed="ahead$n"; log "pushed: NO, $n commit(s) not pushed"
        else
          pushed=diverged; log "pushed: NO, remote has commits we don't have"
        fi
        dirty=$(git -C "$d" status --short -- . ':!build' | wc -l)
        log "uncommitted files (excluding build/): $dirty"
        [ "$dirty" -gt 0 ] && notes="$dirty uncommitted"
      elif [ $rc -eq 0 ]; then
        log "github repo: exists but empty"; gh=empty
      else
        log "github repo: NOT reachable -> ${remote_head//$'\n'/ }"
      fi
    fi
  else
    log "local git repo: NO (no .git in $d)"; notes="no git"
  fi

  log "running: curl https://pub.dev/api/packages/$name"
  code=$(curl -s -m 10 -o /tmp/pubcheck.$$ -w '%{http_code}' "https://pub.dev/api/packages/$name")
  if [ "$code" = "200" ]; then
    latest=$(sed -n 's/.*"latest":{"version":"\([^"]*\)".*/\1/p' /tmp/pubcheck.$$ | head -1)
    log "pub.dev: published, latest=$latest"
    if [ "$latest" = "$ver" ]; then pub=$latest; else pub=$latest; notes="$notes pub=$latest local=$ver"; log "local version differs from pub.dev"; fi
  elif [ "$code" = "404" ]; then
    log "pub.dev: not published (404)"
  else
    log "pub.dev: request failed (http $code)"; pub="err$code"
  fi
  rm -f /tmp/pubcheck.$$
  rows+=("$d|$lg|$gh|$pushed|$pub|$notes")
done

printf "\n${B}%-28s %-9s %-9s %-9s %-9s %s${N}\n" PACKAGE LOCALGIT GITHUB PUSHED PUBDEV NOTES
for r in "${rows[@]}"; do
  IFS='|' read -r d lg gh pushed pub notes <<<"$r"
  printf "%-28s " "$d"
  for v in "$lg" "$gh" "$pushed" "$pub"; do
    case $v in
      no|empty|err*|diverged) cell "$R" "$v";;
      ahead*) cell "$Y" "$v";;
      *) cell "$G" "$v";;
    esac
    printf " "
  done
  echo "$notes"
done
