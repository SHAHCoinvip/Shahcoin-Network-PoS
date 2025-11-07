#!/bin/bash
# SHAHCOIN Final Working Genesis Script
set -e

echo "🚀 SHAHCOIN Genesis Setup (Final Working Version)"
echo "=================================================="
echo ""

# Use the binary's default home
HOME_DIR="$HOME/.shah"
CHAIN_ID="shahcoin-1"

# Clean everything
echo "🧹 Cleaning old data..."
rm -rf "$HOME_DIR"
echo ""

# Initialize
echo "🔧 Initializing node..."
./build/shahd init shahcoin-genesis --chain-id $CHAIN_ID
echo ""

# Configure genesis
echo "⚙️  Configuring genesis..."
jq '.app_state.staking.params.bond_denom = "shahi"' $HOME_DIR/config/genesis.json > /tmp/g.json && mv /tmp/g.json $HOME_DIR/config/genesis.json
jq '.app_state.mint.params.mint_denom = "shahi"' $HOME_DIR/config/genesis.json > /tmp/g.json && mv /tmp/g.json $HOME_DIR/config/genesis.json
jq '.app_state.gov.params.min_deposit[0].denom = "shahi"' $HOME_DIR/config/genesis.json > /tmp/g.json && mv /tmp/g.json $HOME_DIR/config/genesis.json
jq '.app_state.gov.params.expedited_min_deposit[0].denom = "shahi"' $HOME_DIR/config/genesis.json > /tmp/g.json && mv /tmp/g.json $HOME_DIR/config/genesis.json
echo "✅ Genesis configured with shahi denom"
echo ""

# Create keys WITHOUT redirecting (so they save properly to keyring)
echo "🔑 Creating keys..."
mkdir -p $HOME_DIR/keys_backup

echo ""
echo "⚠️  SAVE THE MNEMONICS THAT APPEAR BELOW!"
echo ""

echo "Creating founder..."
./build/shahd keys add founder --keyring-backend test | tee $HOME_DIR/keys_backup/founder.txt
echo ""

echo "Creating validator1..."
./build/shahd keys add validator1 --keyring-backend test | tee $HOME_DIR/keys_backup/validator1.txt
echo ""

echo "Creating validator2..."
./build/shahd keys add validator2 --keyring-backend test | tee $HOME_DIR/keys_backup/validator2.txt
echo ""

echo "Creating validator3..."
./build/shahd keys add validator3 --keyring-backend test | tee $HOME_DIR/keys_backup/validator3.txt
echo ""

echo "Creating validator4..."
./build/shahd keys add validator4 --keyring-backend test | tee $HOME_DIR/keys_backup/validator4.txt
echo ""

echo "✅ All keys created and saved to $HOME_DIR/keys_backup/"
echo ""

# Add to genesis (use key names, not addresses)
echo "💰 Adding genesis accounts..."
./build/shahd genesis add-genesis-account founder 1575000000000000shahi --keyring-backend test
./build/shahd genesis add-genesis-account validator1 1575000000000000shahi --keyring-backend test
./build/shahd genesis add-genesis-account validator2 1575000000000000shahi --keyring-backend test
./build/shahd genesis add-genesis-account validator3 1575000000000000shahi --keyring-backend test
./build/shahd genesis add-genesis-account validator4 1575000000000000shahi --keyring-backend test
echo "✅ Genesis accounts added (63M SHAH total)"
echo ""

# Create gentxs
echo "📜 Creating genesis transactions..."
./build/shahd genesis gentx validator1 1000000000000000shahi --chain-id $CHAIN_ID --moniker "Validator 1" --keyring-backend test
./build/shahd genesis gentx validator2 1000000000000000shahi --chain-id $CHAIN_ID --moniker "Validator 2" --keyring-backend test
./build/shahd genesis gentx validator3 1000000000000000shahi --chain-id $CHAIN_ID --moniker "Validator 3" --keyring-backend test
./build/shahd genesis gentx validator4 1000000000000000shahi --chain-id $CHAIN_ID --moniker "Validator 4" --keyring-backend test
echo "✅ Gentxs created"
echo ""

# Collect
echo "📥 Collecting gentxs..."
./build/shahd genesis collect-gentxs
echo "✅ Gentxs collected"
echo ""

# Validate
echo "🔍 Validating genesis..."
./build/shahd genesis validate-genesis $HOME_DIR/config/genesis.json
echo ""

# Hash
HASH=$(sha256sum $HOME_DIR/config/genesis.json | awk '{print $1}')
echo "═══════════════════════════════════════════════════════════"
echo "✅ GENESIS READY!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📊 Summary:"
echo "  Chain ID: $CHAIN_ID"
echo "  Total Supply: 63,000,000 SHAH"
echo "  Staked: 40,000,000 SHAH (63.5%)"
echo "  Liquid: 23,000,000 SHAH (36.5%)"
echo ""
echo "🔑 Addresses:"
echo "  founder: $FOUNDER"
echo "  validator1: $VAL1"
echo "  validator2: $VAL2"
echo "  validator3: $VAL3"
echo "  validator4: $VAL4"
echo ""
echo "📁 Files:"
echo "  Genesis: $HOME_DIR/config/genesis.json"
echo "  Genesis Hash: $HASH"
echo "  Keys Backup: $HOME_DIR/keys_backup/"
echo ""
echo "🚀 Test your blockchain:"
echo "  ./build/shahd start"
echo ""
echo "═══════════════════════════════════════════════════════════"

# Save summary
cat > $HOME_DIR/GENESIS_SUMMARY.txt << EOF
SHAHCOIN Genesis Summary
========================

Chain ID: $CHAIN_ID
Genesis Hash: $HASH

Addresses:
----------
founder: $FOUNDER
validator1: $VAL1
validator2: $VAL2
validator3: $VAL3
validator4: $VAL4

Mnemonics saved in: $HOME_DIR/keys_backup/*.json

⚠️  BACKUP THIS DIRECTORY: $HOME_DIR/keys_backup/

Generated: $(date)
EOF

echo "📄 Summary saved to: $HOME_DIR/GENESIS_SUMMARY.txt"
echo ""

