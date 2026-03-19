#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a fresh machine with git, dotfiles, and Claude Code config.
#
# Usage:
#   bash bootstrap.sh
#   REPO_DIR=~/custom/path bash bootstrap.sh
#
# REPO_DIR: Where to clone the repo (default: ~/Projects/AI/claude-config)

REPO_DIR="${REPO_DIR:-$HOME/Projects/AI/claude-config}"

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
  echo "Cloning claude-config into $REPO_DIR..."
  echo "Git will prompt for your GitHub credentials if needed."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone https://github.com/esp1/claude-config.git "$REPO_DIR"
fi

# --- Run setup ---

echo ""
"$REPO_DIR/bin/install-tools.sh"

# --- Done ---

echo ""
echo "Done! Run 'claude login' to authenticate, then 'claude' to start."
