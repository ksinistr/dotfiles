#!/usr/bin/env bash
tool=$(jq -r '.tool_name // empty')
[[ "$tool" =~ ^mcp__ ]] || exit 0
[[ "$tool" =~ ^mcp__bigquery__ ]] && exit 0
if [[ "$tool" =~ (add|create|edit|update|delete|remove|upload|build|release|batch|apply|clear|merge|restore|cancel|send|post|import|install|invite|assign|replace|revalidate|translate|notify|set_|write|transition|move|share|trash|sync|execute_sql$) ]]; then
  jq -n --arg t "$tool" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:("MCP write tool: "+$t)}}'
fi
exit 0
