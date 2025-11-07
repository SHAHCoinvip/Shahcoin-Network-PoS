# 🖥️ VPS Requirements & Shopping Guide

Everything you need to know about buying and configuring VPS servers for SHAHCOIN.

---

## 🎯 **Quick Answer**

**What to buy:**
- **4 VPS servers**
- **8GB RAM, 4 CPU cores, 500GB SSD**
- **Ubuntu 22.04 LTS**
- **Static IP**

**When to buy:**
- **Day 5-6** of deployment (after local testing)

**Total cost:**
- **$130-200/month** (all 4 servers)

---

## 📋 **Detailed Specifications**

### Minimum Specs (Per Server)

```
CPU: 4 cores (2.0+ GHz)
RAM: 8GB
Storage: 500GB SSD
Network: 100Mbps unmetered
OS: Ubuntu 22.04 LTS
IPv4: 1 static IP (required)
IPv6: Optional
Location: Any (see geographic distribution below)
```

### Recommended Specs (Per Server)

```
CPU: 8 cores (2.5+ GHz) - AMD EPYC or Intel Xeon
RAM: 16GB
Storage: 1TB NVMe SSD
Network: 1Gbps unmetered
OS: Ubuntu 22.04 LTS
IPv4: 1 static IP
IPv6: Yes
Backups: Automated daily
Location: Different regions
```

### Why These Specs?

| Component | Why |
|-----------|-----|
| **4 cores** | Tendermint consensus + module processing |
| **8GB RAM** | Cosmos SDK + IBC + state caching |
| **500GB SSD** | State data grows ~1GB/month, need 1yr+ capacity |
| **Ubuntu 22.04** | Best supported, long-term support (LTS) |
| **Static IP** | Required for DNS configuration |

---

## 💰 **Provider Comparison**

### Option 1: Hetzner 🏆 **RECOMMENDED - Best Value**

**Plan**: CPX31
- **CPU**: 4 vCPU (AMD EPYC)
- **RAM**: 8GB
- **Storage**: 160GB SSD (+€10/month for 500GB volume)
- **Network**: 20TB traffic
- **Price**: €30.96/month (~$33)
- **Locations**: Germany, Finland, USA
- **Total for 4**: ~$132/month

**Pros:**
- ✅ Cheapest option
- ✅ Excellent performance
- ✅ Great uptime (99.9%+)
- ✅ Simple control panel

**Cons:**
- ⚠️ Europe-based company
- ⚠️ Fewer locations than others

**Sign up**: https://www.hetzner.com/cloud

### Option 2: DigitalOcean - Popular Choice

**Plan**: Basic Droplet (Regular)
- **CPU**: 4 vCPU
- **RAM**: 8GB
- **Storage**: 160GB SSD
- **Network**: 5TB transfer
- **Price**: $48/month
- **Locations**: 15+ worldwide
- **Total for 4**: ~$192/month

**Pros:**
- ✅ Easy to use
- ✅ Excellent documentation
- ✅ Great for beginners
- ✅ Many locations
- ✅ $200 free credit for new users

**Cons:**
- ⚠️ More expensive than Hetzner
- ⚠️ Storage costs extra

**Sign up**: https://www.digitalocean.com

### Option 3: Vultr - Good Performance

**Plan**: High Performance
- **CPU**: 4 vCPU (AMD EPYC)
- **RAM**: 8GB
- **Storage**: 256GB NVMe
- **Network**: 4TB bandwidth
- **Price**: $48/month
- **Locations**: 25+ worldwide
- **Total for 4**: ~$192/month

**Pros:**
- ✅ Fast NVMe storage
- ✅ Many locations
- ✅ Good performance
- ✅ Hourly billing

**Cons:**
- ⚠️ Support can be slow
- ⚠️ Same price as DigitalOcean

**Sign up**: https://www.vultr.com

### Option 4: Linode (Akamai) - Enterprise Grade

**Plan**: Dedicated 8GB
- **CPU**: 4 cores (dedicated)
- **RAM**: 8GB
- **Storage**: 160GB SSD
- **Network**: 5TB transfer
- **Price**: $60/month
- **Locations**: 11 worldwide
- **Total for 4**: ~$240/month

**Pros:**
- ✅ Dedicated CPU (not shared)
- ✅ Very reliable
- ✅ Excellent support
- ✅ Owned by Akamai (trusted)

**Cons:**
- ⚠️ Most expensive option
- ⚠️ Fewer locations

**Sign up**: https://www.linode.com

### Option 5: Contabo - Budget Option

**Plan**: Cloud VPS M
- **CPU**: 6 vCores
- **RAM**: 16GB
- **Storage**: 400GB SSD
- **Network**: 32TB traffic
- **Price**: €15.99/month (~$17)
- **Locations**: Germany, USA, Singapore
- **Total for 4**: ~$68/month

**Pros:**
- ✅ Cheapest option available
- ✅ Good specs for price
- ✅ Lots of storage

**Cons:**
- ⚠️ Shared CPU (can be slow)
- ⚠️ Support is basic
- ⚠️ Not recommended for validators (performance)

**Sign up**: https://contabo.com

---

## 🌍 **Geographic Distribution**

**Recommended setup for global coverage:**

| Validator | Location | Why |
|-----------|----------|-----|
| **Validator 1** | **USA East** (New York) | Americas coverage, low latency to US users |
| **Validator 2** | **Europe** (Germany) | European users, GDPR compliant |
| **Validator 3** | **Asia** (Singapore/Tokyo) | Asian markets, 24/7 coverage |
| **Validator 4** | **USA West** (San Francisco) | West coast USA, backup for Americas |

**Benefits:**
- ⚡ Low latency worldwide
- 🛡️ Geographic redundancy
- 🌍 24/7 timezone coverage
- ⚖️ Regulatory distribution
- 🔄 High availability

---

## 🛒 **How to Order VPS**

### Step-by-Step (Using Hetzner as example)

1. **Go to**: https://www.hetzner.com/cloud
2. **Click**: "Create Project"
3. **Name**: "SHAHCOIN"
4. **Add Server**:
   - Location: Nuremberg (Germany)
   - Image: Ubuntu 22.04
   - Type: CPX31 (4 vCPU, 8GB RAM)
   - Volume: +500GB SSD (€10/month extra)
   - Name: shahcoin-val1
   - SSH Key: Upload your public key OR set password
   - Click "Create & Buy Now"
5. **Repeat** 3 more times for other validators (different locations if available)

**You'll receive:**
```
Server created successfully!
  Name: shahcoin-val1
  IP: 64.225.12.34
  Password: Abc123xyz (if no SSH key)
  SSH: ssh root@64.225.12.34
```

**Save this info!**

---

## 🔐 **SSH Key Setup** (Recommended)

Before ordering, create SSH keys:

```bash
# On your local machine
ssh-keygen -t ed25519 -C "shahcoin-validator"
# Save to: ~/.ssh/shahcoin_validator

# View public key
cat ~/.ssh/shahcoin_validator.pub
# Copy this when ordering VPS
```

**Benefits:**
- More secure than passwords
- Easier automated deployment
- Can't be brute-forced

---

## ✅ **VPS Setup Checklist**

### Before Ordering
- [ ] Decided on provider
- [ ] Calculated budget (~$150/month)
- [ ] Created SSH key pair (recommended)
- [ ] Have payment method ready

### While Ordering
- [ ] Selected Ubuntu 22.04 LTS
- [ ] Chosen 8GB RAM + 4 CPU minimum
- [ ] Added 500GB SSD storage
- [ ] Selected different geographic locations
- [ ] Uploaded SSH public key OR set strong password
- [ ] Noted down server names

### After Ordering (Within 5 minutes)
- [ ] Received IP addresses
- [ ] Tested SSH connection to each server
- [ ] Noted down login credentials securely
- [ ] Verified server specs
- [ ] Checked network connectivity

### Verification Script

```bash
# Test connection to all servers
for ip in VPS1_IP VPS2_IP VPS3_IP VPS4_IP; do
  echo "Testing $ip..."
  ssh -o ConnectTimeout=5 root@$ip "echo 'Connected successfully' && uname -a"
done
```

---

## 📊 **VPS Information Template**

Save this template and fill it out when you order:

```yaml
SHAHCOIN VPS Servers
====================

Validator 1:
  Provider: Hetzner
  Plan: CPX31
  Location: Nuremberg, Germany
  IP Address: 64.225.12.34
  SSH User: root
  SSH Password: [SAVE IN PASSWORD MANAGER]
  SSH Key: ~/.ssh/shahcoin_validator
  Cost: €30.96/month
  Ordered: 2025-11-07
  Access: ssh root@64.225.12.34

Validator 2:
  Provider: DigitalOcean
  Plan: Basic 8GB
  Location: New York, USA
  IP Address: 167.99.45.67
  SSH User: root
  SSH Password: [SAVE IN PASSWORD MANAGER]
  SSH Key: ~/.ssh/shahcoin_validator
  Cost: $48/month
  Ordered: 2025-11-07
  Access: ssh root@167.99.45.67

Validator 3:
  Provider: Vultr
  Plan: High Performance
  Location: Singapore
  IP Address: 178.128.78.90
  SSH User: root
  SSH Password: [SAVE IN PASSWORD MANAGER]
  SSH Key: ~/.ssh/shahcoin_validator
  Cost: $48/month
  Ordered: 2025-11-07
  Access: ssh root@178.128.78.90

Validator 4:
  Provider: Linode
  Plan: Dedicated 8GB
  Location: San Francisco, USA
  IP Address: 142.93.11.22
  SSH User: root
  SSH Password: [SAVE IN PASSWORD MANAGER]
  SSH Key: ~/.ssh/shahcoin_validator
  Cost: $60/month
  Ordered: 2025-11-07
  Access: ssh root@142.93.11.22

Total Monthly Cost: ~$186 USD
Total Annual Cost: ~$2,232 USD

Provider Support:
- Hetzner: support@hetzner.com
- DigitalOcean: support ticket system
- Vultr: support ticket system
- Linode: support@linode.com
```

---

## 🔧 **First Connection to VPS**

After ordering, immediately test:

```bash
# Try connecting
ssh root@YOUR_VPS_IP

# If using password, you'll be prompted
# If using SSH key:
ssh -i ~/.ssh/shahcoin_validator root@YOUR_VPS_IP

# Once connected, you should see:
root@shahcoin-val1:~#

# Check specs
cat /etc/os-release  # Should show Ubuntu 22.04
free -h              # Should show ~8GB RAM
df -h                # Should show ~500GB storage
nproc                # Should show 4 cores

# Exit
exit
```

---

## 💡 **Cost Optimization Tips**

### Save Money:

1. **Use Hetzner**: Cheapest reliable option (~50% savings)

2. **Annual billing**: Some providers offer 10-15% discount

3. **Reserved instances**: AWS/GCP offer 30-50% off for 1-year commit

4. **Start with 2 validators**: Scale to 4 later
   - Still functional (2/3 = 67% quorum)
   - Half the cost initially
   - Add validators as revenue grows

5. **Use block storage**: Cheaper than high-storage instances
   - Base instance: 4CPU/8GB/160GB ($30)
   - Add block storage: 500GB ($10)
   - Total: $40 vs $60 for high-storage instance

6. **Spot/Preemptible instances**: NOT recommended for validators
   - Can be terminated anytime
   - Only use for non-critical nodes

### Free Credits:

- **DigitalOcean**: $200 credit for new users (via referrals)
- **Vultr**: $100 credit (limited time offers)
- **Linode**: $100 credit for new users
- **Google Cloud**: $300 credit (90 days)

**Use these for initial testing!**

---

## 🚨 **Common Mistakes to Avoid**

### ❌ Don't:
- Order servers too small (will crash under load)
- Use Windows servers (compatibility issues)
- Skip backups (risk data loss)
- Use shared CPU VPS for validators (performance issues)
- Put all validators in one location (single point of failure)
- Use the same provider for all (provider outage risk)

### ✅ Do:
- Order slightly over-spec'd (room to grow)
- Use different providers (redundancy)
- Enable automated backups
- Set up monitoring from day 1
- Use SSH keys instead of passwords
- Document everything

---

## 📞 **Provider Support Comparison**

| Provider | Support Quality | Response Time | Documentation |
|----------|----------------|---------------|---------------|
| **Hetzner** | Good | 6-24 hours | Good |
| **DigitalOcean** | Excellent | 1-6 hours | Excellent |
| **Vultr** | Good | 6-12 hours | Good |
| **Linode** | Excellent | 1-4 hours | Excellent |
| **Contabo** | Basic | 24-48 hours | Basic |

---

## 🎯 **Recommended Configuration**

**Best Value Setup** ($132/month):

```
All 4 validators: Hetzner CPX31
- Location 1: Nuremberg (Germany)
- Location 2: Helsinki (Finland)  
- Location 3: Ashburn (USA)
- Location 4: Falkenstein (Germany)
- Total: 4 x €30.96 = €123.84 (~$132/month)
```

**Balanced Setup** ($180/month):

```
Validator 1: Hetzner CPX31 (Germany) - $33
Validator 2: DigitalOcean Basic (NYC) - $48
Validator 3: Vultr HP (Singapore) - $48
Validator 4: Hetzner CPX31 (USA) - $33
Total: ~$162/month
```

**Premium Setup** ($240/month):

```
All 4: Linode Dedicated 8GB
- Different locations
- Dedicated CPU
- Best performance
- Enterprise support
```

---

## 📦 **What's Included**

Most providers include:

✅ **Included:**
- Operating system (Ubuntu 22.04)
- Static IPv4 address
- Bandwidth (usually 3-20TB/month)
- Basic DDoS protection
- Console access
- API access
- Monitoring dashboard

❌ **Extra Cost:**
- Backups: $1-10/month
- Snapshots: $0.05/GB/month
- Load balancer: $10-20/month
- Additional storage: $0.10/GB/month
- Additional IPs: $3-5/month each

---

## 🔍 **How to Test VPS Performance**

After ordering, benchmark your VPS:

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# CPU benchmark
sysbench cpu --cpu-max-prime=20000 run

# RAM benchmark
sysbench memory run

# Disk I/O benchmark
sysbench fileio --file-test-mode=rndrw prepare
sysbench fileio --file-test-mode=rndrw run
sysbench fileio --file-test-mode=rndrw cleanup

# Network benchmark
apt install iperf3
iperf3 -c speedtest.hetzner.com

# Expected results:
# CPU: 2000+ events/second
# Disk: 500+ MB/s read, 300+ MB/s write
# Network: 100+ Mbps
```

If performance is bad, contact provider or request different server.

---

## 📈 **Scaling Plan**

### Month 1-3: Initial Setup (4 validators)
- Cost: $150-200/month
- Sufficient for launch

### Month 4-6: Add Redundancy
- Add 1 backup validator: +$40/month
- Add dedicated RPC node: +$40/month
- Total: $230-280/month

### Month 7-12: Full Infrastructure
- 6 validators: $240/month
- 2 public RPC nodes: $80/month
- 1 API node: $40/month
- 1 Explorer server: $20/month
- 1 Website/CDN: $20/month
- **Total: ~$400/month**

### Year 2+: Enterprise Setup
- 10+ validators
- Multiple RPC endpoints
- Global CDN
- **Total: $800-1500/month**

---

## 🎓 **Learning Resources**

**Before ordering VPS:**
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials)
- [Hetzner Docs](https://docs.hetzner.com)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

**After ordering:**
- [Initial Server Setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04)
- [Secure VPS](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-22-04)

---

## ⏰ **When to Order**

### **Don't order yet if:**
- Haven't tested locally
- Haven't pushed to GitHub
- Not ready for $150-200/month commitment
- Just exploring/learning

### **Order NOW if:**
- ✅ Local testing complete
- ✅ Genesis validated
- ✅ Code on GitHub
- ✅ Ready to launch in 7-10 days
- ✅ Have budget allocated

---

## 📝 **Order Process** (Step-by-Step)

### Day 5 Morning: Research & Compare

1. Visit all provider websites
2. Check current pricing
3. Look for coupon codes
4. Compare locations available
5. Decide on provider(s)

### Day 5 Afternoon: Place Orders

1. Create account with chosen provider(s)
2. Add payment method
3. Order server 1 (test it first!)
4. Wait 2-5 minutes for provisioning
5. Test SSH connection
6. If good, order remaining 3 servers
7. Save all credentials securely

### Day 5 Evening: Initial Access

1. SSH into each server
2. Update system: `apt update && apt upgrade -y`
3. Install basics: `apt install git curl wget jq -y`
4. Create non-root user (optional): `adduser shahcoin`
5. Exit and wait for Day 6 deployment

---

## 💾 **Backup Strategy**

**VPS Provider Backups:**
- Enable automated snapshots: $5-10/month
- Frequency: Daily
- Retention: 7 days
- Recovery time: 5-15 minutes

**Manual Backups:**
```bash
# Daily backup script (runs on each VPS)
#!/bin/bash
tar -czf /backup/shahd-data-$(date +%Y%m%d).tar.gz ~/.shahd/data
# Keep last 7 days only
find /backup -mtime +7 -delete
```

**Off-Site Backups:**
- Use AWS S3, Backblaze B2, or similar
- Cost: ~$5/month for 100GB
- Critical for disaster recovery

---

## 🆘 **Troubleshooting VPS Issues**

### Can't SSH into VPS

**Solutions:**
```bash
# 1. Check IP is correct
ping YOUR_VPS_IP

# 2. Check SSH service
# (ask provider support to verify sshd is running)

# 3. Check firewall
# (provider firewall may block SSH)

# 4. Reset root password via provider control panel
```

### VPS Too Slow

**Solutions:**
1. Run benchmark (see above)
2. Check if CPU is shared or dedicated
3. Contact provider support
4. Request server migration to different hardware
5. Upgrade to better plan

### VPS Disk Full

**Solutions:**
```bash
# Check usage
df -h

# Find large files
du -h --max-depth=1 / | sort -hr | head -20

# Enable pruning in app.toml
# Clean old logs: journalctl --vacuum-time=7d
```

---

## 📞 **Need Help Choosing?**

**For your case (SHAHCOIN):**

**Best choice**: **Hetzner** (4x CPX31)
- **Total: ~$132/month**
- **Why**: Best performance per dollar
- **Setup**: 2 in Europe, 2 in USA

**Alternative**: **Mixed**
- 2x Hetzner ($66) + 2x DigitalOcean ($96)
- Total: ~$162/month
- Why: Spread risk across providers

**Budget tight?**: Start with **2 servers**
- 2x Hetzner = $66/month
- Still functional (2 validators can run chain)
- Add 2 more later

---

**🎯 Bottom Line:**

Wait until **Day 5** (after local testing works), then order:
- **4x VPS servers**
- **Hetzner CPX31** (best value)
- **Different locations**
- **Total: ~$132/month**

**You'll provide me this info on Day 6:**
```
VPS1: root@64.225.12.34 (password: XYZ)
VPS2: root@167.99.45.67 (password: ABC)
VPS3: root@178.128.78.90 (password: DEF)
VPS4: root@142.93.11.22 (password: GHI)
```

**Then I'll help you deploy to all 4 automatically!** 🚀

---

**Questions about VPS?** Ask before ordering!

