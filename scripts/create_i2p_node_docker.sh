#!/bin/bash

# config for the advanced
CONTAINER_NAME="monero-i2p-gui-node"
IMAGE="ghcr.io/sethforprivacy/simple-monerod:latest"

# trusted seeds list
PEERS=(
    "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p"
    "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p"
    "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p"
    "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p"
)

# build the args list
PEER_ARGS=""
for peer in "${PEERS[@]}"; do
    PEER_ARGS+="--add-peer $peer "
done

# make sure they actually have docker installed
if ! command -v docker &> /dev/null; then
    echo "STATUS:Error - docker command not found. install docker desktop."
    exit 1
fi

echo "STATUS:killing any old containers..."
docker rm -f $CONTAINER_NAME >/dev/null 2>&1

echo "STATUS:spinning up the docker node..."

# --net=host is needed so it can hit the local i2p router
# -v saves the blockchain to a volume so u dont resync every time
docker run --rm --name $CONTAINER_NAME \
    --net=host \
    -v monero-data:/home/monero/.bitmonero \
    $IMAGE \
    --tx-proxy i2p,127.0.0.1:4447 \
    $PEER_ARGS \
    --no-igd \
    --hide-my-port \
    --non-interactive

# if we get here it crashed or stopped
echo "STATUS:docker container stopped."
