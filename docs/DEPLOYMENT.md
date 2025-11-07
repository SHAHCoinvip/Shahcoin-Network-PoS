# 🚀 SHAHCOIN Deployment Guide

Complete guide for deploying SHAHCOIN to production.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Testing](#local-testing)
3. [GitHub Setup](#github-setup)
4. [VPS Setup](#vps-setup)
5. [Domain Configuration](#domain-configuration)
6. [Genesis Ceremony](#genesis-ceremony)
7. [Mainnet Launch](#mainnet-launch)
8. [Post-Launch Monitoring](#post-launch-monitoring)

---

## 1. Prerequisites

### Hardware Requirements (Per Validator)

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8 cores |
| RAM | 8GB | 16-32GB |
| Storage | 500GB SSD | 1TB NVMe SSD |
| Network | 100Mbps | 1Gbps |
| OS | Ubuntu 20.04 | Ubuntu 22.04 LTS |

### Software Requirements

- Go 1.23 or higher
- Git
- jq (JSON processor)
- Build tools (gcc, make)

### Accounts Needed

- [x] GitHub account
- [x] 4x VPS servers (DigitalOcean, Vultr, Hetzner, etc.)
- [x] Domain registrar access (for shah.vip)
- [x] SSH keys for server access

### Estimated Costs

| Item | Monthly Cost |
|------|--------------|
| 4x VPS (8GB RAM, 4 CPU) | $160-400 |
| Domain (shah.vip) | $10-15/year |
| SSL Certificates | Free (Let's Encrypt) |
| **Total** | ~$200-450/month |

---

## 2. Local Testing

### Step 1: Build and Initialize

```bash
# Navigate to project
cd shahcoin

# Build binary
go build -o build/shahd ./cmd/shahd

# Run complete initialization
./scripts/init_genesis.sh
```

This will:
- Initialize the node
- Configure genesis parameters
- Create 5 keys (founder + 4 validators)
- Add genesis accounts
- Create gentx files
- Collect gentxs
- Validate genesis

### Step 2: Test Locally

```bash
# Start node
./build/shahd start

# In another terminal, test transactions
./build/shahd keys list
./build/shahd query bank balances $(./build/shahd keys show founder -a)

# Stop when satisfied (Ctrl+C)
```

### Step 3: Verify All Modules

```bash
# Check shahswap
./build/shahd query shahswap params

# Check treasury
./build/shahd query treasury params

# Check fees
./build/shahd query fees params

# Check monitoring
./build/shahd query monitoring metrics
```

---

## 3. GitHub Setup

### Step 1: Prepare Repository

```bash
# Run GitHub preparation script
./scripts/prepare_github.sh

# Review what will be committed
git status
```

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `shahcoin`
3. Description: "SHAHCOIN - Next-Generation Blockchain with Native DeFi"
4. Visibility: **Public** (recommended for blockchain)
5. Do NOT initialize with README
6. Click "Create repository"

### Step 3: Push to GitHub

```bash
# Stage all files
git add .

# Commit
git commit -m "feat: Initial release - SHAHCOIN Blockchain v1.0.0"

# Add remote (REPLACE YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/shahcoin.git

# Push
git branch -M main
git push -u origin main

# Tag release
git tag -a v1.0.0 -m "SHAHCOIN v1.0.0 - Genesis Release"
git push origin v1.0.0
```

### Step 4: Configure Repository

1. **Add Topics**: `blockchain`, `cosmos-sdk`, `defi`, `dex`, `cosmos`, `ibc`
2. **Add Description**: "Next-generation blockchain with native DeFi"
3. **Enable Discussions**: For community engagement
4. **Add License**: Apache 2.0
5. **Create Release**: From tag v1.0.0

### Step 5: Upload Genesis File

```bash
# Copy final genesis.json to repository root
cp ~/.shahd/config/genesis.json ./genesis.json

# Commit and push
git add genesis.json
git commit -m "docs: Add mainnet genesis.json"
git push
```

---

## 4. VPS Setup

### Step 1: Provision VPS Servers

Order 4 VPS servers with:
- **Ubuntu 22.04 LTS**
- **8GB RAM minimum**
- **4 CPU cores**
- **500GB SSD**
- **Static IP address**

Recommended providers:
- **DigitalOcean**: $48/month (Basic Droplet)
- **Vultr**: $48/month (High Performance)
- **Hetzner**: $30/month (CPX31 - Europe)
- **Linode**: $60/month (Dedicated 8GB)

### Step 2: Initial Server Setup

For each VPS:

```bash
# SSH into server
ssh root@YOUR_VPS_IP

# Update system
apt update && apt upgrade -y

# Create non-root user (recommended)
adduser shahcoin
usermod -aG sudo shahcoin
su - shahcoin

# Set up SSH key authentication
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# Copy your public key to ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 26656/tcp  # P2P
sudo ufw allow 26657/tcp  # RPC
sudo ufw allow 1317/tcp   # API
sudo ufw allow 9090/tcp   # gRPC
sudo ufw enable
```

### Step 3: Deploy Using Script

Edit `scripts/deploy_all_validators.sh` with your VPS IPs:

```bash
# Edit the script
nano scripts/deploy_all_validators.sh

# Set your IPs:
# validator1_ip="203.0.113.1"
# validator2_ip="203.0.113.2"
# validator3_ip="203.0.113.3"
# validator4_ip="203.0.113.4"

# Run deployment
./scripts/deploy_all_validators.sh
```

### Step 4: Transfer Keys to VPS

```bash
# For each validator, transfer the key securely
scp ~/.shahd/keys_backup/validator1.key root@VPS1_IP:/tmp/
ssh root@VPS1_IP
shahd keys import validator1 /tmp/validator1.key --keyring-backend file
rm /tmp/validator1.key  # Delete after import

# Repeat for all 4 validators
```

### Step 5: Distribute Genesis

```bash
# Copy genesis to each VPS
for vps in VPS1_IP VPS2_IP VPS3_IP VPS4_IP; do
    scp ~/.shahd/config/genesis.json root@$vps:~/.shahd/config/
done

# Verify hash on each server
ssh root@VPS_IP "sha256sum ~/.shahd/config/genesis.json"
# Should match your local hash!
```

---

## 5. Domain Configuration (shah.vip)

### Step 1: DNS Records

Log into your domain registrar (Cloudflare recommended) and add:

**A Records:**
```
shah.vip                → VPS1_IP (or load balancer)
rpc1.shah.vip          → VPS1_IP
rpc2.shah.vip          → VPS2_IP
rpc3.shah.vip          → VPS3_IP
rpc4.shah.vip          → VPS4_IP
api1.shah.vip          → VPS1_IP
api2.shah.vip          → VPS2_IP
api3.shah.vip          → VPS3_IP
api4.shah.vip          → VPS4_IP
```

**CNAME Records (Load Balanced):**
```
rpc.shah.vip           → rpc1.shah.vip (with round-robin to all)
api.shah.vip           → api1.shah.vip (with round-robin to all)
```

**Optional:**
```
explorer.shah.vip      → Explorer server IP
docs.shah.vip          → Docs server IP (or GitHub Pages)
www.shah.vip           → shah.vip (redirect)
```

### Step 2: SSL Certificates

On each VPS:

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificates
sudo certbot certonly --standalone -d rpc1.shah.vip
sudo certbot certonly --standalone -d api1.shah.vip

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### Step 3: Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install nginx -y

# Create config
sudo nano /etc/nginx/sites-available/shahcoin
```

**Nginx Config:**

```nginx
# RPC Endpoint
server {
    listen 80;
    listen 443 ssl;
    server_name rpc1.shah.vip;
    
    ssl_certificate /etc/letsencrypt/live/rpc1.shah.vip/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rpc1.shah.vip/privkey.pem;
    
    location / {
        proxy_pass http://localhost:26657;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# API Endpoint
server {
    listen 80;
    listen 443 ssl;
    server_name api1.shah.vip;
    
    ssl_certificate /etc/letsencrypt/live/api1.shah.vip/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api1.shah.vip/privkey.pem;
    
    location / {
        proxy_pass http://localhost:1317;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type" always;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/shahcoin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 4: Configure Load Balancing

If using Cloudflare:
1. Enable **Load Balancing** (paid feature, ~$5/month)
2. Create pool with all RPC endpoints
3. Set health checks: `GET /health` → `localhost:26657/health`
4. Enable auto-failover

Alternative (free): Use DNS round-robin

---

## 6. Genesis Ceremony

### Collect Node IDs

From each VPS:

```bash
# Get node ID
shahd tendermint show-node-id

# Save format: NODE_ID@IP:PORT
# Example: 8ef203b6ae35923d9f2f73172e798ae4327c637e@203.0.113.1:26656
```

### Update Peers on All Nodes

Edit `~/.shahd/config/config.toml` on each VPS:

```toml
seeds = "node1@rpc1.shah.vip:26656,node2@rpc2.shah.vip:26656,node3@rpc3.shah.vip:26656,node4@rpc4.shah.vip:26656"

persistent_peers = "8ef203b6@203.0.113.1:26656,9fa204c7@203.0.113.2:26656,7eb305d8@203.0.113.3:26656,6dc406e9@203.0.113.4:26656"
```

### Set Genesis Time

Choose a launch time (e.g., 24 hours from now):

```bash
# Calculate genesis time
GENESIS_TIME=$(date -u -d '+24 hours' +"%Y-%m-%dT%H:%M:%SZ")
echo "Genesis time: $GENESIS_TIME"

# Update on all servers
ssh root@VPS "jq \".genesis_time = \\\"$GENESIS_TIME\\\"\" ~/.shahd/config/genesis.json > /tmp/genesis.json && mv /tmp/genesis.json ~/.shahd/config/genesis.json"
```

### Final Verification

On each VPS:

```bash
# Verify genesis hash
sha256sum ~/.shahd/config/genesis.json
# Must match on ALL servers!

# Validate genesis
shahd genesis validate-genesis ~/.shahd/config/genesis.json

# Check node is ready
shahd status 2>&1 | jq .SyncInfo
```

---

## 7. Mainnet Launch

### Launch Sequence

**T-1 hour**: Final checks
```bash
# All validators check:
- Genesis hash matches
- Config.toml has correct peers
- Systemd service is enabled
- Firewall rules are correct
```

**T-15 minutes**: Pre-start coordination
```bash
# Join video call/Telegram with all validators
# Confirm everyone is ready
```

**T-0 (Genesis Time)**: START!

```bash
# Validator 1
ssh root@VPS1 "sudo systemctl start shahd"

# Wait 30 seconds

# Validator 2
ssh root@VPS2 "sudo systemctl start shahd"

# Wait 30 seconds

# Validator 3
ssh root@VPS3 "sudo systemctl start shahd"

# Wait 30 seconds

# Validator 4
ssh root@VPS4 "sudo systemctl start shahd"
```

**Network starts when 2/3 voting power is online (3 validators)**

### Monitor Launch

```bash
# Check logs on each validator
ssh root@VPS "sudo journalctl -u shahd -f"

# Look for:
# - "executed block" messages
# - Block height incrementing
# - No error messages
```

### Verify Launch Success

```bash
# Check node status
curl https://rpc1.shah.vip:26657/status

# Check latest block
curl https://api1.shah.vip:1317/cosmos/base/tendermint/v1beta1/blocks/latest

# Query validator set
shahd query staking validators --node https://rpc1.shah.vip:26657
```

---

## 8. Post-Launch Monitoring

### Set Up Monitoring Tools

**Prometheus + Grafana:**

```bash
# Install on monitoring server
sudo apt install prometheus grafana -y

# Configure Prometheus
# Add targets in /etc/prometheus/prometheus.yml:
scrape_configs:
  - job_name: 'shahcoin'
    static_configs:
      - targets:
        - 'rpc1.shah.vip:26660'
        - 'rpc2.shah.vip:26660'
        - 'rpc3.shah.vip:26660'
        - 'rpc4.shah.vip:26660'
```

**Telegram Alerts:**

Use [Cosmos Validator Alerter](https://github.com/solarlabsteam/cosmos-validator-alerter)

**Key Metrics to Monitor:**

- Block height (should increase ~every 6 seconds)
- Validator missed blocks
- Peer count (should be >3)
- Memory usage
- Disk usage
- Network traffic

### Health Check Endpoints

```bash
# Node health
curl https://rpc.shah.vip:26657/health

# Validator status
curl https://api.shah.vip:1317/cosmos/base/tendermint/v1beta1/validatorsets/latest
```

### Backup Procedures

**Automated Daily Backups:**

```bash
#!/bin/bash
# Add to crontab: 0 2 * * * /root/backup_shahd.sh

# Stop node
sudo systemctl stop shahd

# Backup data
tar -czf /backup/shahd-$(date +%Y%m%d).tar.gz ~/.shahd/data

# Restart node
sudo systemctl start shahd

# Delete old backups (keep 7 days)
find /backup -name "shahd-*.tar.gz" -mtime +7 -delete
```

---

## 🔐 Security Best Practices

### Server Hardening

```bash
# Disable password authentication
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd

# Enable automatic security updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades

# Install fail2ban
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
```

### Key Management

- **NEVER** commit keys to GitHub
- Store validator keys on encrypted USB drives
- Use hardware security modules (HSM) for high-value validators
- Keep 3 backup copies in different physical locations
- Use multisig for treasury operations

### Monitoring & Alerting

- Set up Telegram/Discord alerts for:
  - Node offline
  - Missed blocks > 10
  - Disk usage > 80%
  - Memory usage > 90%

---

## 📞 Emergency Procedures

### Node Offline

```bash
# Check status
sudo systemctl status shahd

# Check logs
sudo journalctl -u shahd -n 100

# Restart
sudo systemctl restart shahd
```

### Chain Halt

If chain stops producing blocks:

1. Check validator group chat
2. Coordinate with other validators
3. May need to upgrade if consensus failure
4. Follow governance proposal process

### Security Incident

1. Stop the node immediately: `sudo systemctl stop shahd`
2. Notify other validators
3. Assess the damage
4. Follow incident response plan
5. May need emergency upgrade

---

## 🎯 Deployment Checklist

### Pre-Launch
- [ ] Binary built and tested locally
- [ ] All 6 custom modules working
- [ ] Genesis configured with correct parameters
- [ ] 4 validator keys created and backed up
- [ ] Genesis hash verified
- [ ] Code pushed to GitHub
- [ ] 4 VPS servers provisioned
- [ ] Domain DNS configured
- [ ] SSL certificates obtained
- [ ] All validators have genesis.json

### Launch Day
- [ ] All validators connected via chat
- [ ] Genesis time coordinated
- [ ] Peers configured on all nodes
- [ ] Systemd services enabled
- [ ] Monitoring dashboards ready
- [ ] Launch sequence executed
- [ ] First blocks produced
- [ ] All 4 validators active

### Post-Launch (Week 1)
- [ ] Block explorer deployed
- [ ] Website live at shah.vip
- [ ] Social media announced
- [ ] Community channels created
- [ ] Documentation published
- [ ] First governance proposal
- [ ] DEX pools created
- [ ] Monitoring alerts configured

---

## 📊 Success Metrics

After launch, verify:

✅ All 4 validators producing blocks
✅ Block time stable (~6 seconds)
✅ No missed blocks
✅ IBC channels active
✅ API/RPC endpoints responding
✅ Explorer showing transactions
✅ Community engagement growing

---

## 💡 Troubleshooting

### Common Issues

**Issue**: "connection refused"
**Solution**: Check firewall, verify service is running

**Issue**: "genesis hash mismatch"  
**Solution**: All validators must have identical genesis.json

**Issue**: "validator not in active set"
**Solution**: Check stake amount, verify gentx was included

**Issue**: "peers not connecting"
**Solution**: Verify node IDs, check firewall port 26656

---

## 📚 Additional Resources

- [Cosmos Validator Guide](https://hub.cosmos.network/validators/overview.html)
- [CometBFT Documentation](https://docs.cometbft.com)
- [IBC Documentation](https://ibc.cosmos.network)
- [Cosmos SDK Modules](https://docs.cosmos.network/main/modules)

---

**Questions? Join our community:**
- Telegram: https://t.me/shahcoin
- Discord: https://discord.gg/shahcoin
- Twitter: https://twitter.com/shahcoin

**Built with ❤️ by the SHAHCOIN Team**

