# claude-statusline

A custom status line for [Claude Code](https://claude.ai/code) showing folder, git branch, model, context usage, and rate limits — all with color-coded progress bars.

## Install

**Requirements:** `bash`, `python3`, `curl` (standard on macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/videvjs/claude-statusline/main/install.sh | bash
```

That's it. Restart Claude Code.

> **macOS — Xcode Command Line Tools:** If this is your first time using `git` on this machine, macOS will interrupt the install and ask you to install Xcode Command Line Tools. Accept it, wait for the install to complete, then **run the curl command again**. The second run will complete normally.

### Windows

**Requirements:** [Git for Windows](https://git-scm.com/download/win) (provides Git Bash), `python3`, `git`, and **PowerShell 5.1 or newer**.

> **Which PowerShell?** The installer is tested on both **Windows PowerShell 5.1** (the built-in `powershell` on Windows 10/11 — no install needed) and **PowerShell 7+** ([`pwsh`](https://aka.ms/powershell)). Use whichever you have; `pwsh` is recommended when available (faster, fewer legacy quirks). The commands below work verbatim in both — for the local-clone command you can substitute `pwsh` for `powershell`.

The macOS/Linux installer above does not run on Windows. Use the PowerShell installer instead:

```powershell
# One-liner (no clone):
irm https://raw.githubusercontent.com/videvjs/claude-statusline/main/install.ps1 | iex
```

```powershell
# Or from a local clone:
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Claude Code (or just send a message — the status line updates on the next interaction).

**Why a separate installer?** On Windows, Claude Code runs status line commands through **Git Bash**. Two non-obvious traps the installer handles for you:

1. **Git Bash eats backslashes.** A Windows-style path like `C:\Users\you\.claude\statusline-command.sh` reaches the runner with its separators stripped, and the status line fails **silently** (blank, no error). The installer writes the command with forward slashes: `~/.claude/statusline-command.sh`.
2. **No flashing windows.** The status line is the bash script itself — there is no `pwsh`/`powershell` wrapper to spawn a console window on every refresh.

The installer also normalises the script to **LF** line endings (CRLF breaks bash) and merges the `statusLine` block into your existing `settings.json` (backed up to `settings.json.bak`).

**Manual setup** (equivalent to the installer): copy `statusline-command.sh` into `~/.claude/` (LF endings), then add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

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
