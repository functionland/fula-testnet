#!/bin/sh
set -e
set -x
user=ipfs

# First start with current persistent volume
[ -f $IPFS_PATH/version ] || {
    echo "No ipfs repo found in $IPFS_PATH. Initializing..."
    ipfs init
    ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
    ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
    ipfs config Datastore.StorageMax 5GB
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
    chown -R ipfs $IPFS_PATH
    echo "Removing all bootstrap nodes..."
    ipfs bootstrap rm --all
}

# Check for the swarm key
[ -f $IPFS_PATH/swarm.key ] || {
    echo "ERROR: No swarm.key found in IPFS..."
    exit 0
}

# Add the bootnode to peer with other nodes
ipfs bootstrap add /dns4/ipfs.testnet.fx.land/tcp/4001/ipfs/12D3KooWBNonCBdf689W94wbBhvm39LGeoP5FZDNNh8j8qwy5M3B

ipfs daemon --migrate=true --agent-version-suffix=docker
