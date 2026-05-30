# claude-statusline

A custom status line for [Claude Code](https://claude.ai/code) showing folder, git branch, model, context usage, and rate limits — all with color-coded progress bars.

## Install

**Requirements:** `bash`, `python3`, `curl` (standard on macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/videvjs/claude-statusline/main/install.sh | bash
```

That's it. Restart Claude Code.

> **macOS — Xcode Command Line Tools:** If this is your first time using `git` on this machine, macOS will interrupt the install and ask you to install Xcode Command Line Tools. Accept it, wait for the install to complete, then **run the curl command again**. The second run will complete normally.

## What it shows

`/project-name | (main) | claude-opus-4-6 | ctx [████████░░] 78% | 5h [███░░░░░░░] 28% Reset in 1h42m`

| Segment | Description |
|---|---|
| `/folder` | Current project directory |
| `(branch)` | Git branch or short commit hash |
| Model | Active model name + effort level if set |
| `ctx` | Context window usage (blue → yellow → red) |
| `5h` | 5-hour rate limit with countdown to reset |
| `7d` | 7-day rate limit (only shown above 30%) |

## Uninstall

Remove the `statusLine` block from `~/.claude/settings.json` and delete `~/.claude/statusline-command.sh`.
