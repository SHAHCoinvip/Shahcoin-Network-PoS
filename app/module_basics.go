package app

import (
	"github.com/cosmos/cosmos-sdk/types/module"
	"github.com/cosmos/cosmos-sdk/x/auth"
	"github.com/cosmos/cosmos-sdk/x/auth/vesting"
	"github.com/cosmos/cosmos-sdk/x/bank"
	consensus "github.com/cosmos/cosmos-sdk/x/consensus"
	distr "github.com/cosmos/cosmos-sdk/x/distribution"
	"github.com/cosmos/cosmos-sdk/x/genutil"
	genutiltypes "github.com/cosmos/cosmos-sdk/x/genutil/types"
	"github.com/cosmos/cosmos-sdk/x/gov"
	"github.com/cosmos/cosmos-sdk/x/mint"
	"github.com/cosmos/cosmos-sdk/x/params"
	"github.com/cosmos/cosmos-sdk/x/slashing"
	"github.com/cosmos/cosmos-sdk/x/staking"
	"github.com/cosmos/ibc-go/v8/modules/apps/transfer"
	ibc "github.com/cosmos/ibc-go/v8/modules/core"

	"github.com/shahcoin/shahcoin/x/airdrop"
	"github.com/shahcoin/shahcoin/x/fees"
	"github.com/shahcoin/shahcoin/x/monitoring"
	"github.com/shahcoin/shahcoin/x/shahbridge"
	"github.com/shahcoin/shahcoin/x/shahswap"
	"github.com/shahcoin/shahcoin/x/treasury"
)

// ModuleBasics defines the module BasicManager that lists all the modules that are
// essential for the shahcoin blockchain.
// Note: We initialize it with a function to provide codec
var ModuleBasics = NewBasicManagerWithCodec()

func NewBasicManagerWithCodec() module.BasicManager {
	encodingConfig := MakeEncodingConfig()
	cdc := encodingConfig.Codec

	return module.NewBasicManager(
		auth.AppModuleBasic{},
		genutil.NewAppModuleBasic(genutiltypes.DefaultMessageValidator),
		bank.AppModuleBasic{},
		staking.AppModuleBasic{},
		mint.AppModuleBasic{},
		distr.AppModuleBasic{},
		gov.NewAppModuleBasic(nil),
		params.AppModuleBasic{},
		slashing.AppModuleBasic{},
		vesting.AppModuleBasic{},
		consensus.AppModuleBasic{},
		// IBC
		ibc.AppModuleBasic{},
		transfer.AppModuleBasic{},
		// Custom modules
		shahswap.NewAppModuleBasic(cdc),
		treasury.NewAppModuleBasic(cdc),
		fees.NewAppModuleBasic(cdc),
		airdrop.NewAppModuleBasic(cdc),
		monitoring.NewAppModuleBasic(cdc),
		shahbridge.NewAppModuleBasic(cdc),
	)
}

func init() {
	// Set the address prefix configuration
	SetConfig()
}
