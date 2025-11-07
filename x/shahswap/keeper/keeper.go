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

	"github.com/shahcoin/shahcoin/x/shahswap/types"
)

type Keeper struct {
	cdc          codec.BinaryCodec
	storeService store.KVStoreService
	logger       log.Logger

	// authority is the address capable of executing governance proposals
	authority string

	// Collections
	Schema      collections.Schema
	Params      collections.Item[types.Params]
	Pools       collections.Map[uint64, types.Pool]
	PoolCounter collections.Sequence
	LPPositions collections.Map[collections.Pair[uint64, string], types.LPPosition]

	bankKeeper types.BankKeeper
}

// NewKeeper creates a new shahswap Keeper instance
func NewKeeper(
	cdc codec.BinaryCodec,
	storeService store.KVStoreService,
	logger log.Logger,
	authority string,
	bankKeeper types.BankKeeper,
) Keeper {
	sb := collections.NewSchemaBuilder(storeService)

	k := Keeper{
		cdc:          cdc,
		storeService: storeService,
		authority:    authority,
		logger:       logger,
		Params:       collections.NewItem(sb, types.ParamsKey, "params", codec.CollValue[types.Params](cdc)),
		Pools:        collections.NewMap(sb, types.PoolsKey, "pools", collections.Uint64Key, codec.CollValue[types.Pool](cdc)),
		PoolCounter:  collections.NewSequence(sb, types.PoolCounterKey, "pool_counter"),
		LPPositions:  collections.NewMap(sb, types.LPPositionsKey, "lp_positions", collections.PairKeyCodec(collections.Uint64Key, collections.StringKey), codec.CollValue[types.LPPosition](cdc)),
		bankKeeper:   bankKeeper,
	}

	schema, err := sb.Build()
	if err != nil {
		panic(err)
	}
	k.Schema = schema

	return k
}

// GetAuthority returns the module's authority.
func (k Keeper) GetAuthority() string {
	return k.authority
}

// Logger returns a module-specific logger.
func (k Keeper) Logger() log.Logger {
	return k.logger.With("module", fmt.Sprintf("x/%s", types.ModuleName))
}

// CreatePool creates a new liquidity pool
func (k Keeper) CreatePool(ctx context.Context, creator sdk.AccAddress, coinA, coinB sdk.Coin) (uint64, math.Int, error) {
	// Get next pool ID
	poolID, err := k.PoolCounter.Next(ctx)
	if err != nil {
		return 0, math.ZeroInt(), err
	}

	// Initial LP shares = sqrt(amountA * amountB)
	reserveA := coinA.Amount
	reserveB := coinB.Amount

	// Calculate initial LP shares using sqrt(x * y)
	product := reserveA.Mul(reserveB)
	lpSharesDec, err := product.ToLegacyDec().ApproxSqrt()
	if err != nil {
		return 0, math.ZeroInt(), err
	}
	lpShares := lpSharesDec.TruncateInt()

	if lpShares.IsZero() {
		return 0, math.ZeroInt(), fmt.Errorf("initial liquidity too small")
	}

	// Create pool
	pool := types.Pool{
		Id:            poolID,
		DenomA:        coinA.Denom,
		DenomB:        coinB.Denom,
		ReserveA:      reserveA.String(),
		ReserveB:      reserveB.String(),
		TotalLpShares: lpShares.String(),
		TotalVolume:   math.ZeroInt().String(),
	}

	// Save pool
	if err := k.Pools.Set(ctx, poolID, pool); err != nil {
		return 0, math.ZeroInt(), err
	}

	// Save LP position
	position := types.LPPosition{
		PoolId:   poolID,
		Address:  creator.String(),
		LpShares: lpShares.String(),
	}
	if err := k.LPPositions.Set(ctx, collections.Join(poolID, creator.String()), position); err != nil {
		return 0, math.ZeroInt(), err
	}

	// Transfer tokens from creator to module
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	if err := k.bankKeeper.SendCoins(ctx, creator, moduleAddr, sdk.NewCoins(coinA, coinB)); err != nil {
		return 0, math.ZeroInt(), err
	}

	return poolID, lpShares, nil
}

// AddLiquidity adds liquidity to an existing pool
func (k Keeper) AddLiquidity(ctx context.Context, sender sdk.AccAddress, poolID uint64, coinA, coinB sdk.Coin) (math.Int, error) {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return math.ZeroInt(), fmt.Errorf("pool not found: %d", poolID)
	}

	reserveA, _ := math.NewIntFromString(pool.ReserveA)
	reserveB, _ := math.NewIntFromString(pool.ReserveB)
	totalShares, _ := math.NewIntFromString(pool.TotalLpShares)

	// Calculate LP shares to mint
	// shares = min(amountA * totalShares / reserveA, amountB * totalShares / reserveB)
	sharesA := coinA.Amount.Mul(totalShares).Quo(reserveA)
	sharesB := coinB.Amount.Mul(totalShares).Quo(reserveB)

	lpShares := sharesA
	if sharesB.LT(sharesA) {
		lpShares = sharesB
	}

	if lpShares.IsZero() {
		return math.ZeroInt(), fmt.Errorf("insufficient liquidity added")
	}

	// Update pool
	newReserveA := reserveA.Add(coinA.Amount)
	newReserveB := reserveB.Add(coinB.Amount)
	newTotalShares := totalShares.Add(lpShares)

	pool.ReserveA = newReserveA.String()
	pool.ReserveB = newReserveB.String()
	pool.TotalLpShares = newTotalShares.String()

	if err := k.Pools.Set(ctx, poolID, pool); err != nil {
		return math.ZeroInt(), err
	}

	// Update or create LP position
	key := collections.Join(poolID, sender.String())
	position, err := k.LPPositions.Get(ctx, key)
	existingShares := math.ZeroInt()
	if err == nil {
		existingShares, _ = math.NewIntFromString(position.LpShares)
	} else {
		position = types.LPPosition{
			PoolId:  poolID,
			Address: sender.String(),
		}
	}
	newShares := existingShares.Add(lpShares)
	position.LpShares = newShares.String()
	if err := k.LPPositions.Set(ctx, key, position); err != nil {
		return math.ZeroInt(), err
	}

	// Transfer tokens from sender to module
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	if err := k.bankKeeper.SendCoins(ctx, sender, moduleAddr, sdk.NewCoins(coinA, coinB)); err != nil {
		return math.ZeroInt(), err
	}

	return lpShares, nil
}

// RemoveLiquidity removes liquidity from a pool
func (k Keeper) RemoveLiquidity(ctx context.Context, sender sdk.AccAddress, poolID uint64, lpShares math.Int) (sdk.Coin, sdk.Coin, error) {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return sdk.Coin{}, sdk.Coin{}, fmt.Errorf("pool not found: %d", poolID)
	}

	reserveA, _ := math.NewIntFromString(pool.ReserveA)
	reserveB, _ := math.NewIntFromString(pool.ReserveB)
	totalLpShares, _ := math.NewIntFromString(pool.TotalLpShares)

	// Check LP position
	key := collections.Join(poolID, sender.String())
	position, err := k.LPPositions.Get(ctx, key)
	if err != nil {
		return sdk.Coin{}, sdk.Coin{}, fmt.Errorf("no LP position found")
	}

	posShares, _ := math.NewIntFromString(position.LpShares)
	if posShares.LT(lpShares) {
		return sdk.Coin{}, sdk.Coin{}, fmt.Errorf("insufficient LP shares")
	}

	// Calculate amounts to return
	// amountA = lpShares * reserveA / totalShares
	// amountB = lpShares * reserveB / totalShares
	amountA := lpShares.Mul(reserveA).Quo(totalLpShares)
	amountB := lpShares.Mul(reserveB).Quo(totalLpShares)

	coinA := sdk.NewCoin(pool.DenomA, amountA)
	coinB := sdk.NewCoin(pool.DenomB, amountB)

	// Update pool
	pool.ReserveA = reserveA.Sub(amountA).String()
	pool.ReserveB = reserveB.Sub(amountB).String()
	pool.TotalLpShares = totalLpShares.Sub(lpShares).String()

	if err := k.Pools.Set(ctx, poolID, pool); err != nil {
		return sdk.Coin{}, sdk.Coin{}, err
	}

	// Update LP position
	newPosShares := posShares.Sub(lpShares)
	position.LpShares = newPosShares.String()
	if newPosShares.IsZero() {
		if err := k.LPPositions.Remove(ctx, key); err != nil {
			return sdk.Coin{}, sdk.Coin{}, err
		}
	} else {
		if err := k.LPPositions.Set(ctx, key, position); err != nil {
			return sdk.Coin{}, sdk.Coin{}, err
		}
	}

	// Transfer tokens from module to sender
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	if err := k.bankKeeper.SendCoins(ctx, moduleAddr, sender, sdk.NewCoins(coinA, coinB)); err != nil {
		return sdk.Coin{}, sdk.Coin{}, err
	}

	return coinA, coinB, nil
}

// SwapExactIn performs a constant product swap
func (k Keeper) SwapExactIn(ctx context.Context, sender sdk.AccAddress, poolID uint64, coinIn sdk.Coin, denomOut string) (sdk.Coin, error) {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return sdk.Coin{}, fmt.Errorf("pool not found: %d", poolID)
	}

	params, err := k.Params.Get(ctx)
	if err != nil {
		return sdk.Coin{}, err
	}

	reserveA, _ := math.NewIntFromString(pool.ReserveA)
	reserveB, _ := math.NewIntFromString(pool.ReserveB)

	// Determine reserves
	var reserveIn, reserveOut math.Int
	if coinIn.Denom == pool.DenomA && denomOut == pool.DenomB {
		reserveIn = reserveA
		reserveOut = reserveB
	} else if coinIn.Denom == pool.DenomB && denomOut == pool.DenomA {
		reserveIn = reserveB
		reserveOut = reserveA
	} else {
		return sdk.Coin{}, fmt.Errorf("invalid swap pair")
	}

	// Calculate fee
	tradeFee, _ := math.LegacyNewDecFromStr(params.TradeFee)
	feeAmount := tradeFee.MulInt(coinIn.Amount).TruncateInt()
	amountInAfterFee := coinIn.Amount.Sub(feeAmount)

	// Constant product: k = x * y
	// amountOut = reserveOut - (reserveIn * reserveOut) / (reserveIn + amountInAfterFee)
	constantProduct := reserveIn.Mul(reserveOut)
	newReserveIn := reserveIn.Add(amountInAfterFee)
	newReserveOut := constantProduct.Quo(newReserveIn)
	amountOut := reserveOut.Sub(newReserveOut)

	if amountOut.IsZero() || amountOut.IsNegative() {
		return sdk.Coin{}, fmt.Errorf("insufficient output amount")
	}

	coinOut := sdk.NewCoin(denomOut, amountOut)

	// Update reserves
	totalVol, _ := math.NewIntFromString(pool.TotalVolume)
	if coinIn.Denom == pool.DenomA {
		pool.ReserveA = reserveA.Add(coinIn.Amount).String()
		pool.ReserveB = reserveB.Sub(amountOut).String()
	} else {
		pool.ReserveB = reserveB.Add(coinIn.Amount).String()
		pool.ReserveA = reserveA.Sub(amountOut).String()
	}
	pool.TotalVolume = totalVol.Add(coinIn.Amount).String()

	if err := k.Pools.Set(ctx, poolID, pool); err != nil {
		return sdk.Coin{}, err
	}

	// Transfer tokens
	moduleAddr := sdk.AccAddress([]byte(types.ModuleName))
	if err := k.bankKeeper.SendCoins(ctx, sender, moduleAddr, sdk.NewCoins(coinIn)); err != nil {
		return sdk.Coin{}, err
	}
	if err := k.bankKeeper.SendCoins(ctx, moduleAddr, sender, sdk.NewCoins(coinOut)); err != nil {
		return sdk.Coin{}, err
	}

	// Send protocol fee to treasury (if any)
	if feeAmount.IsPositive() {
		protocolCut, _ := math.LegacyNewDecFromStr(params.ProtocolCut)
		protocolFee := protocolCut.MulInt(feeAmount).TruncateInt()
		if protocolFee.IsPositive() {
			treasuryAddr := sdk.AccAddress([]byte("treasury")) // Treasury module account
			feeCoin := sdk.NewCoin(coinIn.Denom, protocolFee)
			if err := k.bankKeeper.SendCoins(ctx, moduleAddr, treasuryAddr, sdk.NewCoins(feeCoin)); err != nil {
				// Log but don't fail the swap
				k.Logger().Error("failed to send protocol fee to treasury", "error", err)
			}
		}
	}

	return coinOut, nil
}

// GetPool returns a pool by ID
func (k Keeper) GetPool(ctx context.Context, poolID uint64) (types.Pool, error) {
	return k.Pools.Get(ctx, poolID)
}

// GetAllPools returns all pools
func (k Keeper) GetAllPools(ctx context.Context) ([]types.Pool, error) {
	var pools []types.Pool
	err := k.Pools.Walk(ctx, nil, func(key uint64, value types.Pool) (stop bool, err error) {
		pools = append(pools, value)
		return false, nil
	})
	return pools, err
}

// GetLPPosition returns an LP position
func (k Keeper) GetLPPosition(ctx context.Context, poolID uint64, address string) (types.LPPosition, error) {
	return k.LPPositions.Get(ctx, collections.Join(poolID, address))
}

// CalculateSpotPrice calculates the spot price for a swap
func (k Keeper) CalculateSpotPrice(ctx context.Context, poolID uint64, denomIn, denomOut string) (math.LegacyDec, error) {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return math.LegacyDec{}, fmt.Errorf("pool not found: %d", poolID)
	}

	reserveA, _ := math.NewIntFromString(pool.ReserveA)
	reserveB, _ := math.NewIntFromString(pool.ReserveB)

	var reserveIn, reserveOut math.Int
	if denomIn == pool.DenomA && denomOut == pool.DenomB {
		reserveIn = reserveA
		reserveOut = reserveB
	} else if denomIn == pool.DenomB && denomOut == pool.DenomA {
		reserveIn = reserveB
		reserveOut = reserveA
	} else {
		return math.LegacyDec{}, fmt.Errorf("invalid denomination pair")
	}

	// Spot price = reserveOut / reserveIn
	if reserveIn.IsZero() {
		return math.LegacyDec{}, fmt.Errorf("reserve is zero")
	}

	spotPrice := math.LegacyNewDecFromInt(reserveOut).Quo(math.LegacyNewDecFromInt(reserveIn))
	return spotPrice, nil
}
