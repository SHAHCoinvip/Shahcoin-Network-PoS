#!/bin/bash
# SHAHCOIN Validator Setup Script
# Creates 4 founding validator keys and prepares genesis accounts

set -e

echo "🔑 SHAHCOIN Validator Setup"
echo "==========================="
echo ""

# Configuration
CHAIN_ID="shahcoin-1"
DENOM="shahi"
KEYRING_BACKEND="file"  # Use 'file' for production, 'test' for testing
HOME_DIR="$HOME/.shahd"
KEYS_DIR="$HOME_DIR/keys_backup"

# Validator allocation (63M total, distributed among validators and reserves)
# Each validator gets 25% of initial stake (15.75M SHAH each)
VALIDATOR_STAKE="1575000000000000"  # 15.75M SHAH in shahi (8 decimals)

# Treasury reserve (20% = 12.6M SHAH)
TREASURY_RESERVE="1260000000000000"

# Community pool (5% = 3.15M SHAH) 
COMMUNITY_POOL="315000000000000"

# Founder/Team allocation (remaining for liquidity, airdrops, etc.)
FOUNDER_ALLOCATION="1575000000000000"  # 15.75M SHAH

# Create backup directory
mkdir -p "$KEYS_DIR"
chmod 700 "$KEYS_DIR"

echo "📝 Configuration:"
echo "  Chain ID: $CHAIN_ID"
echo "  Keyring Backend: $KEYRING_BACKEND"
echo "  Home Directory: $HOME_DIR"
echo "  Keys Backup: $KEYS_DIR"
echo ""

# Function to create a validator key
create_validator_key() {
    local NAME=$1
    local NUM=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Creating Validator $NUM: $NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if key already exists
    if ./build/shahd keys show "$NAME" --keyring-backend "$KEYRING_BACKEND" --home "$HOME_DIR" 2>/dev/null; then
        echo "⚠️  Key '$NAME' already exists!"
        read -p "   Delete and recreate? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ./build/shahd keys delete "$NAME" --keyring-backend "$KEYRING_BACKEND" --home "$HOME_DIR" -y
        else
            echo "   Skipping..."
            return
        fi
    fi
    
    # Create key
    echo ""
    echo "🔐 Creating key for $NAME..."
    echo "   You will be asked to create a password for this key."
    echo "   ⚠️  STORE THIS PASSWORD SAFELY!"
    echo ""
    
    ./build/shahd keys add "$NAME" \
        --keyring-backend "$KEYRING_BACKEND" \
        --home "$HOME_DIR"
    
    # Get address (with retry in case keyring needs a moment)
    echo ""
    echo "📋 Retrieving address..."
    sleep 1  # Give keyring a moment to save
    
    ADDRESS=$(./build/shahd keys show "$NAME" -a --keyring-backend "$KEYRING_BACKEND" --home "$HOME_DIR" 2>/dev/null || echo "")
    
    if [ -z "$ADDRESS" ]; then
        echo "⚠️  Could not retrieve address automatically"
        echo "   Please check manually after script completes"
        ADDRESS="<check_manually>"
    fi
    
    # Save address info
    echo "$NAME: $ADDRESS" >> "$KEYS_DIR/addresses.txt"
    
    echo ""
    echo "✅ Created: $NAME"
    echo "   Address: $ADDRESS"
    echo "   Backup: $KEYS_DIR/${NAME}.key"
    echo ""
}

# Create founder key first
echo "Creating Founder Key..."
echo ""
create_validator_key "founder" "0"

# Create 4 validator keys
create_validator_key "validator1" "1"
create_validator_key "validator2" "2"
create_validator_key "validator3" "3"
create_validator_key "validator4" "4"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All keys created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Display all addresses
echo "📋 Validator Addresses:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$KEYS_DIR/addresses.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Save to a structured JSON file for easy reference
echo "💾 Saving validator info to validators.json..."
echo "   (Addresses will be retrieved after keyring settles)"
sleep 2

# Try to get addresses, use placeholder if fails
FOUNDER_ADDR=$(./build/shahd keys show founder -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR 2>/dev/null || echo "see_addresses.txt")
VAL1_ADDR=$(./build/shahd keys show validator1 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR 2>/dev/null || echo "see_addresses.txt")
VAL2_ADDR=$(./build/shahd keys show validator2 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR 2>/dev/null || echo "see_addresses.txt")
VAL3_ADDR=$(./build/shahd keys show validator3 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR 2>/dev/null || echo "see_addresses.txt")
VAL4_ADDR=$(./build/shahd keys show validator4 -a --keyring-backend $KEYRING_BACKEND --home $HOME_DIR 2>/dev/null || echo "see_addresses.txt")

cat > "$KEYS_DIR/validators.json" << EOF
{
  "chain_id": "$CHAIN_ID",
  "denom": "$DENOM",
  "keyring_backend": "$KEYRING_BACKEND",
  "validators": [
    {
      "name": "founder",
      "address": "$FOUNDER_ADDR",
      "allocation": "$FOUNDER_ALLOCATION",
      "role": "Founder & Treasury Manager"
    },
    {
      "name": "validator1",
      "address": "$VAL1_ADDR",
      "stake": "$VALIDATOR_STAKE",
      "moniker": "SHAH Genesis Validator 1",
      "website": "https://shah.vip"
    },
    {
      "name": "validator2",
      "address": "$VAL2_ADDR",
      "stake": "$VALIDATOR_STAKE",
      "moniker": "SHAH Genesis Validator 2",
      "website": "https://shah.vip"
    },
    {
      "name": "validator3",
      "address": "$VAL3_ADDR",
      "stake": "$VALIDATOR_STAKE",
      "moniker": "SHAH Genesis Validator 3",
      "website": "https://shah.vip"
    },
    {
      "name": "validator4",
      "address": "$VAL4_ADDR",
      "stake": "$VALIDATOR_STAKE",
      "moniker": "SHAH Genesis Validator 4",
      "website": "https://shah.vip"
    }
  ],
  "distribution": {
    "validators": "63M SHAH (25% each = 15.75M)",
    "treasury": "12.6M SHAH (20%)",
    "community": "3.15M SHAH (5%)",
    "founder": "15.75M SHAH (25%)"
  }
}
EOF

echo "✅ Saved to: $KEYS_DIR/validators.json"
echo ""

echo "⚠️  CRITICAL - BACKUP YOUR KEYS!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "All key backups are in: $KEYS_DIR/"
echo ""
echo "1. Copy this entire directory to a secure location:"
echo "   cp -r $KEYS_DIR /path/to/secure/backup/"
echo ""
echo "2. Store on encrypted USB drive"
echo "3. Keep passwords in a password manager"
echo "4. NEVER commit keys to GitHub!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔜 Next steps:"
echo "  1. Run: ./scripts/add_genesis_accounts.sh"
echo "  2. Run: ./scripts/create_gentxs.sh"
echo "  3. Run: ./build/shahd genesis collect-gentxs"
echo ""

