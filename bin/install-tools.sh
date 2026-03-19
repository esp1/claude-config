#!/usr/bin/env bash
set -euo pipefail

# Install tools (devbox, Claude Code) and symlink config into ~/.claude/.
# For bare-metal setup on macOS or Linux. See also devcontainer.sh for container usage.

# Resolve the repo root (one level up from bin/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Install tools (bare-metal only) ---

# Ensure curl is available (may be missing on minimal Debian)
if ! command -v curl &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    echo "Installing curl..."
    sudo apt-get update -qq && sudo apt-get install -y -qq curl
  else
    echo "ERROR: curl is required but not found" >&2
    exit 1
  fi
fi

# Install devbox if not present
if ! command -v devbox &>/dev/null; then
  echo "Installing devbox..."
  curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
fi

# Install tool dependencies globally via devbox
echo "Installing global tool dependencies via devbox..."
devbox global add jq
eval "$(devbox global shellenv --preserve-path-stack -r)"
hash -r

# Persist devbox shellenv in shell RC
if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
  _SHELL_RC="$HOME/.zshrc"
else
  _SHELL_RC="$HOME/.bashrc"
fi
if ! grep -q 'devbox global shellenv' "$_SHELL_RC" 2>/dev/null; then
  echo 'eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r' >> "$_SHELL_RC"
  echo "OK    devbox shellenv added to $_SHELL_RC"
fi

# Install Claude Code
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "OK    claude already installed ($(claude --version))"
fi

echo ""

# --- Symlink config into ~/.claude/ ---

source "$REPO_ROOT/bin/link-config.sh"
