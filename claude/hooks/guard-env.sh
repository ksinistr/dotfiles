#!/usr/bin/env bash
# PreToolUse guard hook (matcher: Read|Edit|Write).
#
# The tool call arrives as JSON on stdin. Printing a deny decision to stdout
# blocks it, and permissionDecisionReason goes back to the model — which is why
# the reason names the way forward instead of just saying no.
#
# Protected: the .env family — real credentials. An agent rewriting one can drop
# a secret it cannot get back; an agent merely READING one pulls the secret into
# the context window, from where it can reach a summary, a log, or a diff. Hence
# Read in the matcher: for a credentials file, "look but don't touch" is not a
# meaningful safety line.
#
# Matching is on the BASENAME against an EXPLICIT LIST of real-credential files.
# A pattern like *.env.* would be shorter and wrong: it also swallows the
# template files people keep next to them (.env.example, .env.sample), which are
# committed placeholders and exactly where an agent SHOULD be allowed to work.
# Carving those back out needs a second branch placed above this one, and a rule
# whose correctness depends on line order is one you break the day you extend it.
# Adding .env.test tomorrow means adding a name here — no pattern to re-reason
# about, and nothing silently unprotected.

command -v jq >/dev/null || exit 0

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FILE_NAME=${FILE_PATH##*/}

case "$FILE_NAME" in
  .env|.env.local|.env.development|.env.staging|.env.production|.zshrc|.zprofile)
    cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse",
 "permissionDecision": "deny",
 "permissionDecisionReason": ".env holds real credentials and is off limits, to read as well as to write. Tell me which key you need and what for, and I will handle the value myself."}}
EOF
    ;;
esac

exit 0
