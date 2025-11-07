#!/bin/bash
# SHAHCOIN Complete Genesis Initialization Script
# Runs all steps to prepare genesis for mainnet launch

set -e

echo "═══════════════════════════════════════════════════════════"
echo "     🚀 SHAHCOIN GENESIS INITIALIZATION 🚀"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "This script will:"
echo "  1. Initialize node"
echo "  2. Configure genesis parameters"
echo "  3. Create validator keys"
echo "  4. Add genesis accounts"
echo "  5. Create genesis transactions"
echo "  6. Collect gentxs"
echo "  7. Validate genesis"
echo "  8. Generate genesis hash"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Configuration
CHAIN_ID="shahcoin-1"
MONIKER="shahcoin-genesis"
HOME_DIR="$HOME/.shahd"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "STEP 1: Initialize Node"
echo "════════════════════════════════════════════════════════════"

# Check if already initialized
if [ -d "$HOME_DIR/config" ]; then
    echo "⚠️  Node already initialized at $HOME_DIR"
    read -p "   Reset and reinitialize? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🧹 Resetting..."
        rm -rf "$HOME_DIR"
    else
        echo "   Skipping initialization..."
    fi
fi

if [ ! -d "$HOME_DIR/config" ]; then
    echo "🔧 Initializing node..."
    ./build/shahd init "$MONIKER" --chain-id "$CHAIN_ID" --home "$HOME_DIR"
    echo "✅ Node initialized"
fi
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 2: Configure Genesis Parameters"
echo "════════════════════════════════════════════════════════════"
chmod +x scripts/configure_genesis.sh
./scripts/configure_genesis.sh
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 3: Create Validator Keys"
echo "════════════════════════════════════════════════════════════"
chmod +x scripts/setup_validators.sh
./scripts/setup_validators.sh
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 4: Add Genesis Accounts"
echo "════════════════════════════════════════════════════════════"
chmod +x scripts/add_genesis_accounts.sh
./scripts/add_genesis_accounts.sh
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 5: Create Genesis Transactions"
echo "════════════════════════════════════════════════════════════"
chmod +x scripts/create_gentxs.sh
./scripts/create_gentxs.sh
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 6: Collect Genesis Transactions"
echo "════════════════════════════════════════════════════════════"
echo "🔧 Collecting gentxs..."
./build/shahd genesis collect-gentxs --home "$HOME_DIR"
echo "✅ Gentxs collected"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 7: Validate Final Genesis"
echo "════════════════════════════════════════════════════════════"
echo "🔍 Validating genesis..."
if ./build/shahd genesis validate-genesis "$HOME_DIR/config/genesis.json"; then
    echo "✅ Genesis validation PASSED!"
else
    echo "❌ Genesis validation FAILED!"
    exit 1
fi
echo ""

echo "════════════════════════════════════════════════════════════"
echo "STEP 8: Generate Genesis Hash"
echo "════════════════════════════════════════════════════════════"
GENESIS_HASH=$(sha256sum "$HOME_DIR/config/genesis.json" | awk '{print $1}')
echo "📝 Genesis Hash (SHA-256):"
echo "   $GENESIS_HASH"
echo ""
echo "💾 Saving hash to file..."
echo "$GENESIS_HASH" > "$HOME_DIR/config/genesis_hash.txt"
echo "   Saved to: $HOME_DIR/config/genesis_hash.txt"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "     ✅ GENESIS INITIALIZATION COMPLETE! ✅"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Display all validator addresses
echo "📋 Validator Information:"
echo "═══════════════════════════════════════════════════════════"
if [ -f "$HOME_DIR/keys_backup/validators.json" ]; then
    cat "$HOME_DIR/keys_backup/validators.json" | grep -E "name|address" | head -20
fi
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📁 Important Files:"
echo "═══════════════════════════════════════════════════════════"
echo "  Genesis: $HOME_DIR/config/genesis.json"
echo "  Genesis Hash: $HOME_DIR/config/genesis_hash.txt"
echo "  Node Key: $HOME_DIR/config/node_key.json"
echo "  Validator Keys: $HOME_DIR/keys_backup/"
echo "  Config: $HOME_DIR/config/config.toml"
echo "  App Config: $HOME_DIR/config/app.toml"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "🚀 Next Steps:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. BACKUP YOUR KEYS (CRITICAL!):"
echo "   cp -r $HOME_DIR/keys_backup /secure/location/"
echo "   Store passwords in password manager"
echo ""
echo "2. Test start the node locally:"
echo "   ./build/shahd start --home $HOME_DIR"
echo "   (Press Ctrl+C to stop)"
echo ""
echo "3. Push to GitHub (AFTER testing):"
echo "   ./scripts/prepare_github.sh"
echo ""
echo "4. Deploy to VPS servers:"
echo "   ./scripts/deploy_to_vps.sh"
echo ""
echo "5. Configure domain (shah.vip):"
echo "   See docs/DEPLOYMENT.md"
echo ""
echo "6. Coordinate mainnet launch with all validators"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Save summary
SUMMARY_FILE="$HOME_DIR/genesis_summary.txt"
cat > "$SUMMARY_FILE" << EOF
SHAHCOIN Genesis Summary
========================

Chain ID: $CHAIN_ID
Genesis Time: $(jq -r '.genesis_time' "$HOME_DIR/config/genesis.json")
Genesis Hash: $GENESIS_HASH

Validators:
-----------
$(cat "$HOME_DIR/keys_backup/addresses.txt")

Total Supply: 63,000,000 SHAH
Total Staked: 40,000,000 SHAH (63.5%)
Remaining Liquid: 23,000,000 SHAH (36.5%)

Genesis File: $HOME_DIR/config/genesis.json
Keys Backup: $HOME_DIR/keys_backup/

Generated: $(date)
EOF

echo "📄 Summary saved to: $SUMMARY_FILE"
echo ""
echo "🎉 Ready for mainnet launch!"
echo ""
