package types

import "cosmossdk.io/collections"

const (
	ModuleName = "treasury"
	StoreKey   = ModuleName
	RouterKey  = ModuleName
)

var (
	ParamsKey         = collections.NewPrefix(0)
	ReserveSHAHKey    = collections.NewPrefix(1)
	ReserveSHAHUSDKey = collections.NewPrefix(2)
)
