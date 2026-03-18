# dot.claude

Version-controlled configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). The contents of `dot.claude/` are symlinked into `~/.claude/` so that settings, skills, rules, hooks, and agents can be tracked in git.

## What's included

| Path                            | Purpose                                                        |
|---------------------------------|----------------------------------------------------------------|
| `dot.claude/CLAUDE.md`          | Global user instructions loaded into every conversation        |
| `dot.claude/settings.json`      | Global settings (env vars, statusline, plugins)                |
| `dot.claude/statusline-command.sh` | Custom statusline showing dir, git branch/status, model, context % |
| `dot.claude/skills/`            | Custom skills (Clojure editing, REPL, testing, Malli, doc-sync, etc.) |
| `dot.claude/rules/`             | Global rules (Clojure conventions, skill-creator guidelines)   |
| `dot.claude/hooks/`             | Hook definitions (doc-sync reminder on stop)                   |
| `dot.claude/agents/`            | Custom agent definitions (Clojure Malli expert)                |
| `bin/`                          | Scripts (bootstrap, setup, devcontainer, link-config)          |
| `.devcontainer/`                | Podman devcontainer definition                                 |
| `.claude/`                      | Project-local settings for this repo itself                    |

## Prerequisites

The statusline script requires `jq`. The setup script handles this automatically — it installs [devbox](https://www.jetify.com/devbox) if not already present, then uses `devbox global add jq` to make it available system-wide.

## Bootstrap (fresh machine)

Copy `bin/bootstrap.sh` to the new machine and run it:

```bash
bash bootstrap.sh
```

This will install git and curl (if needed), write `~/.gitconfig`, clone the repo (git will prompt for credentials), and run `bin/install-tools.sh`. Override the clone location with `REPO_DIR`:

```bash
REPO_DIR=~/my/path bash bootstrap.sh
```

## Setup (existing clone)

If the repo is already cloned, run the setup script directly:

```bash
cd ~/Projects/AI/dot.claude
./bin/install-tools.sh
```

The script will:
- Install devbox if not already present
- Install `jq` globally via `devbox global add`
- Create `~/.claude/` if it doesn't exist
- Symlink each managed item from `dot.claude/` into `~/.claude/`
- Skip any symlinks that already point to the correct target
- Warn (without overwriting) if a non-symlink file already exists at a target path

## Devcontainer (Podman)

For an isolated, reproducible environment, use the devcontainer with Podman:

```bash
./bin/devcontainer.sh
```

The script builds the container image, prompts for your Anthropic API key (or pass it via `ANTHROPIC_API_KEY` env var), and drops you into Claude Code. The repo is mounted read-only at `/opt/dot.claude` and symlinked into `~/.claude/`.

## Adding new files

If you add a new file or directory to `dot.claude/` that should be symlinked, add it to the `MANAGED_ITEMS` array in `bin/link-config.sh` and re-run setup.
