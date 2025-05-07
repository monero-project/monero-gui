# I2P Integration in Monero GUI

This document outlines the integration of I2P (Invisible Internet Project) into the Monero GUI wallet, providing enhanced privacy for Monero transactions.

## Overview

I2P integration in Monero GUI allows users to route their Monero network traffic through the I2P network, providing an additional layer of privacy and anonymity. This integration includes both built-in I2P support (using the bundled i2pd daemon) and support for external I2P routers.

## Features

- Built-in I2P daemon (i2pd) support
- External I2P router support
- I2P status indicator in the left panel
- Configurable I2P tunnel settings
- Mixed mode support (allowing both I2P and clearnet connections)
- Automatic I2P daemon management

## Architecture

The I2P integration consists of several components:

1. **I2PDaemonManager**: A C++ class that manages the built-in i2pd process
2. **I2PSettingsDialog**: A QML dialog for configuring I2P settings
3. **MoneroSettings**: Extended with I2P-related properties and methods
4. **Wallet**: Extended with I2P-related methods for wallet connections
5. **LeftPanel**: Modified to display I2P connection status
6. **SettingsNode**: Extended with I2P network option

## Configuration Options

The following I2P settings can be configured:

- **Use I2P**: Enable/disable I2P routing for Monero traffic
- **Use built-in I2P**: Use the bundled i2pd daemon or an external I2P router
- **I2P address**: The address of the external I2P router (default: 127.0.0.1)
- **I2P port**: The SAM port of the external I2P router (default: 7656)
- **Inbound tunnels**: Number of inbound tunnels (default: 3)
- **Outbound tunnels**: Number of outbound tunnels (default: 3)
- **Mixed mode**: Allow both I2P and clearnet connections (default: false)

## Technical Implementation

### I2PDaemonManager

The `I2PDaemonManager` class manages the built-in i2pd daemon process. It handles:

- Starting and stopping the i2pd daemon
- Monitoring the daemon's status
- Configuring the daemon
- Providing status updates to the UI

### Wallet Integration

The Monero wallet library has been extended with I2P support through the following methods:

- `i2pEnabled()`: Check if I2P is enabled
- `setI2PEnabled(bool enabled)`: Enable or disable I2P
- `setI2POptions(const std::string &options)`: Set I2P options
- `getI2POptions() const`: Get current I2P options

### UI Components

- **I2P Status Indicator**: Displays the current I2P connection status in the left panel
- **I2P Settings Dialog**: Provides a user interface for configuring I2P settings
- **Settings Node Page**: Includes an option to enable I2P routing

## Building with I2P Support

I2P support is enabled by default in the Monero GUI build. The i2pd binary is automatically downloaded during the build process using the `DownloadI2PD.cmake` script.

To build with I2P support:

```bash
mkdir build && cd build
cmake ..
make
```

To disable I2P support:

```bash
mkdir build && cd build
cmake -DWITH_I2P=OFF ..
make
```

## Usage

1. Open the Monero GUI wallet
2. Go to Settings > Node
3. Click on "I2P Network"
4. Configure I2P settings in the dialog
5. Click "Save" to apply the settings

The I2P status indicator in the left panel will show the current connection status:
- Green: I2P is connected and working
- Red: I2P is enabled but not connected

## Troubleshooting

### Common Issues

1. **I2P daemon fails to start**
   - Check if port 7656 is already in use
   - Check the logs at `<data-dir>/i2p/i2pd.log`

2. **Cannot connect to I2P network**
   - Ensure your internet connection is stable
   - Try restarting the I2P daemon

3. **Slow connections through I2P**
   - This is normal as I2P routes traffic through multiple nodes
   - Try increasing the number of tunnels (but note this may reduce anonymity)

## Security Considerations

- I2P provides additional privacy but is not a perfect solution
- Always use I2P in conjunction with other privacy practices
- Be aware that using I2P may make connections slower
- The mixed mode option reduces privacy but increases reliability

## Future Improvements

- Support for more advanced I2P configurations
- Better integration with the Monero network for peer discovery
- Performance optimizations for I2P connections
- Support for Tor as an alternative routing option 