#!/bin/bash
set -e

# ----------------------------------------------------------------------
# Script: master.sh
# Description: Provisions the Salt Master node.
#   1. Installs Salt Master dependencies.
#   2. Configures the official Salt Project repository (Broadcom).
#   3. Enables 'auto_accept' for easier demo onboarding.
#   4. Links the /vagrant/salt folder to /srv/salt for host editing.
# ----------------------------------------------------------------------

echo "[*] Installing Salt master"

# Install basic utilities
sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 git micro tree bash-completion

sudo mkdir -p /etc/apt/keyrings

#######################################
# Salt Keyring Configuration
# We compare the new key with the existing one to ensure idempotency.
# Only overwrite if the key has changed.
#######################################

TMP_KEY=/tmp/salt-key.pgp
# Note: SaltStack repo moved to Broadcom recently.
wget -q -O "$TMP_KEY" \
  https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public

if ! cmp -s "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp 2>/dev/null; then
  echo "[*] Updating Salt keyring"
  sudo cp "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp
fi

#######################################
# Salt APT Source Configuration
# Only update if changed
#######################################

TMP_SRC=/tmp/salt.sources
wget -q -O "$TMP_SRC" \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

DEST_SRC=/etc/apt/sources.list.d/salt.sources

if ! cmp -s "$TMP_SRC" "$DEST_SRC" 2>/dev/null; then
  echo "[*] Updating Salt sources.list entry"
  sudo cp "$TMP_SRC" "$DEST_SRC"
fi

# Install Master service
sudo apt-get update -y
sudo apt-get install -y salt-master

#######################################
# Master Configuration: Auto Accept Minions
# CRITICAL FOR DEMO: Automatically accepts keys from new minions.
# WARNING: Do not use this in a production environment!
#######################################

grep -qxF "auto_accept: True" /etc/salt/master || echo "auto_accept: True" | sudo tee -a /etc/salt/master

# Restart service to apply config
sudo systemctl stop salt-master
sudo systemctl start salt-master
sudo systemctl enable --now salt-master

#######################################
# Developer Experience: Synced Folders
# Link /vagrant/salt (synced from Host) to /srv/salt (Salt's default).
# This allows editing .sls files in the host/VS Code instantly.
#######################################

# Remove default empty directory if it exists and is not a symlink
if [ -d /srv/salt ] && [ ! -L /srv/salt ]; then
    sudo rm -rf /srv/salt
fi

# Create the symlink
if [ ! -L /srv/salt ]; then
    echo "[*] Linking /vagrant/salt to /srv/salt"
    sudo ln -s /vagrant/salt /srv/salt
fi

echo "[*] Salt master provisioned successfully"