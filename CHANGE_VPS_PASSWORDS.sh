#!/bin/bash
#
# Change VPS Passwords Interactively from WSL
#

set -e

echo "════════════════════════════════════════════════════════════════"
echo "   🔐 VPS Password Change - Interactive"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Install expect if needed
if ! command -v expect &> /dev/null; then
    echo "📦 Installing expect..."
    sudo apt-get update -qq
    sudo apt-get install -y expect
fi

# VPS Information
declare -A VPS=(
    [1_ip]="46.224.22.188"
    [1_pass]="hwkePVgp7LquVXrTRMLd"
    [1_name]="VPS1-Main"
    
    [2_ip]="46.224.17.54"
    [2_pass]="MvTbpVdNriJNWLhgHAJx"
    [2_name]="VPS2"
    
    [3_ip]="91.98.44.79"
    [3_pass]="VvgnqE493ea7fJVLsKaX"
    [3_name]="VPS3"
    
    [4_ip]="46.62.247.1"
    [4_pass]="k74TNek7mFhjrNpjNhLd"
    [4_name]="VPS4"
)

# Prompt for NEW password (same for all VPS)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Choose a NEW password for all 4 VPS servers:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -s -p "New Password: " NEW_PASSWORD
echo ""
read -s -p "Confirm Password: " NEW_PASSWORD_CONFIRM
echo ""
echo ""

if [ "$NEW_PASSWORD" != "$NEW_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

if [ ${#NEW_PASSWORD} -lt 8 ]; then
    echo "❌ Password must be at least 8 characters!"
    exit 1
fi

echo "✅ Password set!"
echo ""

# Function to change password on one VPS
change_password() {
    local NUM=$1
    local IP=${VPS[${NUM}_ip]}
    local OLD_PASS=${VPS[${NUM}_pass]}
    local NAME=${VPS[${NUM}_name]}
    
    echo "═══════════════════════════════════════════════════════════"
    echo "Changing password for $NAME ($IP)"
    echo "═══════════════════════════════════════════════════════════"
    
    # Create expect script
    expect << EOF
set timeout 60
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP
expect {
    "password:" {
        send "$OLD_PASS\r"
        exp_continue
    }
    "Current password:" {
        send "$OLD_PASS\r"
        exp_continue
    }
    "New password:" {
        send "$NEW_PASSWORD\r"
        exp_continue
    }
    "Retype new password:" {
        send "$NEW_PASSWORD\r"
        exp_continue
    }
    "password changed" {
        puts "✅ Password changed successfully!"
        send "exit\r"
    }
    "#" {
        puts "✅ Connected! Enabling SSH password auth..."
        send "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config\r"
        send "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config\r"
        send "sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config\r"
        send "sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config\r"
        send "systemctl restart sshd\r"
        send "echo '✅ SSH configured!'\r"
        send "exit\r"
    }
    timeout {
        puts "❌ Timeout connecting to $IP"
        exit 1
    }
    eof {
        puts "✅ Done!"
    }
}
expect eof
EOF

    echo ""
}

# Change password on all 4 VPS
for i in 1 2 3 4; do
    change_password $i
    sleep 2
done

echo "════════════════════════════════════════════════════════════════"
echo "   ✅ ALL VPS PASSWORDS CHANGED!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "New password set for all 4 VPS servers."
echo ""
echo "Saving credentials..."

# Save new credentials
cat > VPS_NEW_CREDENTIALS.txt << EOF
════════════════════════════════════════════════════════════════
   VPS Credentials - Updated $(date)
════════════════════════════════════════════════════════════════

VPS1 (Main): 46.224.22.188
Username: root
Password: $NEW_PASSWORD

VPS2: 46.224.17.54
Username: root
Password: $NEW_PASSWORD

VPS3: 91.98.44.79
Username: root
Password: $NEW_PASSWORD

VPS4: 46.62.247.1
Username: root
Password: $NEW_PASSWORD

⚠️  KEEP THIS FILE SECURE!
════════════════════════════════════════════════════════════════
EOF

echo "✅ Credentials saved to: VPS_NEW_CREDENTIALS.txt"
echo ""
echo "🚀 NOW YOU CAN DEPLOY!"
echo ""
echo "Update DEPLOY_NOW.sh with new password, then run:"
echo "   ./DEPLOY_NOW.sh"
echo ""

