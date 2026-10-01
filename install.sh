#!/usr/bin/env bash
#
# ClaudeYoga installer.
# Copies claude-yoga.sh into your Claude Code config dir and wires it up as the
# status line. If `jq` is available it patches settings.json for you (with a
# backup); otherwise it prints the snippet to add by hand.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/claude-yoga.sh"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/claude-yoga.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

if [ ! -f "$SRC" ]; then
  echo "error: cannot find claude-yoga.sh next to this installer." >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
cp "$SRC" "$DEST"
chmod +x "$DEST"
echo "✓ Installed status-line script → $DEST"

# Use a tilde path in settings so it's portable across machines.
CMD="~/.claude/claude-yoga.sh"
[ "$CLAUDE_DIR" != "$HOME/.claude" ] && CMD="$DEST"

if command -v jq >/dev/null 2>&1; then
  if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
    echo "✓ Backed up existing settings.json"
  else
    echo '{}' > "$SETTINGS"
  fi
  tmp="$(mktemp)"
  jq --arg cmd "$CMD" \
    '.statusLine = {type: "command", command: $cmd, padding: 0}' \
    "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "✓ Wired up statusLine in $SETTINGS"
  echo
  echo "Done! Restart Claude Code (or start a new session) to see it."
else
  echo
  echo "jq not found — add this to $SETTINGS yourself:"
  echo
  cat <<EOF
  "statusLine": {
    "type": "command",
    "command": "$CMD",
    "padding": 0
  }
EOF
  echo
  echo "Then restart Claude Code to see it."
fi
