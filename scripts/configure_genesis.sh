#!/bin/bash
# SHAHCOIN Genesis Configuration Script
# This script updates the genesis.json with proper SHAHCOIN parameters

set -e

echo "🔧 Configuring SHAHCOIN Genesis..."
echo ""

# Variables
GENESIS_FILE="$HOME/.shahd/config/genesis.json"
CHAIN_ID="shahcoin-1"
DENOM="shahi"
TOTAL_SUPPLY="6300000000000000"  # 63,000,000 SHAH with 8 decimals

# Backup original genesis
if [ -f "$GENESIS_FILE" ]; then
    cp "$GENESIS_FILE" "$GENESIS_FILE.backup"
    echo "✅ Backed up original genesis to $GENESIS_FILE.backup"
else
    echo "❌ Genesis file not found at $GENESIS_FILE"
    echo "   Please run: ./build/shahd init <moniker> --chain-id shahcoin-1"
    exit 1
fi

echo ""
echo "📝 Updating genesis parameters..."

# Use jq to modify genesis.json
# Note: Install jq if not available: sudo apt install jq

# 1. Update staking bond_denom
jq ".app_state.staking.params.bond_denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated staking bond_denom to $DENOM"

# 2. Update mint mint_denom
jq ".app_state.mint.params.mint_denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated mint denom to $DENOM"

# 3. Update gov min_deposit
jq ".app_state.gov.params.min_deposit[0].denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.gov.params.min_deposit[0].amount = \"100000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated gov min_deposit to 1,000 SHAH"

# 4. Update gov expedited_min_deposit
jq ".app_state.gov.params.expedited_min_deposit[0].denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.gov.params.expedited_min_deposit[0].amount = \"500000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated gov expedited_min_deposit to 5,000 SHAH"

# 5. Update crisis constant_fee
jq ".app_state.crisis.constant_fee.denom = \"$DENOM\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.crisis.constant_fee.amount = \"100000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated crisis constant_fee"

# 6. Update staking parameters for PoS
jq ".app_state.staking.params.max_validators = 100" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.staking.params.unbonding_time = \"1814400s\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"  # 21 days
jq ".app_state.staking.params.max_entries = 7" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated staking parameters (100 validators, 21-day unbonding)"

# 7. Update mint parameters
jq ".app_state.mint.params.inflation_rate_change = \"0.130000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.mint.params.inflation_max = \"0.200000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.mint.params.inflation_min = \"0.070000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.mint.params.goal_bonded = \"0.670000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated mint parameters (7-20% inflation, 67% goal bonded)"

# 8. Update distribution community_tax
jq ".app_state.distribution.params.community_tax = \"0.020000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated community tax to 2%"

# 9. Update gov voting period
jq ".app_state.gov.params.voting_period = \"604800s\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"  # 7 days
jq ".app_state.gov.params.expedited_voting_period = \"259200s\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"  # 3 days
echo "  ✓ Updated voting periods (7 days standard, 3 days expedited)"

# 10. Update slashing parameters
jq ".app_state.slashing.params.signed_blocks_window = \"10000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.slashing.params.min_signed_per_window = \"0.050000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.slashing.params.downtime_jail_duration = \"600s\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.slashing.params.slash_fraction_double_sign = \"0.050000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.slashing.params.slash_fraction_downtime = \"0.000100000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated slashing parameters"

# 11. Set genesis time to a future date (change this as needed)
GENESIS_TIME=$(date -u -d '+1 hour' +"%Y-%m-%dT%H:%M:%SZ")
jq ".genesis_time = \"$GENESIS_TIME\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Set genesis time to $GENESIS_TIME"

# 12. Update custom module parameters
jq ".app_state.treasury.params.pricing_mode = \"manual\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.treasury.params.target_rate = \"5.000000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.treasury.params.fee_bps = \"50\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated treasury parameters"

jq ".app_state.shahswap.params.trade_fee = \"0.003000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
jq ".app_state.shahswap.params.protocol_cut = \"0.160000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated shahswap parameters"

jq ".app_state.fees.params.usd_rate = \"5.000000000000000000\"" "$GENESIS_FILE" > "$GENESIS_FILE.tmp" && mv "$GENESIS_FILE.tmp" "$GENESIS_FILE"
echo "  ✓ Updated fees parameters"

echo ""
echo "✅ Genesis configuration complete!"
echo ""
echo "📊 Summary:"
echo "  Chain ID: $CHAIN_ID"
echo "  Base Denom: $DENOM"
echo "  Total Supply: $(echo "scale=0; $TOTAL_SUPPLY / 100000000" | bc) SHAH"
echo "  Max Validators: 100"
echo "  Unbonding Time: 21 days"
echo "  Voting Period: 7 days"
echo "  Community Tax: 2%"
echo "  Genesis Time: $GENESIS_TIME"
echo ""
echo "📁 Genesis file: $GENESIS_FILE"
echo "📁 Backup: $GENESIS_FILE.backup"
echo ""
echo "🔍 Verify genesis:"
echo "  ./build/shahd genesis validate-genesis $GENESIS_FILE"
echo ""

