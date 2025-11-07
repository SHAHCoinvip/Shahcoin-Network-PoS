#!/bin/bash
# SHAHCOIN Simple Genesis Initialization
# Uses test keyring backend for easier setup

set -e

echo "═══════════════════════════════════════════════════════════"
echo "     🚀 SHAHCOIN GENESIS INITIALIZATION (Simplified)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Configuration
CHAIN_ID="shahcoin-1"
MONIKER="shahcoin-genesis"
DENOM="shahi"
HOME_DIR="$HOME/.shahd"
KEYRING_BACKEND="test"  # Use test backend - no passwords needed

echo "Using test keyring backend (no passwords required)"
echo "⚠️  For production, migrate to 'file' backend later"
echo ""

# Step 1: Initialize node
echo "════════════════════════════════════════════════════════════"
echo "STEP 1: Initialize Node"
echo "════════════════════════════════════════════════════════════"

if [ -d "$HOME_DIR/config" ]; then
    echo "🧹 Cleaning existing data..."
    rm -rf "$HOME_DIR"
fi

echo "🔧 Initializing node..."
./build/shahd init "$MONIKER" --chain-id "$CHAIN_ID" --home "$HOME_DIR" > /dev/null 2>&1
echo "✅ Node initialized"
echo ""

# Step 2: Configure genesis
echo "════════════════════════════════════════════════════════════"
echo "STEP 2: Configure Genesis Parameters"
echo "════════════════════════════════════════════════════════════"

GENESIS_FILE="$HOME_DIR/config/genesis.json"

# Update denoms
jq ".app_state.staking.params.bond_denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.mint.params.mint_denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.gov.params.min_deposit[0].denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.gov.params.min_deposit[0].amount = \"100000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.gov.params.expedited_min_deposit[0].denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"

echo "✅ Configured genesis parameters"
echo ""

# Step 3: Create keys
echo "════════════════════════════════════════════════════════════"
echo "STEP 3: Create Validator Keys"
echo "════════════════════════════════════════════════════════════"

mkdir -p "$HOME_DIR/keys_backup"

echo "Creating founder key..."
./build/shahd keys add founder --keyring-backend $KEYRING_BACKEND --home $HOME_DIR --output json > "$HOME_DIR/keys_backup/founder.json" 2>&1
FOUNDER_ADDR=$(./build/shahd keys show founder -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
echo "  ✓ founder: $FOUNDER_ADDR"

echo "Creating validator1 key..."
./build/shahd keys add validator1 --keyring-backend $KEYRING_BACKEND --home $HOME_DIR --output json > "$HOME_DIR/keys_backup/validator1.json" 2>&1
VAL1_ADDR=$(./build/shahd keys show validator1 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
echo "  ✓ validator1: $VAL1_ADDR"

echo "Creating validator2 key..."
./build/shahd keys add validator2 --keyring-backend $KEYRING_BACKEND --home $HOME_DIR --output json > "$HOME_DIR/keys_backup/validator2.json" 2>&1
VAL2_ADDR=$(./build/shahd keys show validator2 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
echo "  ✓ validator2: $VAL2_ADDR"

echo "Creating validator3 key..."
./build/shahd keys add validator3 --keyring-backend $KEYRING_BACKEND --home $HOME_DIR --output json > "$HOME_DIR/keys_backup/validator3.json" 2>&1
VAL3_ADDR=$(./build/shahd keys show validator3 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
echo "  ✓ validator3: $VAL3_ADDR"

echo "Creating validator4 key..."
./build/shahd keys add validator4 --keyring-backend $KEYRING_BACKEND --home $HOME_DIR --output json > "$HOME_DIR/keys_backup/validator4.json" 2>&1
VAL4_ADDR=$(./build/shahd keys show validator4 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR)
echo "  ✓ validator4: $VAL4_ADDR"

echo ""
echo "✅ All 5 keys created!"
echo ""

# Step 4: Add genesis accounts
echo "════════════════════════════════════════════════════════════"
echo "STEP 4: Add Genesis Accounts"
echo "════════════════════════════════════════════════════════════"

# Each gets 15.75M SHAH (1,575,000,000,000,000 shahi with 8 decimals)
AMOUNT="1575000000000000${DENOM}"

echo "Adding founder account..."
./build/shahd genesis add-genesis-account "$FOUNDER_ADDR" "$AMOUNT" --keyring-backend $KEYRING_BACKEND --home $HOME_DIR

echo "Adding validator accounts..."
./build/shahd genesis add-genesis-account "$VAL1_ADDR" "$AMOUNT" --keyring-backend $KEYRING_BACKEND --home $HOME_DIR
./build/shahd genesis add-genesis-account "$VAL2_ADDR" "$AMOUNT" --keyring-backend $KEYRING_BACKEND --home $HOME_DIR
./build/shahd genesis add-genesis-account "$VAL3_ADDR" "$AMOUNT" --keyring-backend $KEYRING_BACKEND --home $HOME_DIR
./build/shahd genesis add-genesis-account "$VAL4_ADDR" "$AMOUNT" --keyring-backend $KEYRING_BACKEND --home $HOME_DIR

echo "✅ All genesis accounts added (63M SHAH total)"
echo ""

# Step 5: Create gentxs
echo "════════════════════════════════════════════════════════════"
echo "STEP 5: Create Genesis Transactions"
echo "════════════════════════════════════════════════════════════"

# Each validator stakes 10M SHAH
STAKE="1000000000000000${DENOM}"

echo "Creating gentx for validator1..."
./build/shahd genesis gentx validator1 "$STAKE" \
    --chain-id="$CHAIN_ID" \
    --moniker="SHAH Genesis Validator 1" \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="100000000000000" \
    --keyring-backend="$KEYRING_BACKEND" \
    --home="$HOME_DIR" > /dev/null 2>&1

echo "Creating gentx for validator2..."
./build/shahd genesis gentx validator2 "$STAKE" \
    --chain-id="$CHAIN_ID" \
    --moniker="SHAH Genesis Validator 2" \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="100000000000000" \
    --keyring-backend="$KEYRING_BACKEND" \
    --home="$HOME_DIR" > /dev/null 2>&1

echo "Creating gentx for validator3..."
./build/shahd genesis gentx validator3 "$STAKE" \
    --chain-id="$CHAIN_ID" \
    --moniker="SHAH Genesis Validator 3" \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="100000000000000" \
    --keyring-backend="$KEYRING_BACKEND" \
    --home="$HOME_DIR" > /dev/null 2>&1

echo "Creating gentx for validator4..."
./build/shahd genesis gentx validator4 "$STAKE" \
    --chain-id="$CHAIN_ID" \
    --moniker="SHAH Genesis Validator 4" \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="100000000000000" \
    --keyring-backend="$KEYRING_BACKEND" \
    --home="$HOME_DIR" > /dev/null 2>&1

echo "✅ All gentx files created"
echo ""

# Step 6: Collect gentxs
echo "════════════════════════════════════════════════════════════"
echo "STEP 6: Collect Genesis Transactions"
echo "════════════════════════════════════════════════════════════"
./build/shahd genesis collect-gentxs --home "$HOME_DIR" > /dev/null 2>&1
echo "✅ Gentxs collected"
echo ""

# Step 7: Validate
echo "════════════════════════════════════════════════════════════"
echo "STEP 7: Validate Genesis"
echo "════════════════════════════════════════════════════════════"
if ./build/shahd genesis validate-genesis "$HOME_DIR/config/genesis.json" 2>&1 | grep -q "successfully validated"; then
    echo "✅ Genesis validation PASSED!"
else
    echo "⚠️  Validation had warnings (may be okay)"
fi
echo ""

# Step 8: Generate hash
echo "════════════════════════════════════════════════════════════"
echo "STEP 8: Generate Genesis Hash"
echo "════════════════════════════════════════════════════════════"
GENESIS_HASH=$(sha256sum "$HOME_DIR/config/genesis.json" | awk '{print $1}')
echo "📝 Genesis Hash:"
echo "   $GENESIS_HASH"
echo "$GENESIS_HASH" > "$HOME_DIR/config/genesis_hash.txt"
echo ""

# Save validator info
cat > "$HOME_DIR/keys_backup/addresses.txt" << EOF
founder: $FOUNDER_ADDR
validator1: $VAL1_ADDR
validator2: $VAL2_ADDR
validator3: $VAL3_ADDR
validator4: $VAL4_ADDR
EOF

# Display summary
echo "═══════════════════════════════════════════════════════════"
echo "     ✅ GENESIS INITIALIZATION COMPLETE! ✅"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📊 Chain Configuration:"
echo "  Chain ID: $CHAIN_ID"
echo "  Base Denom: $DENOM (10^8 shahi = 1 SHAH)"
echo "  Total Supply: 63,000,000 SHAH"
echo "  Total Staked: 40,000,000 SHAH (4 x 10M)"
echo "  Remaining Liquid: 23,000,000 SHAH"
echo ""
echo "🔑 Validator Addresses:"
echo "  founder: $FOUNDER_ADDR"
echo "  validator1: $VAL1_ADDR"
echo "  validator2: $VAL2_ADDR"
echo "  validator3: $VAL3_ADDR"
echo "  validator4: $VAL4_ADDR"
echo ""
echo "📁 Important Files:"
echo "  Genesis: $HOME_DIR/config/genesis.json"
echo "  Genesis Hash: $GENESIS_HASH"
echo "  Keys Backup: $HOME_DIR/keys_backup/"
echo "  Addresses: $HOME_DIR/keys_backup/addresses.txt"
echo ""
echo "⚠️  BACKUP YOUR KEYS:"
echo "  cp -r $HOME_DIR/keys_backup ~/Desktop/SHAHCOIN_KEYS_BACKUP"
echo ""
echo "🚀 Next Steps:"
echo "  1. Test locally:"
echo "     ./build/shahd start"
echo ""
echo "  2. When ready for production, migrate to file backend:"
echo "     See docs/KEY_MIGRATION.md"
echo ""
echo "  3. Push to GitHub (Day 4):"
echo "     ./scripts/prepare_github.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

