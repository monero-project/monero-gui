# I2P Network Integration for Monero GUI

This PR adds support for routing Monero transactions through the I2P network, enhancing user privacy by masking their IP addresses and network activity patterns.

## Features

- **I2P Routing**: Enable transaction routing through the I2P network
- **Built-in I2P Daemon**: Optional bundled I2P daemon with automatic management 
- **User-friendly Settings**: Intuitive UI for configuring I2P options
- **Status Indicator**: Visual indication of I2P connection status
- **Advanced Configuration**: Customizable tunnel length, mixed mode options, and more

## Implementation Details

The implementation consists of several components:

1. **Core Wallet API Integration**:
   - Added `set_i2p_enabled`, `set_i2p_options`, `get_i2p_options`, and other methods to the wallet API
   - Implemented peer discovery through I2P network

2. **I2P Daemon Manager**:
   - Created `I2PDaemonManager` class to handle the bundled I2P daemon
   - Implemented configuration, starting/stopping, and status monitoring features

3. **GUI Components**:
   - Added `SettingsI2P.qml` for I2P configuration
   - Integrated I2P status indicator in StatusBar
   - Added I2P menu item in the LeftPanel
   - Created I2P icon and visual elements

4. **Settings Integration**:
   - Extended `MoneroSettings` to store I2P-related preferences
   - Added initialization of I2P settings on wallet open/creation

## Build Instructions

To enable I2P support, build with:

```
cmake -DWITH_I2P=ON ..
make
```

The build system will automatically handle downloading the bundled I2P daemon binaries for the target platform.

## Testing Performed

- Tested on Windows 10, Ubuntu 20.04, and macOS Catalina
- Verified successful transaction routing through I2P
- Verified peer discovery through I2P
- Tested daemon management functionality
- Verified settings persistence
- Tested with both built-in and external I2P routers

## Documentation

- Added detailed implementation summary
- Added installation guide for users
- Added usage examples
- Updated CHANGELOG.md

## Screenshots

(Screenshots will be attached in the PR comment)

## Related Issues

Closes #123 (Example: Replace with actual issue number if applicable)

## Security Considerations

- The I2P integration is disabled by default and must be explicitly enabled by the user
- A warning is displayed informing users about the potential risks
- Mixed mode (allowing both I2P and clearnet connections) is disabled by default 