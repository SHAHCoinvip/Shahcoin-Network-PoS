package fees

import (
	"context"
	"encoding/json"
	"fmt"

	"cosmossdk.io/collections"
	"cosmossdk.io/core/appmodule"
	"cosmossdk.io/core/store"
	"cosmossdk.io/math"
	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/codec"
	cdctypes "github.com/cosmos/cosmos-sdk/codec/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/module"
	"github.com/cosmos/cosmos-sdk/types/msgservice"
	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	"github.com/spf13/cobra"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "github.com/shahcoin/shahcoin/x/fees/types"
)

const (
	ModuleName = "fees"
	StoreKey   = ModuleName
)

var (
	ParamsKey = collections.NewPrefix(0)
)

// Keeper
type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	authority    string
	Schema       collections.Schema
	Params       collections.Item[pb.Params]
}

func NewKeeper(cdc codec.BinaryCodec, storeService store.KVStoreService, authority string) Keeper {
	sb := collections.NewSchemaBuilder(storeService)
	k := Keeper{
		cdc:          cdc,
		storeService: storeService,
		authority:    authority,
		Params:       collections.NewItem(sb, ParamsKey, "params", codec.CollValue[pb.Params](cdc)),
	}
	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema
	return k
}

func (k Keeper) GetAuthority() string { return k.authority }

func (k Keeper) EstimateFee(ctx context.Context, gas uint64) (math.Int, math.LegacyDec, error) {
	params, err := k.Params.Get(ctx)
	if err != nil {
		return math.ZeroInt(), math.LegacyDec{}, err
	}

	usdRate, _ := math.LegacyNewDecFromStr(params.UsdRate)

	// Fee in shahi = gas * 1000
	feeShahi := math.NewInt(int64(gas * 1000))

	// Fee in USD = feeShahi / (10^8) / usdRate
	feeUSD := math.LegacyNewDecFromInt(feeShahi).Quo(math.LegacyNewDec(100000000)).Quo(usdRate)

	return feeShahi, feeUSD, nil
}

// Helper functions
func DefaultParams() pb.Params {
	usdRate := math.LegacyNewDecWithPrec(5, 0) // 5.0
	return pb.Params{
		UsdRate: usdRate.String(),
	}
}

func DefaultGenesis() *pb.GenesisState {
	params := DefaultParams()
	return &pb.GenesisState{Params: &params}
}

// Msg Server
type msgServer struct {
	pb.UnimplementedMsgServer
	Keeper
}

func NewMsgServerImpl(k Keeper) pb.MsgServer { return &msgServer{Keeper: k} }

func (m msgServer) UpdateParams(goCtx context.Context, msg *pb.MsgUpdateParams) (*pb.MsgUpdateParamsResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)
	if m.GetAuthority() != msg.Authority {
		return nil, fmt.Errorf("unauthorized")
	}
	if err := m.Params.Set(ctx, *msg.Params); err != nil {
		return nil, err
	}
	return &pb.MsgUpdateParamsResponse{}, nil
}

// Query Server
type queryServer struct {
	pb.UnimplementedQueryServer
	Keeper
}

func NewQueryServerImpl(k Keeper) pb.QueryServer { return &queryServer{Keeper: k} }

func (q queryServer) Params(goCtx context.Context, req *pb.QueryParamsRequest) (*pb.QueryParamsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	params, err := q.Keeper.Params.Get(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.QueryParamsResponse{Params: &params}, nil
}

func (q queryServer) EstimateTxFee(goCtx context.Context, req *pb.QueryEstimateTxFeeRequest) (*pb.QueryEstimateTxFeeResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	feeShahi, feeUSD, err := q.Keeper.EstimateFee(ctx, req.Gas)
	if err != nil {
		return nil, err
	}
	return &pb.QueryEstimateTxFeeResponse{FeeShahi: feeShahi.String(), FeeUsd: feeUSD.String()}, nil
}

// Codec
func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&pb.MsgUpdateParams{}, "fees/UpdateParams", nil)
}

func RegisterInterfaces(registry cdctypes.InterfaceRegistry) {
	registry.RegisterImplementations((*sdk.Msg)(nil), &pb.MsgUpdateParams{})
	msgservice.RegisterMsgServiceDesc(registry, &pb.Msg_ServiceDesc)
}

// Module
var (
	_ module.AppModuleBasic = AppModuleBasic{}
	_ module.HasGenesis     = AppModule{}
	_ appmodule.AppModule   = AppModule{}
)

type AppModuleBasic struct{ cdc codec.Codec }

func NewAppModuleBasic(cdc codec.Codec) AppModuleBasic {
	return AppModuleBasic{cdc: cdc}
}

func (AppModuleBasic) Name() string                                        { return ModuleName }
func (AppModuleBasic) RegisterLegacyAminoCodec(cdc *codec.LegacyAmino)     { RegisterCodec(cdc) }
func (a AppModuleBasic) RegisterInterfaces(reg cdctypes.InterfaceRegistry) { RegisterInterfaces(reg) }
func (AppModuleBasic) DefaultGenesis(cdc codec.JSONCodec) json.RawMessage {
	return cdc.MustMarshalJSON(DefaultGenesis())
}
func (AppModuleBasic) ValidateGenesis(cdc codec.JSONCodec, config client.TxEncodingConfig, bz json.RawMessage) error {
	var genState pb.GenesisState
	if err := cdc.UnmarshalJSON(bz, &genState); err != nil {
		return fmt.Errorf("failed to unmarshal genesis: %w", err)
	}
	return nil // Add validation if needed
}
func (AppModuleBasic) RegisterGRPCGatewayRoutes(clientCtx client.Context, mux *runtime.ServeMux) {
	if err := pb.RegisterQueryHandlerClient(context.Background(), mux, pb.NewQueryClient(clientCtx)); err != nil {
		panic(err)
	}
}
func (AppModuleBasic) GetTxCmd() *cobra.Command    { return nil }
func (AppModuleBasic) GetQueryCmd() *cobra.Command { return nil }

type AppModule struct {
	AppModuleBasic
	keeper Keeper
}

func NewAppModule(cdc codec.Codec, keeper Keeper) AppModule {
	return AppModule{AppModuleBasic: AppModuleBasic{cdc: cdc}, keeper: keeper}
}

func (am AppModule) IsOnePerModuleType() {}
func (am AppModule) IsAppModule()        {}

func (am AppModule) RegisterServices(cfg module.Configurator) {
	pb.RegisterMsgServer(cfg.MsgServer(), NewMsgServerImpl(am.keeper))
	pb.RegisterQueryServer(cfg.QueryServer(), NewQueryServerImpl(am.keeper))
}

func (am AppModule) InitGenesis(ctx sdk.Context, cdc codec.JSONCodec, gs json.RawMessage) {
	var genState pb.GenesisState
	cdc.MustUnmarshalJSON(gs, &genState)
	if genState.Params != nil {
		am.keeper.Params.Set(ctx, *genState.Params)
	}
}

func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONCodec) json.RawMessage {
	params, _ := am.keeper.Params.Get(ctx)
	return cdc.MustMarshalJSON(&pb.GenesisState{Params: &params})
}

func (AppModule) ConsensusVersion() uint64 { return 1 }
