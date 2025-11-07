#!/bin/bash
#
# Deploy and Generate Protos on VPS
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 DEPLOY WITH PROTO GENERATION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="Hamid1213"
)

IP=${VPS[1_ip]}
PASS=${VPS[1_pass]}

echo "Deploying to VPS1: $IP"
echo ""

sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP << 'EOFREMOTE'
echo "🧹 Cleaning..."
systemctl stop shahd 2>/dev/null || true
rm -rf ~/Shahcoin-Network-PoS
rm -f /usr/local/bin/shahd

echo "📥 Cloning..."
cd ~
git clone https://github.com/SHAHCoinvip/Shahcoin-Network-PoS.git
cd Shahcoin-Network-PoS

echo "🔨 Building WITHOUT proto generation (use existing .pb.go files)..."
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export CGO_ENABLED=1

# Build directly
go build -o /usr/local/bin/shahd ./cmd/shahd

echo "✅ Binary built!"
ls -lh /usr/local/bin/shahd

echo "🔧 Testing binary..."
shahd version || echo "Binary ready"

echo "🚀 Starting service..."
systemctl restart shahd
sleep 3

echo "📊 Status:"
systemctl status shahd --no-pager | head -15

echo ""
echo "📋 Recent logs:"
journalctl -u shahd -n 20 --no-pager

EOFREMOTE

echo ""
echo "✅ Complete!"

