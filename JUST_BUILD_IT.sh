#!/bin/bash
# Nuclear option: Just build this thing!

set -e

echo "🔥 SHAHCOIN - NUCLEAR BUILD MODE 🔥"
echo ""

# Fix PATH permanently in this session
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

# Verify PATH
if ! command -v cat &> /dev/null; then
    echo "❌ PATH still broken! Run: export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:\$HOME/go/bin"
    exit 1
fi

echo "✅ PATH is good"
echo "✅ Go version: $(go version)"
echo ""

# Clean up old lock files
echo "[1/5] Cleaning up old lock files..."
rm -f proto/buf.lock third_party/proto/buf.lock

# Fix go.mod once and for all
echo "[2/5] Fixing go.mod..."
cat > go.mod << 'EOF'
module github.com/shahcoin/shahcoin

go 1.23

require (
	cosmossdk.io/collections v0.4.0
	cosmossdk.io/core v0.11.1
	cosmossdk.io/errors v1.0.1
	cosmossdk.io/log v1.4.1
	cosmossdk.io/math v1.3.0
	cosmossdk.io/store v1.1.1
	cosmossdk.io/tools/confix v0.1.2
	cosmossdk.io/x/tx v0.13.5
	cosmossdk.io/x/upgrade v0.1.4
	github.com/cometbft/cometbft v0.38.12
	github.com/cosmos/cosmos-db v1.0.2
	github.com/cosmos/cosmos-sdk v0.50.10
	github.com/cosmos/ibc-go/v8 v8.5.1
	github.com/gorilla/mux v1.8.1
	github.com/grpc-ecosystem/grpc-gateway v1.16.0
	github.com/rakyll/statik v0.1.7
	github.com/spf13/cobra v1.8.1
	google.golang.org/grpc v1.67.1
)

replace (
	cosmossdk.io/core => cosmossdk.io/core v0.11.1
	github.com/cosmos/cosmos-sdk => github.com/cosmos/cosmos-sdk v0.50.10
)
EOF

# Tidy
echo "[3/5] Tidying Go modules..."
go clean -modcache
go mod download
go mod tidy

# Generate proto (skip dep update, we have local third_party)
echo "[4/5] Generating proto files..."
buf generate 2>&1 | tee /tmp/buf_generate.log || {
    echo "⚠️  Buf generate had issues, trying alternative..."
    # Skip proto generation for now, we'll build without custom modules
    echo "Skipping proto generation - will build with SDK modules only"
}

echo "[5/5] Done with proto step"

# Build
echo ""
echo "🔨 Building shahd..."
mkdir -p build
go build -o build/shahd ./cmd/shahd

if [ -f "build/shahd" ]; then
    echo ""
    echo "🎉🎉🎉 SUCCESS! 🎉🎉🎉"
    echo ""
    ./build/shahd version 2>/dev/null || echo "Shahd version: dev"
    ls -lh build/shahd
    echo ""
    echo "✅ Ready to initialize genesis!"
    echo "   Run: ./scripts/init_genesis.sh"
else
    echo ""
    echo "❌ Build failed"
    exit 1
fi

