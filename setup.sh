#!/usr/bin/env bash
set -euo pipefail

# Resolve the directory this script lives in (the repo root)
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.claude"

# Files and directories to symlink into ~/.claude
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
