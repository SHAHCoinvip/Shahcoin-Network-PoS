package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
	cdctypes "github.com/cosmos/cosmos-sdk/codec/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/msgservice"
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

	msgservice.RegisterMsgServiceDesc(registry, &Msg_ServiceDesc)
}
