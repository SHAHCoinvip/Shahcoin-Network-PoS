package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
	cdctypes "github.com/cosmos/cosmos-sdk/codec/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&MsgMintShahUSD{}, "treasury/MintShahUSD", nil)
	cdc.RegisterConcrete(&MsgBurnShahUSD{}, "treasury/BurnShahUSD", nil)
	cdc.RegisterConcrete(&MsgBuyShah{}, "treasury/BuyShah", nil)
	cdc.RegisterConcrete(&MsgSellShah{}, "treasury/SellShah", nil)
	cdc.RegisterConcrete(&MsgUpdateParams{}, "treasury/UpdateParams", nil)
}

func RegisterInterfaces(registry cdctypes.InterfaceRegistry) {
	registry.RegisterImplementations((*sdk.Msg)(nil),
		&MsgMintShahUSD{},
		&MsgBurnShahUSD{},
		&MsgBuyShah{},
		&MsgSellShah{},
		&MsgUpdateParams{},
	)

	// Note: Service descriptor registration disabled due to proto descriptor compatibility issues
	// msgservice.RegisterMsgServiceDesc(registry, &Msg_ServiceDesc)
}
