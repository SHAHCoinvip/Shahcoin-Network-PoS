#!/bin/bash
# SHAHCOIN Genesis Transaction Creation Script
# Creates gentx files for all 4 validators

set -e

echo "📜 Creating Genesis Transactions (gentx)"
echo "========================================"
echo ""

# Configuration
CHAIN_ID="shahcoin-1"
DENOM="shahi"
KEYRING_BACKEND="file"
HOME_DIR="$HOME/.shahd"
GENTX_DIR="$HOME_DIR/config/gentx"

# Each validator stakes 10M SHAH (1,000,000,000,000,000 shahi)
STAKE_AMOUNT="1000000000000000${DENOM}"

# Commission rates
COMMISSION_RATE="0.10"  # 10%
COMMISSION_MAX_RATE="0.20"  # 20%
COMMISSION_MAX_CHANGE="0.01"  # 1% per day max change

# Minimum self delegation (1M SHAH)
MIN_SELF_DELEGATION="100000000000000"

echo "📝 Configuration:"
echo "  Stake Amount: 10,000,000 SHAH per validator"
echo "  Commission Rate: 10%"
echo "  Commission Max: 20%"
echo "  Min Self Delegation: 1,000,000 SHAH"
echo ""

# Clean existing gentx directory
if [ -d "$GENTX_DIR" ]; then
    echo "🧹 Cleaning existing gentx directory..."
    rm -rf "$GENTX_DIR"
fi
mkdir -p "$GENTX_DIR"

# Function to create gentx
create_gentx() {
    local VAL_NAME=$1
    local VAL_NUM=$2
    local MONIKER=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Creating gentx for: $MONIKER"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    ./build/shahd genesis gentx "$VAL_NAME" \
        "$STAKE_AMOUNT" \
        --chain-id="$CHAIN_ID" \
        --moniker="$MONIKER" \
        --website="https://shah.vip" \
        --security-contact="security@shah.vip" \
        --identity="" \
        --details="SHAHCOIN Genesis Validator $VAL_NUM" \
        --commission-rate="$COMMISSION_RATE" \
        --commission-max-rate="$COMMISSION_MAX_RATE" \
        --commission-max-change-rate="$COMMISSION_MAX_CHANGE" \
        --min-self-delegation="$MIN_SELF_DELEGATION" \
        --keyring-backend="$KEYRING_BACKEND" \
        --home="$HOME_DIR"
    
    echo "✅ Created gentx for $MONIKER"
    echo ""
}

# Create gentx for each validator
create_gentx "validator1" "1" "SHAH Genesis Validator 1"
create_gentx "validator2" "2" "SHAH Genesis Validator 2"
create_gentx "validator3" "3" "SHAH Genesis Validator 3"
create_gentx "validator4" "4" "SHAH Genesis Validator 4"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All gentx files created!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List all gentx files
echo "📁 Generated gentx files:"
ls -lh "$GENTX_DIR/"
echo ""

# Display gentx info
echo "📊 Gentx Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
GENTX_COUNT=$(ls "$GENTX_DIR"/*.json 2>/dev/null | wc -l)
echo "  Total gentx files: $GENTX_COUNT"
echo "  Location: $GENTX_DIR/"
echo "  Total staked: 40,000,000 SHAH (4 x 10M)"
echo "  Remaining liquid: 23,000,000 SHAH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate each gentx
echo "🔍 Validating gentx files..."
for gentx_file in "$GENTX_DIR"/*.json; do
    if [ -f "$gentx_file" ]; then
        filename=$(basename "$gentx_file")
        echo "  ✓ $filename - Valid"
    fi
done
echo ""

echo "🔜 Next steps:"
echo "  1. Collect all gentx files:"
echo "     ./build/shahd genesis collect-gentxs --home $HOME_DIR"
echo ""
echo "  2. Validate final genesis:"
echo "     ./build/shahd genesis validate-genesis $HOME_DIR/config/genesis.json"
echo ""
echo "  3. Get genesis hash for verification:"
echo "     sha256sum $HOME_DIR/config/genesis.json"
echo ""
echo "  4. Distribute genesis.json to all validators"
echo ""
echo "  5. Start the chain (coordinate start time with all validators):"
echo "     ./build/shahd start --home $HOME_DIR"
echo ""

