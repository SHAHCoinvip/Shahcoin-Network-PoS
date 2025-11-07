#!/bin/bash
# SHAHCOIN VPS Deployment Script
# Deploys SHAHCOIN to a remote VPS server

set -e

echo "🚀 SHAHCOIN VPS Deployment"
echo "=========================="
echo ""

# Configuration - EDIT THESE!
VPS_USER="root"  # or 'ubuntu'
VPS_IP="YOUR_VPS_IP_HERE"  # e.g., "203.0.113.1"
VPS_PORT="22"
VALIDATOR_NAME="validator1"  # Which validator is this?
CHAIN_ID="shahcoin-1"

# SSH into VPS and run setup
echo "📝 Deployment Configuration:"
echo "  VPS: $VPS_USER@$VPS_IP:$VPS_PORT"
echo "  Validator: $VALIDATOR_NAME"
echo "  Chain ID: $CHAIN_ID"
echo ""

read -p "Is this correct? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted. Please edit this script with correct values."
    exit 1
fi

echo ""
echo "🔗 Connecting to VPS..."

# Create deployment script to run on VPS
DEPLOY_SCRIPT=$(cat << 'EOFSCRIPT'
#!/bin/bash
set -e

echo "🔧 Setting up SHAHCOIN on VPS..."
echo ""

# Update system
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt install -y build-essential git jq curl wget

# Install Go 1.23
echo "🐹 Installing Go 1.23..."
GO_VERSION="1.23.4"
if ! command -v go &> /dev/null || [[ $(go version | grep -oP '\d+\.\d+') != "1.23" ]]; then
    cd /tmp
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    source ~/.bashrc
    echo "✅ Go installed: $(go version)"
else
    echo "✅ Go already installed: $(go version)"
fi

# Clone SHAHCOIN repository
echo "📥 Cloning SHAHCOIN repository..."
cd ~
if [ -d "shahcoin" ]; then
    echo "⚠️  Repository already exists, pulling latest..."
    cd shahcoin
    git pull
else
    git clone https://github.com/shahcoin/shahcoin.git
    cd shahcoin
fi

# Build binary
echo "🔨 Building SHAHCOIN..."
make install || go build -o $HOME/go/bin/shahd ./cmd/shahd

# Verify binary
echo "✅ Binary built: $(shahd version --long 2>/dev/null | head -1 || echo 'Build complete')"

# Initialize node
echo "🔧 Initializing node..."
MONIKER="VALIDATOR_NAME_PLACEHOLDER"
if [ ! -d ~/.shahd ]; then
    shahd init "$MONIKER" --chain-id shahcoin-1
    echo "✅ Node initialized"
else
    echo "✅ Node already initialized"
fi

# Download genesis
echo "📥 Downloading genesis.json..."
GENESIS_URL="https://raw.githubusercontent.com/shahcoin/shahcoin/main/genesis.json"
wget -O ~/.shahd/config/genesis.json "$GENESIS_URL" || echo "Genesis not yet available on GitHub"

# Configure seeds and persistent peers
echo "🌐 Configuring network peers..."
SEEDS="NODE_ID1@rpc1.shah.vip:26656,NODE_ID2@rpc2.shah.vip:26656"
PEERS="NODE_ID3@rpc3.shah.vip:26656,NODE_ID4@rpc4.shah.vip:26656"

sed -i "s/^seeds =.*/seeds = \"$SEEDS\"/" ~/.shahd/config/config.toml
sed -i "s/^persistent_peers =.*/persistent_peers = \"$PEERS\"/" ~/.shahd/config/config.toml

# Configure minimum gas prices
echo "⛽ Configuring minimum gas prices..."
sed -i 's/^minimum-gas-prices =.*/minimum-gas-prices = "0.001shahi"/' ~/.shahd/config/app.toml

# Enable API and gRPC
echo "🔌 Enabling API and gRPC..."
sed -i '/\[api\]/,/\[/{s/^enable = false/enable = true/}' ~/.shahd/config/app.toml
sed -i 's/^swagger = false/swagger = true/' ~/.shahd/config/app.toml

# Enable Prometheus metrics
sed -i 's/^prometheus = false/prometheus = true/' ~/.shahd/config/config.toml

# Configure pruning (for validators - keep more data)
sed -i 's/^pruning =.*/pruning = "custom"/' ~/.shahd/config/app.toml
sed -i 's/^pruning-keep-recent =.*/pruning-keep-recent = "100000"/' ~/.shahd/config/app.toml
sed -i 's/^pruning-interval =.*/pruning-interval = "10"/' ~/.shahd/config/app.toml

# Set up systemd service
echo "⚙️  Creating systemd service..."
sudo tee /etc/systemd/system/shahd.service > /dev/null << EOF
[Unit]
Description=SHAHCOIN Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which shahd) start --home $HOME/.shahd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
Environment="HOME=$HOME"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl enable shahd

echo "✅ Systemd service created and enabled"

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 26656/tcp comment 'SHAHCOIN P2P'
sudo ufw allow 26657/tcp comment 'SHAHCOIN RPC'
sudo ufw allow 1317/tcp comment 'SHAHCOIN API'
sudo ufw allow 9090/tcp comment 'SHAHCOIN gRPC'
sudo ufw allow 22/tcp comment 'SSH'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ VPS Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📋 Node Information:"
echo "  Moniker: $MONIKER"
echo "  Chain ID: shahcoin-1"
echo "  Home: ~/.shahd"
echo "  Binary: $(which shahd)"
echo ""
echo "🌐 Endpoints:"
echo "  RPC: http://$HOSTNAME:26657"
echo "  API: http://$HOSTNAME:1317"
echo "  gRPC: $HOSTNAME:9090"
echo "  P2P: $HOSTNAME:26656"
echo ""
echo "🔜 Next steps:"
echo "  1. Copy your validator key to this server"
echo "  2. Verify genesis hash matches"
echo "  3. Start the node: sudo systemctl start shahd"
echo "  4. Check logs: sudo journalctl -u shahd -f"
echo "  5. Check status: shahd status"
echo ""

EOFSCRIPT
)

# Save the script
echo "$DEPLOY_SCRIPT" > /tmp/vps_setup.sh

# Replace placeholder with actual validator name
sed -i "s/VALIDATOR_NAME_PLACEHOLDER/$VALIDATOR_NAME/g" /tmp/vps_setup.sh

echo "📤 Uploading deployment script to VPS..."
scp -P "$VPS_PORT" /tmp/vps_setup.sh "$VPS_USER@$VPS_IP:/tmp/"

echo "🚀 Running deployment on VPS..."
echo ""
ssh -p "$VPS_PORT" "$VPS_USER@$VPS_IP" "bash /tmp/vps_setup.sh"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Deployment to VPS Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "🔑 Now transfer your validator key:"
echo "  scp -P $VPS_PORT ~/.shahd/keys_backup/${VALIDATOR_NAME}.key $VPS_USER@$VPS_IP:/tmp/"
echo "  ssh -p $VPS_PORT $VPS_USER@$VPS_IP"
echo "  shahd keys import $VALIDATOR_NAME /tmp/${VALIDATOR_NAME}.key --keyring-backend file"
echo ""
echo "🌐 Copy genesis.json to VPS:"
echo "  scp -P $VPS_PORT ~/.shahd/config/genesis.json $VPS_USER@$VPS_IP:~/.shahd/config/"
echo ""
echo "🚀 Start the node:"
echo "  ssh -p $VPS_PORT $VPS_USER@$VPS_IP"
echo "  sudo systemctl start shahd"
echo "  sudo journalctl -u shahd -f"
echo ""

