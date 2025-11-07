#!/bin/bash
# SHAHCOIN Multi-VPS Deployment Script
# Deploys to all 4 validator VPS servers

set -e

echo "🌐 SHAHCOIN Multi-Validator Deployment"
echo "======================================="
echo ""

# VPS Configuration - EDIT THESE!
declare -A VPS_INFO=(
    [validator1_ip]="VPS1_IP_HERE"      # e.g., "203.0.113.1"
    [validator2_ip]="VPS2_IP_HERE"      # e.g., "203.0.113.2"
    [validator3_ip]="VPS3_IP_HERE"      # e.g., "203.0.113.3"
    [validator4_ip]="VPS4_IP_HERE"      # e.g., "203.0.113.4"
    [ssh_user]="root"                    # or "ubuntu"
    [ssh_port]="22"
)

# Display configuration
echo "📝 Deployment Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Validator 1: ${VPS_INFO[ssh_user]}@${VPS_INFO[validator1_ip]}:${VPS_INFO[ssh_port]}"
echo "Validator 2: ${VPS_INFO[ssh_user]}@${VPS_INFO[validator2_ip]}:${VPS_INFO[ssh_port]}"
echo "Validator 3: ${VPS_INFO[ssh_user]}@${VPS_INFO[validator3_ip]}:${VPS_INFO[ssh_port]}"
echo "Validator 4: ${VPS_INFO[ssh_user]}@${VPS_INFO[validator4_ip]}:${VPS_INFO[ssh_port]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if configuration is complete
if [[ "${VPS_INFO[validator1_ip]}" == "VPS1_IP_HERE" ]]; then
    echo "❌ ERROR: Please edit this script and set your VPS IP addresses!"
    echo ""
    echo "Edit the VPS_INFO array at the top of this script:"
    echo "  validator1_ip=\"203.0.113.1\"  # Your actual IP"
    echo "  validator2_ip=\"203.0.113.2\"  # Your actual IP"
    echo "  etc."
    echo ""
    exit 1
fi

read -p "Deploy to all 4 validators? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""

# Function to deploy to a single VPS
deploy_to_vps() {
    local VALIDATOR=$1
    local VPS_IP=$2
    local VPS_USER=${VPS_INFO[ssh_user]}
    local VPS_PORT=${VPS_INFO[ssh_port]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Deploying to: $VALIDATOR ($VPS_IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    # Test SSH connection
    echo "🔌 Testing connection..."
    if ssh -p "$VPS_PORT" -o ConnectTimeout=5 "$VPS_USER@$VPS_IP" "echo 'Connection successful'" 2>/dev/null; then
        echo "✅ Connection successful"
    else
        echo "❌ Cannot connect to $VPS_IP"
        echo "   Please check:"
        echo "   - VPS IP address is correct"
        echo "   - SSH is running on the VPS"
        echo "   - Firewall allows SSH (port $VPS_PORT)"
        echo "   - You have SSH access (password or key)"
        echo ""
        read -p "Skip this VPS? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return
        else
            exit 1
        fi
    fi
    
    # Run deployment
    VPS_IP=$VPS_IP VPS_PORT=$VPS_PORT VPS_USER=$VPS_USER VALIDATOR_NAME=$VALIDATOR \
        ./scripts/deploy_to_vps.sh
    
    echo "✅ $VALIDATOR deployed successfully"
    echo ""
}

# Deploy to all validators
deploy_to_vps "validator1" "${VPS_INFO[validator1_ip]}"
deploy_to_vps "validator2" "${VPS_INFO[validator2_ip]}"
deploy_to_vps "validator3" "${VPS_INFO[validator3_ip]}"
deploy_to_vps "validator4" "${VPS_INFO[validator4_ip]}"

echo "═══════════════════════════════════════════════════════════"
echo "✅ All Validators Deployed!"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "🔜 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Transfer validator keys to each VPS securely"
echo "2. Verify genesis hash matches on all servers"
echo "3. Collect node IDs from each validator:"
echo "   ssh user@vps 'shahd tendermint show-node-id'"
echo ""
echo "4. Update config.toml on each VPS with peer info"
echo ""
echo "5. Coordinate genesis time with all validators"
echo ""
echo "6. Start all nodes at the same time:"
echo "   ssh user@vps1 'sudo systemctl start shahd'"
echo "   ssh user@vps2 'sudo systemctl start shahd'"
echo "   ssh user@vps3 'sudo systemctl start shahd'"
echo "   ssh user@vps4 'sudo systemctl start shahd'"
echo ""
echo "7. Monitor logs:"
echo "   ssh user@vps 'sudo journalctl -u shahd -f'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

