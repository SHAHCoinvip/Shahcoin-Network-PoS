#!/bin/bash
#
# Change Password for VPS1 - Interactive
#

echo "════════════════════════════════════════════════════════════════"
echo "   🔐 VPS1 Password Change (46.224.22.188)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Current password: hwkePVgp7LquVXrTRMLd"
echo ""
echo "Instructions:"
echo "1. You'll be connected to VPS1"
echo "2. Enter OLD password: hwkePVgp7LquVXrTRMLd"
echo "3. Enter NEW password (your choice)"
echo "4. Confirm NEW password"
echo "5. Type 'exit' to disconnect"
echo ""
echo "Press ENTER to connect..."
read

ssh root@46.224.22.188

