#!/bin/bash

echo "Testing VPS connections..."
echo ""

echo "═══ VPS1: 46.224.22.188 ═══"
echo "Trying to connect..."
timeout 10s ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@46.224.22.188 'hostname && echo "✅ VPS1 connected!"' 2>&1 || echo "❌ VPS1 failed"
echo ""

echo "═══ VPS2: 46.224.17.54 ═══"
timeout 10s ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@46.224.17.54 'hostname && echo "✅ VPS2 connected!"' 2>&1 || echo "❌ VPS2 failed"
echo ""

echo "═══ VPS3: 91.98.44.79 ═══"
timeout 10s ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@91.98.44.79 'hostname && echo "✅ VPS3 connected!"' 2>&1 || echo "❌ VPS3 failed"
echo ""

echo "═══ VPS4: 46.62.247.1 ═══"
timeout 10s ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@46.62.247.1 'hostname && echo "✅ VPS4 connected!"' 2>&1 || echo "❌ VPS4 failed"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "If all failed, you need to:"
echo "  1. Add SSH keys to the servers, OR"
echo "  2. Enable password authentication, OR"
echo "  3. Use your hosting provider's web console"
echo "════════════════════════════════════════════════════════════"

