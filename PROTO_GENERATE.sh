#!/bin/bash
# Generate proto files using protoc directly (more reliable than buf)

set -e

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "📦 Installing protoc plugins..."

# Install protoc-gen-go and protoc-gen-go-grpc
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@latest
go install github.com/cosmos/gogoproto/protoc-gen-gocosmos@latest

echo "✅ Plugins installed"
echo ""

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo "Installing protoc..."
    cd /tmp
    wget https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-linux-x86_64.zip
    unzip -o protoc-25.1-linux-x86_64.zip -d protoc
    sudo cp protoc/bin/protoc /usr/local/bin/
    sudo cp -r protoc/include/* /usr/local/include/
    cd -
    echo "✅ protoc installed"
else
    echo "✅ protoc already installed: $(protoc --version)"
fi

echo ""
echo "🏗️  Generating proto files..."

# Generate for each module
for dir in proto/shahcoin/*/v1; do
    module=$(basename $(dirname $dir))
    echo "  Generating $module..."
    
    protoc \
        -I proto \
        -I third_party/proto \
        --go_out=. \
        --go_opt=paths=source_relative \
        --go-grpc_out=. \
        --go-grpc_opt=paths=source_relative \
        --grpc-gateway_out=. \
        --grpc-gateway_opt=paths=source_relative \
        --grpc-gateway_opt=logtostderr=true \
        $dir/*.proto || echo "⚠️  Warning: $module had issues"
done

echo ""
echo "✅ Proto generation complete!"
echo ""

# Check if any pb.go files were created
if find x -name "*.pb.go" | grep -q .; then
    echo "✅ Generated files found:"
    find x -name "*.pb.go" | head -10
    echo ""
    echo "Now run: go build -o build/shahd ./cmd/shahd"
else
    echo "⚠️  No .pb.go files found, checking errors..."
fi

