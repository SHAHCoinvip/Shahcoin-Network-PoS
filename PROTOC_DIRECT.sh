#!/bin/bash
# Generate proto files using protoc with correct path settings

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "🏗️  Generating Proto Files (protoc direct mode)"
echo ""

# Ensure protoc and plugins exist
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc not found! Installing..."
    cd /tmp
    wget -q https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-linux-x86_64.zip
    unzip -q -o protoc-25.1-linux-x86_64.zip -d protoc_install
    sudo cp protoc_install/bin/protoc /usr/local/bin/
    sudo cp -r protoc_install/include/* /usr/local/include/
    rm -rf protoc_install protoc-25.1-linux-x86_64.zip
    cd - > /dev/null
fi

# Install plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@latest

echo "✅ Tools ready"
echo ""

# Generate with module mode (not source_relative)
echo "Generating shahswap..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_opt=logtostderr=true \
    proto/shahcoin/shahswap/v1/*.proto

echo "Generating treasury..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    proto/shahcoin/treasury/v1/*.proto

echo "Generating fees..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    proto/shahcoin/fees/v1/*.proto

echo "Generating airdrop..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    proto/shahcoin/airdrop/v1/*.proto

echo "Generating monitoring..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    proto/shahcoin/monitoring/v1/*.proto

echo "Generating shahbridge..."
protoc \
    -I proto \
    -I third_party/proto \
    --go_out=. \
    --go_opt=module=github.com/shahcoin/shahcoin \
    --go-grpc_out=. \
    --go-grpc_opt=module=github.com/shahcoin/shahcoin \
    --grpc-gateway_out=. \
    --grpc-gateway_opt=module=github.com/shahcoin/shahcoin \
    proto/shahcoin/shahbridge/v1/*.proto

echo ""
echo "🎯 Checking results..."
TOTAL=$(find x -name "*.pb.go" 2>/dev/null | wc -l)
echo "Generated $TOTAL files"

if [ "$TOTAL" -gt 0 ]; then
    echo ""
    echo "✅ SUCCESS! Proto files generated:"
    find x -name "*.pb.go"
    echo ""
    echo "Now build:"
    echo "  go build -o build/shahd ./cmd/shahd"
else
    echo "❌ No files generated - checking for errors..."
    echo "Testing single file:"
    protoc -I proto -I third_party/proto --go_out=. --go_opt=module=github.com/shahcoin/shahcoin proto/shahcoin/shahswap/v1/params.proto
fi

