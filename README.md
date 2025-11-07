# 🪙 SHAHCOIN - Next-Generation Blockchain

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
![Go Version](https://img.shields.io/badge/go-1.23%2B-blue.svg)
![Cosmos SDK](https://img.shields.io/badge/Cosmos%20SDK-v0.50.10-blue.svg)
![Status](https://img.shields.io/badge/status-mainnet-green.svg)

**SHAHCOIN** is a high-performance, Proof-of-Stake blockchain built with Cosmos SDK, featuring native DeFi modules, IBC connectivity, and innovative tokenomics.

## 🌟 Key Features

- **⚡ High Performance**: Tendermint BFT consensus with sub-second finality
- **🔗 IBC Enabled**: Cross-chain interoperability with 100+ Cosmos chains
- **💱 Native DEX**: Built-in AMM (shahswap) for decentralized trading
- **🏦 Treasury Module**: Algorithmic reserve management for SHAH/SHAHUSD stability
- **💵 USD-Pegged Fees**: Predictable transaction costs
- **🎁 Merkle Airdrops**: Gas-efficient token distribution
- **📊 On-Chain Monitoring**: Real-time metrics and analytics
- **🌉 IBC Bridge Helper**: Simplified cross-chain transfers

## 🏗️ Architecture

### Blockchain Specs
- **Chain ID**: `shahcoin-1`
- **Consensus**: Tendermint BFT (Proof of Stake)
- **Block Time**: ~6 seconds
- **Bech32 Prefix**: `shah`
- **Base Denom**: `shahi` (10^8 shahi = 1 SHAH)

### Token Economics
- **Total Supply**: 63,000,000 SHAH
- **Decimals**: 8
- **Inflation**: 7-20% annually (target 67% bonded)
- **Staking Rewards**: Distributed to delegators
- **Community Tax**: 2%
- **Validator Commission**: Up to 20%

### Custom Modules

| Module | Purpose | Features |
|--------|---------|----------|
| **x/shahswap** | AMM DEX | Constant product pools, 0.3% fee, 16% protocol cut |
| **x/treasury** | Reserve Management | SHAH/SHAHUSD stability, manual/market pricing |
| **x/fees** | Fee Estimation | USD-pegged gas fees, dynamic adjustment |
| **x/airdrop** | Token Distribution | Merkle proofs, time-locked claims |
| **x/monitoring** | Chain Metrics | TX counters, validator stats, volumes |
| **x/shahbridge** | IBC Helper | Channel registry, transfer utilities |

## 🚀 Quick Start

### Prerequisites
- Go 1.23 or higher
- Linux/WSL/macOS
- 8GB RAM minimum
- 100GB SSD storage

### Build from Source

```bash
# Clone repository
git clone https://github.com/shahcoin/shahcoin.git
cd shahcoin

# Install dependencies
go mod download

# Build binary
make install
# or
go build -o build/shahd ./cmd/shahd

# Verify installation
shahd version
```

### Initialize Node

```bash
# Initialize node
shahd init <your-moniker> --chain-id shahcoin-1

# Download genesis (mainnet)
curl -s https://raw.githubusercontent.com/shahcoin/shahcoin/main/genesis.json > ~/.shahd/config/genesis.json

# Verify genesis hash
sha256sum ~/.shahd/config/genesis.json
# Should match: [GENESIS_HASH_HERE]

# Configure seeds
# Edit ~/.shahd/config/config.toml:
# seeds = "node1@rpc1.shah.vip:26656,node2@rpc2.shah.vip:26656"

# Start node
shahd start
```

## 🔐 Validator Setup

### Create Validator

```bash
# Create validator key
shahd keys add validator --keyring-backend file

# Fund your validator address with SHAH tokens

# Create validator
shahd tx staking create-validator \
  --amount=10000000000000000shahi \
  --pubkey=$(shahd tendermint show-validator) \
  --moniker="My Validator" \
  --website="https://myvalidator.com" \
  --security-contact="security@myvalidator.com" \
  --chain-id=shahcoin-1 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="100000000000000" \
  --from=validator \
  --keyring-backend=file \
  --fees=1000000shahi
```

## 💻 For Developers

### Project Structure

```
shahcoin/
├── app/                  # Application wiring
├── cmd/shahd/           # Binary entrypoint
├── x/                   # Custom modules
│   ├── shahswap/       # AMM DEX
│   ├── treasury/       # Reserve management
│   ├── fees/           # Fee estimation
│   ├── airdrop/        # Token distribution
│   ├── monitoring/     # Chain metrics
│   └── shahbridge/     # IBC helpers
├── proto/              # Protobuf definitions
├── scripts/            # Deployment scripts
├── docs/               # Documentation
├── Makefile           # Build automation
└── go.mod             # Dependencies
```

### Development Setup

```bash
# Install protobuf compiler
make proto-tools

# Generate protobuf files
make proto-gen

# Run tests
make test

# Run linter
make lint

# Format code
make format
```

### Create Your Own Module

```bash
# Use the template
cp -r x/fees x/mymodule

# Update module name in:
# - proto/shahcoin/mymodule/v1/*.proto
# - x/mymodule/module.go
# - x/mymodule/keeper/keeper.go

# Generate protos
make proto-gen

# Wire into app/app.go
```

## 🌐 Network Information

### Mainnet
- **Chain ID**: `shahcoin-1`
- **RPC**: https://rpc.shah.vip:26657
- **API**: https://api.shah.vip:1317
- **gRPC**: grpc.shah.vip:9090
- **Explorer**: https://explorer.shah.vip
- **Website**: https://shah.vip

### Testnet
- **Chain ID**: `shahcoin-testnet-1`
- **RPC**: https://testnet-rpc.shah.vip:26657
- **API**: https://testnet-api.shah.vip:1317

## 📚 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Validator Guide](docs/VALIDATOR_GUIDE.md)
- [Module Documentation](docs/MODULES.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Tokenomics](docs/TOKENOMICS.md)

## 🔧 Configuration

### Minimum Hardware Requirements

| Component | Validator | Full Node | Light Client |
|-----------|-----------|-----------|--------------|
| CPU | 4 cores | 2 cores | 1 core |
| RAM | 16GB | 8GB | 4GB |
| Storage | 500GB SSD | 250GB SSD | 50GB SSD |
| Bandwidth | 100Mbps | 50Mbps | 10Mbps |

### Recommended Configurations

**Validator (Production)**:
- 8 cores CPU
- 32GB RAM
- 1TB NVMe SSD
- 1Gbps network
- Ubuntu 22.04 LTS

## 🛠️ Useful Commands

```bash
# Check node status
shahd status

# Query account balance
shahd query bank balances <address>

# Send tokens
shahd tx bank send <from> <to> 1000000shahi --fees 1000shahi

# Delegate to validator
shahd tx staking delegate <validator-addr> 1000000000shahi --from <key>

# Query validators
shahd query staking validators

# Query shahswap pools
shahd query shahswap list-pools

# Check treasury reserves
shahd query treasury reserves

# Estimate transaction fee
shahd query fees estimate 200000  # gas amount
```

## 🌊 Liquidity & DEX

### ShahSwap (Native AMM)

```bash
# Create liquidity pool
shahd tx shahswap create-pool 1000000000shahi 5000000000shahusd --from founder

# Add liquidity
shahd tx shahswap add-liquidity 1 500000000shahi 2500000000shahusd --min-lp-shares 1 --from trader

# Swap tokens
shahd tx shahswap swap 1 1000000shahi --min-amount-out 4900000shahusd --from trader

# Remove liquidity
shahd tx shahswap remove-liquidity 1 1000000 --min-coin-a 1 --min-coin-b 1 --from lp-provider
```

## 🏦 Treasury Operations

```bash
# Buy SHAH with SHAHUSD
shahd tx treasury buy-shah 1000000000shahusd --min-shah-out 190000000shahi --from buyer

# Sell SHAH for SHAHUSD
shahd tx treasury sell-shah 100000000shahi --min-shahusd-out 480000000shahusd --from seller

# Check policy rate
shahd query treasury policy-rate
```

## 🎁 Airdrop Claims

```bash
# Claim airdrop (requires Merkle proof)
shahd tx airdrop claim <amount> <proof-json> --from claimer

# Check if address has claimed
shahd query airdrop has-claimed <address>
```

## 📊 Monitoring

```bash
# Get chain metrics
shahd query monitoring metrics

# Get chain parameters
shahd query monitoring params
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow [Effective Go](https://golang.org/doc/effective_go.html)
- Write unit tests for new features
- Update documentation
- Run `make lint` before committing

## 🐛 Reporting Issues

Found a bug? [Open an issue](https://github.com/shahcoin/shahcoin/issues/new)

For security vulnerabilities, please email: security@shah.vip

## 📜 License

Copyright © 2025 SHAHCOIN

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## 🔗 Links

- **Website**: https://shah.vip
- **Explorer**: https://explorer.shah.vip
- **Documentation**: https://docs.shah.vip
- **Twitter**: https://twitter.com/shahcoin
- **Telegram**: https://t.me/shahcoin
- **Discord**: https://discord.gg/shahcoin

## 🙏 Acknowledgments

Built with:
- [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) v0.50.10
- [CometBFT](https://github.com/cometbft/cometbft) v0.38.12
- [IBC-Go](https://github.com/cosmos/ibc-go) v8.5.1

---

**Built with ❤️ by the SHAHCOIN Team**

