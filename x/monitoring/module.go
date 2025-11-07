package monitoring

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

	pb "github.com/shahcoin/shahcoin/x/monitoring/types"
)

const (
	ModuleName = "monitoring"
	StoreKey   = ModuleName
)

var (
	ParamsKey  = collections.NewPrefix(0)
	MetricsKey = collections.NewPrefix(1)
)

// Keeper
type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	authority    string

	Schema  collections.Schema
	Params  collections.Item[pb.Params]
	Metrics collections.Item[pb.Metrics]
}

func NewKeeper(cdc codec.BinaryCodec, storeService store.KVStoreService, authority string) Keeper {
	sb := collections.NewSchemaBuilder(storeService)
	k := Keeper{
		cdc:          cdc,
		storeService: storeService,
		authority:    authority,
		Params:       collections.NewItem(sb, ParamsKey, "params", codec.CollValue[pb.Params](cdc)),
		Metrics:      collections.NewItem(sb, MetricsKey, "metrics", codec.CollValue[pb.Metrics](cdc)),
	}
	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema
	return k
}

func (k Keeper) GetAuthority() string { return k.authority }

func (k Keeper) GetMetrics(ctx context.Context) (pb.Metrics, error) {
	metrics, err := k.Metrics.Get(ctx)
	if err != nil {
		return DefaultMetrics(), nil
	}
	return metrics, nil
}

func (k Keeper) IncrementTxCount(ctx context.Context) error {
	metrics, _ := k.GetMetrics(ctx)
	metrics.TotalTransactions++
	return k.Metrics.Set(ctx, metrics)
}

func (k Keeper) UpdateActiveValidators(ctx context.Context, count uint64) error {
	metrics, _ := k.GetMetrics(ctx)
	metrics.ActiveValidators = count
	return k.Metrics.Set(ctx, metrics)
}

func (k Keeper) UpdateSwapVolume(ctx context.Context, volume math.Int) error {
	metrics, _ := k.GetMetrics(ctx)
	metrics.TotalSwapVolume = volume.String()
	return k.Metrics.Set(ctx, metrics)
}

// Helper functions
func DefaultParams() pb.Params {
	return pb.Params{MetricsEnabled: true}
}

func DefaultMetrics() pb.Metrics {
	return pb.Metrics{
		TotalTransactions: 0,
		ActiveValidators:  0,
		TotalSwapVolume:   math.ZeroInt().String(),
		LastBlockTime:     0,
	}
}

func DefaultGenesis() *pb.GenesisState {
	params := DefaultParams()
	metrics := DefaultMetrics()
	return &pb.GenesisState{
		Params:  &params,
		Metrics: &metrics,
	}
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

func (q queryServer) Metrics(goCtx context.Context, req *pb.QueryMetricsRequest) (*pb.QueryMetricsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	metrics, err := q.Keeper.GetMetrics(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.QueryMetricsResponse{Metrics: &metrics}, nil
}

// Codec
func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&pb.MsgUpdateParams{}, "monitoring/UpdateParams", nil)
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
	return nil
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
	if genState.Metrics != nil {
		am.keeper.Metrics.Set(ctx, *genState.Metrics)
	}
}

func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONCodec) json.RawMessage {
	params, _ := am.keeper.Params.Get(ctx)
	metrics, _ := am.keeper.GetMetrics(ctx)
	return cdc.MustMarshalJSON(&pb.GenesisState{Params: &params, Metrics: &metrics})
}

func (AppModule) ConsensusVersion() uint64 { return 1 }
