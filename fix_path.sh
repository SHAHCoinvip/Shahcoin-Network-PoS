#!/bin/bash
# Fix PATH and build Shahcoin

echo "🔧 Fixing PATH..."
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$HOME/go/bin"

echo "✅ PATH fixed: $PATH"
echo ""

# Check if make is available
if ! command -v make &> /dev/null; then
    echo "❌ make not found! Installing build-essential..."
    sudo apt update && sudo apt install -y build-essential
else
    echo "✅ make found"
fi

# Check if go is available
if ! command -v go &> /dev/null; then
    echo "❌ Go not found! Please install Go 1.23+"
    echo "   Visit: https://go.dev/doc/install"
    exit 1
else
    echo "✅ Go found: $(go version)"
fi

echo ""
echo "📦 Installing buf (proto generator)..."
# Install buf
if ! command -v buf &> /dev/null; then
    GO111MODULE=on go install github.com/bufbuild/buf/cmd/buf@latest
    echo "✅ buf installed to $HOME/go/bin/buf"
else
    echo "✅ buf already installed"
fi

echo ""
echo "📋 Running go mod tidy..."
go mod tidy

echo ""
echo "📦 Updating buf dependencies..."
cd proto
buf mod update
cd ..

echo ""
echo "🏗️  Generating proto files..."
buf generate --template buf.gen.yaml --config proto/buf.yaml

echo ""
echo "🔨 Building shahd..."
mkdir -p build
go build -mod=readonly -o build/shahd ./cmd/shahd

if [ -f "build/shahd" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "🎉 Next steps:"
    echo "   ./scripts/init_genesis.sh"
    echo "   ./build/shahd start"
else
    echo ""
    echo "❌ Build failed. Check errors above."
    exit 1
fi

