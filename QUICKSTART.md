# ⚡ SHAHCOIN - Quick Start Guide

**Get your blockchain running in 2 weeks!**

---

## 🎯 **Where You Are Now**

✅ **Day 1 - COMPLETE!**
- Blockchain built successfully
- Binary working: `build/shahd`
- All modules compiled
- Ready for next phase

---

## 📅 **Your 2-Week Roadmap**

### **WEEK 1: Local Setup** (No VPS/Domain needed yet!)

#### **Day 2-3: Configure & Test Locally**

```bash
# Run the complete initialization
cd shahcoin
./scripts/init_genesis.sh
```

This creates:
- ✅ Configured genesis.json
- ✅ 5 validator keys (founder + 4 validators)
- ✅ Genesis accounts with proper allocations
- ✅ Genesis transactions (gentx files)
- ✅ Final validated genesis

**Test locally:**
```bash
./build/shahd start
# Let it run for an hour, test transactions
```

**⚠️ CRITICAL**: Backup your keys!
```bash
cp -r ~/.shahd/keys_backup /secure/location/
```

#### **Day 4: Push to GitHub**

**What you need:**
- GitHub account (free)
- 10 minutes

**Steps:**
```bash
# 1. Create repo on GitHub (github.com/new)
#    Name: shahcoin

# 2. Push code
git add .
git commit -m "feat: SHAHCOIN Blockchain v1.0.0"
git remote add origin https://github.com/YOUR_USERNAME/shahcoin.git
git push -u origin main
```

**Why push now?**
- Validators need to download code
- Shows project is real
- Community can review

---

### **WEEK 2: Production Deployment**

#### **Day 5-6: Get VPS Servers** 🖥️

**🚨 NOW you need VPS info!**

**What to buy:**
- 4 VPS servers
- Ubuntu 22.04 LTS
- 8GB RAM, 4 CPU cores minimum
- 500GB SSD
- Static IP address

**Where to buy:**
| Provider | Cost/month | Link |
|----------|-----------|------|
| **DigitalOcean** | $48 | digitalocean.com |
| **Hetzner** | €30 (~$32) | hetzner.com |
| **Vultr** | $48 | vultr.com |
| **Linode** | $60 | linode.com |

**Recommended**: Hetzner CPX31 ($32/month) - Best value!

**Order 4 servers** in different locations:
1. USA East (New York)
2. Europe (Germany/Netherlands)
3. Asia (Singapore/Tokyo)
4. USA West (San Francisco)

**What info you'll get:**
```
Server 1:
  IP: 64.225.12.34
  SSH: root@64.225.12.34
  Password: Abc123xyz!
  
Server 2:
  IP: 167.99.45.67
  ...
```

**Save this info securely!**

#### **Day 7: Deploy to VPS**

**Now you use VPS info:**

```bash
# Edit deployment script with your VPS IPs
nano scripts/deploy_all_validators.sh

# Change these lines:
validator1_ip="64.225.12.34"   # ← Your VPS1 IP
validator2_ip="167.99.45.67"   # ← Your VPS2 IP
validator3_ip="178.128.78.90"  # ← Your VPS3 IP
validator4_ip="142.93.11.22"   # ← Your VPS4 IP

# Save and run
./scripts/deploy_all_validators.sh
```

This automatically:
- Connects to each VPS
- Installs Go
- Clones your GitHub repo
- Builds binary
- Sets up systemd service
- Configures firewall

**Manual steps:**
```bash
# Transfer keys to each VPS
scp ~/.shahd/keys_backup/validator1.key root@VPS1:/tmp/
ssh root@VPS1 "shahd keys import validator1 /tmp/validator1.key --keyring-backend file"
# Repeat for all 4 validators

# Copy genesis to all VPS
for vps in VPS1 VPS2 VPS3 VPS4; do
  scp ~/.shahd/config/genesis.json root@$vps:~/.shahd/config/
done
```

#### **Day 8: Configure Domain** 🌐

**🚨 NOW you need shah.vip access!**

**What you need:**
- Access to shah.vip DNS settings
- Domain registrar login OR Cloudflare account

**Quick Setup** (5-10 minutes):

**If using Cloudflare** (recommended):

1. Go to https://dash.cloudflare.com
2. Add site → Enter "shah.vip"
3. Add DNS records:
   ```
   Type: A, Name: rpc1, Value: VPS1_IP
   Type: A, Name: rpc2, Value: VPS2_IP
   Type: A, Name: rpc3, Value: VPS3_IP
   Type: A, Name: rpc4, Value: VPS4_IP
   Type: A, Name: api1, Value: VPS1_IP
   Type: A, Name: api2, Value: VPS2_IP
   Type: A, Name: api3, Value: VPS3_IP
   Type: A, Name: api4, Value: VPS4_IP
   ```
4. Save
5. Update nameservers at your registrar to Cloudflare's

**If using your current registrar:**

1. Log into registrar (GoDaddy, Namecheap, etc.)
2. Find "DNS Management" or "DNS Records"
3. Add the same A records as above
4. Save

**Wait 10-30 minutes for DNS to propagate**

**Verify:**
```bash
dig rpc1.shah.vip +short
# Should show your VPS1_IP
```

#### **Day 9-12: SSL & Final Config**

**Get SSL certificates** (free):

```bash
# On each VPS
ssh root@VPS1
sudo certbot certonly --standalone -d rpc1.shah.vip -d api1.shah.vip
# Repeat for all VPS
```

**Configure Nginx** (copy from [DOMAIN_SETUP_SHAH_VIP.md](docs/DOMAIN_SETUP_SHAH_VIP.md))

**Set genesis time:**
```bash
# Pick a launch time (e.g., Day 14 at 12:00 UTC)
# This gives you 2 days buffer for any issues
```

#### **Day 13: Pre-Launch Testing**

**Final checklist:**
- [ ] Genesis hash identical on all 4 VPS
- [ ] Peers configured correctly
- [ ] SSL working on all subdomains
- [ ] Monitoring set up
- [ ] All validators in group chat
- [ ] Launch time coordinated

---

### **WEEK 3: LAUNCH! 🚀**

#### **Day 14: Mainnet Launch**

**Timeline:**
```
T-2 hours: All validators ready, video call
T-1 hour:  Final systems check
T-30 min:  Standby mode
T-0:       START SEQUENCE
  +0:00    Validator 1 starts
  +2:00    Validator 2 starts
  +4:00    Validator 3 starts (chain should start!)
  +6:00    Validator 4 starts
T+15 min:  Verify all producing blocks
T+1 hour:  Public announcement
```

**Commands:**
```bash
# Each validator runs:
sudo systemctl start shahd

# Monitor:
sudo journalctl -u shahd -f
```

**Success = Blocks being produced!**

---

## 📝 **When You Need What**

### ❌ **NOT Needed Now:**
- VPS servers
- Domain configuration
- SSL certificates
- Monitoring tools
- Community channels

### ✅ **Needed Day 2-3** (Tomorrow!):
- Your local computer
- 2-3 hours of time
- Secure password for keys

### 📅 **Needed Day 4**:
- GitHub account (free)
- 10 minutes

### 💰 **Needed Day 5-6**:
- **VPS Info**:
  - 4 server IPs
  - SSH credentials
  - Cost: ~$130-200/month
  
### 🌐 **Needed Day 7-8**:
- **shah.vip Access**:
  - Domain registrar login
  - DNS management access
  - OR Cloudflare account (free)

---

## 💰 **Cost Breakdown**

| Item | When Needed | Cost |
|------|-------------|------|
| Development | ✅ Done | $0 |
| Local Testing | Day 2-3 | $0 |
| GitHub | Day 4 | $0 |
| **4x VPS Servers** | **Day 5** | **$130-200/month** |
| **Domain (shah.vip)** | **Day 7** | **~$15/year** |
| SSL Certificates | Day 9 | $0 (Let's Encrypt) |
| **Total First Month** | - | **~$150-220** |

---

## 🎯 **What to Do RIGHT NOW**

### **TODAY** (Day 1 - Complete!):
✅ You've built the blockchain
✅ Binary is ready
✅ Modules are working

### **TOMORROW** (Day 2):

**Step 1: Configure Genesis** (5 minutes)
```bash
./scripts/init_genesis.sh
```

**Step 2: Backup Keys** (CRITICAL!)
```bash
cp -r ~/.shahd/keys_backup ~/Desktop/SHAHCOIN_KEYS_BACKUP_$(date +%Y%m%d)
# Also copy to USB drive
```

**Step 3: Test Locally** (1 hour)
```bash
./build/shahd start
# Let it run, watch for errors
# Test some transactions
# Press Ctrl+C when satisfied
```

### **DAY AFTER** (Day 3):

Continue testing, familiarize yourself with commands

### **IN 2 DAYS** (Day 4):

```bash
# Push to GitHub
./scripts/prepare_github.sh
# Follow the instructions
```

### **IN 3-4 DAYS** (Day 5-6):

**Order VPS servers** - See providers list above

### **IN 5-6 DAYS** (Day 7-8):

**Configure shah.vip domain** - See DNS setup above

### **IN 12 DAYS** (Day 13):

**Final pre-launch checks**

### **IN 13 DAYS** (Day 14):

**🚀 MAINNET LAUNCH!**

---

## 📞 **Questions at Each Stage**

### **Day 2-3 Questions:**
- "How do I back up my keys safely?"
- "What if genesis validation fails?"
- "How do I test the modules?"

→ Check [DEPLOYMENT.md](docs/DEPLOYMENT.md) Section 2

### **Day 4 Questions:**
- "How do I create a GitHub repository?"
- "What should I include in the README?"
- "Should it be public or private?"

→ Read GITHUB_PUSH_INSTRUCTIONS.txt

### **Day 5-6 Questions:**
- "Which VPS provider should I use?"
- "What specs do I need?"
- "How many servers?"

→ Check [DEPLOYMENT.md](docs/DEPLOYMENT.md) Section 4
→ See VPS comparison table above

### **Day 7-8 Questions:**
- "How do I configure DNS for shah.vip?"
- "Do I need Cloudflare?"
- "What SSL certificates do I need?"

→ Read [DOMAIN_SETUP_SHAH_VIP.md](docs/DOMAIN_SETUP_SHAH_VIP.md)

### **Day 14 Questions:**
- "When do we start the validators?"
- "What if the chain doesn't start?"
- "How do I know if it's working?"

→ Check [DEPLOYMENT_TIMELINE.md](docs/DEPLOYMENT_TIMELINE.md) Launch Day section

---

## 🎓 **Learning Resources**

While you wait for Day 2:

**Read these:**
1. [Cosmos SDK Intro](https://tutorials.cosmos.network)
2. [Running a Validator](https://hub.cosmos.network/validators/overview.html)
3. [Tendermint Consensus](https://docs.tendermint.com/master/introduction/)

**Watch these:**
1. [Cosmos SDK Tutorial](https://www.youtube.com/c/CosmosSDK)
2. [Running a Cosmos Validator](https://www.youtube.com/watch?v=1KR4GGO9iQg)

---

## ✅ **Simple Checklist**

Print this and check off as you go:

```
Week 1:
[ ] Day 1: Build complete ✅
[ ] Day 2: Run init_genesis.sh, backup keys
[ ] Day 3: Test locally for 1+ hour
[ ] Day 4: Push to GitHub

Week 2:
[ ] Day 5: Order 4 VPS servers
[ ] Day 6: SSH into all VPS, verify access
[ ] Day 7: Configure shah.vip DNS
[ ] Day 8: Deploy to all VPS
[ ] Day 9: Get SSL certificates
[ ] Day 10: Collect node IDs
[ ] Day 11: Configure peers
[ ] Day 12: Distribute genesis
[ ] Day 13: Final testing

Week 3:
[ ] Day 14: 🚀 LAUNCH!
[ ] Day 15: Monitor 24/7
[ ] Day 16: Deploy website
[ ] Day 17: Deploy explorer
[ ] Day 18: Create DEX pools
[ ] Day 19: Announce publicly
[ ] Day 20: Community setup
[ ] Day 21: First week review
```

---

## 🚀 **TL;DR - What to Do When**

| When | What | Need |
|------|------|------|
| **NOW** | Rest! You did great today | Nothing |
| **Tomorrow** | Run `./scripts/init_genesis.sh` | Your computer |
| **Day 4** | Push to GitHub | GitHub account (free) |
| **Day 5** | **Order 4 VPS servers** | **Credit card** ($130-200/mo) |
| **Day 7** | **Configure shah.vip** | **Domain access** |
| **Day 8** | Deploy to VPS | VPS IPs + SSH access |
| **Day 14** | **LAUNCH!** | All validators coordinated |

---

## 🎉 **You're on Track!**

**Progress:**
```
[█████████░░░░░░░░░░] 45% Complete

Day 1 of 14 ✅
Next: Day 2 - Local Testing
```

**You have successfully completed** the hardest part (building the blockchain)!

The rest is:
- **70%** following instructions
- **20%** waiting for services to provision  
- **10%** troubleshooting minor issues

---

## 📞 **Get Help**

**Stuck on Day 2-4?**
→ Check [DEPLOYMENT.md](docs/DEPLOYMENT.md)

**Need VPS help?** (Day 5-6)
→ Each provider has excellent documentation
→ Most have one-click Ubuntu deployment

**Domain issues?** (Day 7-8)
→ [DOMAIN_SETUP_SHAH_VIP.md](docs/DOMAIN_SETUP_SHAH_VIP.md)

**Launch day problems?** (Day 14)
→ [DEPLOYMENT_TIMELINE.md](docs/DEPLOYMENT_TIMELINE.md)

---

## 🔥 **Pro Tips**

1. **Don't rush**: Each phase has dependencies
2. **Test everything**: Especially before launch
3. **Backup keys**: Multiple locations, encrypted
4. **Document issues**: You'll forget otherwise
5. **Join Cosmos Discord**: Great community support
6. **Use testnet first**: If you have time/budget

---

## 📊 **Success Metrics**

Track your progress:

### Day 7 Metrics:
- [ ] 4 VPS servers accessible
- [ ] Binary built on all servers
- [ ] genesis.json distributed
- [ ] DNS configured
- [ ] SSL certificates obtained

### Day 14 Metrics (Launch):
- [ ] All 4 validators online
- [ ] Blocks being produced
- [ ] 0 missed blocks
- [ ] API/RPC accessible publicly
- [ ] No critical errors

### Day 30 Metrics:
- [ ] 99.9% uptime
- [ ] 100+ transactions
- [ ] First governance proposal
- [ ] Community of 100+ members

---

**🎯 NEXT ACTION**: Tomorrow, run `./scripts/init_genesis.sh`

**📅 LAUNCH TARGET**: November 20, 2025 (2 weeks!)

**💪 You've got this!**

---

**Questions? Concerns? Blockers?**

Just let me know and I'll help you through each step! 🚀
