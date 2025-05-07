# I2P Integration Testing Plan

This document outlines the testing plan for the I2P integration in Monero GUI.

## Test Environments

### Platforms
- Windows 10/11
- macOS (latest version)
- Linux (Ubuntu 20.04 LTS or later)

### Network Conditions
- Normal internet connection
- Slow/limited connection
- Behind restrictive firewall

## Test Cases

### 1. Installation and Setup

#### 1.1 Built-in I2P Daemon
- [ ] Verify i2pd binary is correctly bundled with the application
- [ ] Verify i2pd binary is correctly installed in the expected location
- [ ] Verify i2pd binary has correct permissions on all platforms

#### 1.2 Configuration
- [ ] Verify default I2P settings are correctly applied
- [ ] Verify custom I2P settings are correctly saved and loaded
- [ ] Verify I2P configuration files are correctly generated

### 2. Basic Functionality

#### 2.1 Enabling/Disabling I2P
- [ ] Verify I2P can be enabled through settings
- [ ] Verify I2P can be disabled through settings
- [ ] Verify settings are persisted across application restarts

#### 2.2 I2P Daemon Management
- [ ] Verify I2P daemon starts automatically when enabled
- [ ] Verify I2P daemon stops when disabled
- [ ] Verify I2P daemon restarts correctly when requested
- [ ] Verify I2P daemon status is correctly reported

#### 2.3 UI Elements
- [ ] Verify I2P status indicator shows correct status
- [ ] Verify I2P settings dialog displays correctly
- [ ] Verify all UI elements are properly translated

### 3. Network Connectivity

#### 3.1 Connection Establishment
- [ ] Verify wallet can connect to the Monero network through I2P
- [ ] Verify connection time is reasonable
- [ ] Verify reconnection works after network interruption

#### 3.2 Peer Discovery
- [ ] Verify I2P-specific peer discovery works
- [ ] Verify I2P peers are correctly identified and stored
- [ ] Verify connection to I2P peers is successful

#### 3.3 Mixed Mode
- [ ] Verify mixed mode (I2P + clearnet) works correctly
- [ ] Verify transactions can be sent/received in mixed mode
- [ ] Verify wallet can fall back to clearnet if I2P fails

### 4. Transaction Testing

#### 4.1 Sending Transactions
- [ ] Verify transactions can be sent through I2P
- [ ] Verify transaction confirmation time is reasonable
- [ ] Verify transaction fees are correctly calculated

#### 4.2 Receiving Transactions
- [ ] Verify transactions can be received through I2P
- [ ] Verify incoming transactions are correctly detected and processed

### 5. Error Handling

#### 5.1 Network Errors
- [ ] Verify appropriate error messages when I2P network is unreachable
- [ ] Verify recovery behavior when I2P network becomes available again
- [ ] Verify wallet handles I2P daemon crashes gracefully

#### 5.2 Configuration Errors
- [ ] Verify validation of I2P settings
- [ ] Verify appropriate error messages for invalid settings
- [ ] Verify recovery options from configuration errors

### 6. Performance Testing

#### 6.1 Resource Usage
- [ ] Measure CPU usage of I2P daemon under various conditions
- [ ] Measure memory usage of I2P daemon under various conditions
- [ ] Verify resource usage is within acceptable limits

#### 6.2 Network Performance
- [ ] Measure connection establishment time
- [ ] Measure transaction propagation time
- [ ] Compare performance between I2P and clearnet

### 7. Security Testing

#### 7.1 IP Leakage
- [ ] Verify no IP leakage occurs during normal operation
- [ ] Verify no IP leakage occurs during network transitions
- [ ] Verify no IP leakage occurs during error conditions

#### 7.2 Tunnels
- [ ] Verify tunnel configuration works correctly
- [ ] Verify tunnel quantity settings are correctly applied
- [ ] Verify tunnel length settings are correctly applied

## Test Procedure

### For Each Platform

1. Install the latest Monero GUI build with I2P support
2. Enable I2P in the settings
3. Verify I2P daemon starts correctly
4. Verify connection to the Monero network through I2P
5. Send and receive test transactions
6. Test error conditions (network interruption, etc.)
7. Test performance under various conditions

### Reporting

For each test case, record:
- Test environment details
- Steps performed
- Expected result
- Actual result
- Any issues encountered

## Success Criteria

The I2P integration will be considered successful if:

1. All test cases pass on all platforms
2. No critical security issues are found
3. Performance is within acceptable limits
4. User experience is smooth and intuitive

## Known Limitations

- I2P connections may be slower than clearnet connections
- Initial connection establishment may take longer
- Some restrictive networks may block I2P traffic 