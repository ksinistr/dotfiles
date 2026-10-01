# Codex English check

Run `make codex` to install the hooks into `${CODEX_HOME:-~/.codex}`. This links the scripts and merges `hooks.json`, backing up the previous file as `hooks.json.bak`. It replaces the `UserPromptSubmit` event configuration, preserves other events and leaves `config.toml` unchanged. Use `make codex CODEX_DIR=/path` to select another installation directory.

Restart Codex and review/trust the installed hook before using it. Codex skips untrusted hooks. Avoid defining the same English check inline in `config.toml`, since Codex combines both sources.

The hook checks English prompts with `codex exec`, using `gpt-6-luna` with low reasoning effort by default. It skips Cyrillic text, short prompts, slash commands and text with fewer than 70% Latin letters. Capitalization-only changes are filtered out. Errors and timeouts never block the main prompt.

The nested run uses a temporary Codex home with the existing authentication file linked in, an empty working directory, a JSON output schema and ephemeral sessions. It excludes user configuration, hooks, MCP servers, plugins and project instructions, disables shell tools, apps, web search and subagents, and uses the read-only sandbox. Temporary files are removed when the hook exits. The model is instructed to review only the supplied text.

Dependencies: a recent Codex CLI supporting the flags in the script, `jq`, and `perl`. Luna must be available through your Codex login. No separate API key is needed for ChatGPT authentication.

Environment variables:

- `ENGLISH_CHECK_MODEL`: default `gpt-6-luna`.
- `ENGLISH_CHECK_TIMEOUT`: nested Codex timeout, default `20` seconds; keep below the hook's 30-second timeout.
- `ENGLISH_CHECK_STATS`: default `${CODEX_HOME:-~/.codex}/english-stats/mistakes.jsonl`.

Run `~/.codex/hooks/english-stats.sh` for all statistics, or add `7` for the last seven days. Categories and output match the Claude English check; set `ENGLISH_CHECK_STATS` to the same file to combine statistics.

References: [Codex hooks](https://learn.chatgpt.com/docs/hooks), [non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode), [model IDs](https://developers.openai.com/api/docs/models).
