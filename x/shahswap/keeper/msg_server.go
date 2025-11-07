package keeper

import (
	"context"

	"cosmossdk.io/math"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/shahcoin/shahcoin/x/shahswap/types"
)

type msgServer struct {
	types.UnimplementedMsgServer
	Keeper
}

// NewMsgServerImpl returns an implementation of the MsgServer interface
// for the provided Keeper.
func NewMsgServerImpl(keeper Keeper) types.MsgServer {
	return &msgServer{Keeper: keeper}
}

var _ types.MsgServer = &msgServer{}

func (m msgServer) CreatePool(goCtx context.Context, msg *types.MsgCreatePool) (*types.MsgCreatePoolResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return nil, err
	}

	poolID, lpShares, err := m.Keeper.CreatePool(ctx, creator, *msg.CoinA, *msg.CoinB)
	if err != nil {
		return nil, err
	}

	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"create_pool",
			sdk.NewAttribute("pool_id", string(poolID)),
			sdk.NewAttribute("creator", msg.Creator),
			sdk.NewAttribute("lp_shares", lpShares.String()),
		),
	)

	return &types.MsgCreatePoolResponse{
		PoolId:   poolID,
		LpShares: lpShares.String(),
	}, nil
}

func (m msgServer) AddLiquidity(goCtx context.Context, msg *types.MsgAddLiquidity) (*types.MsgAddLiquidityResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	sender, err := sdk.AccAddressFromBech32(msg.Sender)
	if err != nil {
		return nil, err
	}

	lpShares, err := m.Keeper.AddLiquidity(ctx, sender, msg.PoolId, *msg.CoinA, *msg.CoinB)
	if err != nil {
		return nil, err
	}

	minLpShares, ok := math.NewIntFromString(msg.MinLpShares)
	if !ok || lpShares.LT(minLpShares) {
		return nil, types.ErrSlippageExceeded
	}

	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"add_liquidity",
			sdk.NewAttribute("pool_id", string(msg.PoolId)),
			sdk.NewAttribute("sender", msg.Sender),
			sdk.NewAttribute("lp_shares", lpShares.String()),
		),
	)

	return &types.MsgAddLiquidityResponse{
		LpShares: lpShares.String(),
	}, nil
}

func (m msgServer) RemoveLiquidity(goCtx context.Context, msg *types.MsgRemoveLiquidity) (*types.MsgRemoveLiquidityResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	sender, err := sdk.AccAddressFromBech32(msg.Sender)
	if err != nil {
		return nil, err
	}

	lpShares, ok := math.NewIntFromString(msg.LpShares)
	if !ok {
		return nil, types.ErrInvalidAmount
	}

	coinA, coinB, err := m.Keeper.RemoveLiquidity(ctx, sender, msg.PoolId, lpShares)
	if err != nil {
		return nil, err
	}

	minCoinA, ok1 := math.NewIntFromString(msg.MinCoinA)
	minCoinB, ok2 := math.NewIntFromString(msg.MinCoinB)
	if !ok1 || !ok2 || coinA.Amount.LT(minCoinA) || coinB.Amount.LT(minCoinB) {
		return nil, types.ErrSlippageExceeded
	}

	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"remove_liquidity",
			sdk.NewAttribute("pool_id", string(msg.PoolId)),
			sdk.NewAttribute("sender", msg.Sender),
			sdk.NewAttribute("coin_a", coinA.String()),
			sdk.NewAttribute("coin_b", coinB.String()),
		),
	)

	return &types.MsgRemoveLiquidityResponse{
		CoinA: &coinA,
		CoinB: &coinB,
	}, nil
}

func (m msgServer) SwapExactIn(goCtx context.Context, msg *types.MsgSwapExactIn) (*types.MsgSwapExactInResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	sender, err := sdk.AccAddressFromBech32(msg.Sender)
	if err != nil {
		return nil, err
	}

	coinOut, err := m.Keeper.SwapExactIn(ctx, sender, msg.PoolId, *msg.CoinIn, msg.DenomOut)
	if err != nil {
		return nil, err
	}

	minAmountOut, ok := math.NewIntFromString(msg.MinAmountOut)
	if !ok || coinOut.Amount.LT(minAmountOut) {
		return nil, types.ErrSlippageExceeded
	}

	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"swap",
			sdk.NewAttribute("pool_id", string(msg.PoolId)),
			sdk.NewAttribute("sender", msg.Sender),
			sdk.NewAttribute("coin_in", msg.CoinIn.String()),
			sdk.NewAttribute("coin_out", coinOut.String()),
		),
	)

	return &types.MsgSwapExactInResponse{
		CoinOut: &coinOut,
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
