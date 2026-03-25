#!/bin/bash

echo "Updating system..."
sudo apt update -y

echo "Installing Node.js..."
sudo apt install nodejs npm -y

echo "Installing dependencies..."
npm install

echo "Starting Node.js application..."
node server.js