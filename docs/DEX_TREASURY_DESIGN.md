# DEX & Treasury Design - Shahcoin

## Overview

Shahcoin implements a tightly integrated DeFi system with three core components:
1. **Shahswap** - Constant-product AMM DEX
2. **Treasury** - Reserve management and stablecoin operations
3. **Fees** - USD-pegged fee estimation

This document explains the design rationale and operational mechanics.

## Token Design

### SHAH (Native Token)
- **Symbol:** SHAH
- **Base Unit:** shahi
- **Decimals:** 8
- **Conversion:** 1 SHAH = 100,000,000 shahi
- **Total Supply:** 63,000,000 SHAH (6.3 quadrillion shahi)
- **Use Cases:**
  - Gas fees
  - Staking
  - Governance
  - DEX liquidity
  - Collateral

### SHAHUSD (Internal Stable Unit)
- **Symbol:** SHAHUSD
- **Peg:** 1 SHAHUSD ≈ $1 USD (policy-based)
- **Supply:** Dynamic (minted/burned by treasury)
- **Use Cases:**
  - Trading pair (SHAH/SHAHUSD)
  - Stable value storage
  - Fee estimation
  - Treasury operations

**Note:** SHAHUSD is NOT a fully-collateralized stablecoin. It's a treasury-managed unit for internal ecosystem use.

## Shahswap DEX

### Architecture

**Type:** Constant Product Market Maker (CPMM)  
**Formula:** `k = x * y` (Uniswap V2 model)

#### Pool Structure
```
Pool {
  id: uint64
  denom_a: "shahi"
  denom_b: "shahusd"
  reserve_a: Int (SHAH reserve)
  reserve_b: Int (SHAHUSD reserve)
  total_lp_shares: Int (LP token supply)
  total_volume: Int (cumulative volume)
}
```

### Core Operations

#### 1. Create Pool
```
CreatePool(creator, coin_a, coin_b) -> (pool_id, lp_shares)
```
- Initial LP shares = sqrt(amount_a * amount_b)
- Minimum liquidity lock (optional)
- Pool ID auto-incremented

#### 2. Add Liquidity
```
AddLiquidity(pool_id, coin_a, coin_b) -> lp_shares
```
- LP shares minted = min(
    coin_a * total_shares / reserve_a,
    coin_b * total_shares / reserve_b
  )
- Protects against price manipulation
- Slippage protection via min_lp_shares

#### 3. Remove Liquidity
```
RemoveLiquidity(pool_id, lp_shares) -> (coin_a, coin_b)
```
- Amount out = (lp_shares * reserve) / total_shares
- Pro-rata distribution
- Slippage protection via min_coin_a/b

#### 4. Swap
```
SwapExactIn(pool_id, coin_in, min_amount_out) -> coin_out
```

**Swap Calculation:**
```
fee = coin_in * trade_fee (0.3%)
amount_in_after_fee = coin_in - fee
k = reserve_in * reserve_out
amount_out = reserve_out - (k / (reserve_in + amount_in_after_fee))
```

**Protocol Fee:**
```
protocol_fee = fee * protocol_cut (16% of trading fee)
-> Sent to treasury
```

### Fee Structure

| Fee Type | Rate | Distribution |
|----------|------|--------------|
| Trading Fee | 0.30% | 84% to LPs, 16% to Treasury |
| Protocol Fee | 0.048% | 100% to Treasury |

**Example:** $1000 swap
- Trading fee: $3.00
- To LPs: $2.52
- To Treasury: $0.48

### LP Token Economics

LP tokens represent proportional ownership of pool reserves:

```
LP Value = (reserve_a + reserve_b * price) * (lp_shares / total_shares)
```

**Impermanent Loss:**
- Occurs when price ratio changes
- IL = 2 * sqrt(price_ratio) / (1 + price_ratio) - 1
- Mitigated by trading fees

## Treasury Module

### Purpose
The treasury manages reserves to:
1. Stabilize SHAHUSD peg
2. Provide liquidity
3. Fund ecosystem development
4. Enable buy/sell operations

### Operations

#### 1. Mint SHAHUSD (Governance Only)
```
MintShahUSD(authority, recipient, amount)
```
- Requires governance approval
- Increases SHAHUSD supply
- Used for:
  - Initial pool seeding
  - Emergency liquidity
  - Ecosystem grants

#### 2. Burn SHAHUSD
```
BurnShahUSD(sender, amount)
```
- Anyone can burn their SHAHUSD
- Decreases supply
- Deflationary mechanism

#### 3. Buy SHAH (from Treasury)
```
BuyShah(buyer, shahusd_in) -> shah_out
```

**Calculation:**
```
shah_out = shahusd_in / target_rate
shah_out_after_fee = shah_out * (1 - fee_bps/10000)
```

**Example:** Target rate = 5.0 SHAHUSD/SHAH, Fee = 0.5%
- User sends: 1000 SHAHUSD
- Before fee: 200 SHAH
- After fee: 199 SHAH

#### 4. Sell SHAH (to Treasury)
```
SellShah(seller, shah_in) -> shahusd_out
```

**Calculation:**
```
shahusd_out = shah_in * target_rate
shahusd_out_after_fee = shahusd_out * (1 - fee_bps/10000)
```

### Pricing Modes

#### Manual Mode (Default)
- `target_rate` set by governance
- Fixed price for treasury operations
- Updated via parameter change proposals

#### Market Mode (Future)
- Derived from DEX spot price
- Dynamic adjustment
- Circuit breakers for extreme volatility

### Reserve Management

**Treasury Holds:**
```
Reserve {
  shah: Int      // SHAH holdings
  shahusd: Int   // SHAHUSD holdings
}
```

**Health Metrics:**
```
Reserve Ratio = shah_reserve * market_price / shahusd_reserve
Target: >150% (over-collateralized)
Warning: <120%
Critical: <100%
```

## Fee Estimation Module

### Purpose
Provide users with USD-denominated fee estimates before transactions.

### Calculation
```
EstimateFee(gas) -> (fee_shahi, fee_usd)

fee_shahi = gas * gas_price (e.g., gas * 1000)
fee_usd = fee_shahi / 10^8 / usd_rate
```

**Example:** 200K gas, rate = 5.0 SHAHUSD/SHAH
```
fee_shahi = 200,000 * 1,000 = 200,000,000 shahi (2 SHAH)
fee_usd = 2 / 5.0 = $0.40
```

### Rate Updates
- Updated via governance
- Could integrate oracle (future)
- Display rate in UI for transparency

## Economic Model

### Value Flow

```
User Transactions
    ↓ (fees)
Fee Collector
    ↓ (distribution)
Validators (40%) | Treasury (10%) | Community Pool (50%)
    ↓
Stakers (via distribution)
```

### DEX Value Flow

```
Swaps
    ↓ (0.3% fee)
84% → LPs (yield)
16% → Treasury (protocol revenue)
    ↓
Ecosystem Development | Liquidity Incentives | Burns
```

### Inflation Model

**Mint Module:**
- Target APR: 2-5% (governance adjustable)
- Bonded ratio target: 67%
- Dynamic adjustment based on bonding rate

**Distribution:**
```
Block Rewards
    ↓
40% Validators
50% Community Pool
10% Treasury
```

## Risk Considerations

### Smart Contract Risks
- Constant product formula is battle-tested
- LP calculations carefully implemented
- Slippage protection on all operations

### Economic Risks
1. **Impermanent Loss**
   - Inherent to AMM design
   - Mitigated by trading fees
   - LPs should understand mechanics

2. **SHAHUSD Depeg**
   - Not fully collateralized
   - Relies on treasury management
   - Governance can adjust parameters

3. **Liquidity Crises**
   - Treasury can provide emergency liquidity
   - Circuit breakers in extreme scenarios
   - Community governance oversight

### Operational Risks
1. **Parameter Misconfigurations**
   - Governance proposals peer-reviewed
   - Simulation before deployment
   - Emergency halt mechanism

2. **Oracle Failures** (if used)
   - Fallback to manual mode
   - Multiple data sources
   - Staleness checks

## Governance Parameters

### Shahswap
- `trade_fee`: Trading fee percentage (default: 0.003)
- `protocol_cut`: Protocol fee share (default: 0.16)

### Treasury
- `pricing_mode`: "manual" or "market"
- `target_rate`: SHAH/USD rate (default: 5.0)
- `fee_bps`: Transaction fee in basis points (default: 50)

### Fees
- `usd_rate`: SHAH/USD rate for estimation (default: 5.0)

### Change Process
1. Submit parameter change proposal
2. Voting period (7 days default)
3. Execution if passed
4. Monitor effects

## Future Enhancements

### Phase 2 (Q2 2025)
- [ ] Multiple trading pairs
- [ ] Concentrated liquidity (Uniswap V3 style)
- [ ] Limit orders
- [ ] Price oracle integration

### Phase 3 (Q3 2025)
- [ ] Cross-chain swaps via IBC
- [ ] Lending protocol
- [ ] Synthetic assets
- [ ] Governance token incentives

### Phase 4 (Q4 2025)
- [ ] Perps/derivatives
- [ ] Insurance fund
- [ ] DAO treasury management
- [ ] Advanced analytics dashboard

## References

- [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper.pdf)
- [Constant Product Market Makers](https://research.paradigm.xyz/amm)
- [Impermanent Loss Calculator](https://dailydefi.org/tools/impermanent-loss-calculator/)

---

**This design is subject to change via governance proposals.**

