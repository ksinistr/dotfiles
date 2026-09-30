#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

SEP=" │ "

# Parse all needed fields with a single jq invocation (separated by \x1f, which unlike a tab is not collapsed by read).
IFS=$'\x1f' read -r ctx_used five_pct five_resets week_pct week_resets transcript_path model_name effort_level <<<"$(
  echo "$input" | jq -r '[
    .context_window.used_percentage,
    .rate_limits.five_hour.used_percentage,
    .rate_limits.five_hour.resets_at,
    .rate_limits.seven_day.used_percentage,
    .rate_limits.seven_day.resets_at,
    .transcript_path,
    .model.display_name,
    .effort.level
  ] | map(. // "" | tostring) | join("\u001f")'
)"

# --- Progress bar renderer ---
# Usage: make_bar <percentage_float> [width]
# Outputs: "<pct>% <bar>" in the thin pip/rich style: colored ━ for the filled
# part with a ╸ half cell, dim ━ for the rest. Color: green ≤50%, yellow ≤80%, red above.
make_bar() {
  local pct="$1"
  local width="${2:-10}"

  local pct_int
  pct_int=$(printf "%.0f" "$pct")
  [ "$pct_int" -gt 100 ] && pct_int=100
  [ "$pct_int" -lt 0   ] && pct_int=0

  local halves=$(( pct_int * width * 2 / 100 ))
  local full_cells=$(( halves / 2 ))
  local has_half=$(( halves % 2 ))

  local ansi_color
  if [ "$pct_int" -le 50 ]; then
    ansi_color="\033[32m"
  elif [ "$pct_int" -le 80 ]; then
    ansi_color="\033[33m"
  else
    ansi_color="\033[31m"
  fi

  local filled="" empty="" i
  for (( i=0; i<full_cells; i++ )); do
    filled="${filled}━"
  done
  [ "$has_half" -eq 1 ] && filled="${filled}╸"
  for (( i=full_cells+has_half; i<width; i++ )); do
    empty="${empty}━"
  done

  printf "\033[2m%d%%\033[0m %b%s\033[0m\033[90m%s\033[0m" "$pct_int" "$ansi_color" "$filled" "$empty"
}

# --- Context window ---
if [ -n "$ctx_used" ]; then
  ctx_bar=$(make_bar "$ctx_used")
  ctx_part="$(printf '\033[2mContext\033[0m') ${ctx_bar}"
else
  ctx_part="$(printf '\033[2mContext\033[0m \033[90m━━━━━━━━━━\033[0m')"
fi

# --- Rate limits helpers ---

# format_reset_5h: "resets in Xh Ym at HH:MM" (used for 5-hour field)
format_reset_5h() {
  local resets_at="$1"
  if [ -z "$resets_at" ] || [ "$resets_at" = "null" ]; then
    echo ""
    return
  fi
  local now
  now=$(date +%s)
  local diff=$(( resets_at - now ))
  if [ "$diff" -le 0 ]; then
    echo "resets now"
    return
  fi
  local h=$(( diff / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  local reset_time
  reset_time=$(date -r "$resets_at" +%H:%M 2>/dev/null || date -d "@$resets_at" +%H:%M 2>/dev/null)
  if [ -n "$reset_time" ]; then
    if [ "$h" -gt 0 ]; then
      printf "resets in %dh %dm at %s" "$h" "$m" "$reset_time"
    else
      printf "resets in %dm at %s" "$m" "$reset_time"
    fi
  else
    if [ "$h" -gt 0 ]; then
      printf "resets in %dh %dm" "$h" "$m"
    else
      printf "resets in %dm" "$m"
    fi
  fi
}

# format_reset_7d: "resets in Xd Yh at Mon May 11 09:00" (used for 7-day field)
# Remaining time: Xd Yh if ≥1 day, Xh if ≥1 hour but <1 day, Xm if <1 hour.
# Wall-clock always includes weekday + month + day + time.
format_reset_7d() {
  local resets_at="$1"
  if [ -z "$resets_at" ] || [ "$resets_at" = "null" ]; then
    echo ""
    return
  fi
  local now
  now=$(date +%s)
  local diff=$(( resets_at - now ))
  if [ "$diff" -le 0 ]; then
    echo "resets now"
    return
  fi
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  local reset_time
  reset_time=$(date -r "$resets_at" "+%a %b %-d %H:%M" 2>/dev/null || date -d "@$resets_at" "+%a %b %-d %H:%M" 2>/dev/null)
  local remaining
  if [ "$d" -ge 1 ]; then
    remaining=$(printf "%dd %dh" "$d" "$h")
  elif [ "$h" -ge 1 ]; then
    remaining=$(printf "%dh" "$h")
  else
    remaining=$(printf "%dm" "$m")
  fi
  if [ -n "$reset_time" ]; then
    printf "resets in %s at %s" "$remaining" "$reset_time"
  else
    printf "resets in %s" "$remaining"
  fi
}

# Validate a rate-limit field: both percent and resets_at must be present,
# non-null, numeric, and resets_at must be in the future. If any check fails,
# the field is suppressed entirely (echo nothing → empty → caller hides it).
# Stdout: "1" if valid, empty otherwise.
is_rate_limit_valid() {
  local pct="$1"
  local resets_at="$2"
  [ -z "$pct" ] || [ "$pct" = "null" ] && return
  [ -z "$resets_at" ] || [ "$resets_at" = "null" ] && return
  # resets_at must be a positive integer-ish timestamp in the future
  case "$resets_at" in
    ''|*[!0-9]*) return ;;
  esac
  local now
  now=$(date +%s)
  [ "$resets_at" -le "$now" ] && return
  echo 1
}

# --- 5-hour session limit ---
if [ -n "$(is_rate_limit_valid "$five_pct" "$five_resets")" ]; then
  five_bar=$(make_bar "$five_pct")
  five_reset_str=$(format_reset_5h "$five_resets")
  if [ -n "$five_reset_str" ]; then
    five_part="$(printf '\033[2m5h\033[0m') ${five_bar} $(printf '\033[2m%s\033[0m' "$five_reset_str")"
  else
    five_part="$(printf '\033[2m5h\033[0m') ${five_bar}"
  fi
else
  five_part=""
fi

# --- 7-day weekly limit ---
if [ -n "$(is_rate_limit_valid "$week_pct" "$week_resets")" ]; then
  week_bar=$(make_bar "$week_pct")
  week_reset_str=$(format_reset_7d "$week_resets")
  if [ -n "$week_reset_str" ]; then
    week_part="$(printf '\033[2m7d\033[0m') ${week_bar} $(printf '\033[2m%s\033[0m' "$week_reset_str")"
  else
    week_part="$(printf '\033[2m7d\033[0m') ${week_bar}"
  fi
else
  week_part=""
fi

# --- Line 1: AI-generated session title (from transcript JSONL) ---
# Claude Code stores the title in entries with type="ai-title"; the most
# recent one is the current title. macOS doesn't ship `tac`, so use `tail -r`
# (BSD) and fall back to `tac` (GNU) for portability.
title=""
if [ -n "$transcript_path" ] && [ -r "$transcript_path" ]; then
  if command -v tac >/dev/null 2>&1; then
    reverse_cmd="tac"
  else
    reverse_cmd="tail -r"
  fi
  title=$($reverse_cmd "$transcript_path" 2>/dev/null \
    | grep -m 1 '"type":"ai-title"' \
    | jq -r '.aiTitle // empty' 2>/dev/null)
fi

# --- Model + reasoning effort segment (plain text; colored on line 1) ---
model_part=""
if [ -n "$model_name" ]; then
  model_part="$model_name"
  [ -n "$effort_level" ] && model_part="${model_part} ${effort_level}"
fi

# --- Line 2: Context / 5h / 7d, with │ separators ---
parts=()
parts+=("$ctx_part")
[ -n "$five_part" ] && parts+=("$five_part")
[ -n "$week_part" ] && parts+=("$week_part")

stats_line=""
for p in "${parts[@]}"; do
  if [ -z "$stats_line" ]; then
    stats_line="$p"
  else
    stats_line="${stats_line}${SEP}${p}"
  fi
done

# Build line 1 text: "model effort │ title" (each part optional), rendered
# entirely in dim grey (\033[2m).
line1_text=""
[ -n "$model_part" ] && line1_text="$model_part"
if [ -n "$title" ]; then
  if [ -n "$line1_text" ]; then
    line1_text="${line1_text}${SEP}${title}"
  else
    line1_text="$title"
  fi
fi

# Emit line 1 (dim grey, if any) then stats on the next line.
if [ -n "$line1_text" ]; then
  printf '\033[2m%s\033[0m\n%s\n' "$line1_text" "$stats_line"
else
  echo "$stats_line"
fi
