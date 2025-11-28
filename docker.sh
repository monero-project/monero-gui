#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating docker/i2p-node directory structure...${NC}"

# Create directory
mkdir -p docker/i2p-node

# Create Dockerfile.linux
cat > docker/i2p-node/Dockerfile.linux << 'EOF'
FROM ubuntu:22.04

ARG MONERO_VERSION=0.18.4.4
ENV DEBIAN_FRONTEND=noninteractive

# Install I2P router and dependencies
RUN apt-get update && apt-get install -y \
    i2pd \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install Monero daemon (Linux x64)
WORKDIR /tmp
RUN wget -q https://downloads.getmonero.org/cli/monero-linux-x64-v${MONERO_VERSION}.tar.bz2 && \
    tar -xjf monero-linux-x64-v${MONERO_VERSION}.tar.bz2 && \
    cp monero-x86_64-linux-gnu-v${MONERO_VERSION}/monerod /usr/local/bin/ && \
    chmod +x /usr/local/bin/monerod && \
    rm -rf monero-* && \
    rm -f *.tar.bz2

# Create directories
RUN mkdir -p /data/monero /data/i2p/tunnels.d /etc/monero /etc/i2p

# Copy configuration templates
COPY monerod.conf.template /etc/monero/monerod.conf.template
COPY i2pd.conf.template /etc/i2p/i2pd.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
# 18081: Monero RPC
# 18089: Monero P2P
# 4447: I2P SOCKS proxy
# 7070: I2P web console
EXPOSE 18081 18089 4447 7070

# Volumes for persistent data
VOLUME ["/data/monero", "/data/i2p"]

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["monerod", "--config-file=/data/monero/monerod.conf"]
EOF

echo -e "${GREEN}✓ Created Dockerfile.linux${NC}"

# Create Dockerfile.windows
cat > docker/i2p-node/Dockerfile.windows << 'EOF'
FROM ubuntu:22.04

ARG MONERO_VERSION=0.18.4.4
ENV DEBIAN_FRONTEND=noninteractive

# Install I2P router and dependencies
RUN apt-get update && apt-get install -y \
    i2pd \
    wget \
    unzip \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install Monero daemon (Windows binary runs in Linux container via Docker Desktop)
WORKDIR /tmp
RUN wget -q https://downloads.getmonero.org/cli/monero-win-x64-v${MONERO_VERSION}.zip && \
    unzip -q monero-win-x64-v${MONERO_VERSION}.zip && \
    cp monero-x86_64-w64-mingw32-v${MONERO_VERSION}/monerod.exe /usr/local/bin/monerod && \
    chmod +x /usr/local/bin/monerod && \
    rm -rf monero-* && \
    rm -f *.zip

# Create directories
RUN mkdir -p /data/monero /data/i2p/tunnels.d /etc/monero /etc/i2p

# Copy configuration templates
COPY monerod.conf.template /etc/monero/monerod.conf.template
COPY i2pd.conf.template /etc/i2p/i2pd.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 18081 18089 4447 7070

VOLUME ["/data/monero", "/data/i2p"]

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["monerod", "--config-file=/data/monero/monerod.conf"]
EOF

echo -e "${GREEN}✓ Created Dockerfile.windows${NC}"

# Create Dockerfile.macos
cat > docker/i2p-node/Dockerfile.macos << 'EOF'
FROM ubuntu:22.04

ARG MONERO_VERSION=0.18.4.4
ENV DEBIAN_FRONTEND=noninteractive

# macOS Docker Desktop runs Linux containers, so same as Linux
# Install I2P router and dependencies
RUN apt-get update && apt-get install -y \
    i2pd \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install Monero daemon (Linux x64 for Docker Desktop)
WORKDIR /tmp
RUN wget -q https://downloads.getmonero.org/cli/monero-linux-x64-v${MONERO_VERSION}.tar.bz2 && \
    tar -xjf monero-linux-x64-v${MONERO_VERSION}.tar.bz2 && \
    cp monero-x86_64-linux-gnu-v${MONERO_VERSION}/monerod /usr/local/bin/ && \
    chmod +x /usr/local/bin/monerod && \
    rm -rf monero-* && \
    rm -f *.tar.bz2

# Create directories
RUN mkdir -p /data/monero /data/i2p/tunnels.d /etc/monero /etc/i2p

# Copy configuration templates
COPY monerod.conf.template /etc/monero/monerod.conf.template
COPY i2pd.conf.template /etc/i2p/i2pd.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 18081 18089 4447 7070

VOLUME ["/data/monero", "/data/i2p"]

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["monerod", "--config-file=/data/monero/monerod.conf"]
EOF

echo -e "${GREEN}✓ Created Dockerfile.macos${NC}"

# Create entrypoint.sh
cat > docker/i2p-node/entrypoint.sh << 'EOF'
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
EOF

chmod +x docker/i2p-node/entrypoint.sh
echo -e "${GREEN}✓ Created entrypoint.sh${NC}"

# Create monerod.conf.template
cat > docker/i2p-node/monerod.conf.template << 'EOF'
# Monero daemon configuration for I2P
data-dir={{DATA_DIR}}
log-file={{LOG_FILE}}
pidfile={{PID_FILE}}

# Network settings
p2p-bind-ip=127.0.0.1
p2p-bind-port=18089
rpc-bind-ip=0.0.0.0
rpc-bind-port=18081

# I2P proxy configuration
tx-proxy=i2p,127.0.0.1:4447

# Trusted I2P nodes (seed nodes)
add-peer=core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089
add-peer=dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089
add-peer=sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089
add-peer=yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089

# Other settings
non-interactive=true
confirm-external-bind=true
EOF

echo -e "${GREEN}✓ Created monerod.conf.template${NC}"

# Create i2pd.conf.template
cat > docker/i2p-node/i2pd.conf.template << 'EOF'
# I2P router configuration
[http]
enabled = true
address = 0.0.0.0
port = 7070

[socksproxy]
enabled = true
address = 0.0.0.0
port = 4447

[upnp]
enabled = false

[reseed]
verify = true
EOF

echo -e "${GREEN}✓ Created i2pd.conf.template${NC}"

# Create docker-compose.yml
cat > docker/i2p-node/docker-compose.yml << 'EOF'
version: '3.8'

services:
  monero-i2p-node:
    build:
      context: .
      dockerfile: Dockerfile.${PLATFORM:-linux}
    container_name: monero-i2p-node
    restart: unless-stopped
    ports:
      - "18081:18081"  # Monero RPC
      - "18089:18089"  # Monero P2P
      - "4447:4447"    # I2P SOCKS proxy
      - "7070:7070"    # I2P web console
    volumes:
      - monero-data:/data/monero
      - i2p-data:/data/i2p
    environment:
      - MONERO_NETWORK=mainnet
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:18081/json_rpc", "-d", "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"get_info\"}", "-H", "Content-Type: application/json"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

volumes:
  monero-data:
    driver: local
  i2p-data:
    driver: local
EOF

echo -e "${GREEN}✓ Created docker-compose.yml${NC}"

# Create README.md
cat > docker/i2p-node/README.md << 'EOF'
# Monero I2P Node Docker Images

Platform-specific Docker images for running Monero daemon with I2P support.

## Building

### Linux
docker build -t monero-i2p-node-linux -f Dockerfile.linux .### macOS (Docker Desktop)
docker build -t monero-i2p-node-macos -f Dockerfile.macos .### Windows (Docker Desktop)
docker build -t monero-i2p-node-windows -f Dockerfile.windows .## Running

### Using Docker Compose
# Linux
PLATFORM=linux docker-compose up -d

# macOS
PLATFORM=macos docker-compose up -d

# Windows
PLATFORM=windows docker-compose up -d### Using Docker directly
# Linux
docker run -d \
  --name monero-i2p-node \
  --restart=unless-stopped \
  -p 18081:18081 -p 18089:18089 -p 4447:4447 -p 7070:7070 \
  -v monero-data:/data/monero \
  -v i2p-data:/data/i2p \
  monero-i2p-node-linux## Volumes

- `monero-data`: Monero blockchain and wallet data
- `i2p-data`: I2P router configuration and tunnel keys

## Ports

- `18081`: Monero RPC
- `18089`: Monero P2P
- `4447`: I2P SOCKS proxy
- `7070`: I2P web console

## Accessing Services

- **Monero RPC**: `http://localhost:18081/json_rpc`
- **I2P Web Console**: `http://localhost:7070`
- **I2P SOCKS Proxy**: `127.0.0.1:4447`

## Notes

- The container automatically initializes I2P and Monero configurations on first run
- I2P tunnel keys are stored in `/data/i2p/tunnels.d/`
- Monero blockchain data is stored in `/data/monero/`
- The container waits 10 seconds for I2P to initialize before starting monerod
EOF

echo -e "${GREEN}✓ Created README.md${NC}"

echo -e "\n${BLUE}=== Setup Complete ===${NC}"
echo -e "${GREEN}All files created in docker/i2p-node/${NC}"
echo -e "\nDirectory structure:"
tree docker/i2p-node/ 2>/dev/null || find docker/i2p-node -type f | sort
