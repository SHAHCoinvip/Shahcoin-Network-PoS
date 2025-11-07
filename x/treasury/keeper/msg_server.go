package keeper

import (
	"context"
	"fmt"

	"cosmossdk.io/math"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/shahcoin/shahcoin/x/treasury/types"
)

type msgServer struct {
	types.UnimplementedMsgServer
	Keeper
}

func NewMsgServerImpl(keeper Keeper) types.MsgServer {
	return &msgServer{Keeper: keeper}
}

var _ types.MsgServer = &msgServer{}

func (m msgServer) MintShahUSD(goCtx context.Context, msg *types.MsgMintShahUSD) (*types.MsgMintShahUSDResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	if m.GetAuthority() != msg.Authority {
		return nil, types.ErrUnauthorized
	}

	recipient, err := sdk.AccAddressFromBech32(msg.Recipient)
	if err != nil {
		return nil, err
	}

	amount, ok := math.NewIntFromString(msg.Amount)
	if !ok {
		return nil, fmt.Errorf("invalid amount")
	}

	if err := m.Keeper.MintShahUSD(ctx, recipient, amount); err != nil {
		return nil, err
	}

	return &types.MsgMintShahUSDResponse{}, nil
}

func (m msgServer) BurnShahUSD(goCtx context.Context, msg *types.MsgBurnShahUSD) (*types.MsgBurnShahUSDResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	sender, err := sdk.AccAddressFromBech32(msg.Sender)
	if err != nil {
		return nil, err
	}

	amount, ok := math.NewIntFromString(msg.Amount)
	if !ok {
		return nil, fmt.Errorf("invalid amount")
	}

	if err := m.Keeper.BurnShahUSD(ctx, sender, amount); err != nil {
		return nil, err
	}

	return &types.MsgBurnShahUSDResponse{}, nil
}

func (m msgServer) BuyShah(goCtx context.Context, msg *types.MsgBuyShah) (*types.MsgBuyShahResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	buyer, err := sdk.AccAddressFromBech32(msg.Buyer)
	if err != nil {
		return nil, err
	}

	shahOut, err := m.Keeper.BuyShah(ctx, buyer, msg.ShahusdIn.Amount)
	if err != nil {
		return nil, err
	}

	minShahOut, ok := math.NewIntFromString(msg.MinShahOut)
	if !ok {
		return nil, fmt.Errorf("invalid min shah out")
	}

	if shahOut.LT(minShahOut) {
		return nil, types.ErrInsufficientFunds
	}

	return &types.MsgBuyShahResponse{
		ShahOut: &sdk.Coin{Denom: "shahi", Amount: shahOut},
	}, nil
}

func (m msgServer) SellShah(goCtx context.Context, msg *types.MsgSellShah) (*types.MsgSellShahResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	seller, err := sdk.AccAddressFromBech32(msg.Seller)
	if err != nil {
		return nil, err
	}

	shahUSDOut, err := m.Keeper.SellShah(ctx, seller, msg.ShahIn.Amount)
	if err != nil {
		return nil, err
	}

	minShahusdOut, ok := math.NewIntFromString(msg.MinShahusdOut)
	if !ok {
		return nil, fmt.Errorf("invalid min shahusd out")
	}

	if shahUSDOut.LT(minShahusdOut) {
		return nil, types.ErrInsufficientFunds
	}

	return &types.MsgSellShahResponse{
		ShahusdOut: &sdk.Coin{Denom: "shahusd", Amount: shahUSDOut},
	}, nil
}

func (m msgServer) UpdateParams(goCtx context.Context, msg *types.MsgUpdateParams) (*types.MsgUpdateParamsResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	if m.GetAuthority() != msg.Authority {
		return nil, types.ErrUnauthorized
	}

	if err := msg.Params.Validate(); err != nil {
		return nil, err
	}

	if err := m.Params.Set(ctx, *msg.Params); err != nil {
		return nil, err
	}

	return &types.MsgUpdateParamsResponse{}, nil
}
