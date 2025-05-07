# I2P Usage Examples

This document provides examples of how to use the I2P functionality in the Monero GUI wallet.

## Enabling I2P in the GUI

1. Open Monero GUI wallet
2. Go to Settings → I2P
3. Check the "Enable I2P Routing" box
4. Configure the I2P router address (default: 127.0.0.1) and port (default: 7656)
5. Click "Apply"

## Using the Bundled I2P Router

1. Open Monero GUI wallet
2. Go to Settings → I2P
3. Check "Enable I2P Routing"
4. Check "Use Bundled I2P Router"
5. Click "Apply"
6. Wait for the I2P router to start and establish connections

## Command-line Examples

### Enabling I2P in monero-wallet-cli

```
set_i2p_enabled 1
set_i2p_options --tx-proxy i2p,127.0.0.1,7656
```

### Checking I2P Status

```
i2p_enabled
```

### Setting Custom I2P Router Address

```
set_i2p_options --tx-proxy i2p,192.168.1.100,7656
```

### Disabling I2P

```
set_i2p_enabled 0
```

## Programmatic Usage

### C++ Example

```cpp
#include "wallet/wallet2.h"

// Initialize wallet
tools::wallet2 wallet;

// Enable I2P
wallet.set_i2p_options("--tx-proxy i2p,127.0.0.1,7656");
wallet.set_i2p_enabled(true);

// Check if I2P is enabled
bool is_enabled = wallet.i2p_enabled();

// Get current I2P options
std::string options = wallet.get_i2p_options();

// Parse I2P options
std::string address;
int port;
bool success = wallet.parse_i2p_options(options, address, port);
```

### QML Example

```qml
// In your QML file
Button {
    text: "Enable I2P"
    onClicked: {
        // Enable I2P with default settings
        walletManager.setI2POptions(currentWallet, "--tx-proxy i2p,127.0.0.1,7656");
        walletManager.setI2PEnabled(currentWallet, true);
    }
}

Button {
    text: "Check I2P Status"
    onClicked: {
        var enabled = walletManager.isI2PEnabled(currentWallet);
        console.log("I2P Enabled:", enabled);
    }
}
```

## Troubleshooting

### I2P Connection Issues

If you experience issues connecting through I2P:

1. Verify that your I2P router is running:
   ```
   curl http://127.0.0.1:7070
   ```
   
2. Check I2P router logs for errors:
   - Windows: `%APPDATA%\i2pd\logs`
   - Linux: `~/.i2pd/logs`
   - macOS: `~/Library/Application Support/i2pd/logs`

3. Verify that the SAM port is enabled in your I2P router config:
   ```
   [sam]
   enabled = true
   address = 127.0.0.1
   port = 7656
   ```

### Common Issues

1. **"Failed to set I2P proxy" error**:
   - Make sure the I2P router is running
   - Verify the address and port are correct
   - Check firewall settings

2. **Slow connections through I2P**:
   - I2P connections are typically slower than clearnet connections
   - Increase the number of tunnels in the I2P router configuration
   - Ensure you have enough peers in your I2P address book

3. **"Failed to discover I2P peers" warning**:
   - This is normal when first starting with I2P
   - The peer discovery will gradually improve as you use the I2P network

## Security Considerations

1. **Mixing I2P and Clearnet Connections**:
   - Using both I2P and clearnet connections simultaneously may compromise anonymity
   - For maximum privacy, use I2P exclusively

2. **I2P Router Configuration**:
   - The default configuration is balanced for privacy and performance
   - Increasing tunnel length improves privacy but reduces performance
   - Decreasing tunnel length improves performance but reduces privacy

3. **Network Isolation**:
   - Use a dedicated I2P router for Monero if possible
   - Avoid using the same I2P router for other applications that could leak identifying information 