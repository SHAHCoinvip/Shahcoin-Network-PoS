# 🌐 shah.vip Domain Configuration Guide

Complete DNS and domain setup for SHAHCOIN blockchain using **shah.vip** domain.

## 📋 DNS Records Configuration

### Required A Records

| Subdomain | Type | Value | TTL | Purpose |
|-----------|------|-------|-----|---------|
| @ | A | `YOUR_MAIN_IP` | 300 | Main website |
| rpc1 | A | `VPS1_IP` | 300 | Validator 1 RPC |
| rpc2 | A | `VPS2_IP` | 300 | Validator 2 RPC |
| rpc3 | A | `VPS3_IP` | 300 | Validator 3 RPC |
| rpc4 | A | `VPS4_IP` | 300 | Validator 4 RPC |
| api1 | A | `VPS1_IP` | 300 | Validator 1 API |
| api2 | A | `VPS2_IP` | 300 | Validator 2 API |
| api3 | A | `VPS3_IP` | 300 | Validator 3 API |
| api4 | A | `VPS4_IP` | 300 | Validator 4 API |

### Load Balanced Records (Cloudflare)

If using Cloudflare Load Balancing:

| Subdomain | Type | Value | Load Balance Pool |
|-----------|------|-------|-------------------|
| rpc | CNAME | rpc-pool | rpc1, rpc2, rpc3, rpc4 |
| api | CNAME | api-pool | api1, api2, api3, api4 |

### Optional Subdomains

| Subdomain | Type | Value | Purpose |
|-----------|------|-------|---------|
| explorer | A | `EXPLORER_IP` | Block explorer |
| docs | CNAME | `username.github.io` | Documentation (GitHub Pages) |
| www | CNAME | shah.vip | Redirect to main site |
| testnet-rpc | A | `TESTNET_IP` | Testnet RPC |
| testnet-api | A | `TESTNET_IP` | Testnet API |
| faucet | A | `FAUCET_IP` | Testnet faucet |
| status | A | `STATUS_IP` | Status page |

---

## 🔧 Setup Instructions

### Option 1: Cloudflare (Recommended)

**Why Cloudflare?**
- Free SSL certificates
- DDoS protection
- Load balancing available
- Great UI
- Fast global CDN

**Steps:**

1. **Transfer domain to Cloudflare** (or update nameservers):
   - Go to https://dash.cloudflare.com
   - Click "Add a Site"
   - Enter `shah.vip`
   - Choose Free plan (or Pro for load balancing)
   - Update nameservers at your registrar to:
     ```
     ns1.cloudflare.com
     ns2.cloudflare.com
     ```

2. **Add DNS Records**:
   - DNS → Add record → Type: A
   - Name: `rpc1`, Value: `YOUR_VPS1_IP`, Proxy: ❌ (DNS only)
   - Repeat for all subdomains above
   - **Important**: Keep "Proxy status" OFF (gray cloud) for RPC/API endpoints

3. **Configure SSL**:
   - SSL/TLS → Overview → Full (strict)
   - Edge Certificates → Always Use HTTPS: ON
   - Minimum TLS Version: 1.2

4. **Set Up Load Balancing** (Optional - $5/month):
   - Traffic → Load Balancing → Create Load Balancer
   - Name: `rpc-pool`
   - Add monitors:
     - Type: HTTPS
     - Port: 26657
     - Path: /health
   - Add origins (VPS1-4)
   - Attach to `rpc.shah.vip`

5. **Configure Rate Limiting** (Pro plan):
   - Security → WAF → Rate limiting
   - Rule: Max 100 requests/minute per IP
   - Apply to `/api/*` and `/rpc/*`

6. **Enable Firewall Rules**:
   - Security → WAF → Create firewall rule
   - Block bad bots
   - Challenge suspicious traffic
   - Allow known good bots

### Option 2: Route53 (AWS)

If your VPS is on AWS:

```bash
# Create hosted zone
aws route53 create-hosted-zone --name shah.vip

# Add A records
aws route53 change-resource-record-sets --hosted-zone-id YOUR_ZONE_ID --change-batch '
{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "rpc1.shah.vip",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "YOUR_VPS1_IP"}]
    }
  }]
}'

# Set up health checks
aws route53 create-health-check --health-check-config \
  IPAddress=YOUR_VPS1_IP,Port=26657,Type=TCP

# Configure failover routing
# Use weighted routing policy with health checks
```

### Option 3: Manual DNS (Any Registrar)

1. Log into your domain registrar
2. Find DNS Management / DNS Records section
3. Add A records manually from table above
4. Set TTL to 300 seconds (5 minutes)
5. Save changes
6. Wait 5-15 minutes for propagation

**Verify DNS propagation:**
```bash
# Check if DNS is propagated
dig rpc1.shah.vip +short
# Should return your VPS1_IP

# Check all subdomains
for sub in rpc1 rpc2 rpc3 rpc4 api1 api2 api3 api4; do
  echo "$sub.shah.vip: $(dig +short $sub.shah.vip)"
done
```

---

## 🔒 SSL Certificate Setup

### Using Let's Encrypt (Free)

**On each VPS:**

```bash
# Install Certbot
sudo apt install certbot -y

# Get certificate for RPC
sudo certbot certonly --standalone -d rpc1.shah.vip
# (Answer prompts, provide email)

# Get certificate for API
sudo certbot certonly --standalone -d api1.shah.vip

# Verify certificates
sudo certbot certificates

# Test auto-renewal
sudo certbot renew --dry-run
```

**Certificates location:**
- Certificate: `/etc/letsencrypt/live/rpc1.shah.vip/fullchain.pem`
- Private Key: `/etc/letsencrypt/live/rpc1.shah.vip/privkey.pem`

### Using Cloudflare SSL (Free)

If using Cloudflare proxy (orange cloud):

1. SSL/TLS → Overview → Full (strict)
2. Edge Certificates → Always Use HTTPS: ON
3. Automatic HTTPS Rewrites: ON
4. Minimum TLS Version: TLS 1.2

**On VPS, install Cloudflare Origin Certificate:**

1. SSL/TLS → Origin Server → Create Certificate
2. Choose: RSA, 2048-bit
3. Hostnames: `*.shah.vip, shah.vip`
4. Validity: 15 years
5. Copy certificate and private key
6. Save on server:
   ```bash
   sudo mkdir -p /etc/ssl/cloudflare
   sudo nano /etc/ssl/cloudflare/cert.pem  # Paste certificate
   sudo nano /etc/ssl/cloudflare/key.pem   # Paste private key
   sudo chmod 600 /etc/ssl/cloudflare/key.pem
   ```

---

## 🌍 CDN & Performance

### Cloudflare CDN

1. **Enable CDN** (automatic with orange cloud):
   - Caching → Configuration → Caching Level: Standard
   - Speed → Optimization → Auto Minify: ON (CSS, JS, HTML)
   - Speed → Optimization → Brotli: ON

2. **Cache Rules**:
   ```
   Page Rule for shah.vip/static/*:
   - Browser Cache TTL: 4 hours
   - Edge Cache TTL: 4 hours
   
   Page Rule for api*.shah.vip/*:
   - Cache Level: Bypass (API requests should not be cached)
   ```

3. **Performance Settings**:
   - Speed → Optimization → Early Hints: ON
   - Speed → Optimization → HTTP/2: ON
   - Speed → Optimization → HTTP/3 (QUIC): ON

---

## 🔧 Subdomain-Specific Configuration

### Main Site (shah.vip)

**Purpose**: Landing page, documentation, links

**Nginx Config:**
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name shah.vip www.shah.vip;
    
    ssl_certificate /etc/letsencrypt/live/shah.vip/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shah.vip/privkey.pem;
    
    root /var/www/shahcoin;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### RPC Endpoints (rpc1-4.shah.vip)

**Purpose**: Tendermint RPC for node communication

**Nginx Config:**
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name rpc1.shah.vip;
    
    ssl_certificate /etc/letsencrypt/live/rpc1.shah.vip/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rpc1.shah.vip/privkey.pem;
    
    # WebSocket support for RPC subscriptions
    location / {
        proxy_pass http://localhost:26657;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 600s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://localhost:26657/health;
        access_log off;
    }
}
```

### API Endpoints (api1-4.shah.vip)

**Purpose**: REST API for queries

**Nginx Config:**
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name api1.shah.vip;
    
    ssl_certificate /etc/letsencrypt/live/api1.shah.vip/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api1.shah.vip/privkey.pem;
    
    location / {
        proxy_pass http://localhost:1317;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # CORS headers for browser access
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
        
        if ($request_method = OPTIONS) {
            return 204;
        }
    }
}
```

### Explorer (explorer.shah.vip)

**Options:**
1. **Big Dipper** (Cosmos native)
2. **Ping.pub** (Lightweight)
3. **Mintscan** (Feature-rich)

**Deploy Big Dipper:**
```bash
# On explorer server
git clone https://github.com/forbole/big-dipper-2.0-cosmos
cd big-dipper-2.0-cosmos

# Configure
cp .env.example .env
# Edit .env with your RPC/API endpoints

# Build and deploy
docker-compose up -d
```

---

## 📈 Monitoring & Analytics

### Subdomain: status.shah.vip

Set up status page showing:
- Chain status (live/halted)
- Block height
- Active validators
- Network TPS
- API endpoint health

**Use**: https://github.com/upptime/upptime (GitHub Actions based, free)

### Subdomain: metrics.shah.vip

**Grafana Dashboard:**

```bash
# Install Grafana
sudo apt install grafana -y

# Configure reverse proxy
# Point metrics.shah.vip → localhost:3000

# Import Cosmos SDK dashboard
# https://grafana.com/grafana/dashboards/11036
```

---

## 🎯 Complete DNS Setup Example

**For Cloudflare:**

```
DNS Records for shah.vip
========================

Type    Name        Content              Proxy   TTL
----    ----        -------              -----   ---
A       @           45.79.XXX.XXX        ☁️ Yes  Auto   → Main website
A       rpc1        64.225.XXX.XXX       ⊗ No   300    → Validator 1
A       rpc2        167.99.XXX.XXX       ⊗ No   300    → Validator 2
A       rpc3        178.128.XXX.XXX      ⊗ No   300    → Validator 3
A       rpc4        142.93.XXX.XXX       ⊗ No   300    → Validator 4
A       api1        64.225.XXX.XXX       ⊗ No   300    → Validator 1
A       api2        167.99.XXX.XXX       ⊗ No   300    → Validator 2
A       api3        178.128.XXX.XXX      ⊗ No   300    → Validator 3
A       api4        142.93.XXX.XXX       ⊗ No   300    → Validator 4
CNAME   www         shah.vip             ☁️ Yes  Auto   → Redirect
CNAME   explorer    explorer-host.com    ☁️ Yes  Auto   → Explorer
CNAME   docs        shahcoin.github.io   ⊗ No   300    → GitHub Pages
A       status      45.79.XXX.XXX        ☁️ Yes  Auto   → Status page
TXT     @           "v=spf1 -all"        -      Auto   → Email security
```

**⚠️ Important:**
- RPC/API endpoints: **Proxy OFF** (gray cloud) - Direct connection needed
- Website/Explorer: **Proxy ON** (orange cloud) - DDoS protection + CDN
- TTL: 300 seconds (5 minutes) for easy updates during deployment

---

## 🔐 Security Settings (Cloudflare)

### 1. SSL/TLS Configuration

```
SSL/TLS → Overview
- Encryption mode: Full (strict)
- Minimum TLS Version: TLS 1.2
- Opportunistic Encryption: ON
- TLS 1.3: ON
```

### 2. Security Rules

```
Security → WAF
- Security Level: Medium
- Challenge Passage: 30 minutes
- Browser Integrity Check: ON
```

**Create Firewall Rule:**
```
Name: API Rate Limit
Expression: (http.host contains "api" and not ip.geoip.country in {"US" "CA" "GB" "DE" "FR"})
Action: Challenge
```

### 3. DDoS Protection

```
Security → DDoS
- HTTP DDoS Attack Protection: ON
- Advanced Security: ON (if on Pro plan)
```

### 4. Page Rules (Pro Plan)

```
Rule 1: Force HTTPS
URL: http://*shah.vip/*
Setting: Always Use HTTPS

Rule 2: Cache Explorer
URL: explorer.shah.vip/*
Settings:
  - Cache Level: Standard
  - Edge Cache TTL: 1 hour

Rule 3: Bypass Cache for API
URL: api*.shah.vip/*
Settings:
  - Cache Level: Bypass
```

---

## 📊 Health Monitoring

### Set Up Uptime Monitoring

**Cloudflare Health Checks** (Pro plan):

1. Traffic → Health Checks → Create
   - Name: RPC1 Health
   - Type: HTTPS
   - Path: /health
   - Host: rpc1.shah.vip
   - Port: 26657
   - Interval: 60 seconds

2. Repeat for all endpoints

**Alternative (Free): UptimeRobot**

1. Go to https://uptimerobot.com
2. Add monitors:
   - `https://rpc1.shah.vip:26657/health`
   - `https://rpc2.shah.vip:26657/health`
   - `https://api1.shah.vip:1317/cosmos/base/tendermint/v1beta1/blocks/latest`
   - etc.
3. Set alert contacts (email, Telegram, Slack)
4. Monitor interval: 5 minutes

---

## 🌍 Geographic Distribution

### Recommended VPS Locations

For global coverage, distribute validators:

| Validator | Location | Provider | Region |
|-----------|----------|----------|--------|
| Validator 1 | USA East | DigitalOcean NYC | Americas |
| Validator 2 | Europe | Hetzner Germany | Europe |
| Validator 3 | Asia | Vultr Tokyo | Asia |
| Validator 4 | USA West | Linode SF | Americas |

This ensures:
- Low latency worldwide
- Geographic redundancy
- Regulatory distribution
- 24/7 coverage across time zones

---

## 📧 Email Configuration (Optional)

Set up email for security alerts:

### MX Records

```
Type    Name    Priority    Value                   TTL
MX      @       10          mail.shah.vip          300
A       mail    -           YOUR_MAIL_SERVER_IP     300
TXT     @       -           "v=spf1 ip4:YOUR_IP -all"  300
```

### Email Addresses

- `security@shah.vip` - Security reports
- `validators@shah.vip` - Validator communications
- `support@shah.vip` - User support
- `noreply@shah.vip` - Automated emails

**Use**: Google Workspace, Zoho Mail, or self-hosted mail server

---

## 🚦 Traffic Management

### Expected Traffic

| Endpoint | Requests/sec | Bandwidth |
|----------|-------------|-----------|
| RPC | 10-100 | 1-10 MB/s |
| API | 100-1000 | 10-100 MB/s |
| Website | 1-10 | 0.1-1 MB/s |
| Explorer | 10-100 | 1-10 MB/s |

### CDN Configuration

**For static assets (website, docs):**

1. Enable Cloudflare CDN (automatic)
2. Configure caching:
   ```
   Page Rule for shah.vip/assets/*:
   - Cache Level: Cache Everything
   - Edge Cache TTL: 1 month
   - Browser Cache TTL: 1 month
   ```

3. Image optimization:
   - Speed → Optimization → Polish: Lossless
   - Speed → Optimization → Mirage: ON

---

## 🔍 Testing & Verification

### Test All Endpoints

```bash
# Test RPC endpoints
curl https://rpc1.shah.vip:26657/status
curl https://rpc2.shah.vip:26657/status
curl https://rpc3.shah.vip:26657/status
curl https://rpc4.shah.vip:26657/status

# Test API endpoints
curl https://api1.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info
curl https://api2.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info
curl https://api3.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info
curl https://api4.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info

# Test load balanced endpoints
curl https://rpc.shah.vip:26657/status
curl https://api.shah.vip:1317/cosmos/base/tendermint/v1beta1/node_info

# Test website
curl -I https://shah.vip
curl -I https://www.shah.vip

# Test SSL
curl -vI https://rpc1.shah.vip 2>&1 | grep -i "ssl\|tls"
```

### DNS Propagation Check

```bash
# Check from multiple locations
dig @8.8.8.8 rpc1.shah.vip        # Google DNS
dig @1.1.1.1 rpc1.shah.vip        # Cloudflare DNS
dig @208.67.222.222 rpc1.shah.vip # OpenDNS

# Online tools
# - https://dnschecker.org
# - https://www.whatsmydns.net
```

### SSL Certificate Check

```bash
# Check certificate expiry
echo | openssl s_client -servername rpc1.shah.vip -connect rpc1.shah.vip:443 2>/dev/null | openssl x509 -noout -dates

# Check SSL grade
# - https://www.ssllabs.com/ssltest/
```

---

## 📝 Domain Configuration Checklist

### Pre-Deployment
- [ ] Domain registered (shah.vip)
- [ ] Access to DNS management
- [ ] Cloudflare account created (recommended)
- [ ] VPS IPs allocated
- [ ] SSL strategy chosen

### DNS Setup
- [ ] Main A record (@) configured
- [ ] All RPC subdomains (rpc1-4) configured
- [ ] All API subdomains (api1-4) configured
- [ ] Load balanced records (rpc, api) configured
- [ ] Optional subdomains configured
- [ ] TTL set to 300 seconds
- [ ] DNS propagation verified

### SSL Configuration
- [ ] SSL certificates obtained for all subdomains
- [ ] Certificates auto-renew configured
- [ ] HTTPS forced on all endpoints
- [ ] TLS 1.2+ enforced
- [ ] SSL grade A or higher

### Security
- [ ] Firewall rules configured
- [ ] DDoS protection enabled
- [ ] Rate limiting configured
- [ ] WAF rules set up
- [ ] DNSSEC enabled (optional)

### Performance
- [ ] CDN enabled for static content
- [ ] Caching rules configured
- [ ] Compression enabled (gzip/brotli)
- [ ] HTTP/2 and HTTP/3 enabled
- [ ] Image optimization enabled

### Monitoring
- [ ] Uptime monitoring configured
- [ ] Health checks set up
- [ ] Alert notifications configured
- [ ] Analytics tracking added

### Testing
- [ ] All endpoints accessible
- [ ] SSL certificates valid
- [ ] Load balancing works
- [ ] Failover tested
- [ ] Performance benchmarked

---

## 🆘 Troubleshooting

### Issue: DNS not resolving

**Check:**
```bash
# Verify nameservers
dig NS shah.vip

# Check authoritative nameservers
dig +trace shah.vip
```

**Solution:**
- Wait 24-48 hours for full propagation
- Verify nameservers at registrar
- Clear local DNS cache: `sudo systemd-resolve --flush-caches`

### Issue: SSL certificate errors

**Check:**
```bash
# Test certificate
openssl s_client -connect rpc1.shah.vip:443 -servername rpc1.shah.vip
```

**Solution:**
- Regenerate certificate: `sudo certbot certonly --force-renew -d rpc1.shah.vip`
- Check certificate paths in Nginx config
- Reload Nginx: `sudo systemctl reload nginx`

### Issue: Endpoints not accessible

**Check:**
```bash
# Test from VPS
curl localhost:26657/status  # Should work

# Test from internet
curl https://rpc1.shah.vip:26657/status  # Should work
```

**Solution:**
- Check Nginx is running: `sudo systemctl status nginx`
- Check firewall: `sudo ufw status`
- Check Cloudflare proxy status
- Verify SSL certificate paths

---

## 📞 Support

Need help with domain setup?

- **DNS Issues**: Check your registrar's support docs
- **Cloudflare**: https://support.cloudflare.com
- **SSL**: https://letsencrypt.org/docs/
- **SHAHCOIN**: Open issue on GitHub

---

**Last Updated**: 2025-11-06
**Version**: 1.0.0

