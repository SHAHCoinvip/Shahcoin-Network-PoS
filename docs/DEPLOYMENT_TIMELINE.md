# ⏰ SHAHCOIN Deployment Timeline

Your complete week-by-week roadmap from build to mainnet launch.

---

## 📅 **WEEK 1: Preparation & Testing**

### Day 1 ✅ COMPLETE
- [x] Blockchain built successfully
- [x] All 6 custom modules compiled
- [x] Binary tested (106MB)
- [x] Initial node initialization works

### Day 2-3: Local Testing & Configuration

**Morning:**
```bash
# Configure genesis properly
cd shahcoin
chmod +x scripts/*.sh
./scripts/configure_genesis.sh

# Create validator keys
./scripts/setup_validators.sh
# ⚠️ BACKUP THESE KEYS IMMEDIATELY!
```

**Afternoon:**
```bash
# Add genesis accounts
./scripts/add_genesis_accounts.sh

# Create gentxs
./scripts/create_gentxs.sh

# Collect and validate
./build/shahd genesis collect-gentxs
./build/shahd genesis validate-genesis ~/.shahd/config/genesis.json
```

**Evening:**
```bash
# Test the chain locally
./build/shahd start

# In another terminal - test transactions
./build/shahd query bank balances $(./build/shahd keys show founder -a --keyring-backend file)

# Test custom modules
./build/shahd query shahswap params
./build/shahd query treasury params
./build/shahd query fees params
```

**✅ Success Criteria:**
- Genesis validation passes
- Node starts without errors
- Blocks are being produced
- All modules respond to queries
- No panics or crashes for 1+ hour

### Day 4: GitHub Preparation

**Tasks:**
```bash
# Prepare repository
./scripts/prepare_github.sh

# Create GitHub account/organization
# Repository name: shahcoin

# Push to GitHub
git add .
git commit -m "feat: SHAHCOIN Blockchain v1.0.0 - Genesis Release"
git remote add origin https://github.com/YOUR_USERNAME/shahcoin.git
git push -u origin main

# Tag release
git tag -a v1.0.0 -m "Genesis Release"
git push origin v1.0.0

# Upload genesis.json
cp ~/.shahd/config/genesis.json ./genesis.json
git add genesis.json
git commit -m "docs: Add mainnet genesis"
git push
```

**✅ Success Criteria:**
- Code on GitHub (public or private)
- genesis.json accessible via raw URL
- README displays properly
- Release v1.0.0 created

---

## 📅 **WEEK 2: VPS Setup & Domain**

### Day 5-6: VPS Provisioning

**What You Need:**
- [ ] 4 VPS servers ordered
- [ ] Static IP addresses received
- [ ] SSH access configured
- [ ] Root/sudo access confirmed

**VPS Information Template:**
```
Validator 1:
  Provider: DigitalOcean
  Location: New York (USA East)
  IP: 64.225.XXX.XXX
  SSH: root@64.225.XXX.XXX
  Password/Key: [SECURE]
  
Validator 2:
  Provider: Hetzner
  Location: Germany (Europe)
  IP: 167.99.XXX.XXX
  SSH: root@167.99.XXX.XXX
  Password/Key: [SECURE]

Validator 3:
  Provider: Vultr
  Location: Tokyo (Asia)
  IP: 178.128.XXX.XXX
  SSH: root@178.128.XXX.XXX
  Password/Key: [SECURE]

Validator 4:
  Provider: Linode
  Location: San Francisco (USA West)
  IP: 142.93.XXX.XXX
  SSH: root@142.93.XXX.XXX
  Password/Key: [SECURE]
```

**Deploy to VPS:**
```bash
# Edit deployment script with your VPS IPs
nano scripts/deploy_all_validators.sh

# Set your IPs:
# validator1_ip="64.225.XXX.XXX"
# validator2_ip="167.99.XXX.XXX"
# etc.

# Run deployment
./scripts/deploy_all_validators.sh
```

**✅ Success Criteria:**
- All 4 VPS accessible via SSH
- SHAHCOIN binary built on each VPS
- systemd service configured
- Firewalls configured
- Monitoring installed

### Day 7: Domain Configuration (shah.vip)

**Morning - DNS Setup:**

1. **Log into domain registrar or Cloudflare**

2. **Add DNS records** (see [DOMAIN_SETUP_SHAH_VIP.md](./DOMAIN_SETUP_SHAH_VIP.md)):
   ```
   rpc1.shah.vip → VPS1_IP
   rpc2.shah.vip → VPS2_IP
   rpc3.shah.vip → VPS3_IP
   rpc4.shah.vip → VPS4_IP
   api1.shah.vip → VPS1_IP
   api2.shah.vip → VPS2_IP
   api3.shah.vip → VPS3_IP
   api4.shah.vip → VPS4_IP
   ```

3. **Verify DNS propagation:**
   ```bash
   dig rpc1.shah.vip +short  # Should return VPS1_IP
   ```

**Afternoon - SSL Certificates:**

On each VPS:
```bash
# SSH into VPS
ssh root@VPS1_IP

# Get certificates
sudo certbot certonly --standalone -d rpc1.shah.vip
sudo certbot certonly --standalone -d api1.shah.vip

# Configure Nginx
sudo nano /etc/nginx/sites-available/shahcoin
# (Use config from DOMAIN_SETUP_SHAH_VIP.md)

# Enable and test
sudo ln -s /etc/nginx/sites-available/shahcoin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Evening - Test All Endpoints:**

```bash
# Test HTTPS
curl https://rpc1.shah.vip:26657/health
curl https://api1.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info

# Repeat for all endpoints
```

**✅ Success Criteria:**
- All subdomains resolve correctly
- SSL certificates valid (A+ grade)
- HTTPS endpoints accessible
- No certificate warnings
- Load balancing works (if configured)

---

## 📅 **WEEK 3: Genesis Ceremony**

### Day 8-9: Validator Key Distribution

**Secure Key Transfer:**

```bash
# For each validator, transfer encrypted key
scp ~/.shahd/keys_backup/validator1.key root@VPS1:/tmp/

# SSH into VPS
ssh root@VPS1

# Import key
shahd keys import validator1 /tmp/validator1.key --keyring-backend file
# Enter password when prompted

# Verify key imported
shahd keys list --keyring-backend file

# DELETE temp file
rm /tmp/validator1.key

# Repeat for all validators
```

**✅ Success Criteria:**
- All 4 validator keys imported on respective VPS
- Keys verified with correct addresses
- Temporary files deleted
- Backup keys still safe locally

### Day 10: Node ID Collection

**Collect from each VPS:**

```bash
# Get node ID
ssh root@VPS1 "shahd tendermint show-node-id"
# Save as: NODE1_ID

# Get node ID and format as peer
ssh root@VPS1 "echo \$(shahd tendermint show-node-id)@rpc1.shah.vip:26656"

# Repeat for all 4
```

**Create peers.txt:**
```
NODE1_ID@rpc1.shah.vip:26656
NODE2_ID@rpc2.shah.vip:26656  
NODE3_ID@rpc3.shah.vip:26656
NODE4_ID@rpc4.shah.vip:26656
```

### Day 11: Peer Configuration

**Update config.toml on each VPS:**

```bash
# Build peers string (exclude own node)
# For VPS1, use nodes 2,3,4 as persistent peers

ssh root@VPS1 << 'EOF'
  # Update config
  cd ~/.shahd/config
  
  # Set seeds (all nodes)
  sed -i 's/^seeds = .*/seeds = "NODE1@rpc1.shah.vip:26656,NODE2@rpc2.shah.vip:26656,NODE3@rpc3.shah.vip:26656,NODE4@rpc4.shah.vip:26656"/' config.toml
  
  # Set persistent peers (exclude self)
  sed -i 's/^persistent_peers = .*/persistent_peers = "NODE2@rpc2.shah.vip:26656,NODE3@rpc3.shah.vip:26656,NODE4@rpc4.shah.vip:26656"/' config.toml
  
  # Enable PEX
  sed -i 's/^pex = .*/pex = true/' config.toml
EOF

# Repeat for all validators (adjust peers for each)
```

### Day 12: Genesis Distribution

**Distribute final genesis.json:**

```bash
# From your local machine
GENESIS_HASH=$(sha256sum ~/.shahd/config/genesis.json | awk '{print $1}')
echo "Expected hash: $GENESIS_HASH"

# Copy to each VPS
for vps in VPS1_IP VPS2_IP VPS3_IP VPS4_IP; do
  scp ~/.shahd/config/genesis.json root@$vps:~/.shahd/config/
done

# Verify hash on each VPS
ssh root@VPS1 "sha256sum ~/.shahd/config/genesis.json"
ssh root@VPS2 "sha256sum ~/.shahd/config/genesis.json"
ssh root@VPS3 "sha256sum ~/.shahd/config/genesis.json"
ssh root@VPS4 "sha256sum ~/.shahd/config/genesis.json"
# All should match $GENESIS_HASH!
```

**✅ Success Criteria:**
- Genesis hash identical on all servers
- All validators have correct peers
- All configs validated
- All services ready to start

### Day 13: Pre-Launch Testing

**Final Checks:**

```bash
# On each VPS, verify:

# 1. Binary version
shahd version

# 2. Genesis validation
shahd genesis validate-genesis ~/.shahd/config/genesis.json

# 3. Config check
cat ~/.shahd/config/config.toml | grep -E "seeds|persistent_peers"

# 4. Systemd service
sudo systemctl status shahd

# 5. Firewall
sudo ufw status | grep -E "26656|26657|1317|9090"

# 6. Disk space
df -h | grep -v tmpfs

# 7. Time sync (critical!)
timedatectl
# Must be synchronized!
```

**Set Genesis Time:**

```bash
# Choose launch time (e.g., tomorrow 12:00 UTC)
GENESIS_TIME="2025-11-07T12:00:00Z"

# Update on ALL servers
for vps in VPS1_IP VPS2_IP VPS3_IP VPS4_IP; do
  ssh root@$vps "jq '.genesis_time = \"$GENESIS_TIME\"' ~/.shahd/config/genesis.json > /tmp/g.json && mv /tmp/g.json ~/.shahd/config/genesis.json"
done

# Verify time set correctly
ssh root@VPS1 "jq -r '.genesis_time' ~/.shahd/config/genesis.json"
```

---

## 📅 **WEEK 4: LAUNCH! 🚀**

### Day 14: Mainnet Launch Day

**T-2 hours: Final Coordination**

```bash
# Join video call/Telegram with all validator operators
# Confirm everyone is ready
# Share contact info for emergencies
```

**T-1 hour: System Checks**

On each VPS:
```bash
# Stop any running processes
sudo systemctl stop shahd

# Clear any old data (if this is a restart)
shahd tendermint unsafe-reset-all --home ~/.shahd --keep-addr-book

# Verify genesis ONE MORE TIME
sha256sum ~/.shahd/config/genesis.json

# Check system resources
free -h
df -h
```

**T-30 minutes: Standby**

- All validators ready
- Terminals open
- Commands prepared
- Monitoring dashboards open

**T-0 (Genesis Time): LAUNCH!**

```bash
# VALIDATOR 1 starts first
ssh root@VPS1 "sudo systemctl start shahd"

# Check logs immediately
ssh root@VPS1 "sudo journalctl -u shahd -f"
# Look for: "Waiting for peers..."

# Wait 2 minutes, then VALIDATOR 2
ssh root@VPS2 "sudo systemctl start shahd"

# Wait 2 minutes, then VALIDATOR 3
ssh root@VPS3 "sudo systemctl start shahd"
# Chain should start after this (2/3 voting power)

# Wait 2 minutes, then VALIDATOR 4
ssh root@VPS4 "sudo systemctl start shahd"
```

**Expected Log Output:**
```
INFO Starting ABCI with Tendermint
INFO service start
INFO Starting multiAppConn service
INFO Starting baseWAL service
INFO Starting blockchain service
INFO Starting consensus service
INFO This node is a validator (priv_key available)
INFO Starting pprof server
INFO Executed block height=1
INFO Committed state height=1
INFO Executed block height=2
...
```

**T+15 minutes: Verify Launch**

```bash
# Check block height on all validators
curl https://rpc1.shah.vip:26657/status | jq .result.sync_info.latest_block_height
curl https://rpc2.shah.vip:26657/status | jq .result.sync_info.latest_block_height
curl https://rpc3.shah.vip:26657/status | jq .result.sync_info.latest_block_height
curl https://rpc4.shah.vip:26657/status | jq .result.sync_info.latest_block_height

# All should be same and increasing!

# Check validator set
curl https://api1.shah.vip:1317/cosmos/base/tendermint/v1beta1/validatorsets/latest | jq
# Should show 4 validators
```

**T+1 hour: Announce Launch**

```bash
# Post on social media
# Update website
# Send email to community
# Post in Cosmos Discord
```

---

## 📅 **WEEK 4-5: Post-Launch Stabilization**

### Day 15: Monitoring Setup

**Set up alerts:**
- Validator missed blocks
- Node offline
- High memory/disk usage
- Network issues

**Set up dashboards:**
- Grafana for metrics
- Block explorer
- Status page

### Day 16-17: Website Launch

**Deploy website at shah.vip:**

```bash
# Option 1: Static site (simple)
# - Upload HTML/CSS/JS to VPS
# - Configure Nginx to serve

# Option 2: Next.js/React (dynamic)
# - Deploy to Vercel/Netlify
# - Point shah.vip to deployment

# Option 3: WordPress (easy)
# - Install on VPS
# - Use shahcoin theme
```

**Website Content:**
- About SHAHCOIN
- How to get SHAH tokens
- Validator list
- Documentation links
- API endpoints
- Block explorer link
- Social media links

### Day 18: Block Explorer

**Deploy Big Dipper:**

```bash
# On explorer server
git clone https://github.com/forbole/big-dipper-2.0-cosmos
cd big-dipper-2.0-cosmos

# Configure .env
NEXT_PUBLIC_CHAIN_ID=shahcoin-1
NEXT_PUBLIC_RPC_WEBSOCKET=wss://rpc.shah.vip:26657/websocket
NEXT_PUBLIC_URL=https://api.shah.vip:1317

# Build and deploy
docker-compose up -d

# Point explorer.shah.vip to this server
```

### Day 19-20: Community Building

**Create channels:**
- [ ] Telegram group
- [ ] Discord server  
- [ ] Twitter account
- [ ] Reddit community
- [ ] GitHub Discussions

**First announcements:**
- Launch announcement
- How to become a validator
- How to get tokens
- Roadmap sharing

### Day 21: First Week Review

**Metrics to check:**
- [ ] Uptime: 99.9%+
- [ ] Missed blocks: <1%
- [ ] Peer count: 4+ on each validator
- [ ] Transaction count
- [ ] Active addresses
- [ ] Total value staked

---

## 📅 **MONTH 2: Growth Phase**

### Week 5: DEX Launch

**Create initial liquidity pools:**

```bash
# Create SHAH/SHAHUSD pool
shahd tx shahswap create-pool \
  1000000000000shahi \
  5000000000000shahusd \
  --from founder \
  --fees 100000shahi

# Create additional pairs as needed
```

**Marketing:**
- Announce DEX launch
- Trading competition
- Liquidity mining incentives

### Week 6: IBC Connections

**Connect to Cosmos Hub:**

```bash
# Create IBC channel
# Use Hermes relayer or IBC-Go relayer

# Test cross-chain transfers
# ATOM <-> SHAH swaps
```

### Week 7: Governance Proposals

**First governance proposals:**

1. **Parameter changes** (test governance)
2. **Community pool spend** (marketing budget)
3. **Validator set expansion** (if needed)

### Week 8: Partnerships

- List on CoinGecko
- List on CoinMarketCap
- Partner with Cosmos projects
- CEX listing discussions (if desired)

---

## 📅 **MONTH 3+: Ecosystem Growth**

### Ongoing Tasks

**Weekly:**
- Monitor validator performance
- Review security alerts
- Engage with community
- Process governance proposals

**Monthly:**
- Review and optimize costs
- Performance tuning
- Security audits
- Feature releases

**Quarterly:**
- Major upgrades
- Tokenomics review
- Partnership reviews
- Roadmap updates

---

## 🎯 **Critical Milestones**

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Build Complete | Day 1 | ✅ DONE |
| Local Testing | Day 2-3 | ⏳ Next |
| GitHub Push | Day 4 | 📅 Planned |
| VPS Setup | Day 5-6 | 📅 Planned |
| Domain Config | Day 7 | 📅 Planned |
| Genesis Ceremony | Day 8-13 | 📅 Planned |
| **MAINNET LAUNCH** | **Day 14** | 🚀 **TARGET** |
| Explorer Live | Day 18 | 📅 Planned |
| DEX Launch | Week 5 | 📅 Planned |
| IBC Connected | Week 6 | 📅 Planned |

---

## 📊 **Budget Timeline**

| Period | Item | Cost |
|--------|------|------|
| **Week 1** | Development (Complete) | $0 |
| **Week 2** | VPS (4 servers x $12/week) | ~$50 |
| **Week 2** | Domain (shah.vip annual) | ~$15 |
| **Week 3-4** | VPS (continued) | ~$100 |
| **Month 2** | VPS + Explorer + Website | ~$250 |
| **Month 3+** | Full infrastructure | ~$300-500/month |

**Total First Month**: ~$400-500

---

## 🚨 **Risk Management**

### Technical Risks

| Risk | Mitigation | Contingency |
|------|------------|-------------|
| Chain halt | Test thoroughly, have upgrade plan ready | Coordinate emergency patch |
| Validator offline | Monitoring + alerts, backup validators | Standby servers ready |
| Security breach | Regular audits, key management | Incident response plan |
| High gas fees | Fee estimation module, monitor | Adjust parameters via governance |

### Financial Risks

| Risk | Mitigation |
|------|------------|
| High VPS costs | Use Hetzner (cheaper), optimize resources |
| Domain renewal | Set auto-renew, calendar reminders |
| Bandwidth overages | Monitor usage, use CDN |

---

## ✅ **Launch Day Checklist**

### Pre-Launch (T-24 hours)
- [ ] All validators have identical genesis.json
- [ ] Genesis hash verified on all nodes
- [ ] Peers configured correctly
- [ ] SSL certificates valid
- [ ] Domain DNS propagated
- [ ] Monitoring dashboards ready
- [ ] Communication channels open
- [ ] Backup procedures tested
- [ ] Emergency contacts shared

### Launch (T-0)
- [ ] All validators on video call
- [ ] Time synchronized across all servers
- [ ] Launch sequence coordinated
- [ ] All validators start within 5 minutes
- [ ] First block produced
- [ ] All 4 validators signing
- [ ] No errors in logs
- [ ] Public RPC/API accessible

### Post-Launch (T+6 hours)
- [ ] Block production stable
- [ ] No validator missed blocks
- [ ] All endpoints healthy
- [ ] Explorer showing data
- [ ] Community notified
- [ ] Press release sent (if applicable)
- [ ] Social media updated
- [ ] GitHub release published

---

## 📞 **Support & Escalation**

### During Launch

**Telegram/Discord Validator Channel:**
- All 4 validators must be present
- Quick response time critical
- Share real-time status

**Emergency Contacts:**
- Validator 1: [Phone/Telegram]
- Validator 2: [Phone/Telegram]
- Validator 3: [Phone/Telegram]
- Validator 4: [Phone/Telegram]

### Issue Escalation

**Level 1**: Minor issue (one validator down)
- Try to resolve individually
- Share in group chat
- No immediate action needed

**Level 2**: Moderate issue (chain slow, high latency)
- All validators investigate
- Coordinate fixes
- May need restart

**Level 3**: Critical issue (chain halted)
- Emergency call
- Coordinated response
- Follow incident plan
- May need governance proposal

---

## 🎉 **Success Indicators**

### Week 1 Post-Launch
- ✅ 100% uptime
- ✅ 4/4 validators active
- ✅ >1000 blocks produced
- ✅ 0 security incidents
- ✅ All modules working

### Month 1 Post-Launch
- ✅ 99.9%+ uptime
- ✅ 100+ unique addresses
- ✅ DEX operational with liquidity
- ✅ First governance proposal passed
- ✅ IBC channels established

### Month 3 Post-Launch
- ✅ 10,000+ transactions
- ✅ $100K+ TVL in DEX
- ✅ 10+ active validators
- ✅ Listed on CoinGecko
- ✅ Active community (500+ members)

---

**YOU ARE HERE**: ✅ Day 1 - Build Complete

**NEXT STEP**: Day 2 - Local Testing & Genesis Configuration

Run:
```bash
./scripts/init_genesis.sh
```

---

📅 **Last Updated**: 2025-11-06  
🚀 **Launch Target**: 2025-11-20 (2 weeks from now)

