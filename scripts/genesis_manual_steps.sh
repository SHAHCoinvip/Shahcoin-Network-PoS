#!/bin/bash
# SHAHCOIN Manual Genesis Steps
# Workaround for keyring issues - creates keys one at a time

set -e

echo "🔑 SHAHCOIN Manual Key Creation"
echo "================================"
echo ""
echo "Due to a keyring issue in SDK 0.50.10, we'll create keys manually."
echo "Save the addresses shown after each key creation!"
echo ""

HOME_DIR="$HOME/.shahd"
CHAIN_ID="shahcoin-1"

# Clean start
rm -rf ~/.shahd
./build/shahd init shahcoin-genesis --chain-id $CHAIN_ID --home $HOME_DIR > /dev/null 2>&1

echo "Creating keys with test backend (no passwords)..."
echo ""

echo "1. Creating founder key..."
./build/shahd keys add founder --keyring-backend test --home $HOME_DIR
echo ""
read -p "Copy the address above and press Enter..."

echo ""
echo "2. Creating validator1 key..."
./build/shahd keys add validator1 --keyring-backend test --home $HOME_DIR
echo ""
read -p "Copy the address above and press Enter..."

echo ""
echo "3. Creating validator2 key..."
./build/shahd keys add validator2 --keyring-backend test --home $HOME_DIR
echo ""
read -p "Copy the address above and press Enter..."

echo ""
echo "4. Creating validator3 key..."
./build/shahd keys add validator3 --keyring-backend test --home $HOME_DIR  
echo ""
read -p "Copy the address above and press Enter..."

echo ""
echo "5. Creating validator4 key..."
./build/shahd keys add validator4 --keyring-backend test --home $HOME_DIR
echo ""
read -p "Copy the address above and press Enter..."

echo ""
echo "✅ All keys created!"
echo ""
echo "Now manually add them to genesis.json and continue..."
echo ""

