package types

import (
	"cosmossdk.io/errors"
)

var (
	ErrInvalidParams     = errors.Register(ModuleName, 1, "invalid parameters")
	ErrInsufficientFunds = errors.Register(ModuleName, 2, "insufficient funds")
	ErrUnauthorized      = errors.Register(ModuleName, 3, "unauthorized")
)
