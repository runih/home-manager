#!/usr/bin/env bash
# GitHub Copilot CLI status line — inspired by oh-my-posh blue-owl theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_window=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
session_id=$(echo "$input" | jq -r '.session.id // empty')
mode=$(echo "$input" | jq -r '.mode // empty')
rl_5h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_5h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_7d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Git branch
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null)
fi

# ANSI colors matching blue-owl palette
CYAN='\033[38;2;67;204;234m'
BLUE='\033[38;2;1;87;155m'
GREEN='\033[38;2;0;200;83m'
PURPLE='\033[38;2;41;49;90m'
ORANGE='\033[38;2;255;165;0m'
WHITE='\033[97m'
DIM='\033[2m'
RESET='\033[0m'

parts=()

# current directory (shorten home)
short_cwd="${cwd/#$HOME/~}"
parts+=("$(printf "${BLUE}📁 %s${RESET}" "$short_cwd")")

# git branch
if [ -n "$git_branch" ]; then
  parts+=("$(printf "${GREEN}🌿 %s${RESET}" "$git_branch")")
fi

# model
if [ -n "$model" ]; then
  parts+=("$(printf "${PURPLE}🤖 %s${RESET}" "$model")")
fi

# mode indicator
if [ -n "$mode" ]; then
  case "$mode" in
    autopilot) mode_icon="🚀" ;;
    suggest)   mode_icon="💡" ;;
    *)         mode_icon="⚙️" ;;
  esac
  parts+=("$(printf "${ORANGE}%s %s${RESET}" "$mode_icon" "$mode")")
fi

# context progress bar
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  bar_width=15
  filled=$(( used_int * bar_width / 100 ))
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  empty=$(( bar_width - filled ))
  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty; i++)); do bar="${bar}░"; done
  if [ "$used_int" -ge 80 ]; then
    BAR_COLOR='\033[38;2;255;80;80m'    # red — nearly full
  elif [ "$used_int" -ge 50 ]; then
    BAR_COLOR='\033[38;2;255;200;0m'    # yellow — halfway
  else
    BAR_COLOR='\033[38;2;0;200;83m'     # green — plenty left
  fi
  # Token count label
  token_label=""
  if [ -n "$total_tokens" ] && [ -n "$ctx_window" ]; then
    used_k=$(awk "BEGIN {printf \"%.0f\", $total_tokens / 1000}")
    total_k=$(awk "BEGIN {printf \"%.0f\", $ctx_window / 1000}")
    token_label=" ${used_k}k/${total_k}k"
  fi
  parts+=("$(printf "💭 ${BAR_COLOR}[%s]${WHITE} %d%%%s${RESET}" "$bar" "$used_int" "$token_label")")
fi

# account rate limit bars
if [ -n "$rl_5h_pct" ] || [ -n "$rl_7d_pct" ]; then
  rl_bar_width=8
  rl_parts=()

  make_rl_bar() {
    local pct="$1" label="$2"
    local pct_int=$(printf '%.0f' "$pct")
    local filled=$(( pct_int * rl_bar_width / 100 ))
    [ "$filled" -gt "$rl_bar_width" ] && filled=$rl_bar_width
    local empty=$(( rl_bar_width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    if [ "$pct_int" -ge 80 ]; then
      local C='\033[38;2;255;80;80m'
    elif [ "$pct_int" -ge 50 ]; then
      local C='\033[38;2;255;200;0m'
    else
      local C='\033[38;2;0;200;83m'
    fi
    printf "⏱️  ${DIM}%s${RESET}${C}[%s]${WHITE}%d%%${RESET}" "$label" "$bar" "$pct_int"
  }

  if [ -n "$rl_5h_pct" ]; then
    reset_label=""
    if [ -n "$rl_5h_resets" ]; then
      now=$(date +%s)
      secs_left=$(( rl_5h_resets - now ))
      if [ "$secs_left" -gt 0 ]; then
        h=$(( secs_left / 3600 ))
        m=$(( (secs_left % 3600) / 60 ))
        reset_label=" $(printf "${DIM}↻%dh%dm${RESET}" "$h" "$m")"
      fi
    fi
    rl_parts+=("$(make_rl_bar "$rl_5h_pct" "5h:")${reset_label}")
  fi

  if [ -n "$rl_7d_pct" ]; then
    rl_parts+=("$(make_rl_bar "$rl_7d_pct" "7d:")")
  fi

  rl_sep="$(printf "${DIM} ${RESET}")"
  rl_str=""
  for rp in "${rl_parts[@]}"; do
    if [ -z "$rl_str" ]; then rl_str="$rp"; else rl_str="${rl_str}${rl_sep}${rp}"; fi
  done
  parts+=("$rl_str")
fi

# session ID (short form)
if [ -n "$session_id" ]; then
  short_id="${session_id:0:8}"
  parts+=("$(printf "${DIM}🔗 %s${RESET}" "$short_id")")
fi

# join with separator
sep="$(printf "${DIM} | ${RESET}")"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf "%b\n" "$result"
