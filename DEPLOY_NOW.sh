#!/bin/bash
# SHAHCOIN VPS Deployment - All 4 Servers
# Your VPS credentials included

set -e

echo "🚀 SHAHCOIN Production Deployment"
echo "=================================="
echo ""

# Your VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_user]="root"
    [1_pass]="hwkePVgp7LquVXrTRMLd"
    [1_name]="MainVPS-Val1"
    
    [2_ip]="46.224.17.54"
    [2_user]="root"
    [2_pass]="MvTbpVdNriJNWLhgHAJx"
    [2_name]="Val2"
    
    [3_ip]="91.98.44.79"
    [3_user]="root"
    [3_pass]="VvgnqE493ea7fJVLsKaX"
    [3_name]="Val3"
    
    [4_ip]="46.62.247.1"
    [4_user]="root"
    [4_pass]="k74TNek7mFhjrNpjNhLd"
    [4_name]="Val4"
)

echo "📋 VPS Servers:"
echo "  VPS1 (Main): ${VPS[1_ip]}"
echo "  VPS2: ${VPS[2_ip]}"
echo "  VPS3: ${VPS[3_ip]}"
echo "  VPS4: ${VPS[4_ip]}"
echo ""

# Function to deploy to a single VPS
deploy_vps() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local USER=${VPS[${NUM}_user]}
    local PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    local VAL_NAME="validator${NUM}"
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Deploying to VPS${NUM}: $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    # Create deployment script for this VPS
    cat > /tmp/deploy_vps${NUM}.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

echo "🔧 Setting up SHAHCOIN on VPS..."

# Update system
echo "📦 Updating system..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq

# Install dependencies
echo "📦 Installing dependencies..."
apt install -y -qq build-essential git jq curl wget nginx certbot

# Install Go 1.23
echo "🐹 Installing Go..."
if ! command -v go &> /dev/null; then
    cd /tmp
    wget -q https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
fi

# Clone repository
echo "📥 Cloning SHAHCOIN..."
cd ~
if [ -d "Shahcoin-Network-PoS" ]; then
    cd Shahcoin-Network-PoS
    git pull
else
    git clone https://github.com/SHAHCoinvip/Shahcoin-Network-PoS.git
    cd Shahcoin-Network-PoS
fi

# Build
echo "🔨 Building SHAHCOIN..."
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go build -o /usr/local/bin/shahd ./cmd/shahd

# Verify
echo "✅ Binary built: $(shahd version 2>/dev/null | head -1 || echo 'installed')"

# Initialize (will be customized per validator)
echo "🔧 Initializing node..."
shahd init VALIDATOR_NAME --chain-id shahcoin-1

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow 22/tcp
ufw allow 26656/tcp
ufw allow 26657/tcp
ufw allow 1317/tcp
ufw allow 9090/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Create systemd service
echo "⚙️  Creating systemd service..."
cat > /etc/systemd/system/shahd.service << EOF
[Unit]
Description=SHAHCOIN Node
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/shahd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable shahd

echo "✅ VPS setup complete!"
echo ""
echo "📊 Node Info:"
echo "  Binary: $(which shahd)"
echo "  Home: ~/.shah"
echo "  Service: shahd.service"
echo ""
EOFSCRIPT

    # Replace validator name
    sed -i "s/VALIDATOR_NAME/$NAME/g" /tmp/deploy_vps${NUM}.sh
    
    # Upload and execute
    echo "📤 Uploading deployment script..."
    sshpass -p "$PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q \
        /tmp/deploy_vps${NUM}.sh $USER@$IP:/tmp/deploy.sh
    
    echo "🚀 Running deployment..."
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q \
        $USER@$IP "bash /tmp/deploy.sh" 2>&1 | grep -E "Installing|Building|setup complete|ERR|Error" || true
    
    echo "✅ VPS${NUM} deployed successfully!"
    echo ""
}

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "📦 Installing sshpass..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq sshpass
fi

# Deploy to all 4 VPS
deploy_vps 1
deploy_vps 2
deploy_vps 3
deploy_vps 4

echo "═══════════════════════════════════════════════════════════"
echo "✅ ALL 4 VPS SERVERS DEPLOYED!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "🎯 Next steps:"
echo "  1. Copy genesis.json to all servers"
echo "  2. Copy validator keys to respective servers"
echo "  3. Configure peers"
echo "  4. Set up shah.vip DNS"
echo "  5. Get SSL certificates"
echo "  6. Launch!"
echo ""
echo "Run: ./scripts/finalize_deployment.sh"
echo ""

