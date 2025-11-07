#!/bin/bash
# Simple build script for Shahcoin

set -e

echo "🚀 Building Shahcoin..."
echo ""

# Fix PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

# Clean and tidy
echo "📦 Step 1/4: Tidying dependencies..."
go mod download cosmossdk.io/core
go mod tidy

# Update buf deps
echo "📦 Step 2/4: Updating proto dependencies..."
cd proto
buf dep update || buf mod update
cd ..

# Generate proto (skip if it fails, we'll build without for now)
echo "🏗️  Step 3/4: Generating proto files..."
buf generate || echo "⚠️  Proto generation failed, continuing anyway..."

# Build
echo "🔨 Step 4/4: Building shahd binary..."
mkdir -p build
go build -o build/shahd ./cmd/shahd 2>&1 | tee build.log

if [ -f "build/shahd" ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "Binary: ./build/shahd"
    ./build/shahd version 2>/dev/null || echo "Version: dev"
    echo ""
    echo "Next steps:"
    echo "  ./scripts/init_genesis.sh"
    echo "  ./build/shahd start"
else
    echo ""
    echo "❌ Build failed. Check build.log for details"
    tail -50 build.log
    exit 1
fi

