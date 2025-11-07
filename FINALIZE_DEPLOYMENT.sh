#!/bin/bash
#
# Finalize SHAHCOIN Deployment - Copy Genesis & Start Nodes
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 FINALIZING SHAHCOIN DEPLOYMENT"
echo "════════════════════════════════════════════════════════════════"
echo ""

# VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="Hamid1213"
    [1_name]="Val1"
    
    [2_ip]="46.224.17.54"
    [2_pass]="Hamid1213"
    [2_name]="Val2"
    
    [3_ip]="91.98.44.79"
    [3_pass]="Hamid1213"
    [3_name]="Val3"
    
    [4_ip]="46.62.247.1"
    [4_pass]="Hamid1213"
    [4_name]="Val4"
)

GENESIS_FILE="$HOME/.shahd/config/genesis.json"

if [ ! -f "$GENESIS_FILE" ]; then
    echo "❌ Genesis file not found: $GENESIS_FILE"
    exit 1
fi

echo "✅ Genesis file found!"
echo ""

# Function to setup each VPS
setup_vps() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Setting up VPS${NUM}: $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    # Create directories and copy genesis file
    echo "📤 Creating directories and copying genesis file..."
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP "mkdir -p ~/.shah/config ~/.shah/data"
    sshpass -p "$PASS" scp -o StrictHostKeyChecking=no "$GENESIS_FILE" root@$IP:~/.shah/config/genesis.json
    
    # Create systemd service
    echo "⚙️  Creating systemd service..."
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP << 'EOFREMOTE'
cat > /etc/systemd/system/shahd.service << 'EOF'
[Unit]
Description=SHAHCOIN Node
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/shahd start --home /root/.shah
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable shahd
echo "✅ Service created!"
EOFREMOTE

    echo "✅ VPS${NUM} configured!"
    echo ""
}

# Setup all 4 VPS
for i in 1 2 3 4; do
    setup_vps $i
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ ALL VPS CONFIGURED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 SHAHCOIN Network Status:"
echo "   • Chain ID: shahcoin-1"
echo "   • 4 VPS servers configured"
echo "   • Genesis file copied"
echo "   • Services created"
echo ""
echo "🚀 TO START ALL NODES:"
echo "   Run: ./START_ALL_NODES.sh"
echo ""
echo "🎯 TO START INDIVIDUAL NODES:"
echo "   ssh root@46.224.22.188  # then: systemctl start shahd"
echo "   ssh root@46.224.17.54   # then: systemctl start shahd"
echo "   ssh root@91.98.44.79    # then: systemctl start shahd"
echo "   ssh root@46.62.247.1    # then: systemctl start shahd"
echo ""
echo "📊 TO CHECK STATUS:"
echo "   ssh root@<IP>  # then: systemctl status shahd"
echo "   ssh root@<IP>  # then: journalctl -u shahd -f"
echo ""
echo "════════════════════════════════════════════════════════════════"

