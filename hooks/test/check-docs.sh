#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0
need() { grep -q "$2" "$ROOT/$1" 2>/dev/null || { echo "MISSING in $1: $2"; fail=1; }; }

# constitution.md required anchors
need constitution.md "# ADLC Project Constitution"
need constitution.md "## Non-negotiable security"
need constitution.md "## No direct merge to main"
need constitution.md "## Deterministic enforcement"
need constitution.md "## Definition of done"

[ "$fail" -eq 0 ] && echo "docs OK" || { echo "docs FAIL"; exit 1; }
