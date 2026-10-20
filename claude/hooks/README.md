# Claude Code hooks

Personal hooks wired in `~/.claude/settings.json`. Install them with `make claude` from the dotfiles root: it symlinks the scripts and the status line into `~/.claude` and replaces the `hooks` and `statusLine` keys of `~/.claude/settings.json` with the ones from `claude/settings.json`, keeping a copy in `settings.json.bak`.

## Hooks

### guard-env.sh

- Event: `PreToolUse`, matcher `Read|Edit|Write|Bash`
- Denies reading or editing real credential files: `.env`, `.env.local`, `.env.development`, `.env.staging`, `.env.production`, `.zshrc`, `.zprofile`.
- For Bash, denies any command that names one of these files as a path component (`cat ~/.zprofile`, `grep x .env`). It catches accidental reads; a glob or a variable gets past it.
- Templates such as `.env.example` and `.env.sample` stay allowed.
- To protect another file, add its basename to `PROTECTED_FILES`.

### mcp-write-ask.sh

- Event: `PreToolUse`, matcher `mcp__.*`
- Asks for approval before any MCP tool whose name looks like a write (`create`, `update`, `delete`, `send`, `transition`, `execute_sql`, ...).
- BigQuery MCP tools (`mcp__bigquery__*`) are always allowed.
- `mcp__ccd_turn__update_plan` (the Claude desktop app task list) is always allowed.

### gh-publish-ask.sh

- Event: `PreToolUse`, matcher `Bash`
- Asks for approval before `gh` commands that publish to GitHub:
  - `gh pr|issue comment|review|create|merge|close|edit|ready|reopen|lock`
  - `gh api` with `-X/--method POST|PUT|PATCH|DELETE` or with `-f/-F/--field/--input`
  - `gh release create|edit|delete`
