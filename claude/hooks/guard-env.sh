#!/usr/bin/env bash
# PreToolUse guard hook (matcher: Read|Edit|Write|Bash).
#
# The tool call arrives as JSON on stdin. Printing a deny decision to stdout
# blocks it, and permissionDecisionReason goes back to the model — which is why
# the reason names the way forward instead of just saying no.
#
# Protected: the .env family and shell init files — real credentials. An agent
# rewriting one can drop a secret it cannot get back; an agent merely READING one
# pulls the secret into the context window, from where it can reach a summary, a
# log, or a diff. Hence Read in the matcher: for a credentials file, "look but
# don't touch" is not a meaningful safety line.
#
# Matching is on the BASENAME against an EXPLICIT LIST of real-credential files.
# A pattern like *.env.* would be shorter and wrong: it also swallows the
# template files people keep next to them (.env.example, .env.sample), which are
# committed placeholders and exactly where an agent SHOULD be allowed to work.
# Carving those back out needs a second branch placed above this one, and a rule
# whose correctness depends on line order is one you break the day you extend it.
# Adding .env.test tomorrow means adding a name here — no pattern to re-reason
# about, and nothing silently unprotected.
#
# Bash: the same list is matched as a whole path component inside the command,
# so `cat ~/.zprofile` is denied while `cat .env.example` passes. This stops the
# accidental read; it is no sandbox — a glob (`~/.z*`) or a variable walks past it.

command -v jq >/dev/null || exit 0

PROTECTED_FILES=(.env .env.local .env.development .env.staging .env.production .zshrc .zprofile)
BEFORE='(^|[[:space:]/"'\''=<>(`])'
AFTER='([[:space:]"'\'';|&)<>`]|$)'

deny() {
  jq -n --arg reason "$1" '{hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason}}'
  exit 0
}

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_NAME=${FILE_PATH##*/}

for name in "${PROTECTED_FILES[@]}"; do
  pattern="${BEFORE}${name//./\\.}${AFTER}"
  if [ "$FILE_NAME" = "$name" ] || [[ $COMMAND =~ $pattern ]]; then
    deny "This file holds real credentials (.env family, ~/.zshrc, ~/.zprofile) and is off limits, to read as well as to write, through any tool including Bash. Tell me what you need from it and why, and I will check it myself."
  fi
done

exit 0
