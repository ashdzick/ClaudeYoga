# 🪑 ClaudeYoga

A tiny [Claude Code](https://docs.claude.com/en/docs/claude-code) status line
that nudges you to move. It shows a random chair-yoga stretch that rotates on a
fixed interval, so while you're deep in a session there's always a small
reminder to roll your shoulders, breathe, or look away from the screen.

```
🪑 Seated twist — hand to opposite knee, 20s each side  ·  next in 12m
```

The move stays put for the whole window (default 20 minutes) and then quietly
changes to the next one — no nagging, no notifications, just a gentle prompt
sitting at the bottom of your terminal.

## Install

```sh
git clone https://github.com/ashdzick/ClaudeYoga.git
cd ClaudeYoga
./install.sh
```

The installer copies `claude-yoga.sh` into `~/.claude/` and wires it up as your
status line. If you have [`jq`](https://jqlang.github.io/jq/) it edits
`settings.json` for you (keeping a backup); otherwise it prints the two-line
snippet to paste in. Restart Claude Code (or open a new session) and you'll see
it.

### Manual install

Copy the script anywhere and point your status line at it. In
`~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/claude-yoga.sh",
    "padding": 0
  }
}
```

## Configure

ClaudeYoga reads its settings from a config file at
`~/.config/claude-yoga/config.sh` (or `$CLAUDE_YOGA_CONFIG`), falling back to
environment variables, then built-in defaults.

```sh
mkdir -p ~/.config/claude-yoga
cp config.example.sh ~/.config/claude-yoga/config.sh
```

| Setting | Default | What it does |
| --- | --- | --- |
| `CLAUDE_YOGA_INTERVAL` | `1200` | Seconds before the move rotates (1200 = 20m). |
| `CLAUDE_YOGA_ICON` | `🪑` | The leading icon. |
| `CLAUDE_YOGA_MOVES_FILE` | *(built-in list)* | Path to your own list of moves. |
| `CLAUDE_YOGA_SHOW_NEXT` | `1` | Set to `0` to hide the "· next in Nm" countdown. |

### Your own moves

Make a text file with one move per line (blank lines and `#` comments are
ignored), then point `CLAUDE_YOGA_MOVES_FILE` at it. There's a ready-made
example in [`examples/desk-stretches.txt`](examples/desk-stretches.txt):

```sh
# in ~/.config/claude-yoga/config.sh
CLAUDE_YOGA_MOVES_FILE="$HOME/.config/claude-yoga/moves.txt"
```

## How it works

The status-line command runs on every refresh, so picking a *random* move each
time would make it flicker. Instead the script seeds the shell's `RANDOM` with
the current time divided by the interval — the "window index" — so every refresh
inside the same window lands on the same move, and the move changes exactly when
the window rolls over. No state files, no background process.

It's a single Bash script with no dependencies and runs on the stock macOS Bash
(3.2) as well as modern Bash and Linux.

## Uninstall

```sh
./uninstall.sh
```

Removes the script and clears the `statusLine` entry (with a backup) if you
installed it with `jq`.

## Contributing

Issues and PRs welcome — especially new stretches. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Ash Dzick
