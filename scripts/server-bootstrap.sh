#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/devops-webapp"

echo "[1/7] Updating package index..."
sudo apt-get update -y

echo "[2/7] Installing required packages..."
sudo apt-get install -y ca-certificates curl gnupg git

echo "[3/7] Installing Docker official repository..."
sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[4/7] Installing Docker Engine and Compose plugin..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[5/7] Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[6/7] Adding current user to docker group..."
sudo usermod -aG docker "$USER"

echo "[7/7] Preparing application directory..."
sudo mkdir -p "$APP_DIR"
sudo chown -R "$USER:$USER" "$APP_DIR"

echo
echo "Bootstrap completed."
echo "Docker version:"
docker --version || true
echo
echo "Docker Compose version:"
docker compose version || true
echo
echo "IMPORTANT: log out and log in again, or run: newgrp docker"
