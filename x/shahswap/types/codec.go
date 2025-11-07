package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
	cdctypes "github.com/cosmos/cosmos-sdk/codec/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&MsgCreatePool{}, "shahswap/CreatePool", nil)
	cdc.RegisterConcrete(&MsgAddLiquidity{}, "shahswap/AddLiquidity", nil)
	cdc.RegisterConcrete(&MsgRemoveLiquidity{}, "shahswap/RemoveLiquidity", nil)
	cdc.RegisterConcrete(&MsgSwapExactIn{}, "shahswap/SwapExactIn", nil)
	cdc.RegisterConcrete(&MsgUpdateParams{}, "shahswap/UpdateParams", nil)
}

func RegisterInterfaces(registry cdctypes.InterfaceRegistry) {
	registry.RegisterImplementations((*sdk.Msg)(nil),
		&MsgCreatePool{},
		&MsgAddLiquidity{},
		&MsgRemoveLiquidity{},
		&MsgSwapExactIn{},
		&MsgUpdateParams{},
	)

	// Note: Service descriptor registration disabled due to proto descriptor compatibility issues
	// msgservice.RegisterMsgServiceDesc(registry, &Msg_ServiceDesc)
}
