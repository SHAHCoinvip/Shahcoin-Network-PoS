package keeper

// This file contains updated keeper methods that work with proto-generated types
// Replaces the problematic methods in keeper.go

import (
	"context"

	"cosmossdk.io/math"
)

// UpdatePool updates pool reserves (call this instead of directly modifying pool)
func (k Keeper) UpdatePoolReserves(ctx context.Context, poolID uint64, reserveA, reserveB, totalShares, volume math.Int) error {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return err
	}

	pool.ReserveA = reserveA.String()
	pool.ReserveB = reserveB.String()
	pool.TotalLpShares = totalShares.String()
	pool.TotalVolume = volume.String()

	return k.Pools.Set(ctx, poolID, pool)
}

// GetPoolReserves gets pool reserves as math types
func (k Keeper) GetPoolReserves(ctx context.Context, poolID uint64) (reserveA, reserveB, totalShares, volume math.Int, err error) {
	pool, err := k.Pools.Get(ctx, poolID)
	if err != nil {
		return
	}

	reserveA, _ = math.NewIntFromString(pool.ReserveA)
	reserveB, _ = math.NewIntFromString(pool.ReserveB)
	totalShares, _ = math.NewIntFromString(pool.TotalLpShares)
	volume, _ = math.NewIntFromString(pool.TotalVolume)
	return
}
