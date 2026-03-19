#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a fresh machine with git, dotfiles, and Claude Code config.
#
# Usage:
#   bash bootstrap.sh
#   REPO_DIR=~/custom/path bash bootstrap.sh
#
# REPO_DIR: Where to clone the repo (default: ~/Projects/AI/dot.claude)

REPO_DIR="${REPO_DIR:-$HOME/Projects/AI/dot.claude}"

# --- Install prerequisites ---

install_pkg() {
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq "$@"
  elif command -v brew &>/dev/null; then
    brew install "$@"
  else
    echo "ERROR: No supported package manager found (need apt-get or brew)" >&2
    exit 1
  fi
}

for cmd in curl git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Installing $cmd..."
    install_pkg "$cmd"
  fi
done

# --- Install .gitconfig ---

if [ ! -f "$HOME/.gitconfig" ]; then
  echo "Installing .gitconfig..."
  cat > "$HOME/.gitconfig" << 'EOF'
[alias]
	st = status
	ci = commit
	co = checkout
	sub = submodule
	wt = worktree
[user]
	name = Edwin Park
	email = esp1@cornell.edu
EOF
  echo "OK    .gitconfig installed"
else
  echo "SKIP  .gitconfig already exists"
fi

# --- Clone repo (git will prompt for credentials if needed) ---

if [ -d "$REPO_DIR/.git" ]; then
  echo "SKIP  repo already cloned at $REPO_DIR"
else
  echo ""
  echo "Cloning dot.claude into $REPO_DIR..."
  echo "Git will prompt for your GitHub credentials if needed."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone https://github.com/esp1/claude-config.git "$REPO_DIR"
fi

# --- Run setup ---

echo ""
"$REPO_DIR/bin/install-tools.sh"

# --- Persist Anthropic API key ---

# Determine shell RC file
if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
  SHELL_RC="$HOME/.zshrc"
else
  SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q ANTHROPIC_API_KEY "$SHELL_RC" 2>/dev/null; then
  echo ""
  read -rp "Enter your Anthropic API key (or press Enter to skip): " api_key
  if [ -n "$api_key" ]; then
    echo "export ANTHROPIC_API_KEY='$api_key'" >> "$SHELL_RC"
    echo "OK    API key saved to $SHELL_RC"
  else
    echo "SKIP  API key (set ANTHROPIC_API_KEY later)"
  fi
fi

# --- Done ---

echo ""
echo "Done! Run 'source $SHELL_RC' (or start a new shell), then run 'claude'."
