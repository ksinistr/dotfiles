#!/usr/bin/env bash
command -v jq >/dev/null || exit 0
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')
[[ "$tool" == "Bash" ]] || exit 0
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
if [[ "$cmd" =~ gh[[:space:]]+(pr|issue)[[:space:]]+(comment|review|create|merge|close|edit|ready|reopen|lock) ]] \
   || [[ "$cmd" =~ gh[[:space:]]+api.*(-X|--method)[[:space:]]+(POST|PUT|PATCH|DELETE) ]] \
   || [[ "$cmd" =~ gh[[:space:]]+api.*(-f|--field|--input|-F)[[:space:]] ]] \
   || [[ "$cmd" =~ gh[[:space:]]+release[[:space:]]+(create|edit|delete) ]]; then
  jq -n --arg c "$cmd" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:("Publishes to GitHub, needs explicit approval: "+$c)}}'
fi
exit 0
