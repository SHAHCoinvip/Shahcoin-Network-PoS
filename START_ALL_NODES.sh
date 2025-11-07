#!/bin/bash
#
# Start SHAHCOIN on All Nodes
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🚀 STARTING SHAHCOIN NETWORK"
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

# Function to start node on VPS
start_node() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Starting $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no root@$IP << 'EOFREMOTE'
echo "🚀 Starting SHAHCOIN..."
systemctl start shahd
sleep 3
systemctl status shahd --no-pager | head -10
echo ""
echo "📊 Checking logs..."
journalctl -u shahd -n 20 --no-pager
EOFREMOTE

    echo ""
}

# Start all 4 nodes
for i in 1 2 3 4; do
    start_node $i
    sleep 2
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ ALL NODES STARTED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🎉 SHAHCOIN NETWORK IS LIVE!"
echo ""
echo "📊 Check status on any VPS:"
echo "   ssh root@46.224.22.188"
echo "   systemctl status shahd"
echo "   journalctl -u shahd -f"
echo ""
echo "🌐 Genesis Hash: $(sha256sum ~/.shahd/config/genesis.json | awk '{print $1}')"
echo ""
echo "════════════════════════════════════════════════════════════════"

