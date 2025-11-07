package types

import "cosmossdk.io/collections"

const (
	// ModuleName defines the module name
	ModuleName = "shahswap"

	// StoreKey defines the primary module store key
	StoreKey = ModuleName

	// RouterKey defines the module's message routing key
	RouterKey = ModuleName
)

var (
	ParamsKey      = collections.NewPrefix(0)
	PoolsKey       = collections.NewPrefix(1)
	PoolCounterKey = collections.NewPrefix(2)
	LPPositionsKey = collections.NewPrefix(3)
)
