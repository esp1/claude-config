#!/usr/bin/env bash
set -euo pipefail

# Build and run the Claude Code devcontainer with Podman.
#
# Usage:
#   ./devcontainer.sh
#   ANTHROPIC_API_KEY=sk-ant-... ./devcontainer.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="claude-code"

# --- Get API key ---

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  printf "Enter your Anthropic API key: "
  read -rs ANTHROPIC_API_KEY
  echo ""
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "ERROR: API key is required" >&2
    exit 1
  fi
fi

# --- Ensure Podman is available ---

if ! command -v podman &>/dev/null; then
  echo "ERROR: podman is required but not found" >&2
  echo "       Install it from https://podman.io/docs/installation" >&2
  exit 1
fi

# --- Build image ---

echo "Building container image..."
podman build -t "$IMAGE_NAME" -f "$REPO_ROOT/.devcontainer/Dockerfile" "$REPO_ROOT/.devcontainer"

# --- Run container ---

echo "Starting Claude Code..."
exec podman run -it --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$REPO_ROOT:/opt/dot.claude:ro" \
  --user vscode \
  "$IMAGE_NAME" \
  bash -c "/opt/dot.claude/.devcontainer/post-create.sh && exec claude"
