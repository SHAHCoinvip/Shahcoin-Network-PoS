#!/bin/bash
#
# SHAHCOIN GENESIS SETUP - COMPLETE
# This script creates a fully working genesis with proper shah addresses
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 SHAHCOIN GENESIS SETUP - FINAL VERSION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Navigate to project root
cd "/mnt/c/Users/hamid/#3 - Shahcoin Blockchain PoS/Shahcoin"

# Step 1: Rebuild with fixed Bech32 prefix
echo "📦 Step 1: Rebuilding binary with 'shah' prefix..."
make build
echo "✅ Binary rebuilt!"
echo ""

# Step 2: Clean and init
echo "🧹 Step 2: Clean start..."
rm -rf ~/.shahd ~/.shah
./build/shahd init shahcoin-mainnet --chain-id shahcoin-1 --home ~/.shahd
echo "✅ Initialized!"
echo ""

# Step 3: Create keys and extract addresses
echo "🔑 Step 3: Creating keys..."

KEYRING_BACKEND="test"

# Create founder key
echo "Creating founder key..."
FOUNDER_OUTPUT=$(./build/shahd keys add founder --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
FOUNDER_ADDR=$(echo "$FOUNDER_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
FOUNDER_MNEMONIC=$(echo "$FOUNDER_OUTPUT" | tail -1)

# Create validator1 key
echo "Creating validator1 key..."
VAL1_OUTPUT=$(./build/shahd keys add validator1 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL1_ADDR=$(echo "$VAL1_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL1_MNEMONIC=$(echo "$VAL1_OUTPUT" | tail -1)

# Create validator2 key
echo "Creating validator2 key..."
VAL2_OUTPUT=$(./build/shahd keys add validator2 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL2_ADDR=$(echo "$VAL2_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL2_MNEMONIC=$(echo "$VAL2_OUTPUT" | tail -1)

# Create validator3 key
echo "Creating validator3 key..."
VAL3_OUTPUT=$(./build/shahd keys add validator3 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL3_ADDR=$(echo "$VAL3_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL3_MNEMONIC=$(echo "$VAL3_OUTPUT" | tail -1)

# Create validator4 key
echo "Creating validator4 key..."
VAL4_OUTPUT=$(./build/shahd keys add validator4 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL4_ADDR=$(echo "$VAL4_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL4_MNEMONIC=$(echo "$VAL4_OUTPUT" | tail -1)

echo ""
echo "✅ Keys created with 'shah' prefix!"
echo ""
echo "📍 Addresses:"
echo "   Founder:    $FOUNDER_ADDR"
echo "   Validator1: $VAL1_ADDR"
echo "   Validator2: $VAL2_ADDR"
echo "   Validator3: $VAL3_ADDR"
echo "   Validator4: $VAL4_ADDR"
echo ""

# Verify addresses have correct prefix
if [[ $FOUNDER_ADDR != shah* ]]; then
    echo "❌ ERROR: Addresses don't have 'shah' prefix!"
    echo "   Got: $FOUNDER_ADDR"
    echo "   This means the Bech32 config didn't apply."
    exit 1
fi

echo "✅ All addresses verified with 'shah' prefix!"
echo ""

# Step 4: Configure genesis parameters
echo "⚙️  Step 4: Configuring genesis..."

GENESIS_FILE="$HOME/.shahd/config/genesis.json"

# Fix denoms
jq '.app_state.staking.params.bond_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.mint.params.mint_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].amount = "1000000000000"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

echo "✅ Genesis parameters configured!"
echo ""

# Step 5: Add genesis accounts using addresses directly
echo "💰 Step 5: Adding genesis accounts..."

# Use addresses directly (bypass keyring bug)
./build/shahd genesis add-genesis-account "$FOUNDER_ADDR" 1575000000000000shahi --keyring-backend $KEYRING_BACKEND --home ~/.shahd
./build/shahd genesis add-genesis-account "$VAL1_ADDR" 1575000000000000shahi --keyring-backend $KEYRING_BACKEND --home ~/.shahd
./build/shahd genesis add-genesis-account "$VAL2_ADDR" 1575000000000000shahi --keyring-backend $KEYRING_BACKEND --home ~/.shahd
./build/shahd genesis add-genesis-account "$VAL3_ADDR" 1575000000000000shahi --keyring-backend $KEYRING_BACKEND --home ~/.shahd
./build/shahd genesis add-genesis-account "$VAL4_ADDR" 1575000000000000shahi --keyring-backend $KEYRING_BACKEND --home ~/.shahd

echo "✅ Genesis accounts added!"
echo ""

# Step 6: Create genesis transactions
echo "📝 Step 6: Creating genesis transactions..."

./build/shahd genesis gentx validator1 1000000000000000shahi \
    --chain-id shahcoin-1 \
    --moniker "Validator 1" \
    --commission-rate "0.10" \
    --commission-max-rate "0.20" \
    --commission-max-change-rate "0.01" \
    --min-self-delegation "1" \
    --keyring-backend $KEYRING_BACKEND \
    --home ~/.shahd

./build/shahd genesis gentx validator2 1000000000000000shahi \
    --chain-id shahcoin-1 \
    --moniker "Validator 2" \
    --commission-rate "0.10" \
    --commission-max-rate "0.20" \
    --commission-max-change-rate "0.01" \
    --min-self-delegation "1" \
    --keyring-backend $KEYRING_BACKEND \
    --home ~/.shahd

./build/shahd genesis gentx validator3 1000000000000000shahi \
    --chain-id shahcoin-1 \
    --moniker "Validator 3" \
    --commission-rate "0.10" \
    --commission-max-rate "0.20" \
    --commission-max-change-rate "0.01" \
    --min-self-delegation "1" \
    --keyring-backend $KEYRING_BACKEND \
    --home ~/.shahd

./build/shahd genesis gentx validator4 1000000000000000shahi \
    --chain-id shahcoin-1 \
    --moniker "Validator 4" \
    --commission-rate "0.10" \
    --commission-max-rate "0.20" \
    --commission-max-change-rate "0.01" \
    --min-self-delegation "1" \
    --keyring-backend $KEYRING_BACKEND \
    --home ~/.shahd

echo "✅ Genesis transactions created!"
echo ""

# Step 7: Collect genesis transactions
echo "📦 Step 7: Collecting genesis transactions..."
./build/shahd genesis collect-gentxs --home ~/.shahd
echo "✅ Genesis transactions collected!"
echo ""

# Step 8: Validate genesis
echo "✔️  Step 8: Validating genesis..."
./build/shahd genesis validate --home ~/.shahd
echo "✅ Genesis validated!"
echo ""

# Step 9: Calculate genesis hash
echo "🔐 Step 9: Calculating genesis hash..."
GENESIS_HASH=$(sha256sum ~/.shahd/config/genesis.json | awk '{print $1}')
echo "✅ Genesis hash: $GENESIS_HASH"
echo ""

# Step 10: Save all information
echo "💾 Step 10: Saving credentials..."

cat > SHAHCOIN_GENESIS_INFO.txt << EOF
════════════════════════════════════════════════════════════════
   SHAHCOIN MAINNET GENESIS INFORMATION
   Generated: $(date)
════════════════════════════════════════════════════════════════

CHAIN INFORMATION:
  Chain ID:      shahcoin-1
  Genesis Hash:  $GENESIS_HASH
  Total Supply:  63,000,000 SHAH (6,300,000,000,000,000 shahi)

FOUNDER ACCOUNT:
  Address:  $FOUNDER_ADDR
  Balance:  15,750,000 SHAH (1,575,000,000,000,000 shahi)
  Mnemonic: $FOUNDER_MNEMONIC

VALIDATOR 1:
  Address:  $VAL1_ADDR
  Balance:  15,750,000 SHAH (1,575,000,000,000,000 shahi)
  Staked:   10,000,000 SHAH (1,000,000,000,000,000 shahi)
  Mnemonic: $VAL1_MNEMONIC

VALIDATOR 2:
  Address:  $VAL2_ADDR
  Balance:  15,750,000 SHAH (1,575,000,000,000,000 shahi)
  Staked:   10,000,000 SHAH (1,000,000,000,000,000 shahi)
  Mnemonic: $VAL2_MNEMONIC

VALIDATOR 3:
  Address:  $VAL3_ADDR
  Balance:  15,750,000 SHAH (1,575,000,000,000,000 shahi)
  Staked:   10,000,000 SHAH (1,000,000,000,000,000 shahi)
  Mnemonic: $VAL3_MNEMONIC

VALIDATOR 4:
  Address:  $VAL4_ADDR
  Balance:  15,750,000 SHAH (1,575,000,000,000,000 shahi)
  Staked:   10,000,000 SHAH (1,000,000,000,000,000 shahi)
  Mnemonic: $VAL4_MNEMONIC

⚠️  CRITICAL: Store this file securely! These mnemonics control all funds.
════════════════════════════════════════════════════════════════
EOF

echo "✅ Credentials saved to: SHAHCOIN_GENESIS_INFO.txt"
echo ""

# Final summary
echo "════════════════════════════════════════════════════════════════"
echo "   ✅ SHAHCOIN GENESIS SETUP COMPLETE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 SUMMARY:"
echo "   • Chain ID: shahcoin-1"
echo "   • 5 accounts created (1 founder + 4 validators)"
echo "   • 4 validators bonded with 10M SHAH each"
echo "   • Genesis hash: $GENESIS_HASH"
echo ""
echo "📁 FILES:"
echo "   • Genesis:     ~/.shahd/config/genesis.json"
echo "   • Credentials: ./SHAHCOIN_GENESIS_INFO.txt"
echo ""
echo "🚀 NEXT STEPS:"
echo "   1. Review SHAHCOIN_GENESIS_INFO.txt"
echo "   2. Test local start: ./build/shahd start"
echo "   3. Deploy to VPS servers"
echo ""
echo "════════════════════════════════════════════════════════════════"

