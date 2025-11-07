#!/bin/bash
#
# Enable SSH Password Auth - Run from WSL
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🔐 Enabling SSH Password Auth on All VPS"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Install sshpass if not present
if ! command -v sshpass &> /dev/null; then
    echo "📦 Installing sshpass..."
    sudo apt-get update -qq
    sudo apt-get install -y sshpass
fi

# VPS credentials
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="hwkePVgp7LquVXrTRMLd"
    
    [2_ip]="46.224.17.54"
    [2_pass]="MvTbpVdNriJNWLhgHAJx"
    
    [3_ip]="91.98.44.79"
    [3_pass]="VvgnqE493ea7fJVLsKaX"
    
    [4_ip]="46.62.247.1"
    [4_pass]="k74TNek7mFhjrNpjNhLd"
)

enable_ssh() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local PASS=${VPS[${NUM}_pass]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "VPS${NUM}: $IP"
    echo "═══════════════════════════════════════════════════════════"
    
    # Try to enable SSH password auth
    echo "🔐 Attempting to enable password authentication..."
    
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 root@$IP \
        'sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
         sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
         sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
         sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
         systemctl restart sshd && \
         echo "✅ SSH password auth enabled on VPS${NUM}!"' 2>&1 || echo "❌ Failed to connect to VPS${NUM}"
    
    echo ""
}

# Try each VPS
for i in 1 2 3 4; do
    enable_ssh $i
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ SSH Configuration Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Now run: ./DEPLOY_NOW.sh"
echo ""

