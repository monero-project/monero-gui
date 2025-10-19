# I2P Integration Testing Guide

## Overview
This guide walks through testing the complete I2P integration in Monero GUI. The integration allows Monero transactions to be routed through I2P for enhanced privacy.

## Prerequisites

### Build Environment (Windows)
1. **Install MSYS2**: Download from https://www.msys2.org/
2. **Install Dependencies**:
```bash
pacman -Syu
pacman -S mingw-w64-x86_64-toolchain
pacman -S mingw-w64-x86_64-cmake
pacman -S mingw-w64-x86_64-boost
pacman -S mingw-w64-x86_64-qt5
pacman -S mingw-w64-x86_64-libsodium
pacman -S mingw-w64-x86_64-hidapi
pacman -S git make
```

3. **Clone Monero GUI** (if not already):
```bash
git clone --recursive https://github.com/monero-project/monero-gui.git
cd monero-gui
git checkout feature/i2p-binary-manager
```

## Build Instructions

### Option 1: Full Build
```bash
cd monero-gui
make release-win64
```

### Option 2: Quick Build (development)
```bash
cd monero-gui
mkdir build && cd build
cmake -G "MSYS Makefiles" -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
```

## Testing Checklist

### Phase 1: Basic Compilation
- [ ] Project compiles without errors
- [ ] No warnings related to I2PManager
- [ ] Binary runs and launches GUI

### Phase 2: I2P Manager Functionality

#### 2.1 Initial State
- [ ] Navigate to Settings → I2P
- [ ] Verify "Enable I2P" toggle is unchecked by default
- [ ] Verify status shows "Not installed"
- [ ] Verify "Download i2pd" button is visible

#### 2.2 Download i2pd
- [ ] Click "Download i2pd" button
- [ ] Verify download progress bar appears
- [ ] Verify download completes successfully
- [ ] **CRITICAL**: Check console/logs for "Hash verification passed"
- [ ] Verify status changes to "Installed, not running"
- [ ] Verify i2pd binary exists in: `~/.config/monero-gui/i2pd/`

**Hash Verification Test**:
- [ ] Manually corrupt the downloaded binary
- [ ] Try to start i2pd - should fail with hash error
- [ ] Re-download to get clean binary

#### 2.3 Start/Stop i2pd
- [ ] Click "Start i2pd" button
- [ ] Verify status changes to "Running"
- [ ] Check process manager for `i2pd` process
- [ ] Verify SAM bridge is listening: `netstat -ano | findstr 7656`
- [ ] Click "Stop i2pd" button
- [ ] Verify status changes to "Installed, not running"
- [ ] Verify i2pd process is terminated

#### 2.4 Connection Test
- [ ] Start i2pd
- [ ] Click "Test Connection" button
- [ ] Verify connection test succeeds
- [ ] Check console for SAM bridge response

### Phase 3: monerod Integration

#### 3.1 Daemon Without I2P
- [ ] Disable I2P toggle
- [ ] Start local monerod (Settings → Node → Start daemon)
- [ ] Verify daemon starts normally
- [ ] Check monerod logs - should NOT contain `--tx-proxy`
- [ ] Stop daemon

#### 3.2 Daemon With I2P
- [ ] Enable I2P toggle
- [ ] Start i2pd
- [ ] Wait for i2pd status to show "Running"
- [ ] Start local monerod
- [ ] **CRITICAL**: Check console for "I2P proxy enabled for monerod: 127.0.0.1:7656"
- [ ] Check monerod process args: `ps aux | grep monerod` (Linux) or Task Manager details (Windows)
- [ ] Verify `--tx-proxy 127.0.0.1:7656` is present
- [ ] Verify daemon syncs normally through I2P

#### 3.3 Auto-Restart on I2P Toggle
**Test 1: Stop I2P while daemon running**
- [ ] Start both i2pd and monerod with I2P enabled
- [ ] Stop i2pd
- [ ] Verify daemon automatically restarts WITHOUT `--tx-proxy`
- [ ] Check console for "Restarting daemon without I2P proxy"

**Test 2: Start I2P while daemon running**
- [ ] Start monerod WITHOUT I2P
- [ ] Enable I2P and start i2pd
- [ ] Verify daemon automatically restarts WITH `--tx-proxy`
- [ ] Check console for "Restarting daemon with I2P proxy enabled"

### Phase 4: Persistent Settings

#### 4.1 Auto-Start I2P
- [ ] Enable "Auto-start I2P on launch"
- [ ] Close Monero GUI
- [ ] Reopen Monero GUI
- [ ] Verify i2pd starts automatically
- [ ] Check console for "Auto-starting I2P on application launch"

#### 4.2 Settings Persistence
- [ ] Enable I2P, set custom I2P node address
- [ ] Close and reopen GUI
- [ ] Verify I2P remains enabled
- [ ] Verify custom I2P node address is saved

### Phase 5: Error Handling

#### 5.1 Download Failures
- [ ] Disconnect network
- [ ] Try to download i2pd
- [ ] Verify error popup appears
- [ ] Verify user-friendly error message

#### 5.2 Port Conflicts
- [ ] Start another application on port 7656
- [ ] Try to start i2pd
- [ ] Verify error message about port conflict

#### 5.3 Binary Corruption
- [ ] Manually delete/corrupt i2pd binary
- [ ] Try to start i2pd
- [ ] Verify error handling and re-download option

### Phase 6: Transaction Testing

#### 6.1 Transaction Through I2P
- [ ] Enable I2P and start i2pd
- [ ] Ensure daemon is running with I2P proxy
- [ ] Create a test transaction (testnet recommended)
- [ ] Monitor network traffic to verify I2P routing
- [ ] Verify transaction completes successfully

#### 6.2 Network Analysis
- [ ] Use Wireshark/tcpdump during I2P transaction
- [ ] Verify NO direct connections to Monero nodes
- [ ] Verify traffic goes through 127.0.0.1:7656
- [ ] Check i2pd logs for SAM bridge activity

## Expected Console Output

### Successful I2P Start
```
I2P configuration written to: /home/user/.config/monero-gui/i2pd/i2pd.conf
Starting i2pd process: /home/user/.config/monero-gui/i2pd/i2pd --conf=/home/user/.config/monero-gui/i2pd/i2pd.conf
I2P started successfully
```

### Successful Daemon Start with I2P
```
I2P proxy enabled for monerod: 127.0.0.1:7656
daemon started
```

### Auto-Restart on I2P Toggle
```
I2P started successfully
Restarting daemon with I2P proxy enabled
daemon start flags: [existing flags] --tx-proxy 127.0.0.1:7656
```

## Common Issues & Troubleshooting

### Issue: "Failed to start i2pd"
**Possible Causes**:
- Port 7656 already in use
- i2pd binary missing or corrupted
- Insufficient permissions

**Solutions**:
1. Check port: `netstat -ano | findstr 7656` (Windows) or `netstat -tuln | grep 7656` (Linux)
2. Re-download i2pd binary
3. Run as administrator (if needed)

### Issue: Daemon won't start with I2P
**Possible Causes**:
- i2pd not running
- SAM bridge not ready
- Firewall blocking localhost connections

**Solutions**:
1. Ensure i2pd is running before starting daemon
2. Wait 10-15 seconds after i2pd start for SAM bridge initialization
3. Check firewall rules for localhost:7656

### Issue: Transactions timeout
**Possible Causes**:
- I2P network congestion
- Insufficient I2P tunnels
- Node connectivity issues through I2P

**Solutions**:
1. Wait for I2P tunnel establishment (can take 2-5 minutes)
2. Increase transaction timeout settings
3. Verify i2pd logs show active tunnels

## Performance Benchmarks

### Expected Timings
- **i2pd download**: 2-10 seconds (3.8 MB)
- **i2pd startup**: 5-10 seconds
- **SAM bridge ready**: 5-15 seconds after startup
- **Daemon restart**: 10-20 seconds
- **Transaction through I2P**: 30-120 seconds (vs 10-30 seconds direct)

### Resource Usage
- **i2pd RAM**: 30-50 MB baseline, 100-150 MB active
- **i2pd CPU**: <5% idle, 10-30% active
- **Additional network overhead**: ~20-50% due to I2P routing

## Test Environments

### Recommended Test Order
1. **Windows 10/11 (MSYS2)**: Primary development platform
2. **Ubuntu 22.04/24.04**: Linux compatibility
3. **macOS 13+ (Intel)**: macOS compatibility
4. **macOS 14+ (ARM64)**: Apple Silicon verification

### Network Scenarios
- [ ] Testnet transactions (safest)
- [ ] Mainnet small transactions (after thorough testing)
- [ ] Behind corporate firewall
- [ ] Behind VPN
- [ ] With IPv6 enabled/disabled

## Reporting Issues

When reporting issues, include:
1. **Environment**: OS version, Qt version, build method
2. **Steps to reproduce**: Exact sequence of actions
3. **Console output**: Copy full error messages
4. **Logs**: `~/.config/monero-gui/logs/` and i2pd logs
5. **Network info**: Firewall settings, proxy configuration

## Success Criteria

This integration is ready for PR when:
- [ ] All Phase 1-5 tests pass on Windows
- [ ] All Phase 1-5 tests pass on Linux
- [ ] All Phase 1-5 tests pass on macOS
- [ ] Phase 6 transaction test succeeds on testnet
- [ ] No memory leaks detected (valgrind/sanitizers)
- [ ] Code review completed
- [ ] Documentation updated

## Next Steps After Testing

1. **Fix any discovered bugs**
2. **Performance optimization** if needed
3. **Update documentation** with test findings
4. **Prepare PR description** with testing evidence
5. **Submit PR** to monero-project/monero-gui

---

**Target**: Claim 140.167 XMR bounty for I2P integration
**Status**: Implementation complete, testing phase
**Last Updated**: December 2024
