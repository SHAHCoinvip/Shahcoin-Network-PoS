package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/shahcoin/shahcoin/x/shahswap/types"
)

type queryServer struct {
	types.UnimplementedQueryServer
	Keeper
}

// NewQueryServerImpl returns an implementation of the QueryServer interface
func NewQueryServerImpl(keeper Keeper) types.QueryServer {
	return &queryServer{Keeper: keeper}
}

var _ types.QueryServer = &queryServer{}

func (q queryServer) Params(goCtx context.Context, req *types.QueryParamsRequest) (*types.QueryParamsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	params, err := q.Keeper.Params.Get(ctx)
	if err != nil {
		return nil, err
	}

	return &types.QueryParamsResponse{Params: &params}, nil
}

func (q queryServer) Pool(goCtx context.Context, req *types.QueryPoolRequest) (*types.QueryPoolResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	pool, err := q.Keeper.GetPool(ctx, req.PoolId)
	if err != nil {
		return nil, status.Error(codes.NotFound, "pool not found")
	}

	return &types.QueryPoolResponse{Pool: &pool}, nil
}

func (q queryServer) Pools(goCtx context.Context, req *types.QueryPoolsRequest) (*types.QueryPoolsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	pools, err := q.Keeper.GetAllPools(ctx)
	if err != nil {
		return nil, err
	}

	poolPtrs := make([]*types.Pool, len(pools))
	for i := range pools {
		poolPtrs[i] = &pools[i]
	}

	return &types.QueryPoolsResponse{Pools: poolPtrs}, nil
}

func (q queryServer) SpotPrice(goCtx context.Context, req *types.QuerySpotPriceRequest) (*types.QuerySpotPriceResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	spotPrice, err := q.Keeper.CalculateSpotPrice(ctx, req.PoolId, req.DenomIn, req.DenomOut)
	if err != nil {
		return nil, err
	}

	return &types.QuerySpotPriceResponse{SpotPrice: spotPrice.String()}, nil
}

func (q queryServer) LPPosition(goCtx context.Context, req *types.QueryLPPositionRequest) (*types.QueryLPPositionResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	position, err := q.Keeper.GetLPPosition(ctx, req.PoolId, req.Address)
	if err != nil {
		return nil, status.Error(codes.NotFound, "position not found")
	}

	return &types.QueryLPPositionResponse{Position: &position}, nil
}
