#!/bin/bash
#
# SHAHCOIN GENESIS - WORKING VERSION (uses jq to bypass SDK codec bugs)
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 SHAHCOIN GENESIS SETUP - WORKING VERSION"
echo "════════════════════════════════════════════════════════════════"
echo ""

cd "/mnt/c/Users/hamid/#3 - Shahcoin Blockchain PoS/Shahcoin"

# Step 1: Clean and init
echo "🧹 Step 1: Clean start..."
rm -rf ~/.shahd ~/.shah
./build/shahd init shahcoin-mainnet --chain-id shahcoin-1 --home ~/.shahd
echo "✅ Initialized!"
echo ""

# Step 2: Create keys
echo "🔑 Step 2: Creating keys..."
KEYRING_BACKEND="test"

FOUNDER_OUTPUT=$(./build/shahd keys add founder --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
FOUNDER_ADDR=$(echo "$FOUNDER_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
FOUNDER_MNEMONIC=$(echo "$FOUNDER_OUTPUT" | tail -1)

VAL1_OUTPUT=$(./build/shahd keys add validator1 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL1_ADDR=$(echo "$VAL1_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL1_MNEMONIC=$(echo "$VAL1_OUTPUT" | tail -1)

VAL2_OUTPUT=$(./build/shahd keys add validator2 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL2_ADDR=$(echo "$VAL2_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL2_MNEMONIC=$(echo "$VAL2_OUTPUT" | tail -1)

VAL3_OUTPUT=$(./build/shahd keys add validator3 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL3_ADDR=$(echo "$VAL3_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL3_MNEMONIC=$(echo "$VAL3_OUTPUT" | tail -1)

VAL4_OUTPUT=$(./build/shahd keys add validator4 --keyring-backend $KEYRING_BACKEND --home ~/.shahd 2>&1)
VAL4_ADDR=$(echo "$VAL4_OUTPUT" | grep -oP "shah[a-z0-9]{39}" | head -1)
VAL4_MNEMONIC=$(echo "$VAL4_OUTPUT" | tail -1)

echo "✅ Keys created with 'shah' prefix!"
echo ""
echo "📍 Addresses:"
echo "   Founder:    $FOUNDER_ADDR"
echo "   Validator1: $VAL1_ADDR"
echo "   Validator2: $VAL2_ADDR"
echo "   Validator3: $VAL3_ADDR"
echo "   Validator4: $VAL4_ADDR"
echo ""

# Step 3: Configure genesis with jq
echo "⚙️  Step 3: Configuring genesis..."

GENESIS_FILE="$HOME/.shahd/config/genesis.json"

# Fix denoms
jq '.app_state.staking.params.bond_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.mint.params.mint_denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].denom = "shahi"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq '.app_state.gov.params.min_deposit[0].amount = "1000000000000"' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Add accounts directly to genesis
jq --arg addr "$FOUNDER_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL1_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL2_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL3_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL4_ADDR" '.app_state.auth.accounts += [{"@type":"/cosmos.auth.v1beta1.BaseAccount","address":$addr,"pub_key":null,"account_number":"0","sequence":"0"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Add balances
jq --arg addr "$FOUNDER_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"1575000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL1_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"1575000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL2_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"1575000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL3_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"1575000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"
jq --arg addr "$VAL4_ADDR" '.app_state.bank.balances += [{"address":$addr,"coins":[{"denom":"shahi","amount":"1575000000000000"}]}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

# Add supply
jq '.app_state.bank.supply += [{"denom":"shahi","amount":"7875000000000000"}]' "$GENESIS_FILE" > /tmp/g.json && mv /tmp/g.json "$GENESIS_FILE"

echo "✅ Genesis configured with accounts!"
echo ""

# Step 4: Create gentxs
echo "📝 Step 4: Creating genesis transactions..."

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

# Step 5: Collect gentxs
echo "📦 Step 5: Collecting genesis transactions..."
./build/shahd genesis collect-gentxs --home ~/.shahd
echo "✅ Genesis transactions collected!"
echo ""

# Step 6: Validate
echo "✔️  Step 6: Validating genesis..."
./build/shahd genesis validate --home ~/.shahd
echo "✅ Genesis validated!"
echo ""

# Step 7: Calculate hash
echo "🔐 Step 7: Calculating genesis hash..."
GENESIS_HASH=$(sha256sum ~/.shahd/config/genesis.json | awk '{print $1}')
echo "✅ Genesis hash: $GENESIS_HASH"
echo ""

# Step 8: Save credentials
cat > SHAHCOIN_MAINNET_GENESIS.txt << EOF
════════════════════════════════════════════════════════════════
   SHAHCOIN MAINNET GENESIS
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

VALIDATOR 2:
Address: $VAL2_ADDR
Mnemonic: $VAL2_MNEMONIC

VALIDATOR 3:
Address: $VAL3_ADDR
Mnemonic: $VAL3_MNEMONIC

VALIDATOR 4:
Address: $VAL4_ADDR
Mnemonic: $VAL4_MNEMONIC

⚠️  KEEP THIS SAFE! These mnemonics control all funds.
════════════════════════════════════════════════════════════════
EOF

echo "💾 Credentials saved to: SHAHCOIN_MAINNET_GENESIS.txt"
echo ""

# Final summary
echo "════════════════════════════════════════════════════════════════"
echo "   ✅ SHAHCOIN GENESIS COMPLETE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 SUMMARY:"
echo "   • Chain ID: shahcoin-1"
echo "   • 5 accounts (1 founder + 4 validators)"
echo "   • 4 validators bonded with 10M SHAH each"
echo "   • Genesis hash: $GENESIS_HASH"
echo ""
echo "🚀 NEXT: Test with ./build/shahd start --home ~/.shahd"
echo ""
echo "════════════════════════════════════════════════════════════════"

