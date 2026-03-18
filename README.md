# dot.claude

Version-controlled configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The contents of this repo are symlinked into `~/.claude/` so that settings, skills, rules, hooks, and agents can be tracked in git.

## What's included

| Path                    | Purpose                                                        |
|-------------------------|----------------------------------------------------------------|
| `CLAUDE.md`             | Global user instructions loaded into every conversation        |
| `settings.json`         | Global settings (env vars, statusline, plugins)                |
| `statusline-command.sh` | Custom statusline showing dir, git branch/status, model, context % |
| `skills/`               | Custom skills (Clojure editing, REPL, testing, Malli, doc-sync, etc.) |
| `rules/`                | Global rules (Clojure conventions, skill-creator guidelines)   |
| `hooks/`                | Hook definitions (doc-sync reminder on stop)                   |
| `agents/`               | Custom agent definitions (Clojure Malli expert)                |
| `.claude/`              | Project-local settings for this repo itself                    |

## Setup

Clone the repo and run the setup script to create symlinks:

```bash
git clone <repo-url> ~/Projects/AI/dot.claude
cd ~/Projects/AI/dot.claude
./setup.sh
```

The script will:
- Create `~/.claude/` if it doesn't exist
- Symlink each managed file/directory into `~/.claude/`
- Skip any symlinks that already point to the correct target
- Warn (without overwriting) if a non-symlink file already exists at a target path

## Adding new files

If you add a new top-level file or directory that should be symlinked, add it to the `MANAGED_ITEMS` array in `setup.sh` and re-run the script.
