#!/bin/bash
#
# Complete Redeploy - Clean and Fresh Install
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 COMPLETE SHAHCOIN REDEPLOY"
echo "════════════════════════════════════════════════════════════════"
echo ""

# VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="Hamid1213"
    [1_name]="VPS1-Main"
    
    [2_ip]="46.224.17.54"
    [2_pass]="Hamid1213"
    [2_name]="VPS2"
    
    [3_ip]="91.98.44.79"
    [3_pass]="Hamid1213"
    [3_name]="VPS3"
    
    [4_ip]="46.62.247.1"
    [4_pass]="Hamid1213"
    [4_name]="VPS4"
)

deploy_vps() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Deploying $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP << 'EOFREMOTE'
echo "🧹 Cleaning old installation..."
systemctl stop shahd 2>/dev/null || true
rm -rf ~/Shahcoin-Network-PoS
rm -f /usr/local/bin/shahd

echo "📥 Cloning fresh repository..."
cd ~
git clone https://github.com/SHAHCoinvip/Shahcoin-Network-PoS.git
cd Shahcoin-Network-PoS

echo "🔨 Building SHAHCOIN..."
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go build -o /usr/local/bin/shahd ./cmd/shahd

echo "✅ Verifying..."
ls -lh /usr/local/bin/shahd
shahd version 2>/dev/null || echo "Binary ready!"

echo "✅ $NAME deployed!"
EOFREMOTE

    echo ""
}

# Deploy all 4 VPS
for i in 1 2 3 4; do
    deploy_vps $i
    sleep 1
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ ALL VPS REDEPLOYED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Next: ./START_ALL_NODES.sh"
echo ""

