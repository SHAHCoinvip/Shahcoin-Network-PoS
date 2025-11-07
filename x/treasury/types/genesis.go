package types

import (
	"cosmossdk.io/math"
)

func DefaultGenesis() *GenesisState {
	params := DefaultParams()
	return &GenesisState{
		Params:         &params,
		ReserveShah:    math.ZeroInt().String(),
		ReserveShahusd: math.ZeroInt().String(),
	}
}

func (gs GenesisState) Validate() error {
	return gs.Params.Validate()
}

func DefaultParams() Params {
	targetRate := math.LegacyNewDecWithPrec(5, 0) // 5.0 SHAHUSD per SHAH
	return Params{
		PricingMode: "manual",
		TargetRate:  targetRate.String(),
		FeeBps:      50, // 0.5%
	}
}

func (p Params) Validate() error {
	if p.PricingMode != "manual" && p.PricingMode != "market" {
		return ErrInvalidParams
	}
	targetRate, err := math.LegacyNewDecFromStr(p.TargetRate)
	if err != nil || targetRate.IsNegative() || targetRate.IsZero() {
		return ErrInvalidParams
	}
	if p.FeeBps > 10000 {
		return ErrInvalidParams
	}
	return nil
}
