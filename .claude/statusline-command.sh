#!/bin/bash
# Claude Code statusLine — Tokyo Night / Catppuccin IDE status bar
# Uses $'...' bash syntax so ESC bytes are real at assignment time — no raw \033 bleed-through.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# ── Data extraction ───────────────────────────────────────────────────────────
dir=$(basename "$cwd")
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
git_dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
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

# ── Build output ──────────────────────────────────────────────────────────────
out=''

# 1. Directory segment  ── 📁 dir
out+=" ${FG_LABEL}${DIM}in${RST} ${BOLD}${FG_DIR}${dir}${RST}"

# 2. Git segment  ── ⎇ branch [*]
if [[ -n "$branch" ]]; then
  local_dirty=''
  if [[ -n "$git_dirty" ]]; then
    local_dirty=" ${FG_DIRTY}*${RST}"
  fi
  out+="${SEP_DOT}${FG_GIT}${branch}${RST}${local_dirty}"
fi

# 3. Model segment  ── model short-name
if [[ -n "$model" ]]; then
  smodel=$(short_model "$model")
  out+="${SEP_DOT}${FG_MODEL}${smodel}${RST}"
fi

# 4. Context segment  ── bar pct% used/total
if [[ -n "$used_pct" ]]; then
  pct=$(printf '%.0f' "$used_pct")

  # Pick colour based on usage level
  if [[ "$pct" -ge 80 ]]; then
    C_CTX="$FG_CTX_CRIT"
  elif [[ "$pct" -ge 50 ]]; then
    C_CTX="$FG_CTX_WARN"
  else
    C_CTX="$FG_CTX_OK"
  fi

  bar=$(mini_bar "$pct")
  used_fmt=$(fmt_tokens "$input_tok")
  total_fmt=$(fmt_tokens "$win_size")

  out+="${SEP_DOT}${C_CTX}${bar}${RST} ${FG_LABEL}${pct}%${RST} ${FG_DIM}${used_fmt}/${total_fmt}${RST}"
fi

printf '%s\n' "$out"
