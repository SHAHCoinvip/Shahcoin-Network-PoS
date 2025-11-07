# ⏰ When You Need What - Simple Timeline

Quick reference: When do you need VPS, GitHub, and shah.vip domain access?

---

## 📅 **TODAY (Day 1)** ✅ DONE
**Status**: Build complete!
**Need**: Nothing - You're all set!

---

## 📅 **TOMORROW (Day 2-3)**
**What**: Local testing & genesis configuration
**Need**:
- ✅ Your computer
- ✅ 2-3 hours
- ✅ Nothing else!

**No VPS, no GitHub, no domain needed!**

**Commands:**
```bash
./scripts/init_genesis.sh  # Runs everything
./build/shahd start        # Test locally
```

---

## 📅 **DAY 4** 
**What**: Push code to GitHub
**Need**: 
- 📤 **GitHub account** (free - create at github.com)
- ⏰ 10 minutes

**Why push to GitHub?**
- Validators need to download code
- Makes project public/professional
- Easy updates and collaboration

**Commands:**
```bash
./scripts/prepare_github.sh
# Then follow instructions
```

**No VPS or domain needed yet!**

---

## 📅 **DAY 5-6** 🖥️ **VPS TIME!**
**What**: Order and set up VPS servers
**Need**:
- 💳 **Credit card** (~$150-200/month budget)
- 🖥️ **4 VPS servers** with these specs:
  - Ubuntu 22.04 LTS
  - 8GB RAM
  - 4 CPU cores  
  - 500GB SSD
  - Static IP address
- 📝 **SSH credentials** for each server

**What I need from you on Day 6:**
```
Just paste this:

VPS1 IP: 64.225.12.34
VPS1 SSH: ssh root@64.225.12.34
VPS1 Password: YourPassword123

VPS2 IP: 167.99.45.67
VPS2 SSH: ssh root@167.99.45.67
VPS2 Password: YourPassword456

VPS3 IP: 178.128.78.90
VPS3 SSH: ssh root@178.128.78.90
VPS3 Password: YourPassword789

VPS4 IP: 142.93.11.22
VPS4 SSH: ssh root@142.93.11.22
VPS4 Password: YourPassword012
```

**Then I'll help you deploy automatically!**

**No domain needed yet!**

---

## 📅 **DAY 7-8** 🌐 **DOMAIN TIME!**
**What**: Configure shah.vip DNS
**Need**:
- 🌐 **Access to shah.vip domain**
- 🔧 **DNS management access** (at registrar or Cloudflare)
- ⏰ 15-30 minutes

**What I need from you on Day 7:**
```
Just answer these:

1. Where is shah.vip registered?
   □ GoDaddy
   □ Namecheap
   □ Google Domains
   □ Other: _____________

2. Do you have DNS access?
   □ Yes, I can add DNS records
   □ No, need help getting access
   
3. Want to use Cloudflare? (recommended)
   □ Yes (I'll guide you)
   □ No, use current registrar
```

**I'll provide exact DNS records to add:**
```
rpc1.shah.vip → Your VPS1 IP
rpc2.shah.vip → Your VPS2 IP
api1.shah.vip → Your VPS1 IP
... etc
```

**Still no VPS needed if you're not there yet!**

---

## 📅 **DAY 9-13**
**What**: Final configuration, testing, genesis distribution
**Need**:
- ✅ Everything from Days 5-8 (VPS + Domain)
- 📞 Communication with validators
- ⏰ Few hours for testing

**No new resources needed - just configuration!**

---

## 📅 **DAY 14** 🚀 **LAUNCH DAY!**
**What**: Start all validators, go live!
**Need**:
- ✅ All previous setup complete
- 📞 All 4 validators coordinated
- ⏰ 2-3 hours for launch sequence
- 🍿 Excitement!

**Everything comes together:**
- VPS servers start running
- Domain points to your blockchain
- Public can access RPC/API
- Blocks being produced!

---

## 📊 **Visual Timeline**

```
┌─────────────────────────────────────────────────────────────┐
│                    SHAHCOIN DEPLOYMENT                       │
└─────────────────────────────────────────────────────────────┘

Day 1  ████████ YOU ARE HERE ✅
       ↓ BUILD COMPLETE

Day 2-3 ░░░░░░░░ Local Testing
         Need: Nothing new

Day 4   ░░░░░░░░ GitHub Push  
         Need: 📤 GitHub account (free)
         ↓
         [Code now public/accessible]

Day 5-6 ░░░░░░░░ VPS Setup
         Need: 🖥️ 4 VPS servers ($150/mo)
               📝 SSH credentials
         ↓
         [Servers running in cloud]

Day 7-8 ░░░░░░░░ Domain Config
         Need: 🌐 shah.vip DNS access
               🔧 15 minutes
         ↓
         [rpc1.shah.vip → VPS1]
         [rpc2.shah.vip → VPS2]
         [api1.shah.vip → VPS1]
         [...etc]

Day 9-13 ░░░░░░░░ Testing & Genesis Prep
          Need: ✅ Everything above
          ↓
          [All validators have genesis]
          [Peers configured]
          [SSL certificates installed]

Day 14  ██████████ LAUNCH! 🚀
         Need: ✅ Everything ready
               🤝 Validators coordinated
         ↓
         [Blockchain LIVE!]
         [https://rpc.shah.vip works!]
         [https://api.shah.vip works!]
         [https://shah.vip website live!]
```

---

## 🎯 **Summary Table**

| Day | Task | Need VPS? | Need GitHub? | Need Domain? |
|-----|------|-----------|--------------|--------------|
| 1 | Build | ❌ | ❌ | ❌ |
| 2-3 | Local Test | ❌ | ❌ | ❌ |
| 4 | GitHub | ❌ | ✅ **YES** | ❌ |
| 5-6 | VPS Setup | ✅ **YES** | ✅ | ❌ |
| 7-8 | Domain | ✅ | ✅ | ✅ **YES** |
| 9-13 | Config | ✅ | ✅ | ✅ |
| 14 | Launch | ✅ | ✅ | ✅ |

---

## 💡 **Simple Answers to Your Questions**

### ❓ "When do I need VPS info?"

**Answer**: **Day 5-6** (4-5 days from now)

**What happens:**
- You've tested locally (Days 2-4)
- Code is on GitHub (Day 4)
- Ready to deploy to cloud
- I ask you for 4 VPS IPs + SSH credentials
- We deploy automatically using scripts

**Format I need:**
```
VPS1: root@64.225.12.34 password: XYZ
VPS2: root@167.99.45.67 password: ABC
VPS3: root@178.128.78.90 password: DEF
VPS4: root@142.93.11.22 password: GHI
```

---

### ❓ "When do I push to GitHub?"

**Answer**: **Day 4** (3 days from now)

**Why then:**
- After local testing is complete (Days 2-3)
- Before VPS deployment (Days 5-6)
- So validators can download code from GitHub

**What gets pushed:**
- All source code
- Genesis.json (final version)
- Documentation
- Deployment scripts

**What stays secret:**
- Your validator keys (NEVER push!)
- Passwords
- SSH credentials
- .env files

---

### ❓ "When do I use domain shah.vip?"

**Answer**: **Day 7-8** (6-7 days from now)

**Why then:**
- VPS servers are already running (Days 5-6)
- Need to point domain to VPS IPs
- So public can access: https://rpc.shah.vip

**What I need from you:**
- Access to add DNS records for shah.vip
- Either:
  - Login to your domain registrar (GoDaddy, Namecheap, etc.) OR
  - Transfer DNS to Cloudflare (recommended, free)

**What we'll add:**
```
rpc1.shah.vip  → VPS1 IP
rpc2.shah.vip  → VPS2 IP
rpc3.shah.vip  → VPS3 IP
rpc4.shah.vip  → VPS4 IP
api1.shah.vip  → VPS1 IP
... etc
```

**Simple 10-minute task with my guidance!**

---

## 🎯 **Action Items by Day**

### **TODAY (Day 1)**: ✅ DONE
- Celebrate! You built a blockchain!
- Read this documentation
- Plan next 2 weeks

### **TOMORROW (Day 2)**:
```bash
cd shahcoin
./scripts/init_genesis.sh
```
**Need**: Your computer only

### **Day 3**:
```bash
./build/shahd start  # Test for 1+ hour
```
**Need**: Your computer only

### **Day 4**:
```bash
./scripts/prepare_github.sh  # Push to GitHub
```
**Need**: GitHub account (create if don't have)

### **Day 5**: 
**Order 4 VPS servers** (see VPS_REQUIREMENTS.md)
**Need**: Credit card, ~$150-200/month budget

### **Day 6**:
**Give me VPS credentials, I'll deploy**
**Need**: VPS IPs + SSH passwords

### **Day 7**:
**Configure shah.vip DNS**
**Need**: Domain DNS access

### **Day 8-13**:
**SSL, testing, final prep**
**Need**: Everything above

### **Day 14**:
**🚀 LAUNCH!**

---

## 📞 **Contact Points**

You'll need to provide info at these times:

**Day 4**: GitHub username
→ "I created repo at github.com/MyUsername/shahcoin"

**Day 6**: VPS credentials  
→ "Here are my 4 server IPs and SSH info"

**Day 7**: Domain access
→ "I can add DNS records" or "Help me set up Cloudflare"

**Day 13**: Final coordination
→ "All validators ready, let's set launch time"

---

## 🎯 **The Simplest Possible Summary**

| What | When | Cost |
|------|------|------|
| GitHub account | Day 4 | Free |
| **4 VPS servers** | **Day 5** | **~$150/month** |
| **shah.vip DNS** | **Day 7** | **(Already own)** |
| SSL certificates | Day 9 | Free |
| Launch! | Day 14 | 🎉 |

---

**RIGHT NOW**: You don't need anything!

**NEXT**: Focus on Day 2 (tomorrow) - Local testing

**LATER**: I'll remind you when each resource is needed

---

**Questions?** Just ask when you get to each step! 🚀

