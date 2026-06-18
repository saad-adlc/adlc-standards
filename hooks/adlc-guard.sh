#!/usr/bin/env bash
# ADLC PreToolUse deny hook. Reads the tool-call JSON on stdin and blocks:
#   - Bash: push/merge to main, gh pr merge, rm -rf /, curl|bash
#   - Write/Edit: paths outside workspaces/<slug>/, or content with secret patterns
# Fires even under --permission-mode bypassPermissions. Deny = print decision JSON, exit 0.
set -euo pipefail
input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")

deny() {
  jq -n --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

case "$tool" in
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push.*\bmain\b|git[[:space:]]+merge.*\bmain\b|gh[[:space:]]+pr[[:space:]]+merge|rm[[:space:]]+-rf[[:space:]]+/|curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh)'; then
      deny "ADLC hook: blocked merge-to-main / dangerous command"
    fi
    ;;
  Write|Edit|MultiEdit)
    f=$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<<"$input")
    case "$f" in
      */workspaces/*|workspaces/*) : ;;            # allowed
      "") : ;;
      *) deny "ADLC hook: writes allowed only under workspaces/<slug>/ (attempted: $f)" ;;
    esac
    content=$(jq -r '.tool_input.content // .tool_input.new_string // empty' <<<"$input")
    if printf '%s' "$content" | grep -Eiq '(api[_-]?key|secret|password|token)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9/_+-]{16,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----'; then
      deny "ADLC hook: possible secret in file content"
    fi
    ;;
esac
exit 0
