#!/bin/bash
# Install Go 1.23 in WSL

echo "🚀 Installing Go 1.23..."

# Download Go 1.23
GO_VERSION="1.23.4"
GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"

cd /tmp
echo "📥 Downloading Go ${GO_VERSION}..."
wget https://go.dev/dl/${GO_TARBALL}

# Remove old Go installation if exists
if [ -d "/usr/local/go" ]; then
    echo "🗑️  Removing old Go installation..."
    sudo rm -rf /usr/local/go
fi

# Extract and install
echo "📦 Installing Go..."
sudo tar -C /usr/local -xzf ${GO_TARBALL}

# Add to PATH
echo "🔧 Configuring PATH..."
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
fi

# Source bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Verify installation
echo ""
echo "✅ Go installed successfully!"
go version

echo ""
echo "🎯 Next steps:"
echo "   source ~/.bashrc  # Reload your shell"
echo "   cd /mnt/c/Users/hamid/#3\\ -\\ Shahcoin\\ Blockchain\\ PoS/Shahcoin"
echo "   ./fix_path.sh     # Run the build script"

