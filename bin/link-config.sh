#!/usr/bin/env bash
set -euo pipefail

# Symlink dot.claude/ config into ~/.claude/
# Sourced by bin/setup.sh (bare metal) and .devcontainer/post-create.sh (container).
# Expects REPO_ROOT to be set by the caller.

: "${REPO_ROOT:?REPO_ROOT must be set}"
REPO_DIR="$REPO_ROOT/dot.claude"
TARGET_DIR="$HOME/.claude"

MANAGED_ITEMS=(
  CLAUDE.md
  settings.json
  statusline-command.sh
  skills
  rules
  hooks
  agents
)

mkdir -p "$TARGET_DIR"

for item in "${MANAGED_ITEMS[@]}"; do
  source="$REPO_DIR/$item"
  target="$TARGET_DIR/$item"

  if [ ! -e "$source" ]; then
    echo "SKIP  $item (not found in repo)"
    continue
  fi

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    if [ "$current" = "$source" ]; then
      echo "OK    $item (already linked)"
      continue
    else
      echo "UPDATE $item (repointing symlink)"
      rm "$target"
    fi
  elif [ -e "$target" ]; then
    echo "WARN  $item already exists and is not a symlink — skipping (back up and remove it to proceed)"
    continue
  fi

  ln -s "$source" "$target"
  echo "LINK  $item -> $source"
done

echo ""
echo "Done. Symlinks are in $TARGET_DIR"
