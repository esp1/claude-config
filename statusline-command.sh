#!/usr/bin/env bash

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
home="$HOME"

# Shorten home directory to ~
if [[ "$cwd" == "$home"* ]]; then
  rel_dir="~${cwd#$home}"
else
  rel_dir="$cwd"
fi

# Git info
branch=""
git_status=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

  # Git status indicators
  status_output=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=""
  modified=""
  untracked=""

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    x="${line:0:1}"
    y="${line:1:1}"
    # Staged changes (index)
    if [[ "$x" =~ [MADRC] ]]; then
      staged="+"
    fi
    # Unstaged changes (worktree)
    if [[ "$y" =~ [MD] ]]; then
      modified="!"
    fi
    # Untracked files
    if [[ "$x" == "?" ]]; then
      untracked="?"
    fi
  done <<< "$status_output"

  git_status="${staged}${modified}${untracked}"

  if [ -n "$branch" ]; then
    if [ -n "$git_status" ]; then
      branch=" 🌱($branch $git_status)"
    else
      branch=" 🌱($branch)"
    fi
  fi
fi

model=$(echo "$input" | jq -r '.model.display_name')

# Context window bar
pct=$(echo "$input" | jq '.context_window.used_percentage // 0')
if [ -n "$pct" ]; then
  pct=${pct%.*}
  filled=$((pct / 5))
  empty=$((20 - filled))
  bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  # Color based on usage percentage
  if [ "$pct" -ge 80 ]; then
    color='31'  # red
  elif [ "$pct" -ge 60 ]; then
    color='33'  # yellow
  else
    color='32'  # green
  fi
fi

format_statusline() {
  printf '📁\033[36m%s\033[0m \033[34m%s\033[0m  🧠\033[35m%s\033[0m  \033[%sm%s\033[0m' "$rel_dir" "$branch" "$model" "$color" "$bar"
}

format_statusline
