package app

import (
	"sync"

	"cosmossdk.io/core/address"
	"cosmossdk.io/x/tx/signing"
	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/codec"
	codecaddress "github.com/cosmos/cosmos-sdk/codec/address"
	"github.com/cosmos/cosmos-sdk/codec/types"
	"github.com/cosmos/cosmos-sdk/std"
	"github.com/cosmos/cosmos-sdk/x/auth/tx"
)

// EncodingConfig specifies the concrete encoding types to use for a given app.
type EncodingConfig struct {
	InterfaceRegistry types.InterfaceRegistry
	Codec             codec.Codec
	TxConfig          client.TxConfig
	Amino             *codec.LegacyAmino
	AddressCodec      address.Codec
	ValidatorCodec    address.Codec
	ConsensusCodec    address.Codec
}

var (
	encodingConfig EncodingConfig
	encConfigOnce  sync.Once
)

// MakeEncodingConfig creates an EncodingConfig for shahcoin.
func MakeEncodingConfig() EncodingConfig {
	encConfigOnce.Do(func() {
		encodingConfig = makeEncodingConfig()
	})
	return encodingConfig
}

func makeEncodingConfig() EncodingConfig {
	amino := codec.NewLegacyAmino()
	interfaceRegistry := types.NewInterfaceRegistry()
	cdc := codec.NewProtoCodec(interfaceRegistry)

	// Create address codecs with shah prefix
	addressCodec := codecaddress.NewBech32Codec("shah")
	validatorCodec := codecaddress.NewBech32Codec("shahvaloper")
	consensusCodec := codecaddress.NewBech32Codec("shahvalcons")

	// Create signing options
	signingOptions := signing.Options{
		AddressCodec:          addressCodec,
		ValidatorAddressCodec: validatorCodec,
	}

	txConfig, err := tx.NewTxConfigWithOptions(
		cdc,
		tx.ConfigOptions{
			EnabledSignModes: tx.DefaultSignModes,
			SigningOptions:   &signingOptions,
		},
	)
	if err != nil {
		panic(err)
	}

	return EncodingConfig{
		InterfaceRegistry: interfaceRegistry,
		Codec:             cdc,
		TxConfig:          txConfig,
		Amino:             amino,
		AddressCodec:      addressCodec,
		ValidatorCodec:    validatorCodec,
		ConsensusCodec:    consensusCodec,
	}
}

// RegisterLegacyAminoCodec registers the necessary x/auth interfaces and concrete types
// on the provided LegacyAmino codec. These types are used for Amino JSON serialization.
func RegisterLegacyAminoCodec(cdc *codec.LegacyAmino) {
	std.RegisterLegacyAminoCodec(cdc)
}

// RegisterInterfaces registers Interfaces from sdk and custom modules
func RegisterInterfaces(interfaceRegistry types.InterfaceRegistry) {
	std.RegisterInterfaces(interfaceRegistry)
}
