#!/usr/bin/env bash
# ADLC approved-packages validator — WS8 allow-list gate (default-deny).
#
# Fails (exit 1) if any DIRECT dependency in <package.json> is NOT on the approved
# allow-list, or is on the banned list. Transitive (lockfile) deps are NOT checked
# here — that is Dependabot's job (CVE/GPL, WS5). Deterministic: the allow-list is
# data (steering/approved-packages.json), never model judgment.
#
# Usage: check-approved-packages.sh <package.json> [approved-packages.json]
set -uo pipefail

PKG="${1:-}"
ALLOW="${2:-$(cd "$(dirname "$0")" && pwd)/../steering/approved-packages.json}"

[ -n "$PKG" ] || { echo "usage: check-approved-packages.sh <package.json> [approved-packages.json]" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "check-approved-packages: jq required" >&2; exit 2; }
[ -f "$PKG" ]   || { echo "check-approved-packages: no package.json at '$PKG'" >&2; exit 2; }
[ -f "$ALLOW" ] || { echo "check-approved-packages: no allow-list at '$ALLOW'" >&2; exit 2; }

# Direct deps only (dependencies + devDependencies). Allow-list = runtime + dev.
deps="$(jq -r '((.dependencies // {}) + (.devDependencies // {})) | keys[]' "$PKG" 2>/dev/null)" \
  || { echo "check-approved-packages: malformed package.json '$PKG'" >&2; exit 2; }
allowed="$(jq -r '((.allowed.runtime // []) + (.allowed.dev // [])) | .[]' "$ALLOW")"
banned="$(jq -r '(.banned // []) | .[]' "$ALLOW")"

rc=0
while IFS= read -r dep; do
  [ -z "$dep" ] && continue
  if printf '%s\n' "$banned" | grep -qxF -- "$dep"; then
    echo "DENY: '$dep' is a banned package"; rc=1; continue
  fi
  if ! printf '%s\n' "$allowed" | grep -qxF -- "$dep"; then
    echo "DENY: '$dep' is not on the approved allow-list (default-deny — add it via a signed-off standards PR if genuinely needed)"; rc=1
  fi
done <<EOF
$deps
EOF

[ "$rc" -eq 0 ] && echo "OK: all direct dependencies are approved"
exit "$rc"
