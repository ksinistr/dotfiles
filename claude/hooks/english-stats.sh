#!/usr/bin/env bash
set -euo pipefail

stats_file="${ENGLISH_CHECK_STATS:-$HOME/.claude/english-stats/mistakes.jsonl}"
days="${1:-}"

[[ -s "$stats_file" ]] || { echo "No stats yet: $stats_file"; exit 0; }

jq -rs --arg days "$days" '
  (if $days == "" then . else
    ((now - ($days | tonumber) * 86400) | todate) as $since | map(select(.ts >= $since))
  end) as $checks
  | ($checks | map(.categories) | add // []) as $all
  | ($checks | map(select(.categories | length > 0)) | length) as $with_mistakes
  | [
      "Period: \(if $days == "" then "all time" else "last \($days) days" end)",
      "Prompts checked: \($checks | length)",
      "Prompts with mistakes: \($with_mistakes) (\(if ($checks | length) > 0 then ($with_mistakes * 100 / ($checks | length) | floor) else 0 end)%)",
      "Total mistakes: \($all | length)",
      "",
      "By type:",
      ($all | group_by(.) | map({category: .[0], count: length}) | sort_by(-.count)[]
        | "- \(.category): \(.count) (\(.count * 100 / ($all | length) | floor)%)"),
      "",
      "By week (mistakes per prompt):",
      ($checks | group_by(.ts[0:10] | strptime("%Y-%m-%d") | mktime | strftime("%G-W%V"))[]
        | "- \(.[0].ts[0:10] | strptime("%Y-%m-%d") | mktime | strftime("%G-W%V")): \(map(.categories | length) | add) mistakes / \(length) prompts = \((map(.categories | length) | add) * 100 / length | round / 100)")
    ] | .[]
' "$stats_file"
