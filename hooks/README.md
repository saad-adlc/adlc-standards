# Deny hooks

Deterministic `PreToolUse` enforcement (constitution §5). Fires even under `--permission-mode bypassPermissions`.

## CI wiring (WS4)
Before the agent runs, the generate/iterate workflow must place both files in the workdir:

```bash
mkdir -p .claude/hooks
cp _standards/hooks/adlc-guard.sh .claude/hooks/adlc-guard.sh
cp _standards/hooks/settings.json .claude/settings.json
chmod +x .claude/hooks/adlc-guard.sh
```

Claude Code reads `.claude/settings.json` → runs `.claude/hooks/adlc-guard.sh` on every Bash/Write/Edit. Requires `jq` (present on GitHub runners).

## Blocks
- Bash: `git push/merge … main`, `gh pr merge`, `rm -rf /`, `curl … | bash`
- Write/Edit: paths outside `workspaces/<slug>/`; content matching secret patterns
