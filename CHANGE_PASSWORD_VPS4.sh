#!/bin/bash
#
# Change Password for VPS4 - Interactive
#

echo "════════════════════════════════════════════════════════════════"
echo "   🔐 VPS4 Password Change (46.62.247.1)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Current password: k74TNek7mFhjrNpjNhLd"
echo ""
echo "Instructions:"
echo "1. You'll be connected to VPS4"
echo "2. Enter OLD password: k74TNek7mFhjrNpjNhLd"
echo "3. Enter NEW password (same as VPS1, 2 & 3)"
echo "4. Confirm NEW password"
echo "5. Type 'exit' to disconnect"
echo ""
echo "Press ENTER to connect..."
read

ssh root@46.62.247.1

