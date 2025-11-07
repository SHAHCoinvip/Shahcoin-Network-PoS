package types

import (
	"cosmossdk.io/errors"
)

// x/shahswap module sentinel errors
var (
	ErrInvalidPoolID     = errors.Register(ModuleName, 1, "invalid pool id")
	ErrPoolNotFound      = errors.Register(ModuleName, 2, "pool not found")
	ErrInvalidDenom      = errors.Register(ModuleName, 3, "invalid denomination")
	ErrInsufficientFunds = errors.Register(ModuleName, 4, "insufficient funds")
	ErrInvalidAmount     = errors.Register(ModuleName, 5, "invalid amount")
	ErrSlippageExceeded  = errors.Register(ModuleName, 6, "slippage exceeded")
	ErrInvalidParams     = errors.Register(ModuleName, 7, "invalid parameters")
	ErrUnauthorized      = errors.Register(ModuleName, 8, "unauthorized")
)
