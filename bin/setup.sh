#!/usr/bin/env bash
set -euo pipefail

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
devbox global add jq nodejs

# Install Claude Code
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
else
  echo "OK    claude already installed ($(claude --version))"
fi

echo ""

# --- Symlink config into ~/.claude/ ---

source "$REPO_ROOT/bin/link-config.sh"
