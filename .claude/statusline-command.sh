#!/bin/bash
# Claude Code statusLine — Tokyo Night / Catppuccin IDE status bar
# Uses $'...' bash syntax so ESC bytes are real at assignment time — no raw \033 bleed-through.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# ── Cache dir for expensive operations ────────────────────────────────────────
CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/cc-statusline"
mkdir -p "$CACHE_DIR"

# Cache git operations per-directory (TTL: 5 seconds)
_git_cache() {
  local key tag cache_file result now mtime
  tag=$(printf '%s' "$cwd" | tr '/' '_')
  cache_file="$CACHE_DIR/git_${tag}"
  now=$(date +%s)
  if [[ -f "$cache_file" ]]; then
    mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    if (( now - mtime < 5 )); then
      cat "$cache_file"
      return
    fi
  fi
  # Compute branch + dirty flag together to avoid double git calls
  local b d
  b=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  d=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  result="${b}|${d}"
  printf '%s' "$result" > "$cache_file"
  printf '%s' "$result"
}

git_info=$(_git_cache)
branch="${git_info%%|*}"
git_dirty="${git_info#*|}"

# ── Data extraction ───────────────────────────────────────────────────────────
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# Derive used tokens from percentage × window size (input_tokens only counts latest request)
input_tok=$(echo "$input" | jq -r '
  (.context_window.used_percentage // 0) as $pct |
  (.context_window.context_window_size // 0) as $win |
  if $pct > 0 and $win > 0 then (($pct / 100 * $win) | floor | tostring)
  else empty end
')
win_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# ── Rate limit extraction ─────────────────────────────────────────────────────
five_pct=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage  // empty')
week_pct=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage  // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at       // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at       // empty')

# ── Colour palette — Tokyo Night (256-colour foreground codes) ────────────────
# All variables hold real ESC bytes thanks to $'...' bash syntax.
RST=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'

# Foreground colours
FG_DIR=$'\e[38;5;111m'      # blue  (#7aa2f7 approx)
FG_GIT=$'\e[38;5;150m'      # green (#9ece6a approx)
FG_DIRTY=$'\e[38;5;203m'    # red   (#f7768e approx)
FG_MODEL=$'\e[38;5;183m'    # purple (#bb9af7 approx)
FG_CTX_OK=$'\e[38;5;179m'   # orange (#e0af68 approx)
FG_CTX_WARN=$'\e[38;5;215m' # amber
FG_CTX_CRIT=$'\e[38;5;203m' # red   (#f7768e approx)
FG_LABEL=$'\e[38;5;245m'    # mid-grey labels
FG_SEP=$'\e[38;5;237m'      # dark grey separators
FG_DIM=$'\e[38;5;240m'      # dimmed punctuation
FG_TIME=$'\e[38;5;110m'     # soft blue (#87afd7 approx) — kept for reference
FG_RATE_OK=$'\e[38;5;150m'  # green  — low usage
FG_RATE_MID=$'\e[38;5;179m' # orange — mid usage
FG_RATE_HIGH=$'\e[38;5;215m'# amber  — high usage
FG_RATE_CRIT=$'\e[38;5;203m'# red    — near limit

# Segment separators — plain dot works in any font, arrow for visual flair
SEP_DOT="${FG_SEP} · ${RST}"

# ── Helper: format token count as e.g. "12.4k" ───────────────────────────────
fmt_tokens() {
  local tok="$1"
  if [[ -z "$tok" || "$tok" == "null" ]]; then
    printf '?'
    return
  fi
  awk -v t="$tok" 'BEGIN{
    if (t >= 1000000) {
      m = t / 1000000
      if (m == int(m)) printf "%dM", m
      else              printf "%.1fM", m
    } else if (t >= 1000) {
      k = t / 1000
      if (k == int(k)) printf "%dk", k
      else              printf "%.1fk", k
    } else {
      printf "<1k"
    }
  }'
}

# ── Helper: compact model name ("Claude 3.5 Sonnet" → "Sonnet 3.5") ──────────
short_model() {
  local m="$1"
  # Strip "Claude " prefix and any parenthetical suffix like "(1M context)"
  m="${m#Claude }"
  m=$(printf '%s' "$m" | sed 's/ *([^)]*)$//')
  printf '%s' "$m"
}

# ── Helper: "resets in Xh Ym" from Unix epoch ────────────────────────────────
fmt_reset() {
  local epoch="$1"
  [[ -z "$epoch" || "$epoch" == "null" ]] && return
  local now diff
  now=$(date +%s)
  diff=$(( epoch - now ))
  (( diff <= 0 )) && printf 'now' && return
  local h=$(( diff / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if (( h > 0 )); then
    printf '%dh%dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

# ── Helper: rate-limit colour based on used % ─────────────────────────────────
rate_color() {
  local pct="$1"
  local ip
  ip=$(printf '%.0f' "$pct" 2>/dev/null) || ip=0
  if   (( ip >= 90 )); then printf '%s' "$FG_RATE_CRIT"
  elif (( ip >= 70 )); then printf '%s' "$FG_RATE_HIGH"
  elif (( ip >= 40 )); then printf '%s' "$FG_RATE_MID"
  else                      printf '%s' "$FG_RATE_OK"
  fi
}

# ── Helper: mini progress bar (8 chars) ──────────────────────────────────────
mini_bar() {
  local pct="$1" width=8
  local filled
  filled=$(awk -v p="$pct" -v w="$width" 'BEGIN{printf "%d", int(p*w/100+0.5)}')
  local empty=$((width - filled))
  local bar=''
  local i
  for ((i = 0; i < filled; i++)); do bar+='█'; done
  for ((i = 0; i < empty; i++)); do bar+='░'; done
  printf '%s' "$bar"
}

# ── Terminal width ────────────────────────────────────────────────────────────
cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 120)}

# Visible length: strip ANSI escapes, count characters
vlen() {
  printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g' | wc -m | tr -d ' '
}

# ── Build output — full detail, wrap to second line if needed ────────────────
# Line 1: dir · branch · model · context
# Line 2 (overflow): 5h rate limit · 7d rate limit

# ── Line 1 segments ──
line1=" ${FG_LABEL}${DIM}in${RST} ${BOLD}${FG_DIR}${dir}${RST}"

if [[ -n "$branch" ]]; then
  local_dirty=''
  [[ -n "$git_dirty" ]] && local_dirty=" ${FG_DIRTY}*${RST}"
  line1+="${SEP_DOT}${FG_GIT}${branch}${RST}${local_dirty}"
fi

if [[ -n "$model" ]]; then
  smodel=$(short_model "$model")
  line1+="${SEP_DOT}${FG_MODEL}${smodel}${RST}"
fi

if [[ -n "$used_pct" ]]; then
  pct=$(printf '%.0f' "$used_pct")
  if   (( pct >= 80 )); then C_CTX="$FG_CTX_CRIT"
  elif (( pct >= 50 )); then C_CTX="$FG_CTX_WARN"
  else                       C_CTX="$FG_CTX_OK"
  fi
  bar=$(mini_bar "$pct")
  used_fmt=$(fmt_tokens "$input_tok")
  total_fmt=$(fmt_tokens "$win_size")
  line1+="${SEP_DOT}${C_CTX}${bar}${RST} ${FG_LABEL}${pct}%${RST} ${FG_DIM}${used_fmt}/${total_fmt}${RST}"
fi

# ── Rate-limit segments (may overflow to line 2) ──
rate_out=''

if [[ -n "$five_pct" ]]; then
  five_int=$(printf '%.0f' "$five_pct")
  five_c=$(rate_color "$five_pct")
  five_bar=$(mini_bar "$five_int")
  five_reset_str=$(fmt_reset "$five_reset")
  reset_label=''
  [[ -n "$five_reset_str" ]] && reset_label=" ${FG_DIM}↺${five_reset_str}${RST}"
  rate_out+="${FG_LABEL}${DIM}5h${RST} ${five_c}${five_bar}${RST} ${FG_LABEL}${five_int}%${RST}${reset_label}"
fi

if [[ -n "$week_pct" ]]; then
  [[ -n "$rate_out" ]] && rate_out+="${SEP_DOT}"
  week_int=$(printf '%.0f' "$week_pct")
  week_c=$(rate_color "$week_pct")
  week_bar=$(mini_bar "$week_int")
  week_reset_str=$(fmt_reset "$week_reset")
  reset_label=''
  [[ -n "$week_reset_str" ]] && reset_label=" ${FG_DIM}↺${week_reset_str}${RST}"
  rate_out+="${FG_LABEL}${DIM}7d${RST} ${week_c}${week_bar}${RST} ${FG_LABEL}${week_int}%${RST}${reset_label}"
fi

# ── Assemble: one line if it fits, two lines if it doesn't ───────────────────
if [[ -z "$rate_out" ]]; then
  printf '%s\n' "$line1"
else
  full="${line1}${SEP_DOT}${rate_out}"
  if (( $(vlen "$full") <= cols )); then
    printf '%s\n' "$full"
  else
    printf '%s\n %s\n' "$line1" "$rate_out"
  fi
fi
