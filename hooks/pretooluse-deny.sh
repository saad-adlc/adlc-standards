#!/usr/bin/env bash
# ADLC PreToolUse deny hook — deterministic governance guardrail.
# Fails CLOSED: every error path denies. Deny = exit 0 + JSON; allow = bare exit 0.
# Fires even under --permission-mode bypassPermissions (verified).
# Env: ADLC_WORKSPACE — the one workspace writes are confined to (Task 3).
set -uo pipefail   # NOT -e: we route errors to explicit deny

deny() {
  jq -nc --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
allow() { exit 0; }

command -v jq >/dev/null 2>&1 || deny "deny-hook: jq unavailable"
INPUT="$(cat)" || deny "deny-hook: cannot read stdin"
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')" || deny "deny-hook: malformed input"
[ -n "$TOOL" ] || deny "deny-hook: missing tool_name"

case "$TOOL" in
  Bash)
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
    if printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])rm[[:space:]]+-[A-Za-z]*[rRf][A-Za-z]*[[:space:]]+(-[A-Za-z]+[[:space:]]+)*(/|~|\$HOME|\*)([[:space:]]|$)'; then
      deny "deny-hook: dangerous 'rm' targeting root/home/glob"
    fi
    if printf '%s' "$CMD" | grep -Eq '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)'; then
      deny "deny-hook: piping a download into a shell"
    fi
    if printf '%s' "$CMD" | grep -Eq ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:|mkfs|dd[[:space:]]+if=|>[[:space:]]*/dev/sd'; then
      deny "deny-hook: fork-bomb / disk-destroying command"
    fi
    if printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(origin[[:space:]]+)?(main|master|HEAD:main|HEAD:master)([^[:alnum:]/_-]|$)'; then
      deny "deny-hook: push to protected branch (main/master)"
    fi
    if printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])(git[[:space:]]+merge|gh[[:space:]]+pr[[:space:]]+merge)([[:space:]]|$)'; then
      deny "deny-hook: merge is reserved for the human gate"
    fi
    allow
    ;;
  *)
    allow ;;
esac
