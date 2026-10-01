#!/usr/bin/env bash
#
# ClaudeYoga uninstaller. Removes the status-line script and, if `jq` is
# available, clears the statusLine entry from settings.json (with a backup).

set -eu

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/claude-yoga.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

if [ -f "$DEST" ]; then
  rm -f "$DEST"
  echo "✓ Removed $DEST"
else
  echo "• No script found at $DEST (already gone)"
fi

if command -v jq >/dev/null 2>&1 && [ -f "$SETTINGS" ]; then
  if jq -e '.statusLine.command | test("claude-yoga")' "$SETTINGS" >/dev/null 2>&1; then
    cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
    tmp="$(mktemp)"
    jq 'del(.statusLine)' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    echo "✓ Removed statusLine from $SETTINGS (backup saved)"
  else
    echo "• statusLine in $SETTINGS doesn't point at ClaudeYoga — left untouched"
  fi
else
  echo "• Remove the \"statusLine\" entry from $SETTINGS by hand if you added it."
fi

echo "Done."
