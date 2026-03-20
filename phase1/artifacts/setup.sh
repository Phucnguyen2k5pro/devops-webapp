#!/usr/bin/env bash
set -e

echo "[1/6] Updating package index..."
sudo apt update

echo "[2/6] Installing required system packages..."
sudo apt install -y curl git build-essential

if ! command -v node >/dev/null 2>&1; then
  echo "[3/6] Installing Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "[3/6] Node.js already installed: $(node -v)"
fi

echo "[4/6] Installing PM2 globally..."
sudo npm install -g pm2

echo "[5/6] Preparing application directories..."
mkdir -p public/uploads logs
touch public/uploads/.gitkeep logs/.gitkeep

echo "[6/6] Installing project dependencies..."
npm install

echo ""
echo "Setup completed successfully."
echo "Next steps:"
echo "  1. Copy .env.example to .env"
echo "  2. Update MONGO_URI if needed"
echo "  3. Start the app with: npm start"
echo "  4. For Phase 2, run with PM2 using main.js"