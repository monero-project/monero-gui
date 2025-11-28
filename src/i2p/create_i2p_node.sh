#!/bin/bash

# --- native monero node launcher ---

# hardcoded trusted peers list
PEERS=(
    "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p"
    "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p"
    "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p"
    "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p"
)

# build the arg string
PEER_ARGS=""
for peer in "${PEERS[@]}"; do
    PEER_ARGS+="--add-peer $peer "
done

# figure out where we are running from
# this assumes the script is in /bin/scripts/ and binary is in /bin/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_EXEC="$SCRIPT_DIR/../monerod"

# check if binary exists, handle windows/mac oddities
if [ ! -f "$MONERO_EXEC" ]; then
    if [ -f "$SCRIPT_DIR/../monerod.exe" ]; then
        MONERO_EXEC="$SCRIPT_DIR/../monerod.exe"
    elif [ -f "$SCRIPT_DIR/../../MacOS/monerod" ]; then
        # macos bundle path fix
        MONERO_EXEC="$SCRIPT_DIR/../../MacOS/monerod"
    else
        echo "STATUS:Error - cant find monerod binary at $MONERO_EXEC"
        exit 1
    fi
fi

# standard i2p port
I2P_PROXY="127.0.0.1:4447"

echo "STATUS:starting local monero i2p node..."

# running it. not detaching so we can kill it later from the gui.
"$MONERO_EXEC" --tx-proxy i2p,$I2P_PROXY \
               $PEER_ARGS \
               --no-igd \
               --hide-my-port \
               --non-interactive

# if we got here, something killed the process
EXIT_CODE=$?
echo "STATUS:monerod died with code $EXIT_CODE"
exit $EXIT_CODE
