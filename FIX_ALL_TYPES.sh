#!/bin/bash
# Comprehensive type fixes for all modules

echo "🔧 Applying comprehensive type fixes..."

# The issue: Proto generates string types for customtype fields
# Solution: Add conversion helpers

cat > x/shahswap/types/helpers.go << 'EOF'
package types

import "cosmossdk.io/math"

// Helper functions to convert between proto strings and math types

func (p *Pool) GetReserveA() math.Int {
	v, _ := math.NewIntFromString(p.ReserveA)
	return v
}

func (p *Pool) GetReserveB() math.Int {
	v, _ := math.NewIntFromString(p.ReserveB)
	return v
}

func (p *Pool) GetTotalLpShares() math.Int {
	v, _ := math.NewIntFromString(p.TotalLpShares)
	return v
}

func (p *Pool) GetTotalVolume() math.Int {
	v, _ := math.NewIntFromString(p.TotalVolume)
	return v
}

func (p *Params) GetTradeFee() math.LegacyDec {
	v, _ := math.LegacyNewDecFromStr(p.TradeFee)
	return v
}

func (p *Params) GetProtocolCut() math.LegacyDec {
	v, _ := math.LegacyNewDecFromStr(p.ProtocolCut)
	return v
}
EOF

cat > x/treasury/types/helpers.go << 'EOF'
package types

import "cosmossdk.io/math"

func (p *Params) GetTargetRate() math.LegacyDec {
	v, _ := math.LegacyNewDecFromStr(p.TargetRate)
	return v
}
EOF

cat > x/fees/types/helpers.go << 'EOF'
package types

import "cosmossdk.io/math"

func (p *Params) GetUsdRate() math.LegacyDec {
	v, _ := math.LegacyNewDecFromStr(p.UsdRate)
	return v
}
EOF

echo "✅ Helper files created"
echo "Now rebuild: go build -o build/shahd ./cmd/shahd"

