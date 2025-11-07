#!/bin/bash
# Test proto generation for ONE module with verbose output

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "🔍 Testing proto generation for shahswap module..."
echo ""

# Test with maximum verbosity
echo "Running protoc with verbose output..."

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
    proto/shahcoin/shahswap/v1/genesis.proto \
    proto/shahcoin/shahswap/v1/params.proto \
    proto/shahcoin/shahswap/v1/pool.proto \
    proto/shahcoin/shahswap/v1/tx.proto \
    proto/shahcoin/shahswap/v1/query.proto

echo ""
echo "Checking output..."
find . -name "*shahswap*.pb.go" -newer /tmp 2>/dev/null || echo "No files generated"

echo ""
echo "Checking where files might have gone..."
find . -name "*.pb.go" -mmin -1 2>/dev/null | head -10

echo ""
echo "Expected location: x/shahswap/types/*.pb.go"
ls -la x/shahswap/types/ 2>/dev/null || echo "Directory doesn't exist or is empty"

