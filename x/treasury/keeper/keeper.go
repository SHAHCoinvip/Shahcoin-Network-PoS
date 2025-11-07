package keeper

import (
	"context"
	"fmt"

	"cosmossdk.io/collections"
	"cosmossdk.io/core/store"
	"cosmossdk.io/log"
	"cosmossdk.io/math"
	"github.com/cosmos/cosmos-sdk/codec"
	sdk "github.com/cosmos/cosmos-sdk/types"

	"github.com/shahcoin/shahcoin/x/treasury/types"
)

type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	logger       log.Logger
	authority    string

	Schema         collections.Schema
	Params         collections.Item[types.Params]
	ReserveSHAH    collections.Item[math.Int]
	ReserveSHAHUSD collections.Item[math.Int]

	bankKeeper types.BankKeeper
}

func NewKeeper(
	cdc codec.BinaryCodec,
	storeService store.KVStoreService,
	logger log.Logger,
	authority string,
	bankKeeper types.BankKeeper,
) Keeper {
	sb := collections.NewSchemaBuilder(storeService)

	k := Keeper{
		cdc:            cdc,
		storeService:   storeService,
		authority:      authority,
		logger:         logger,
		Params:         collections.NewItem(sb, types.ParamsKey, "params", codec.CollValue[types.Params](cdc)),
		ReserveSHAH:    collections.NewItem(sb, types.ReserveSHAHKey, "reserve_shah", sdk.IntValue),
		ReserveSHAHUSD: collections.NewItem(sb, types.ReserveSHAHUSDKey, "reserve_shahusd", sdk.IntValue),
		bankKeeper:     bankKeeper,
	}

	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema

	return k
}

func (k Keeper) GetAuthority() string {
	return k.authority
}

func (k Keeper) Logger() log.Logger {
	return k.logger.With("module", fmt.Sprintf("x/%s", types.ModuleName))
}

func (k Keeper) MintShahUSD(ctx context.Context, recipient sdk.AccAddress, amount math.Int) error {
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	coin := sdk.NewCoin("shahusd", amount)

	// Mint to module account then send to recipient
	coins := sdk.NewCoins(coin)
	if err := k.bankKeeper.MintCoins(ctx, types.ModuleName, coins); err != nil {
		return err
	}

	if err := k.bankKeeper.SendCoins(ctx, moduleAddr, recipient, coins); err != nil {
		return err
	}

	// Update reserve
	reserve, _ := k.ReserveSHAHUSD.Get(ctx)
	reserve = reserve.Add(amount)
	return k.ReserveSHAHUSD.Set(ctx, reserve)
}

func (k Keeper) BurnShahUSD(ctx context.Context, sender sdk.AccAddress, amount math.Int) error {
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	coin := sdk.NewCoin("shahusd", amount)
	coins := sdk.NewCoins(coin)

	// Send from user to module
	if err := k.bankKeeper.SendCoins(ctx, sender, moduleAddr, coins); err != nil {
		return err
	}

	// Burn from module
	if err := k.bankKeeper.BurnCoins(ctx, types.ModuleName, coins); err != nil {
		return err
	}

	// Update reserve
	reserve, _ := k.ReserveSHAHUSD.Get(ctx)
	reserve = reserve.Sub(amount)
	return k.ReserveSHAHUSD.Set(ctx, reserve)
}

func (k Keeper) GetPolicyRate(ctx context.Context) (math.LegacyDec, error) {
	params, err := k.Params.Get(ctx)
	if err != nil {
		return math.LegacyDec{}, err
	}
	return math.LegacyNewDecFromStr(params.TargetRate)
}

func (k Keeper) BuyShah(ctx context.Context, buyer sdk.AccAddress, shahUSDIn math.Int) (math.Int, error) {
	params, err := k.Params.Get(ctx)
	if err != nil {
		return math.ZeroInt(), err
	}

	targetRate, err := math.LegacyNewDecFromStr(params.TargetRate)
	if err != nil {
		return math.ZeroInt(), err
	}

	// Calculate SHAH output based on policy rate
	// shahOut = shahUSDIn / targetRate
	shahOut := math.LegacyNewDecFromInt(shahUSDIn).Quo(targetRate).TruncateInt()

	// Apply fee
	feeBps := math.LegacyNewDec(int64(params.FeeBps))
	feeMultiplier := math.LegacyNewDec(10000).Sub(feeBps).Quo(math.LegacyNewDec(10000))
	shahOut = feeMultiplier.MulInt(shahOut).TruncateInt()

	if shahOut.IsZero() {
		return math.ZeroInt(), fmt.Errorf("insufficient output")
	}

	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))

	// Transfer SHAHUSD from buyer to treasury
	shahUSDCoin := sdk.NewCoin("shahusd", shahUSDIn)
	if err := k.bankKeeper.SendCoins(ctx, buyer, moduleAddr, sdk.NewCoins(shahUSDCoin)); err != nil {
		return math.ZeroInt(), err
	}

	// Transfer SHAH from treasury to buyer
	shahCoin := sdk.NewCoin("shahi", shahOut)
	if err := k.bankKeeper.SendCoins(ctx, moduleAddr, buyer, sdk.NewCoins(shahCoin)); err != nil {
		return math.ZeroInt(), err
	}

	// Update reserves
	reserveSHAH, _ := k.ReserveSHAH.Get(ctx)
	reserveSHAH = reserveSHAH.Sub(shahOut)
	k.ReserveSHAH.Set(ctx, reserveSHAH)

	reserveSHAHUSD, _ := k.ReserveSHAHUSD.Get(ctx)
	reserveSHAHUSD = reserveSHAHUSD.Add(shahUSDIn)
	k.ReserveSHAHUSD.Set(ctx, reserveSHAHUSD)

	return shahOut, nil
}

func (k Keeper) SellShah(ctx context.Context, seller sdk.AccAddress, shahIn math.Int) (math.Int, error) {
	params, err := k.Params.Get(ctx)
	if err != nil {
		return math.ZeroInt(), err
	}

	targetRate, err := math.LegacyNewDecFromStr(params.TargetRate)
	if err != nil {
		return math.ZeroInt(), err
	}

	// Calculate SHAHUSD output based on policy rate
	// shahUSDOut = shahIn * targetRate
	shahUSDOut := targetRate.MulInt(shahIn).TruncateInt()

	// Apply fee
	feeBps := math.LegacyNewDec(int64(params.FeeBps))
	feeMultiplier := math.LegacyNewDec(10000).Sub(feeBps).Quo(math.LegacyNewDec(10000))
	shahUSDOut = feeMultiplier.MulInt(shahUSDOut).TruncateInt()

	if shahUSDOut.IsZero() {
		return math.ZeroInt(), fmt.Errorf("insufficient output")
	}

	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))

	// Transfer SHAH from seller to treasury
	shahCoin := sdk.NewCoin("shahi", shahIn)
	if err := k.bankKeeper.SendCoins(ctx, seller, moduleAddr, sdk.NewCoins(shahCoin)); err != nil {
		return math.ZeroInt(), err
	}

	// Transfer SHAHUSD from treasury to seller
	shahUSDCoin := sdk.NewCoin("shahusd", shahUSDOut)
	if err := k.bankKeeper.SendCoins(ctx, moduleAddr, seller, sdk.NewCoins(shahUSDCoin)); err != nil {
		return math.ZeroInt(), err
	}

	// Update reserves
	reserveSHAH, _ := k.ReserveSHAH.Get(ctx)
	reserveSHAH = reserveSHAH.Add(shahIn)
	k.ReserveSHAH.Set(ctx, reserveSHAH)

	reserveSHAHUSD, _ := k.ReserveSHAHUSD.Get(ctx)
	reserveSHAHUSD = reserveSHAHUSD.Sub(shahUSDOut)
	k.ReserveSHAHUSD.Set(ctx, reserveSHAHUSD)

	return shahUSDOut, nil
}

func (k Keeper) GetReserves(ctx context.Context) (math.Int, math.Int, error) {
	reserveSHAH, err := k.ReserveSHAH.Get(ctx)
	if err != nil {
		reserveSHAH = math.ZeroInt()
	}
	reserveSHAHUSD, err := k.ReserveSHAHUSD.Get(ctx)
	if err != nil {
		reserveSHAHUSD = math.ZeroInt()
	}
	return reserveSHAH, reserveSHAHUSD, nil
}
