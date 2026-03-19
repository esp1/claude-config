#!/usr/bin/env bash
set -euo pipefail

# Create a Hetzner Cloud server and bootstrap it for Claude Code development.
#
# Prerequisites:
#   - devbox installed (for hcloud CLI)
#   - hcloud context active (hcloud context create <name>)
#   - SSH key registered in Hetzner Cloud
#
# Usage:
#   ./hetzner-create.sh                          # uses defaults
#   SERVER_NAME=my-dev SERVER_TYPE=cx32 ./hetzner-create.sh
#
# Environment variables:
#   SERVER_NAME   Name for the server          (default: claude-dev)
#   SERVER_TYPE   Hetzner server type          (default: cax11)
#   IMAGE         OS image                     (default: ubuntu-24.04)
#   LOCATION      Datacenter location          (default: nbg1)
#   SSH_KEY       Name of SSH key in Hetzner   (auto-detected if only one exists)

SERVER_NAME="${SERVER_NAME:-claude-dev}"
SERVER_TYPE="${SERVER_TYPE:-cax11}"
IMAGE="${IMAGE:-ubuntu-24.04}"
LOCATION="${LOCATION:-nbg1}"

# --- Install hcloud via devbox ---

if ! command -v hcloud &>/dev/null; then
  echo "Installing hcloud via devbox..."
  devbox global add hcloud
fi

if [ -z "$(hcloud context active 2>/dev/null)" ]; then
  echo "ERROR: No active hcloud context." >&2
  echo "" >&2
  echo "To fix this:" >&2
  echo "  1. Get an API token from Hetzner Cloud Console → Security → API Tokens" >&2
  echo "  2. Run: hcloud context create <name>" >&2
  echo "     (it will prompt for your token)" >&2
  exit 1
fi

# --- Detect SSH key ---

if [ -z "${SSH_KEY:-}" ]; then
  key_count=$(hcloud ssh-key list -o noheader | wc -l | tr -d ' ')
  if [ "$key_count" -eq 0 ]; then
    echo "ERROR: No SSH keys found in Hetzner Cloud." >&2
    echo "       Add one with: hcloud ssh-key create --name mykey --public-key-from-file ~/.ssh/id_ed25519.pub" >&2
    exit 1
  elif [ "$key_count" -eq 1 ]; then
    SSH_KEY=$(hcloud ssh-key list -o noheader -o columns=name)
    echo "Using SSH key: $SSH_KEY"
  else
    echo "ERROR: Multiple SSH keys found. Set SSH_KEY=<name> to choose one." >&2
    hcloud ssh-key list
    exit 1
  fi
fi

# --- Create server ---

echo "Creating server '$SERVER_NAME' ($SERVER_TYPE, $IMAGE, $LOCATION)..."
hcloud server create \
  --name "$SERVER_NAME" \
  --type "$SERVER_TYPE" \
  --image "$IMAGE" \
  --location "$LOCATION" \
  --ssh-key "$SSH_KEY" \
  --user-data-from-file <(cat <<'CLOUDINIT'
#!/usr/bin/env bash
set -euo pipefail

apt-get update -qq && apt-get install -y -qq curl git

# Create dev user with sudo
useradd -m -s /bin/bash dev
echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev

# Copy SSH authorized keys from root to dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/authorized_keys
chown -R dev:dev /home/dev/.ssh
chmod 700 /home/dev/.ssh
chmod 600 /home/dev/.ssh/authorized_keys

# Run bootstrap as dev user
su - dev -c 'curl -fsSL https://raw.githubusercontent.com/esp1/claude-config/main/bin/bootstrap.sh | bash'
CLOUDINIT
)

# --- Wait for server to be running ---

IP=$(hcloud server ip "$SERVER_NAME")

# --- Upsert SSH config entry ---

SSH_CONFIG="$HOME/.ssh/config"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

if grep -q "^Host $SERVER_NAME\$" "$SSH_CONFIG"; then
  # Update existing entry's HostName
  sed -i.bak "/^Host $SERVER_NAME\$/,/^Host / s/^  HostName .*/  HostName $IP/" "$SSH_CONFIG"
  rm -f "$SSH_CONFIG.bak"
  echo "Updated SSH config entry for $SERVER_NAME → $IP"
else
  # Append new entry
  printf '\nHost %s\n  HostName %s\n  User dev\n' "$SERVER_NAME" "$IP" >> "$SSH_CONFIG"
  echo "Added SSH config entry for $SERVER_NAME → $IP"
fi

echo ""
echo "Server created!"
echo "  Name:  $SERVER_NAME"
echo "  IP:    $IP"
echo "  User:  dev"
echo ""
echo "Cloud-init is bootstrapping in the background (installs devbox, Node.js, Claude Code)."
echo "You can monitor progress with:"
echo "  ssh $SERVER_NAME -l root tail -f /var/log/cloud-init-output.log"
echo ""
echo "Once ready, connect and set your API key:"
echo "  ssh $SERVER_NAME"
echo "  export ANTHROPIC_API_KEY='sk-ant-...'"
echo "  claude"
