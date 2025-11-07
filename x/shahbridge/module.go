package shahbridge

import (
	"context"
	"encoding/json"
	"fmt"

	"cosmossdk.io/collections"
	"cosmossdk.io/core/appmodule"
	"cosmossdk.io/core/store"
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

	pb "github.com/shahcoin/shahcoin/x/shahbridge/types"
)

const (
	ModuleName = "shahbridge"
	StoreKey   = ModuleName
)

var (
	ParamsKey   = collections.NewPrefix(0)
	ChannelsKey = collections.NewPrefix(1)
)

// Keeper
type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	authority    string

	Schema   collections.Schema
	Params   collections.Item[pb.Params]
	Channels collections.Map[string, pb.ChannelMetadata]
}

func NewKeeper(cdc codec.BinaryCodec, storeService store.KVStoreService, authority string) Keeper {
	sb := collections.NewSchemaBuilder(storeService)
	k := Keeper{
		cdc:          cdc,
		storeService: storeService,
		authority:    authority,
		Params:       collections.NewItem(sb, ParamsKey, "params", codec.CollValue[pb.Params](cdc)),
		Channels:     collections.NewMap(sb, ChannelsKey, "channels", collections.StringKey, codec.CollValue[pb.ChannelMetadata](cdc)),
	}
	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema
	return k
}

func (k Keeper) GetAuthority() string { return k.authority }

func (k Keeper) RegisterChannel(ctx context.Context, metadata pb.ChannelMetadata) error {
	return k.Channels.Set(ctx, metadata.ChannelId, metadata)
}

func (k Keeper) GetAllChannels(ctx context.Context) ([]pb.ChannelMetadata, error) {
	var channels []pb.ChannelMetadata
	err := k.Channels.Walk(ctx, nil, func(key string, value pb.ChannelMetadata) (stop bool, err error) {
		channels = append(channels, value)
		return false, nil
	})
	return channels, err
}

// Helper functions
func DefaultParams() pb.Params {
	return pb.Params{BridgeEnabled: true}
}

func DefaultGenesis() *pb.GenesisState {
	params := DefaultParams()
	return &pb.GenesisState{
		Params:   &params,
		Channels: []*pb.ChannelMetadata{},
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
	keeper Keeper
}

func NewQueryServerImpl(k Keeper) pb.QueryServer { return &queryServer{keeper: k} }

func (q queryServer) Params(goCtx context.Context, req *pb.QueryParamsRequest) (*pb.QueryParamsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	params, err := q.keeper.Params.Get(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.QueryParamsResponse{Params: &params}, nil
}

func (q queryServer) Channels(goCtx context.Context, req *pb.QueryChannelsRequest) (*pb.QueryChannelsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	channels, err := q.keeper.GetAllChannels(ctx)
	if err != nil {
		return nil, err
	}
	channelPtrs := make([]*pb.ChannelMetadata, len(channels))
	for i := range channels {
		channelPtrs[i] = &channels[i]
	}
	return &pb.QueryChannelsResponse{Channels: channelPtrs}, nil
}

// Codec
func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&pb.MsgUpdateParams{}, "shahbridge/UpdateParams", nil)
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
	for _, ch := range genState.Channels {
		if ch != nil {
			am.keeper.Channels.Set(ctx, ch.ChannelId, *ch)
		}
	}
}

func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONCodec) json.RawMessage {
	params, _ := am.keeper.Params.Get(ctx)
	channels, _ := am.keeper.GetAllChannels(ctx)
	channelPtrs := make([]*pb.ChannelMetadata, len(channels))
	for i := range channels {
		channelPtrs[i] = &channels[i]
	}
	return cdc.MustMarshalJSON(&pb.GenesisState{Params: &params, Channels: channelPtrs})
}

func (AppModule) ConsensusVersion() uint64 { return 1 }
