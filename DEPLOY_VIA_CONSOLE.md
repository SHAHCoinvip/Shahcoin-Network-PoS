# 🚀 SHAHCOIN VPS Deployment via Web Console

SSH password authentication is disabled on your VPS servers. **Use your hosting provider's web console instead!**

---

## ✅ **EASIEST METHOD: Web Console**

### Step 1: Access Each VPS Console

Go to your VPS hosting provider (Contabo/Hetzner/etc.) and open the **web console** or **VNC** for each server:

- **VPS1**: 46.224.22.188
- **VPS2**: 46.224.17.54
- **VPS3**: 91.98.44.79
- **VPS4**: 46.62.247.1

---

### Step 2: Run Deployment (Copy-Paste into Console)

**For each VPS**, open the web console and paste these commands:

```bash
# Update system
apt update && apt install -y build-essential git jq curl wget

# Install Go
cd /tmp
wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc

# Clone and build SHAHCOIN
cd ~
git clone https://github.com/SHAHCoinvip/Shahcoin-Network-PoS.git
cd Shahcoin-Network-PoS
go build -o /usr/local/bin/shahd ./cmd/shahd

# Verify
shahd version

# Initialize (CHANGE THE NAME FOR EACH VPS!)
# VPS1: shahd init Val1 --chain-id shahcoin-1
# VPS2: shahd init Val2 --chain-id shahcoin-1
# VPS3: shahd init Val3 --chain-id shahcoin-1
# VPS4: shahd init Val4 --chain-id shahcoin-1
shahd init Val1 --chain-id shahcoin-1

# Configure firewall
ufw allow 22/tcp
ufw allow 26656/tcp
ufw allow 26657/tcp
ufw allow 1317/tcp
ufw allow 9090/tcp
ufw --force enable

echo "✅ Setup complete!"
```

**Important**: Change `Val1` to `Val2`, `Val3`, `Val4` for each respective server!

---

### Step 3: Copy Genesis File

Your genesis file is at: `~/.shahd/config/genesis.json` (on your Windows WSL)

**Option A**: Use WinSCP or FileZilla to upload it to each VPS at `~/.shah/config/genesis.json`

**Option B**: Copy-paste the content via console:

```bash
# On each VPS, run:
cat > ~/.shah/config/genesis.json << 'EOF'
# PASTE YOUR GENESIS.JSON CONTENT HERE
EOF
```

---

### Step 4: Create Systemd Service

On each VPS:

```bash
cat > /etc/systemd/system/shahd.service << 'EOF'
[Unit]
Description=SHAHCOIN Node
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/shahd start --home /root/.shah
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable shahd
systemctl start shahd
```

---

### Step 5: Check Status

```bash
systemctl status shahd
journalctl -u shahd -f
```

---

## 📋 **Summary**

1. ✅ Binary created locally
2. ✅ Genesis file created
3. ✅ Code pushed to GitHub
4. ⏳ Deploy to VPS via web console (copy-paste commands above)
5. ⏳ Start nodes
6. ⏳ Configure DNS (shah.vip)
7. ⏳ Launch mainnet!

---

## 🆘 **Need Help?**

If you prefer SSH access, you need to either:
1. Add your SSH public key to each server
2. Enable password authentication in `/etc/ssh/sshd_config`

But the web console method above is **fastest and most reliable!**

