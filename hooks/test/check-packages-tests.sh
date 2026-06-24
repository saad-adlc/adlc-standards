#!/usr/bin/env bash
# TDD harness for check-approved-packages.sh (the WS8 allow-list validator).
# bash 3.2 compatible. Mirrors hooks/test/run-tests.sh.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CHECK="$HERE/../check-approved-packages.sh"
ALLOW="$HERE/../../steering/approved-packages.json"
PASS=0; FAIL=0
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

run() {  # <package.json content> -> "pass" | "fail"
  printf '%s' "$1" > "$TMP/package.json"
  if bash "$CHECK" "$TMP/package.json" "$ALLOW" >/dev/null 2>&1; then echo pass; else echo fail; fi
}
check() {  # <expected> <desc> <package.json content>
  local exp="$1" desc="$2" got; got="$(run "$3")"
  if [ "$got" = "$exp" ]; then PASS=$((PASS+1));
  else FAIL=$((FAIL+1)); echo "FAIL: $desc (expected $exp, got $got)"; fi
}

# --- allowed (default-deny passes only approved) ---
check pass "approved runtime + dev"        '{"dependencies":{"react":"^18.3.1","react-router-dom":"^6"},"devDependencies":{"vite":"^5","vitest":"^2"}}'
check pass "full Orix-approved runtime"    '{"dependencies":{"react":"^18","react-dom":"^18","react-router-dom":"^6","axios":"^1","zustand":"^4","@tanstack/react-query":"^5"}}'
check pass "approved alternatives"         '{"dependencies":{"date-fns":"^3","lodash-es":"^4"}}'
check pass "scoped dev packages"           '{"devDependencies":{"@testing-library/react":"^16","@types/react":"^18","@vitest/coverage-v8":"^2"}}'
check pass "no deps at all"                '{"name":"x","version":"0.0.0","private":true}'

# --- denied (unlisted = default-deny; banned = explicit) ---
check fail "unlisted runtime dep"          '{"dependencies":{"react":"^18","left-pad":"^1"}}'
check fail "unlisted dev dep"              '{"devDependencies":{"webpack":"^5"}}'
check fail "banned: moment"                '{"dependencies":{"moment":"^2"}}'
check fail "banned: full lodash"           '{"dependencies":{"lodash":"^4"}}'
check fail "approved + one unlisted"       '{"dependencies":{"react":"^18","react-router-dom":"^6","recharts":"^2"}}'

echo "----"; echo "PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]
