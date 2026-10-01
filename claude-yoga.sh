#!/usr/bin/env bash
#
# ClaudeYoga — a Claude Code status line that nudges you to move.
#
# Prints a single random chair-yoga stretch that rotates on a fixed interval,
# so every status-line refresh within the same window shows the same move
# (and it changes to a new one when the window rolls over).
#
# Repo:    https://github.com/ashdzick/ClaudeYoga
# License: MIT
#
# Works with the stock macOS bash (3.2) as well as modern bash.

# Claude Code pipes session JSON on stdin; we don't use it. Drain it quietly.
cat >/dev/null 2>&1

# --- Configuration -----------------------------------------------------------
# Precedence (highest first): config file > environment variable > built-in default.
#
#   CLAUDE_YOGA_INTERVAL    seconds between moves          (default: 1200 = 20m)
#   CLAUDE_YOGA_ICON        leading icon                   (default: 🪑)
#   CLAUDE_YOGA_MOVES_FILE  path to a custom moves list    (default: built-in list)
#   CLAUDE_YOGA_SHOW_NEXT   1 = append "· next in Nm", 0 = hide (default: 1)
#
# Config file (a shell snippet sourced if present), searched in this order:
#   1) $CLAUDE_YOGA_CONFIG
#   2) ${XDG_CONFIG_HOME:-~/.config}/claude-yoga/config.sh

# Apply defaults only where an env var hasn't already set a value.
: "${CLAUDE_YOGA_INTERVAL:=1200}"
: "${CLAUDE_YOGA_ICON:=🪑}"
: "${CLAUDE_YOGA_MOVES_FILE:=}"
: "${CLAUDE_YOGA_SHOW_NEXT:=1}"

_config_file="${CLAUDE_YOGA_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/claude-yoga/config.sh}"
if [ -f "$_config_file" ]; then
  # shellcheck disable=SC1090
  . "$_config_file"
fi

# Sanitize the interval: must be a positive integer, else fall back to 20m.
case "$CLAUDE_YOGA_INTERVAL" in
  '' | *[!0-9]*) CLAUDE_YOGA_INTERVAL=1200 ;;
esac
[ "$CLAUDE_YOGA_INTERVAL" -lt 1 ] && CLAUDE_YOGA_INTERVAL=1200

# --- Moves -------------------------------------------------------------------
moves=(
  "Shoulder shrugs — lift to ears, drop, x10"
  "Shoulder rolls — 5 back, 5 forward"
  "Neck rolls — slow half-circles, 5 each way"
  "Ear to shoulder — hold 15s each side"
  "Seated cat-cow — arch & round, x8"
  "Seated twist — hand to opposite knee, 20s each side"
  "Side bend — arm overhead, lean, 15s each side"
  "Overhead reach — interlace fingers, stretch up, 5 breaths"
  "Chest opener — clasp hands behind back, lift, 5 breaths"
  "Seated forward fold — hang over knees, 5 breaths"
  "Ankle circles — 10 each way, each foot"
  "Seated figure-4 — ankle on knee, lean in, 20s each side"
  "Wrist circles & finger spreads — x10"
  "Eagle arms — wrap arms, lift elbows, 15s each side"
  "Seated march — lift knees alternately, x20"
  "Leg extensions — straighten one leg, hold 5s, x5 each"
  "Jaw release — open wide, then relax, x5"
  "Eye break — look 20ft away for 20s"
  "Box breathing — in 4, hold 4, out 4, hold 4, x4"
  "Seated pigeon — ankle on knee, sit tall, 20s each side"
)

# Replace the built-in list if a readable custom moves file is configured.
# Blank lines and lines beginning with '#' are ignored.
if [ -n "$CLAUDE_YOGA_MOVES_FILE" ] && [ -f "$CLAUDE_YOGA_MOVES_FILE" ]; then
  custom=()
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '' | \#*) continue ;;
    esac
    custom+=("$line")
  done < "$CLAUDE_YOGA_MOVES_FILE"
  [ "${#custom[@]}" -gt 0 ] && moves=("${custom[@]}")
fi

# --- Pick & print ------------------------------------------------------------
now=$(date +%s)
window=$CLAUDE_YOGA_INTERVAL

# Seed RANDOM with the window index so the same move holds for the whole window.
RANDOM=$(( now / window ))
idx=$(( RANDOM % ${#moves[@]} ))
move="${moves[idx]}"

if [ "$CLAUDE_YOGA_SHOW_NEXT" = "1" ]; then
  mins_left=$(( (window - now % window + 59) / 60 ))
  printf '%s %s  ·  next in %dm' "$CLAUDE_YOGA_ICON" "$move" "$mins_left"
else
  printf '%s %s' "$CLAUDE_YOGA_ICON" "$move"
fi
