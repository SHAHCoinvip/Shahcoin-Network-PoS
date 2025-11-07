#!/bin/bash

# Firewall configuration for Shahcoin validator node

echo "Configuring firewall for Shahcoin..."

# Enable UFW
sudo ufw --force enable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow P2P port (publicly accessible)
sudo ufw allow 26656/tcp comment "Shahcoin P2P"

# Allow RPC port (restrict to specific IPs in production)
# For dev: open
sudo ufw allow 26657/tcp comment "Shahcoin RPC"

# Allow REST API (restrict in production)
sudo ufw allow 1317/tcp comment "Shahcoin REST API"

# Allow gRPC (restrict in production)
sudo ufw allow 9090/tcp comment "Shahcoin gRPC"

# Allow HTTP/HTTPS for nginx reverse proxy
sudo ufw allow 80/tcp comment "HTTP"
sudo ufw allow 443/tcp comment "HTTPS"

# Show status
sudo ufw status verbose

echo ""
echo "Firewall configured! Summary:"
echo "  - P2P (26656): OPEN (required for validators)"
echo "  - RPC (26657): OPEN (restrict in production!)"
echo "  - REST (1317): OPEN (restrict in production!)"
echo "  - gRPC (9090): OPEN (restrict in production!)"
echo ""
echo "For production validators:"
echo "  - Restrict RPC/REST/gRPC to specific IPs only"
echo "  - Use nginx reverse proxy with rate limiting"
echo "  - Consider VPN for sensitive endpoints"

