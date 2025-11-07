package app

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
)

const (
	// Bech32MainPrefix defines the Bech32 prefix for account addresses
	Bech32MainPrefix = "shah"

	// Bech32PrefixAccAddr defines the Bech32 prefix of an account's address
	Bech32PrefixAccAddr = Bech32MainPrefix
	// Bech32PrefixAccPub defines the Bech32 prefix of an account's public key
	Bech32PrefixAccPub = Bech32MainPrefix + "pub"
	// Bech32PrefixValAddr defines the Bech32 prefix of a validator's operator address
	Bech32PrefixValAddr = Bech32MainPrefix + "valoper"
	// Bech32PrefixValPub defines the Bech32 prefix of a validator's operator public key
	Bech32PrefixValPub = Bech32MainPrefix + "valoperpub"
	// Bech32PrefixConsAddr defines the Bech32 prefix of a consensus node address
	Bech32PrefixConsAddr = Bech32MainPrefix + "valcons"
	// Bech32PrefixConsPub defines the Bech32 prefix of a consensus node public key
	Bech32PrefixConsPub = Bech32MainPrefix + "valconspub"

	// Bond denom (base denom is shahi, 10^8 shahi = 1 SHAH)
	BondDenom = "shahi"
)

// SetConfig sets the configuration for addresses
func SetConfig() {
	config := sdk.GetConfig()
	// Only set if not already set to "shah" (default is "cosmos")
	if config.GetBech32AccountAddrPrefix() != Bech32MainPrefix {
		config.SetBech32PrefixForAccount(Bech32PrefixAccAddr, Bech32PrefixAccPub)
		config.SetBech32PrefixForValidator(Bech32PrefixValAddr, Bech32PrefixValPub)
		config.SetBech32PrefixForConsensusNode(Bech32PrefixConsAddr, Bech32PrefixConsPub)
		config.Seal()
	}
}
