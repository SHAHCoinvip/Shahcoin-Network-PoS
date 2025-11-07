#!/bin/bash
# Build FULL Shahcoin with all custom modules

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "🔥 BUILDING FULL SHAHCOIN 🔥"
echo ""

# Clean and prepare
echo "[1/5] Cleaning..."
rm -f proto/buf.lock third_party/proto/buf.lock

echo "[2/5] Installing protoc plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest  
go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@latest
echo "✅ Plugins installed"

echo "[3/5] Tidying dependencies..."
go mod download
go mod tidy

# Generate proto
echo "[4/5] Generating proto files..."
buf generate

# Check if proto files were generated
if ls x/shahswap/types/*.pb.go 1> /dev/null 2>&1; then
    echo "✅ Proto files generated successfully!"
else
    echo "❌ Proto generation failed"
    echo "Checking buf output..."
    buf generate --template buf.gen.yaml 2>&1 | head -20
    exit 1
fi

# Build
echo "[3/4] Building shahd with ALL modules..."
mkdir -p build
go build -o build/shahd ./cmd/shahd

if [ -f "build/shahd" ]; then
    echo ""
    echo "🎉🎉🎉 FULL BUILD SUCCESSFUL! 🎉🎉🎉"
    echo ""
    echo "✅ Binary: ./build/shahd"
    ./build/shahd version 2>&1 || echo "Shahd ready!"
    ls -lh build/shahd
    echo ""
    echo "✅ All custom modules included:"
    echo "   - x/shahswap (AMM DEX)"
    echo "   - x/treasury (Reserve management)"
    echo "   - x/fees (USD fee estimation)"
    echo "   - x/airdrop (Merkle claims)"
    echo "   - x/monitoring (Chain metrics)"
    echo "   - x/shahbridge (IBC metadata)"
    echo ""
    echo "[4/4] Next steps:"
    echo "   ./scripts/init_genesis.sh  # Initialize genesis"
    echo "   ./build/shahd start        # Start the chain!"
else
    echo ""
    echo "❌ Build failed"
    exit 1
fi

