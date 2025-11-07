# SHAHCOIN - Production-Grade Cosmos SDK Blockchain

**Chain ID:** shahcoin-1  
**Bech32 Prefix:** shah  
**Base Denom:** shahi (8 decimals)  
**Consensus:** Tendermint BFT (Proof-of-Stake)  
**SDK Version:** v0.50.10 (compatible with v0.53.3 patterns)  
**CometBFT:** v0.38.12  
**IBC:** v8.5.1

## Overview

Shahcoin is a feature-rich Cosmos SDK blockchain designed for decentralized finance (DeFi) with built-in AMM DEX, treasury management, and USD-pegged fee estimation.

### Token Economics

- **Total Supply:** 63,000,000 SHAH (6,300,000,000,000,000 shahi)
- **Founder Grant:** 10,000,000 SHAH
- **Decimals:** 8 (1 SHAH = 100,000,000 shahi)
- **Inflation:** ~2-5% APY (configurable via governance)

## Core Features

### Standard Cosmos SDK Modules
- **auth, bank, staking, distribution, mint, gov, params, slashing** - Full suite of standard modules
- **IBC + Transfer** - Inter-blockchain communication enabled
- **Snapshots** - Enabled by default (interval: 1000 blocks, keep: 2)

### Custom Native Modules

#### 1. **x/shahswap** - AMM DEX
Constant-product (x*y=k) automated market maker with:
- Single canonical pool: SHAH ↔ SHAHUSD
- 0.3% trading fee (configurable)
- 16% protocol cut to treasury
- LP tokens for liquidity providers

**Endpoints:**
- `GET /shahcoin/shahswap/v1/pools` - List all pools
- `GET /shahcoin/shahswap/v1/pools/{pool_id}` - Get pool details
- `GET /shahcoin/shahswap/v1/spot_price/{pool_id}` - Get spot price

#### 2. **x/treasury** - Reserve Management
Treasury module for managing SHAH and SHAHUSD reserves:
- Mint/burn SHAHUSD (governance controlled)
- Buy/sell SHAH at policy rate
- Manual or market-based pricing modes
- Fee collection (0.5% default)

**Endpoints:**
- `GET /shahcoin/treasury/v1/reserves` - Get treasury reserves
- `GET /shahcoin/treasury/v1/policy_rate` - Get current policy rate

#### 3. **x/fees** - USD-Pegged Fee Estimator
Real-time fee estimation in USD:
- Configurable USD/SHAH rate
- Gas estimation
- Multi-currency fee display

**Endpoints:**
- `GET /shahcoin/fees/v1/estimate?gas=200000` - Estimate transaction fee

#### 4. **x/airdrop** - Merkle-Based Airdrops
One-time claim system with:
- Merkle tree proof verification
- Configurable claim windows
- Bitmap tracking for claimed addresses

**Endpoints:**
- `GET /shahcoin/airdrop/v1/claim_status/{address}` - Check claim status

#### 5. **x/monitoring** - Chain Metrics
Basic chain statistics for dashboards:
- Total transactions
- Active validators
- Swap volume
- Block timestamps

**Endpoints:**
- `GET /shahcoin/monitoring/v1/metrics` - Get chain metrics

#### 6. **x/shahbridge** - IBC Channel Metadata
Thin wrapper around IBC transfer:
- Channel metadata storage
- Bridge status tracking
- Future cross-chain integration

**Endpoints:**
- `GET /shahcoin/shahbridge/v1/channels` - List IBC channels

## Quick Start (Development)

### Prerequisites
```bash
# Ubuntu/WSL
sudo apt update && sudo apt install -y build-essential git jq

# Go 1.23+
go version

# Buf (for proto generation)
# See: https://buf.build/docs/installation
```

### Build from Source
```bash
git clone https://github.com/shahcoin/shahcoin.git
cd shahcoin

# Install dependencies
go mod tidy

# Generate proto files (requires buf)
make proto

# Build binary
make build

# Binary will be at: ./build/shahd
```

### Initialize Single-Node Devnet
```bash
# Run initialization script
./scripts/init_genesis.sh

# Start the chain
./build/shahd start

# Or use systemd (production)
sudo cp deploy/systemd/shahd.service /etc/systemd/system/
sudo systemctl enable shahd
sudo systemctl start shahd
```

### Check Health
```bash
./scripts/health.sh

# Or manually:
curl localhost:26657/status
curl localhost:1317/shahcoin/shahswap/v1/pools
curl localhost:1317/cosmos/bank/v1beta1/supply
```

## Network Ports

| Service | Port | Public | Description |
|---------|------|--------|-------------|
| P2P | 26656 | ✅ Yes | Required for validators |
| RPC | 26657 | ⚠️ Dev only | CometBFT RPC |
| REST API | 1317 | ⚠️ Restrict | Cosmos REST API |
| gRPC | 9090 | ⚠️ Restrict | gRPC endpoint |
| Prometheus | 26660 | ❌ No | Metrics (optional) |

**Production:** Restrict RPC/REST/gRPC to specific IPs or use nginx reverse proxy

## Configuration

### Minimum Gas Prices
Edit `~/.shah/config/app.toml`:
```toml
minimum-gas-prices = "1000shahi"
```

### Enable API & CORS
```toml
[api]
enable = true
enabled-unsafe-cors = true  # Dev only!
address = "tcp://0.0.0.0:1317"
```

### Snapshots
```toml
[state-sync]
snapshot-interval = 1000
snapshot-keep-recent = 2
```

## Validator Setup

### Create Validator
```bash
shahd tx staking create-validator \
  --amount=1000000000000000shahi \
  --pubkey=$(shahd comet show-validator) \
  --moniker="my-validator" \
  --chain-id=shahcoin-1 \
  --commission-rate=0.10 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1 \
  --from=my_key \
  --fees=5000shahi
```

### Backup Validator Key
```bash
# CRITICAL: Backup these files securely!
~/.shah/config/priv_validator_key.json
~/.shah/config/node_key.json
~/.shah/data/priv_validator_state.json
```

## Example Transactions

### Send Tokens
```bash
shahd tx bank send founder shah1abc...xyz 1000000000shahi \
  --chain-id shahcoin-1 \
  --keyring-backend test \
  --fees 5000shahi
```

### Delegate to Validator
```bash
shahd tx staking delegate shahvaloper1abc...xyz 1000000000shahi \
  --from my_key \
  --chain-id shahcoin-1 \
  --fees 5000shahi
```

### Submit Governance Proposal
```bash
shahd tx gov submit-proposal \
  --title "Update Inflation Rate" \
  --description "Reduce inflation to 3%" \
  --type Text \
  --deposit 10000000000shahi \
  --from founder \
  --chain-id shahcoin-1
```

## Querying

### Account Balance
```bash
shahd q bank balances shah1abc...xyz
```

### Staking Info
```bash
shahd q staking validators
shahd q staking delegation shah1abc...xyz shahvaloper1abc...xyz
```

### Custom Module Queries
```bash
# Shahswap pools
shahd q shahswap pools

# Treasury reserves
shahd q treasury reserves

# Fee estimation
curl "localhost:1317/shahcoin/fees/v1/estimate?gas=200000"
```

## Governance

### Parameter Changes
All modules support governance-based parameter updates:
```bash
# Example: Update mint inflation
shahd tx gov submit-proposal param-change proposal.json \
  --from founder \
  --chain-id shahcoin-1
```

### Voting
```bash
shahd tx gov vote 1 yes --from my_key --chain-id shahcoin-1
```

## Security Best Practices

1. **Never expose private keys** - Use hardware wallets for production
2. **Restrict RPC/API access** - Use firewall rules or VPN
3. **Regular backups** - Automate validator key backups
4. **Monitor uptime** - Use tools like Grafana/Prometheus
5. **Keep software updated** - Follow upgrade proposals
6. **Use strong passphrases** - For keyring encryption

## Troubleshooting

### Node won't start
```bash
# Check logs
journalctl -u shahd -f

# Verify genesis
shahd validate-genesis

# Reset data (CAUTION: loses state)
shahd comet unsafe-reset-all
```

### Sync issues
```bash
# Check sync status
curl localhost:26657/status | jq .result.sync_info

# Add peers
# Edit ~/.shah/config/config.toml
persistent_peers = "node1_id@host1:26656,node2_id@host2:26656"
```

### Transaction failures
```bash
# Check account sequence
shahd q auth account shah1abc...xyz

# Increase gas limit
--gas 300000

# Adjust fees
--fees 10000shahi
```

## Development

### Running Tests
```bash
make test
make test-race
```

### Code Formatting
```bash
make format
make lint
```

### Generate Proto Files
```bash
make proto
```

## Resources

- **Website:** https://shah.vip
- **Documentation:** https://docs.shah.vip
- **Explorer:** https://explorer.shah.vip
- **RPC:** https://rpc.shah.vip
- **API:** https://api.shah.vip

## Support

- **Discord:** https://discord.gg/shahcoin
- **Telegram:** https://t.me/shahcoin
- **Twitter:** https://twitter.com/shahcoin
- **GitHub:** https://github.com/shahcoin/shahcoin

## License

Apache 2.0

---

**Built with ❤️ using Cosmos SDK**

