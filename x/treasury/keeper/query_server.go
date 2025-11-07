package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/shahcoin/shahcoin/x/treasury/types"
)

type queryServer struct {
	types.UnimplementedQueryServer
	Keeper
}

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

func (q queryServer) Reserves(goCtx context.Context, req *types.QueryReservesRequest) (*types.QueryReservesResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	reserveSHAH, reserveSHAHUSD, err := q.Keeper.GetReserves(ctx)
	if err != nil {
		return nil, err
	}

	return &types.QueryReservesResponse{
		ReserveShah:    reserveSHAH.String(),
		ReserveShahusd: reserveSHAHUSD.String(),
	}, nil
}

func (q queryServer) PolicyRate(goCtx context.Context, req *types.QueryPolicyRateRequest) (*types.QueryPolicyRateResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)

	rate, err := q.Keeper.GetPolicyRate(ctx)
	if err != nil {
		return nil, err
	}

	return &types.QueryPolicyRateResponse{Rate: rate.String()}, nil
}
