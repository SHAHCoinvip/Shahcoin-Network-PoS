package types

import (
	"cosmossdk.io/math"
)

// DefaultGenesis returns the default genesis state
func DefaultGenesis() *GenesisState {
	params := DefaultParams()
	return &GenesisState{
		Params:      &params,
		Pools:       []*Pool{},
		PoolCounter: 1,
	}
}

// Validate performs basic genesis state validation returning an error upon any failure.
func (gs GenesisState) Validate() error {
	if err := gs.Params.Validate(); err != nil {
		return err
	}

	return nil
}

// DefaultParams returns default module parameters
func DefaultParams() Params {
	tradeFee := math.LegacyNewDecWithPrec(3, 3)     // 0.003 = 0.3%
	protocolCut := math.LegacyNewDecWithPrec(16, 2) // 0.16 = 16%
	return Params{
		TradeFee:    tradeFee.String(),
		ProtocolCut: protocolCut.String(),
	}
}

// Validate performs validation on Params
func (p Params) Validate() error {
	tradeFee, err := math.LegacyNewDecFromStr(p.TradeFee)
	if err != nil || tradeFee.IsNegative() || tradeFee.GT(math.LegacyOneDec()) {
		return ErrInvalidParams
	}
	protocolCut, err := math.LegacyNewDecFromStr(p.ProtocolCut)
	if err != nil || protocolCut.IsNegative() || protocolCut.GT(math.LegacyOneDec()) {
		return ErrInvalidParams
	}
	return nil
}
