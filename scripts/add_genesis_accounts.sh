#!/bin/bash
# SHAHCOIN Add Genesis Accounts Script
# Adds validator accounts to genesis.json with proper allocations

set -e

echo "💰 Adding Genesis Accounts to SHAHCOIN"
echo "======================================="
echo ""

# Configuration
CHAIN_ID="shahcoin-1"
DENOM="shahi"
KEYRING_BACKEND="file"
HOME_DIR="$HOME/.shahd"
KEYS_DIR="$HOME_DIR/keys_backup"

# Check if keys exist
if [ ! -f "$KEYS_DIR/validators.json" ]; then
    echo "❌ validators.json not found!"
    echo "   Please run ./scripts/setup_validators.sh first"
    exit 1
fi

echo "📝 Reading validator info from: $KEYS_DIR/validators.json"
echo ""

# Get addresses
FOUNDER_ADDR=$(./build/shahd keys show founder -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
VAL1_ADDR=$(./build/shahd keys show validator1 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
VAL2_ADDR=$(./build/shahd keys show validator2 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
VAL3_ADDR=$(./build/shahd keys show validator3 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
VAL4_ADDR=$(./build/shahd keys show validator4 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)

echo "🔑 Adding genesis accounts..."
echo ""

# Add founder account (25% = 15.75M SHAH + treasury management)
echo "  Adding founder account..."
./build/shahd genesis add-genesis-account "$FOUNDER_ADDR" \
    1575000000000000${DENOM} \
    --keyring-backend $KEYRING_BACKEND \
    --home $HOME_DIR

# Add validator 1 (25% = 15.75M SHAH)
echo "  Adding validator1 account..."
./build/shahd genesis add-genesis-account "$VAL1_ADDR" \
    1575000000000000${DENOM} \
    --keyring-backend $KEYRING_BACKEND \
    --home $HOME_DIR

# Add validator 2 (25% = 15.75M SHAH)
echo "  Adding validator2 account..."
./build/shahd genesis add-genesis-account "$VAL2_ADDR" \
    1575000000000000${DENOM} \
    --keyring-backend $KEYRING_BACKEND \
    --home $HOME_DIR

# Add validator 3 (25% = 15.75M SHAH)
echo "  Adding validator3 account..."
./build/shahd genesis add-genesis-account "$VAL3_ADDR" \
    1575000000000000${DENOM} \
    --keyring-backend $KEYRING_BACKEND \
    --home $HOME_DIR

# Add validator 4 (25% = 15.75M SHAH - to be distributed)
echo "  Adding validator4 account..."
./build/shahd genesis add-genesis-account "$VAL4_ADDR" \
    1575000000000000${DENOM} \
    --keyring-backend $KEYRING_BACKEND \
    --home $HOME_DIR

echo ""
echo "✅ All genesis accounts added!"
echo ""

# Display allocation summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SHAHCOIN Genesis Allocation (63,000,000 SHAH Total)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "👤 Founder Account:"
echo "   Address: $FOUNDER_ADDR"
echo "   Amount: 15,750,000 SHAH (25%)"
echo "   Purpose: Team, Development, Marketing, Reserves"
echo ""
echo "🔐 Validator 1:"
echo "   Address: $VAL1_ADDR"
echo "   Amount: 15,750,000 SHAH (25%)"
echo "   Purpose: Stake 10M, Keep 5.75M for operations"
echo ""
echo "🔐 Validator 2:"
echo "   Address: $VAL2_ADDR"
echo "   Amount: 15,750,000 SHAH (25%)"
echo "   Purpose: Stake 10M, Keep 5.75M for operations"
echo ""
echo "🔐 Validator 3:"
echo "   Address: $VAL3_ADDR"
echo "   Amount: 15,750,000 SHAH (25%)"
echo "   Purpose: Stake 10M, Keep 5.75M for operations"
echo ""
echo "🔐 Validator 4:"
echo "   Address: $VAL4_ADDR"
echo "   Amount: 15,750,000 SHAH (25%)"
echo "   Purpose: Stake 10M, Keep 5.75M for liquidity/airdrops"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Each validator will stake 10,000,000 SHAH (10M)"
echo "💡 Remaining 23,000,000 SHAH for operations, liquidity, airdrops"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify genesis
echo "🔍 Validating genesis..."
if ./build/shahd genesis validate-genesis $HOME_DIR/config/genesis.json; then
    echo "✅ Genesis validation passed!"
else
    echo "❌ Genesis validation failed!"
    exit 1
fi

echo ""
echo "🔜 Next step: Create gentx files"
echo "   Run: ./scripts/create_gentxs.sh"
echo ""

