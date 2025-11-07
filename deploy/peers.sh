#!/bin/bash

# Shahcoin Peer Management Script

SHAHD_HOME="${SHAHD_HOME:-$HOME/.shah}"
CONFIG_FILE="$SHAHD_HOME/config/config.toml"

# Example peer list (replace with actual peers)
PERSISTENT_PEERS="
node1_id@rpc1.shah.vip:26656,
node2_id@rpc2.shah.vip:26656,
node3_id@rpc3.shah.vip:26656,
node4_id@rpc4.shah.vip:26656
"

# Seeds (optional)
SEEDS=""

echo "Updating peers configuration..."

# Update persistent peers
if [ ! -z "$PERSISTENT_PEERS" ]; then
    sed -i.bak "s/^persistent_peers = .*/persistent_peers = \"$PERSISTENT_PEERS\"/" "$CONFIG_FILE"
    echo "Updated persistent peers"
fi

# Update seeds
if [ ! -z "$SEEDS" ]; then
    sed -i.bak "s/^seeds = .*/seeds = \"$SEEDS\"/" "$CONFIG_FILE"
    echo "Updated seeds"
fi

echo "Peer configuration updated!"
echo ""
echo "To get your node ID for sharing with others:"
echo "  shahd comet show-node-id --home $SHAHD_HOME"
echo ""
echo "To check current peers:"
echo "  curl localhost:26657/net_info | jq '.result.peers'"

