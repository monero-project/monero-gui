# I2P Implementation for Monero GUI

This directory contains the implementation files for adding I2P support to the Monero GUI wallet.

## Overview

The I2P integration allows Monero users to route their transactions through the Invisible Internet Protocol (I2P) network, providing enhanced privacy and protection against network-level tracking.

## Implementation Files

- **set_i2p_enabled.cpp** - Implements the `wallet2::set_i2p_enabled` method
- **set_i2p_options.cpp** - Implements the `wallet2::set_i2p_options` method
- **parse_i2p_options.cpp** - Implements the `wallet2::parse_i2p_options` method
- **init_i2p_connection.cpp** - Implements the `wallet2::init_i2p_connection` method
- **discover_i2p_peers.cpp** - Implements the `wallet2::discover_i2p_peers` method
- **check_connection.cpp** - Modifies the `wallet2::check_connection` method to incorporate I2P peer discovery
- **apply_changes.ps1** - PowerShell script to apply the I2P changes to the wallet2.cpp file
- **verify_implementation.ps1** - PowerShell script to verify the I2P implementation in wallet2.cpp
- **i2p_testing_script.ps1** - Comprehensive testing script for the I2P implementation

## Integration Components

The I2P integration consists of several components:

1. **Core Wallet API** - New methods added to wallet2.cpp to support I2P network functionality
2. **I2P Daemon Manager** - A class for managing the built-in I2P daemon
3. **GUI Components** - QML files for I2P settings and status indicators
4. **Settings Layer** - Integration with the existing settings framework

## Usage

To apply the changes to the wallet2.cpp file:

```
.\apply_changes.ps1
```

To verify the implementation:

```
.\verify_implementation.ps1
```

To run the test suite:

```
.\i2p_testing_script.ps1
```

## Building

To build the Monero GUI with I2P support:

```
cmake -DWITH_I2P=ON ..
make
```

## Documentation

For more detailed information, please see:

- [I2P_IMPLEMENTATION_SUMMARY.md](../I2P_IMPLEMENTATION_SUMMARY.md) - Full implementation summary
- [I2P_INSTALLATION_GUIDE.md](../I2P_INSTALLATION_GUIDE.md) - Installation guide for users 