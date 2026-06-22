#!/usr/bin/env bash
# ADLC PreToolUse deny hook — deterministic governance guardrail.
# Fails CLOSED: every error path denies. Deny = exit 0 + JSON; allow = bare exit 0.
# Fires even under --permission-mode bypassPermissions (verified).
# Env: ADLC_WORKSPACE — the one workspace writes are confined to (Task 3).
set -uo pipefail   # NOT -e: we route errors to explicit deny

SECRET_RE='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|xox[baprs]-[0-9A-Za-z-]{10,}|(secret|token|password|api[_-]?key)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9/+_-]{12,}'

deny() {
  jq -nc --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
allow() { exit 0; }

path_outside_workspace() {  # returns 0 (true) if $1 is OUTSIDE the assigned workspace
  local p="${1#./}" ws="${ADLC_WORKSPACE:-}" root="${GITHUB_WORKSPACE:-$PWD}"
  root="${root%/}"
  # Claude's Write/Edit tools ALWAYS pass an absolute file_path
  # ($GITHUB_WORKSPACE/workspaces/<slug>/...). Normalize repo-root-absolute paths
  # back to repo-relative so the confinement check below compares like with like.
  case "$p" in "$root"/*) p="${p#"$root"/}" ;; esac
  # Any leftover absolute path, or any parent-traversal segment, escapes the repo
  # or hops out of the workspace — deny outright (don't let ".." sneak past the prefix).
  case "$p" in /*|../*|*/../*|*/..|..) return 0 ;; esac
  if [ -n "$ws" ]; then
    ws="${ws%/}"
    case "$p" in "$ws"/*) return 1 ;; *) return 0 ;; esac
  else
    case "$p" in workspaces/*/*) return 1 ;; *) return 0 ;; esac
  fi
}

command -v jq >/dev/null 2>&1 || deny "deny-hook: jq unavailable"
INPUT="$(cat)" || deny "deny-hook: cannot read stdin"
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)" || deny "deny-hook: malformed input"
[ -n "$TOOL" ] || deny "deny-hook: missing tool_name"

case "$TOOL" in
  Bash)
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)" || deny "deny-hook: cannot parse Bash tool_input"
    if printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])rm[[:space:]]+-[A-Za-z]*[rRf][A-Za-z]*[[:space:]]+(-[A-Za-z]+[[:space:]]+)*(/|~|\$HOME|\*)([[:space:]]|$)'; then
      deny "deny-hook: dangerous 'rm' targeting root/home/glob"
    fi
    if printf '%s' "$CMD" | grep -Eq '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)'; then
      deny "deny-hook: piping a download into a shell"
    fi
    if printf '%s' "$CMD" | grep -Eq ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:|mkfs|dd[[:space:]]+if=|>[[:space:]]*/dev/sd'; then
      deny "deny-hook: fork-bomb / disk-destroying command"
    fi
    if printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+([^[:space:]]*:)?(refs/heads/)?(main|master)([^[:alnum:]/_-]|$)'; then
      deny "deny-hook: push to protected branch (main/master)"
    fi
    if printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_])(git[[:space:]]+merge|gh[[:space:]]+pr[[:space:]]+merge)([[:space:]]|$)'; then
      deny "deny-hook: merge is reserved for the human gate"
    fi
    if printf '%s' "$CMD" | grep -Eq '(>>?|tee([[:space:]]+-a)?[[:space:]]+)[[:space:]]*\.?/?\.github/'; then
      deny "deny-hook: Bash write into .github/"
    fi
    if printf '%s' "$CMD" | grep -Eq '(>>?|tee([[:space:]]+-a)?[[:space:]]+)[[:space:]]*\.?/?(CLAUDE\.md|package\.json|tsconfig\.json|eslint\.config|vite\.config)'; then
      deny "deny-hook: Bash write into root config"
    fi
    if printf '%s' "$CMD" | grep -Eq 'sed[[:space:]]+-i([[:space:]]|[^[:space:]]*[[:space:]]).*(\.github/|CLAUDE\.md)'; then
      deny "deny-hook: in-place edit of protected path via sed"
    fi
    # redirect/tee target confinement (heuristic, defense-in-depth)
    if printf '%s' "$CMD" | grep -Eq '(>>?|tee)[^|;&<]*\.\.(/|[[:space:]]|$)'; then
      deny "deny-hook: Bash redirect with path traversal"
    fi
    if [ -n "${ADLC_WORKSPACE:-}" ] && printf '%s' "$CMD" | grep -Eq '(>>?|tee)' \
       && printf '%s' "$CMD" | grep -oE 'workspaces/[A-Za-z0-9._-]+' | grep -qv "^workspaces/$(basename "${ADLC_WORKSPACE%/}")$"; then
      deny "deny-hook: Bash command touches another workspace while redirecting"
    fi
    if printf '%s' "$CMD" | grep -Eq "$SECRET_RE"; then
      deny "deny-hook: secret-like literal in Bash command"
    fi
    allow
    ;;
  Write|Edit)
    FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || deny "deny-hook: cannot parse ${TOOL} tool_input"
    [ -n "$FILE" ] || deny "deny-hook: ${TOOL} without file_path"
    case "$FILE" in
      *.github/*|*/.github/*|.github/*) deny "deny-hook: writes to .github/ are forbidden" ;;
    esac
    if path_outside_workspace "$FILE"; then
      deny "deny-hook: write outside assigned workspace ('$FILE')"
    fi
    CONTENT="$(printf '%s' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)" || deny "deny-hook: cannot parse ${TOOL} content"
    if printf '%s' "$CONTENT" | grep -Eq "$SECRET_RE"; then
      deny "deny-hook: secret-like literal in file content"
    fi
    allow
    ;;
  *)
    allow ;;
esac
