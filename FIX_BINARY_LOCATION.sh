#!/bin/bash
#
# Fix Binary Location on All VPS
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🔧 FIXING SHAHD BINARY LOCATION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="Hamid1213"
    [1_name]="VPS1"
    
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

fix_binary() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Fixing $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP << 'EOFREMOTE'
echo "🔍 Locating shahd binary..."
cd ~/Shahcoin-Network-PoS

echo "🔨 Building shahd..."
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go build -o /usr/local/bin/shahd ./cmd/shahd

echo "✅ Verifying installation..."
which shahd
shahd version 2>/dev/null || echo "Binary installed at: $(which shahd)"

echo "🔄 Restarting service..."
systemctl restart shahd
sleep 2
systemctl status shahd --no-pager | head -15

echo ""
echo "📊 Recent logs:"
journalctl -u shahd -n 10 --no-pager
EOFREMOTE

    echo ""
}

# Fix all 4 VPS
for i in 1 2 3 4; do
    fix_binary $i
    sleep 1
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ ALL BINARIES FIXED!"
echo "════════════════════════════════════════════════════════════════"
echo ""

