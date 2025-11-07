#!/bin/bash
# SHAHCOIN GitHub Preparation Script
# Prepares the repository for pushing to GitHub

set -e

echo "📦 Preparing SHAHCOIN for GitHub"
echo "================================"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git repository already initialized"
fi
echo ""

# Create necessary documentation files
echo "📝 Creating documentation structure..."
mkdir -p docs
mkdir -p .github/workflows

# Check for sensitive files
echo "🔍 Checking for sensitive files..."
SENSITIVE_FOUND=0

if [ -d ".shahd" ]; then
    echo "  ⚠️  Found .shahd directory - will be ignored by .gitignore"
fi

if find . -name "*.key" -o -name "*_key.json" | grep -q .; then
    echo "  ⚠️  Found key files - ensure they're in .gitignore!"
    SENSITIVE_FOUND=1
fi

if find . -name ".env" | grep -q .; then
    echo "  ⚠️  Found .env files - ensure they're in .gitignore!"
    SENSITIVE_FOUND=1
fi

if [ $SENSITIVE_FOUND -eq 1 ]; then
    echo ""
    echo "❌ STOP! Sensitive files detected!"
    echo "   Review and add to .gitignore before proceeding."
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Show what will be committed
echo "📋 Files to be committed:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git add -n .
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if there are changes to commit
if git diff --cached --quiet 2>/dev/null; then
    echo "📦 Staging all files..."
    git add .
fi

echo "📊 Repository statistics:"
echo "  Total files: $(git ls-files 2>/dev/null | wc -l || echo 'N/A (not yet committed)')"
echo "  Go files: $(find . -name '*.go' | wc -l)"
echo "  Proto files: $(find proto -name '*.proto' 2>/dev/null | wc -l || echo 0)"
echo "  Scripts: $(find scripts -name '*.sh' 2>/dev/null | wc -l || echo 0)"
echo ""

# Prepare commit message
COMMIT_MSG="feat: Initial release - SHAHCOIN Blockchain v1.0.0

Features:
- Cosmos SDK v0.50.10 with CometBFT v0.38.12
- IBC-Go v8.5.1 for cross-chain transfers
- 6 custom native modules (shahswap, treasury, fees, airdrop, monitoring, shahbridge)
- Proof-of-Stake consensus with 100 validator slots
- Native AMM DEX with constant product formula
- Treasury module for SHAH/SHAHUSD stability
- USD-pegged transaction fees
- Merkle-based airdrop system
- On-chain monitoring and metrics
- IBC bridge helpers

Chain Parameters:
- Chain ID: shahcoin-1
- Base Denom: shahi (10^8 shahi = 1 SHAH)
- Total Supply: 63,000,000 SHAH
- Block Time: ~6 seconds
- Bech32 Prefix: shah

Deployment:
- Production-ready code
- Automated deployment scripts
- Comprehensive documentation
- Security audited modules"

echo "💬 Commit message prepared:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🎯 Next steps to push to GitHub:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   → Go to: https://github.com/new"
echo "   → Name: shahcoin"
echo "   → Description: SHAHCOIN - Next-Generation Blockchain with Native DeFi"
echo "   → Visibility: Public (for open-source) or Private"
echo "   → Do NOT initialize with README (we have one)"
echo ""
echo "2. Run these commands:"
echo ""
echo "   # Commit changes"
echo "   git commit -m \"$COMMIT_MSG\""
echo ""
echo "   # Set main branch"
echo "   git branch -M main"
echo ""
echo "   # Add remote (replace YOUR_USERNAME)"
echo "   git remote add origin https://github.com/YOUR_USERNAME/shahcoin.git"
echo ""
echo "   # Push to GitHub"
echo "   git push -u origin main"
echo ""
echo "   # Create version tag"
echo "   git tag -a v1.0.0 -m \"SHAHCOIN v1.0.0 - Genesis Release\""
echo "   git push origin v1.0.0"
echo ""
echo "3. After successful push:"
echo "   → Add repository description and topics"
echo "   → Enable GitHub Pages for documentation"
echo "   → Set up branch protection for main"
echo "   → Add collaborators if needed"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Save instructions to file
cat > GITHUB_PUSH_INSTRUCTIONS.txt << 'EOF'
SHAHCOIN - GitHub Push Instructions
====================================

STEP 1: Create GitHub Repository
---------------------------------
1. Go to: https://github.com/new
2. Repository name: shahcoin
3. Description: SHAHCOIN - Next-Generation Blockchain with Native DeFi
4. Visibility: Public (recommended for blockchain projects)
5. Do NOT check "Add README" or ".gitignore" (we already have them)
6. Click "Create repository"

STEP 2: Push to GitHub
-----------------------
Run these commands in your terminal:

```bash
# Stage all files
git add .

# Commit
git commit -m "feat: Initial release - SHAHCOIN Blockchain v1.0.0"

# Set main branch
git branch -M main

# Add remote (REPLACE 'YOUR_USERNAME' with your GitHub username!)
git remote add origin https://github.com/YOUR_USERNAME/shahcoin.git

# Push to GitHub
git push -u origin main

# Create and push release tag
git tag -a v1.0.0 -m "SHAHCOIN v1.0.0 - Genesis Release"
git push origin v1.0.0
```

STEP 3: Repository Configuration
---------------------------------
After successful push, configure your repository:

1. **Add Topics** (for discoverability):
   - Settings → Topics → Add: blockchain, cosmos-sdk, cosmos, defi, dex, ibc, proof-of-stake, tendermint

2. **Set Repository Description**:
   "Next-generation blockchain with native DeFi modules built on Cosmos SDK"

3. **Enable GitHub Pages** (optional):
   - Settings → Pages → Source: main branch → /docs folder
   - Your docs will be at: https://YOUR_USERNAME.github.io/shahcoin

4. **Branch Protection**:
   - Settings → Branches → Add rule for 'main'
   - ☑ Require pull request before merging
   - ☑ Require status checks to pass

5. **Add Repository Secrets** (for CI/CD):
   - Settings → Secrets → New repository secret
   - Add: DOCKER_USERNAME, DOCKER_PASSWORD (for Docker Hub)

STEP 4: Create Release
-----------------------
1. Go to: https://github.com/YOUR_USERNAME/shahcoin/releases/new
2. Choose tag: v1.0.0
3. Release title: "SHAHCOIN v1.0.0 - Genesis Release"
4. Description: Copy from release notes
5. Upload: build/shahd binary (optional)
6. Click "Publish release"

STEP 5: Share Your Project
---------------------------
- Tweet about your launch
- Post on Reddit (r/cosmosnetwork, r/cosmos)
- Share in Cosmos Discord
- Submit to https://cosmos.network/ecosystem

Done! 🎉
EOF

echo "📄 Saved detailed instructions to: GITHUB_PUSH_INSTRUCTIONS.txt"
echo ""
echo "✅ Repository is ready for GitHub!"
echo ""

