#!/bin/bash
# Generate proto files using protoc directly (bypass buf completely)

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "🔨 Manual Proto Generation (using protoc directly)"
echo ""

# Install protoc if needed
if ! command -v protoc &> /dev/null; then
    echo "Installing protoc..."
    cd /tmp
    wget -q https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-linux-x86_64.zip
    unzip -q -o protoc-25.1-linux-x86_64.zip -d protoc_install
    sudo cp protoc_install/bin/protoc /usr/local/bin/
    sudo cp -r protoc_install/include/* /usr/local/include/
    rm -rf protoc_install protoc-25.1-linux-x86_64.zip
    cd - > /dev/null
    echo "✅ protoc installed"
else
    echo "✅ protoc found: $(protoc --version)"
fi

# Install Go plugins
echo "Installing protoc plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@latest
go install github.com/cosmos/gogoproto/protoc-gen-gocosmos@latest

echo "✅ Plugins ready"
echo ""

# Create necessary directories
mkdir -p x/shahswap/types
mkdir -p x/treasury/types
mkdir -p x/fees/types
mkdir -p x/airdrop/types
mkdir -p x/monitoring/types
mkdir -p x/shahbridge/types

# Generate each module
echo "Generating proto files for each module..."

PROTO_DIRS="
shahswap
treasury
fees
airdrop
monitoring
shahbridge
"

for module in $PROTO_DIRS; do
    echo "  → $module"
    
    protoc \
        -I proto \
        -I third_party/proto \
        -I /usr/local/include \
        --go_out=. \
        --go_opt=paths=source_relative \
        --go-grpc_out=. \
        --go-grpc_opt=paths=source_relative \
        --grpc-gateway_out=. \
        --grpc-gateway_opt=paths=source_relative \
        --grpc-gateway_opt=logtostderr=true \
        --grpc-gateway_opt=allow_colon_final_segments=true \
        proto/shahcoin/$module/v1/*.proto 2>&1 | grep -v "WARNING" || true
done

echo ""
echo "✅ Proto generation complete!"
echo ""

# Verify generated files
GENERATED=$(find x -name "*.pb.go" 2>/dev/null | wc -l)
echo "Generated $GENERATED .pb.go files"

if [ "$GENERATED" -gt 0 ]; then
    echo ""
    echo "Sample generated files:"
    find x -name "*.pb.go" | head -5
    echo ""
    echo "✅ Ready to build!"
    echo "   Run: go build -o build/shahd ./cmd/shahd"
else
    echo ""
    echo "⚠️  No proto files generated. Checking for errors..."
    protoc --version
    which protoc-gen-go
    which protoc-gen-go-grpc
fi

