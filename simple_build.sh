#!/bin/bash
# Ultra-simple build - just get SOMETHING working

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "🎯 Simple Build Strategy"
echo ""

# Step 1: Fix go.mod
echo "[1/3] Fixing dependencies..."
go mod download cosmossdk.io/core
go mod tidy

# Step 2: Try to build (ignoring proto for now)
echo "[2/3] Building minimal binary..."
mkdir -p build

# Temporarily rename app.go to avoid IBC/custom module issues
if [ -f "app/app.go" ]; then
    mv app/app.go app/app.go.full
fi

if [ -f "app/app_minimal.go" ]; then
    cp app/app_minimal.go app/app.go
fi

# Try build
go build -o build/shahd ./cmd/shahd 2>&1 | tee /tmp/build.log

BUILD_SUCCESS=$?

# Restore original app.go
if [ -f "app/app.go.full" ]; then
    mv app/app.go.full app/app.go
fi

if [ $BUILD_SUCCESS -eq 0 ] && [ -f "build/shahd" ]; then
    echo ""
    echo "✅ MINIMAL BUILD SUCCESSFUL!"
    echo ""
    ./build/shahd version || echo "Shahd binary ready"
    echo ""
    echo "⚠️  Note: This is a minimal build (core SDK modules only)"
    echo "    Custom modules (shahswap, treasury, etc.) require proto generation"
    echo ""
    echo "Next: Generate protos and rebuild full version"
else
    echo ""
    echo "❌ Build failed:"
    tail -20 /tmp/build.log
fi

