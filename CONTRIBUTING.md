# Contributing to ClaudeYoga

Thanks for wanting to help! This is a deliberately tiny project, so
contributions stay simple.

## New stretches

The most welcome kind of PR. Add a line to the `moves` array in
`claude-yoga.sh`, matching the existing style:

```
"Name of move — short cue, duration or reps"
```

Keep them doable from (or right next to) a chair, safe to do without
supervision, and gentle. One clear cue per move.

## Code changes

- Keep it a single dependency-free Bash script that runs on macOS's stock
  Bash 3.2 (avoid `mapfile`, `declare -A`, `${var^^}`, and similar Bash-4-isms).
- Run [ShellCheck](https://www.shellcheck.net/) before opening a PR:

  ```sh
  shellcheck claude-yoga.sh install.sh uninstall.sh
  ```

  CI runs it on every push and pull request.
- Test it by piping empty input, since Claude Code feeds JSON on stdin:

  ```sh
  echo '{}' | ./claude-yoga.sh
  CLAUDE_YOGA_INTERVAL=60 CLAUDE_YOGA_SHOW_NEXT=0 ./claude-yoga.sh </dev/null
  ```

## Reporting issues

Open an issue with your OS, Bash version (`bash --version`), and what you saw
versus what you expected.
