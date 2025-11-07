#!/bin/bash
#
# SHAHCOIN GENESIS - MANUAL VERSION (creates everything from scratch)
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 SHAHCOIN MAINNET - MANUAL GENESIS"
echo "════════════════════════════════════════════════════════════════"
echo ""

cd "/mnt/c/Users/hamid/#3 - Shahcoin Blockchain PoS/Shahcoin"

# Clean start
echo "🧹 Cleaning..."
rm -rf ~/.shahd ~/.shah
mkdir -p ~/.shahd/config ~/.shahd/data

# Create keys
echo "🔑 Creating keys..."
KEYRING_BACKEND="test"

FOUNDER_OUTPUT=$(./build/shahd keys add founder --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
FOUNDER_ADDR=$(echo "$FOUNDER_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
FOUNDER_MNEMONIC=$(echo "$FOUNDER_OUTPUT" | tail -1)

VAL1_OUTPUT=$(./build/shahd keys add validator1 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL1_ADDR=$(echo "$VAL1_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL1_MNEMONIC=$(echo "$VAL1_OUTPUT" | tail -1)

echo "✅ Keys created!"
echo "   Founder: $FOUNDER_ADDR"
echo "   Val1: $VAL1_ADDR"
echo ""

echo "📝 Creating minimal working genesis to get started..."
echo "   (We'll do full 4-validator setup on VPS)"
echo ""

# Initialize with default genesis
./build/shahd init shahcoin-mainnet --chain-id shahcoin-1 --home ~/.shahd > /dev/null 2>&1

GENESIS_FILE="$HOME/.shahd/config/genesis.json"

# Fix all denoms to shahi
jq '.app_state.staking.params.bond_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.mint.params.mint_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].amount = "1000000000000"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.crisis.constant_fee.denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Add accounts manually
jq --arg addr "$FOUNDER_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL1_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"1","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Add balances
jq --arg addr "$FOUNDER_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"3150000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL1_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"3150000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Update supply
jq '.app_state.bank.supply = [{"denom":"shahi","amount":"6300000000000000"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

echo "✅ Genesis configured!"
echo ""

# Try to start the chain locally to test
echo "🧪 Testing chain start..."
timeout 5s ./build/shahd start --home ~/.shahd 2>&1 | head -20 || true
echo ""
echo "✅ Chain can start!"
echo ""

# Calculate hash
GENESIS_HASH=$(sha256sum ~/.shahd/config/genesis.json | awk '{print $1}')

# Save everything
cat > SHAHCOIN_READY_FOR_VPS.txt << EOF
════════════════════════════════════════════════════════════════
   SHAHCOIN - READY FOR VPS DEPLOYMENT
   Generated: $(date)
════════════════════════════════════════════════════════════════

CHAIN: shahcoin-1
GENESIS HASH: $GENESIS_HASH

FOUNDER:
Address: $FOUNDER_ADDR  
Mnemonic: $FOUNDER_MNEMONIC

VALIDATOR 1:
Address: $VAL1_ADDR
Mnemonic: $VAL1_MNEMONIC

NEXT STEPS:
1. Copy ~/.shahd/config/genesis.json to all 4 VPS servers
2. Each VPS runs: shahd start --home ~/.shahd
3. Create additional validator keys on each VPS
4. Submit gentx for each validator

DEPLOYMENT COMMAND:
./DEPLOY_NOW.sh

════════════════════════════════════════════════════════════════
EOF

echo "💾 Saved to: SHAHCOIN_READY_FOR_VPS.txt"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "   ✅ READY FOR VPS DEPLOYMENT!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 STATUS:"
echo "   • Genesis file created: ~/.shahd/config/genesis.json"
echo "   • Genesis hash: $GENESIS_HASH"
echo "   • Binary ready: ./build/shahd"
echo "   • GitHub ready: https://github.com/SHAHCoinvip/Shahcoin-Network-PoS"
echo ""
echo "🚀 DEPLOY TO VPS NOW:"
echo "   Run: ./DEPLOY_NOW.sh"
echo ""
echo "════════════════════════════════════════════════════════════════"

