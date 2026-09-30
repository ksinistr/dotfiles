# Claude Code hooks

Personal hooks wired in `~/.claude/settings.json`. Install them with `make claude` from the dotfiles root: it symlinks the scripts and the status line into `~/.claude` and replaces the `hooks` and `statusLine` keys of `~/.claude/settings.json` with the ones from `claude/settings.json`, keeping a copy in `settings.json.bak`.

## Hooks

### guard-env.sh

- Event: `PreToolUse`, matcher `Read|Edit|Write`
- Denies reading or editing real credential files: `.env`, `.env.local`, `.env.development`, `.env.staging`, `.env.production`, `.zshrc`, `.zprofile`.
- Templates such as `.env.example` and `.env.sample` stay allowed.
- To protect another file, add its basename to the `case` list.

### mcp-write-ask.sh

- Event: `PreToolUse`, matcher `mcp__.*`
- Asks for approval before any MCP tool whose name looks like a write (`create`, `update`, `delete`, `send`, `transition`, `execute_sql`, ...).
- BigQuery MCP tools (`mcp__bigquery__*`) are always allowed.

### gh-publish-ask.sh

- Event: `PreToolUse`, matcher `Bash`
- Asks for approval before `gh` commands that publish to GitHub:
  - `gh pr|issue comment|review|create|merge|close|edit|ready|reopen|lock`
  - `gh api` with `-X/--method POST|PUT|PATCH|DELETE` or with `-f/-F/--field/--input`
  - `gh release create|edit|delete`

### english-check.sh

- Event: `UserPromptSubmit`, timeout 30s
- Sends every English prompt to `claude -p` (Haiku by default, no tools, no MCP, no session persistence) and shows the English mistakes as a system message. It never blocks the prompt.
- Skipped when the prompt:
  - starts with `/`, `!` or `#`
  - has fewer than 4 words
  - has less than 70% Latin letters, so Russian prompts are not checked
- Capitalization is never reported, and any mistake that differs only in letter case is filtered out.
- Every check appends a line to the stats file: `{"ts": "...", "categories": [...]}`.
- Settings (env vars):
  - `ENGLISH_CHECK_MODEL`: Claude model, default `haiku`
  - `ENGLISH_CHECK_TIMEOUT`: `claude -p` time limit in seconds, default `20`
  - `ENGLISH_CHECK_STATS`: stats file, default `~/.claude/english-stats/mistakes.jsonl`

### english-stats.sh

- Not a hook. Run it by hand to see your mistake stats.
- `english-stats.sh` for all time, `english-stats.sh 7` for the last 7 days.
- Shows the number of checked prompts, the share of prompts with mistakes, mistakes by category and mistakes per prompt by week.

## English mistake categories

The categories target mistakes typical for native Russian speakers.

Grammar:

- `article`: missing or wrong a/an/the. "it's good idea" → "it's a good idea"
- `preposition`: wrong or missing preposition, often a calque from Russian. "depends from" → "depends on"
- `subject-verb-agreement`: verb form does not match the subject, usually the missing third-person -s. "it work" → "it works"
- `missing-subject`: dropped formal subject it/there. "Is good idea" → "It is a good idea", "Here is no errors" → "There are no errors"
- `question-form`: question without an auxiliary verb or inversion. "Why it fails?" → "Why does it fail?"
- `gerund-infinitive`: wrong -ing or to-infinitive after a verb or adjective. "suggest to use" → "suggest using"
- `negation`: double negation. "nobody didn't answer" → "nobody answered"
- `plural`: wrong plural, mostly uncountable nouns. "informations", "advices", "feedbacks" → "information", "advice", "feedback"

Verb tenses. The category names the tense that should be used:

- `tense-present-simple`: facts, habits and if/when clauses about the future. "if it will fail" → "if it fails"
- `tense-present-continuous`: an action happening now or a temporary state. "I write the test now" → "I'm writing the test now"
- `tense-present-perfect`: a past action with a present result, with already/yet/just/ever. "Did you already push it?" → "Have you already pushed it?"
- `tense-past-simple`: a finished action at a known past time. "I have fixed it yesterday" → "I fixed it yesterday"
- `tense-past-perfect`: an action that happened before another past action. "after I deployed it, I noticed that nobody reviewed it" → "nobody had reviewed it"
- `tense-future`: will / going to for future actions. "I tell you later" → "I'll tell you later"
- `tense-conditional`: would / could in hypothetical sentences. "if I had time, I will fix it" → "I would fix it"

Vocabulary and style:

- `word-choice`: wrong word, false friend or unnatural collocation. "actual task" (in the meaning of relevant) → "current task", "make a photo" → "take a photo"
- `word-order`: words in the wrong position, such as adverbs or indirect questions. "I use often it" → "I often use it", "I don't know what is the problem" → "I don't know what the problem is"
- `spelling`: misspelled word
- `punctuation`: missing or wrong punctuation that changes readability, such as a missing apostrophe in contractions
- `redundancy`: unnecessary words. "return back" → "return"
- `phrasing`: a sentence that is grammatical but sounds like a word-for-word translation

Stats written before the tense split contain the old `verb-tense` category, and `english-stats.sh` shows them as a separate row.
