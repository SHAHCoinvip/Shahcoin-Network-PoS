package airdrop

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
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

	pb "github.com/shahcoin/shahcoin/x/airdrop/types"
)

const (
	ModuleName = "airdrop"
	StoreKey   = ModuleName
)

var (
	ParamsKey     = collections.NewPrefix(0)
	MerkleRootKey = collections.NewPrefix(1)
	ClaimedKey    = collections.NewPrefix(2)
	StartTimeKey  = collections.NewPrefix(3)
	EndTimeKey    = collections.NewPrefix(4)
)

// Keeper
type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	authority    string
	bankKeeper   BankKeeper

	Schema     collections.Schema
	Params     collections.Item[pb.Params]
	MerkleRoot collections.Item[string]
	Claimed    collections.Map[string, bool]
	StartTime  collections.Item[int64]
	EndTime    collections.Item[int64]
}

type BankKeeper interface {
	SendCoinsFromModuleToAccount(ctx context.Context, senderModule string, recipientAddr sdk.AccAddress, amt sdk.Coins) error
}

func NewKeeper(cdc codec.BinaryCodec, storeService store.KVStoreService, authority string, bankKeeper BankKeeper) Keeper {
	sb := collections.NewSchemaBuilder(storeService)
	k := Keeper{
		cdc:          cdc,
		storeService: storeService,
		authority:    authority,
		bankKeeper:   bankKeeper,
		Params:       collections.NewItem(sb, ParamsKey, "params", codec.CollValue[pb.Params](cdc)),
		MerkleRoot:   collections.NewItem(sb, MerkleRootKey, "merkle_root", collections.StringValue),
		Claimed:      collections.NewMap(sb, ClaimedKey, "claimed", collections.StringKey, collections.BoolValue),
		StartTime:    collections.NewItem(sb, StartTimeKey, "start_time", collections.Int64Value),
		EndTime:      collections.NewItem(sb, EndTimeKey, "end_time", collections.Int64Value),
	}
	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema
	return k
}

func (k Keeper) GetAuthority() string { return k.authority }

func (k Keeper) Claim(ctx context.Context, claimer sdk.AccAddress, amount math.Int, proof [][]byte) error {
	// Check if already claimed
	hasClaimed, _ := k.Claimed.Get(ctx, claimer.String())
	if hasClaimed {
		return fmt.Errorf("already claimed")
	}

	// Mark as claimed
	k.Claimed.Set(ctx, claimer.String(), true)

	// Send tokens
	coins := sdk.NewCoins(sdk.NewCoin("shahi", amount))
	if err := k.bankKeeper.SendCoinsFromModuleToAccount(ctx, ModuleName, claimer, coins); err != nil {
		return err
	}

	return nil
}

func (k Keeper) HasClaimed(ctx context.Context, address string) bool {
	hasClaimed, _ := k.Claimed.Get(ctx, address)
	return hasClaimed
}

// Helper functions
func DefaultParams() pb.Params {
	return pb.Params{AirdropEnabled: false}
}

func DefaultGenesis() *pb.GenesisState {
	params := DefaultParams()
	return &pb.GenesisState{
		Params:           &params,
		MerkleRoot:       "",
		ClaimedAddresses: []string{},
		StartTime:        0,
		EndTime:          0,
	}
}

// Msg Server
type msgServer struct {
	pb.UnimplementedMsgServer
	Keeper
}

func NewMsgServerImpl(k Keeper) pb.MsgServer { return &msgServer{Keeper: k} }

func (m msgServer) Claim(goCtx context.Context, msg *pb.MsgClaim) (*pb.MsgClaimResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)
	claimer, err := sdk.AccAddressFromBech32(msg.Claimer)
	if err != nil {
		return nil, err
	}

	amount, _ := math.NewIntFromString(msg.Amount)
	if err := m.Keeper.Claim(ctx, claimer, amount, msg.MerkleProof); err != nil {
		return nil, err
	}

	return &pb.MsgClaimResponse{AmountClaimed: msg.Amount}, nil
}

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

func (q queryServer) ClaimStatus(goCtx context.Context, req *pb.QueryClaimStatusRequest) (*pb.QueryClaimStatusResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "invalid request")
	}
	ctx := sdk.UnwrapSDKContext(goCtx)
	claimed := q.Keeper.HasClaimed(ctx, req.Address)
	return &pb.QueryClaimStatusResponse{Claimed: claimed}, nil
}

// Codec
func RegisterCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&pb.MsgClaim{}, "airdrop/Claim", nil)
	cdc.RegisterConcrete(&pb.MsgUpdateParams{}, "airdrop/UpdateParams", nil)
}

func RegisterInterfaces(registry cdctypes.InterfaceRegistry) {
	registry.RegisterImplementations((*sdk.Msg)(nil), &pb.MsgClaim{}, &pb.MsgUpdateParams{})
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
	if genState.MerkleRoot != "" {
		am.keeper.MerkleRoot.Set(ctx, genState.MerkleRoot)
	}
	for _, addr := range genState.ClaimedAddresses {
		am.keeper.Claimed.Set(ctx, addr, true)
	}
	if genState.StartTime > 0 {
		am.keeper.StartTime.Set(ctx, genState.StartTime)
	}
	if genState.EndTime > 0 {
		am.keeper.EndTime.Set(ctx, genState.EndTime)
	}
}

func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONCodec) json.RawMessage {
	params, _ := am.keeper.Params.Get(ctx)
	merkleRoot, _ := am.keeper.MerkleRoot.Get(ctx)
	startTime, _ := am.keeper.StartTime.Get(ctx)
	endTime, _ := am.keeper.EndTime.Get(ctx)

	var claimed []string
	am.keeper.Claimed.Walk(ctx, nil, func(key string, value bool) (stop bool, err error) {
		if value {
			claimed = append(claimed, key)
		}
		return false, nil
	})

	return cdc.MustMarshalJSON(&pb.GenesisState{
		Params:           &params,
		MerkleRoot:       merkleRoot,
		ClaimedAddresses: claimed,
		StartTime:        startTime,
		EndTime:          endTime,
	})
}

func (AppModule) ConsensusVersion() uint64 { return 1 }

// Utility: Verify Merkle proof (simplified)
func VerifyMerkleProof(leaf []byte, proof [][]byte, root string) bool {
	hash := sha256.Sum256(leaf)
	current := hash[:]

	for _, proofElement := range proof {
		combined := append(current, proofElement...)
		hash := sha256.Sum256(combined)
		current = hash[:]
	}

	return hex.EncodeToString(current) == root
}
