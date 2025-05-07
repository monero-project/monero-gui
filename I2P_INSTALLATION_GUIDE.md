# I2P Installation and Usage Guide for Monero GUI Wallet

This guide provides detailed instructions on installing, configuring, and using the I2P (Invisible Internet Project) feature in the Monero GUI wallet. The I2P integration allows you to route your Monero transactions through the I2P anonymous network, enhancing privacy and security.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuring I2P](#configuring-i2p)
4. [Using I2P with Monero](#using-i2p-with-monero)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)
7. [Security Considerations](#security-considerations)
8. [Official I2P Downloads](#official-i2p-downloads)
9. [Using External I2P Daemon](#using-external-i2p-daemon)

## Prerequisites

Before using I2P with Monero, ensure you have:

- Monero GUI Wallet version with I2P support (v0.18.0.0 or later)
- Sufficient disk space (approx. 200MB for the I2P router)
- Internet connection
- Administrator privileges (for installation on some systems)

## Installation Methods

### Method 1: Built-in I2P Support

The Monero GUI wallet includes built-in I2P support. To use it:

1. Download and install the latest Monero GUI wallet from the [official website](https://www.getmonero.org/downloads/).
2. Launch the wallet and navigate to `Settings` > `Node` > `I2P`.
3. Enable I2P by toggling the `Enable I2P` switch.
4. The built-in I2P daemon will be automatically downloaded and installed.

### Method 2: Using an External I2P Router

If you prefer to use your own I2P router:

1. Download and install the I2P router from the [official I2P website](https://geti2p.net/en/download).
2. Configure the I2P router to enable SAM (Simple Anonymous Messaging) bridge:
   - Open the I2P router console (typically at `http://127.0.0.1:7070`)
   - Navigate to `Configure` > `Clients`
   - Ensure SAM is enabled and set to port 7656
3. In the Monero GUI wallet, navigate to `Settings` > `Node` > `I2P`.
4. Enable I2P and configure the options to use your external router:
   ```
   sam.host=127.0.0.1 sam.port=7656
   ```

## Configuring I2P

### Basic Configuration

In the Monero GUI wallet, the I2P settings page offers several options:

- **Enable I2P**: Toggle to enable/disable I2P routing for transactions.
- **I2P Status**: Displays the current status of the I2P connection.
- **I2P Options**: Configure connection parameters for the I2P router.

### I2P Options

The following options can be configured:

- `sam.host`: The hostname or IP address of the SAM bridge (default: `127.0.0.1`).
- `sam.port`: The port number of the SAM bridge (default: `7656`).
- `i2p.inbound.quantity`: Number of inbound tunnels (default: `3`).
- `i2p.outbound.quantity`: Number of outbound tunnels (default: `3`).
- `i2p.inbound.length`: Length of inbound tunnels (default: `3`).
- `i2p.outbound.length`: Length of outbound tunnels (default: `3`).

Example configuration:
```
sam.host=127.0.0.1 sam.port=7656 i2p.inbound.quantity=5 i2p.outbound.quantity=5
```

## Using I2P with Monero

After setting up I2P:

1. **Creating/Opening a Wallet**:
   - Open your wallet as usual. I2P will be automatically used if enabled.

2. **Sending Transactions**:
   - When sending transactions, they will be routed through the I2P network if enabled.
   - The transaction process might take longer due to the additional routing.

3. **Checking I2P Status**:
   - The status bar displays an I2P icon indicating connection status.
   - Green icon: I2P is active and working correctly.
   - Gray icon: I2P is enabled but not currently connected.

4. **I2P Address Format**:
   - I2P addresses for Monero nodes look like base32 addresses (e.g., `zzz.i2p`) or base64 addresses.

## Troubleshooting

### Common Issues

1. **I2P Connection Fails**:
   - Ensure the I2P router is running.
   - Check if SAM is enabled in your I2P router configuration.
   - Verify that the I2P options are correctly set.

2. **Slow Connections**:
   - This is normal for I2P, which prioritizes anonymity over speed.
   - Consider adjusting tunnel length for a balance between speed and privacy.

3. **I2P Icon Shows as Gray**:
   - The I2P daemon may still be starting. Allow a few minutes.
   - Try restarting the I2P daemon from the settings page.

### Logs

To view I2P logs:

- For built-in I2P: Check the log file at:
  - Windows: `%APPDATA%\monero-wallet-gui\i2pd\i2pd.log`
  - Linux: `~/.local/share/monero-wallet-gui/i2pd/i2pd.log`
  - macOS: `~/Library/Application Support/monero-wallet-gui/i2pd/i2pd.log`

- For external I2P router: Check the I2P router console for logs.

## Advanced Configuration

### Creating Multiple I2P Tunnels

For advanced users who need multiple I2P tunnels:

1. Edit the I2P configuration to include custom tunnels:
   ```
   [monero-tunnel]
   type=client
   destination=<destination-i2p-address>
   keys=monero-keys.dat
   ```

2. Restart the I2P router to apply changes.

### Using I2P with Remote Nodes

To connect to remote I2P nodes:

1. Find a Monero node with I2P support (e.g., `node.monero.i2p`).
2. In the Monero GUI wallet, go to `Settings` > `Node`.
3. Select `Remote node` and enter the I2P address.

## Security Considerations

When using I2P with Monero:

- **Isolation**: Ensure that your I2P router is isolated from other network activity to prevent correlation attacks.
- **Bandwidth**: I2P requires bandwidth. Consider this when using metered connections.
- **Persistence**: I2P connections can remain open after closing the wallet. Remember to stop the I2P daemon when not in use.
- **Tunnel Length**: Longer tunnels provide more privacy but slower performance. Choose based on your needs.
- **Mixed Mode**: Avoid using mixed mode (I2P and non-I2P connections simultaneously) if strong anonymity is required.

## Additional Resources

- [Monero Project Website](https://getmonero.org/)
- [I2P Project Website](https://geti2p.net/)
- [Monero I2P Documentation](https://getmonero.org/resources/user-guides/i2p-tor.html)

## Official I2P Downloads

For testing and development purposes, you can download the official I2P binaries from the following links:

### Windows
- [I2P Installer for Windows](https://geti2p.net/en/download/2.8.2/clearnet/https/files.i2p-projekt.de/i2pinstall_2.8.2_windows.exe/download)

### macOS and Linux (Java)
- [I2P Installer JAR file](https://geti2p.net/en/download/2.8.2/clearnet/https/files.i2p-projekt.de/i2pinstall_2.8.2.jar/download)

These official I2P binaries can be used for testing the I2P features in the Monero GUI wallet when not using the bundled I2P daemon.

## Using External I2P Daemon

The Monero GUI wallet can be configured to use either:

1. The bundled I2P daemon (recommended for most users)
2. An external I2P daemon that you install separately

To use an external I2P daemon:

1. Download and install I2P from the links above
2. In the Monero GUI wallet, go to Settings > Node
3. Enable I2P
4. Uncheck "Use built-in I2P daemon"
5. Configure the address and port of your external I2P daemon

---

*This guide is for informational purposes only. Always verify information with official sources.* 