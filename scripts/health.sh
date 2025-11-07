#!/bin/bash

# Shahcoin Health Check Script

SHAHD_HOME="${SHAHD_HOME:-$HOME/.shah}"
RPC_ENDPOINT="${RPC_ENDPOINT:-localhost:26657}"
REST_ENDPOINT="${REST_ENDPOINT:-localhost:1317}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔═══════════════════════════════════╗${NC}"
echo -e "${GREEN}║      SHAHCOIN HEALTH CHECK        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════╝${NC}"
echo ""

# Check if node is running
echo -e "${YELLOW}[1/6]${NC} Checking node status..."
if curl -s "$RPC_ENDPOINT/status" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Node is running"
    
    STATUS=$(curl -s "$RPC_ENDPOINT/status")
    CHAIN_ID=$(echo $STATUS | jq -r '.result.node_info.network')
    HEIGHT=$(echo $STATUS | jq -r '.result.sync_info.latest_block_height')
    CATCHING_UP=$(echo $STATUS | jq -r '.result.sync_info.catching_up')
    
    echo -e "  Chain ID: ${GREEN}$CHAIN_ID${NC}"
    echo -e "  Height: ${GREEN}$HEIGHT${NC}"
    echo -e "  Catching up: ${GREEN}$CATCHING_UP${NC}"
else
    echo -e "${RED}✗${NC} Node is not responding"
    exit 1
fi
echo ""

# Check validators
echo -e "${YELLOW}[2/6]${NC} Checking validators..."
VAL_COUNT=$(curl -s "$REST_ENDPOINT/cosmos/staking/v1beta1/validators?status=BOND_STATUS_BONDED" | jq '.validators | length')
echo -e "  Active validators: ${GREEN}$VAL_COUNT${NC}"
echo ""

# Check bank total supply
echo -e "${YELLOW}[3/6]${NC} Checking total supply..."
TOTAL_SUPPLY=$(curl -s "$REST_ENDPOINT/cosmos/bank/v1beta1/supply" | jq -r '.supply[] | select(.denom=="shahi") | .amount')
if [ ! -z "$TOTAL_SUPPLY" ]; then
    # Convert to SHAH (divide by 10^8)
    SHAH_SUPPLY=$((TOTAL_SUPPLY / 100000000))
    echo -e "  Total supply: ${GREEN}$SHAH_SUPPLY SHAH${NC} ($TOTAL_SUPPLY shahi)"
else
    echo -e "${RED}  Failed to retrieve supply${NC}"
fi
echo ""

# Check custom modules
echo -e "${YELLOW}[4/6]${NC} Checking custom modules..."

# Shahswap
SHAHSWAP=$(curl -s "$REST_ENDPOINT/shahcoin/shahswap/v1/params" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Shahswap module"
else
    echo -e "  ${RED}✗${NC} Shahswap module"
fi

# Treasury
TREASURY=$(curl -s "$REST_ENDPOINT/shahcoin/treasury/v1/reserves" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Treasury module"
else
    echo -e "  ${RED}✗${NC} Treasury module"
fi

# Fees
FEES=$(curl -s "$REST_ENDPOINT/shahcoin/fees/v1/params" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Fees module"
else
    echo -e "  ${RED}✗${NC} Fees module"
fi

# Monitoring
MONITORING=$(curl -s "$REST_ENDPOINT/shahcoin/monitoring/v1/metrics" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Monitoring module"
    TOTAL_TXS=$(echo $MONITORING | jq -r '.metrics.total_transactions // 0')
    echo -e "    Total transactions: ${GREEN}$TOTAL_TXS${NC}"
else
    echo -e "  ${RED}✗${NC} Monitoring module"
fi
echo ""

# Check governance params
echo -e "${YELLOW}[5/6]${NC} Checking governance..."
GOV_PARAMS=$(curl -s "$REST_ENDPOINT/cosmos/gov/v1/params/voting" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Governance module active"
else
    echo -e "  ${RED}✗${NC} Governance module"
fi
echo ""

# Check mint params
echo -e "${YELLOW}[6/6]${NC} Checking inflation (mint module)..."
MINT_PARAMS=$(curl -s "$REST_ENDPOINT/cosmos/mint/v1beta1/params" 2>/dev/null)
if [ $? -eq 0 ]; then
    INFLATION=$(curl -s "$REST_ENDPOINT/cosmos/mint/v1beta1/inflation" | jq -r '.inflation // "N/A"')
    echo -e "  ${GREEN}✓${NC} Mint module active"
    echo -e "    Current inflation: ${GREEN}$INFLATION${NC}"
else
    echo -e "  ${RED}✗${NC} Mint module"
fi
echo ""

echo -e "${GREEN}╔═══════════════════════════════════╗${NC}"
echo -e "${GREEN}║         HEALTH CHECK COMPLETE      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════╝${NC}"

