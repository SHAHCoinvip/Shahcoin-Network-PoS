#!/bin/bash
#
# Change Password for VPS2 - Interactive
#

echo "════════════════════════════════════════════════════════════════"
echo "   🔐 VPS2 Password Change (46.224.17.54)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Current password: MvTbpVdNriJNWLhgHAJx"
echo ""
echo "Instructions:"
echo "1. You'll be connected to VPS2"
echo "2. Enter OLD password: MvTbpVdNriJNWLhgHAJx"
echo "3. Enter NEW password (same as VPS1)"
echo "4. Confirm NEW password"
echo "5. Type 'exit' to disconnect"
echo ""
echo "Press ENTER to connect..."
read

ssh root@46.224.17.54

