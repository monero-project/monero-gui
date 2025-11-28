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
