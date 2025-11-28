#!/bin/bash
set -e

echo "Starting I2P Monero Node container..."

# Initialize I2P configuration if not exists
if [ ! -f /data/i2p/i2pd.conf ]; then
    echo "Initializing I2P configuration..."
    cp /etc/i2p/i2pd.conf.template /data/i2p/i2pd.conf
    
    # Create tunnel configurations for Monero
    cat > /data/i2p/tunnels.d/monero-p2p.conf <<'TUNNEL_EOF'
[monero-p2p]
type = server
host = 127.0.0.1
port = 18089
keys = monero-p2p.dat
TUNNEL_EOF

    cat > /data/i2p/tunnels.d/monero-rpc.conf <<'TUNNEL_EOF'
[monero-rpc]
type = server
host = 127.0.0.1
port = 18081
keys = monero-rpc.dat
TUNNEL_EOF
fi

# Initialize monerod configuration if not exists
if [ ! -f /data/monero/monerod.conf ]; then
    echo "Initializing Monero daemon configuration..."
    cp /etc/monero/monerod.conf.template /data/monero/monerod.conf
    
    # Replace placeholders
    sed -i "s|{{DATA_DIR}}|/data/monero|g" /data/monero/monerod.conf
    sed -i "s|{{LOG_FILE}}|/data/monero/monerod.log|g" /data/monero/monerod.conf
    sed -i "s|{{PID_FILE}}|/data/monero/monerod.pid|g" /data/monero/monerod.conf
fi

# Start I2P router in background
echo "Starting I2P router..."
i2pd --datadir=/data/i2p --conf=/data/i2p/i2pd.conf --tunnelsdir=/data/i2p/tunnels.d &

# Wait for I2P to initialize
echo "Waiting for I2P router to initialize (10 seconds)..."
sleep 10

# Check if I2P is running
if ! pgrep -x i2pd > /dev/null; then
    echo "ERROR: I2P router failed to start"
    exit 1
fi

echo "I2P router is running"
echo "I2P web console: http://127.0.0.1:7070"
echo "I2P SOCKS proxy: 127.0.0.1:4447"

# Start Monero daemon with provided arguments
echo "Starting Monero daemon..."
exec "$@"
