# P2Pool Dashboard Testing Plan

## Pre-Build Validation ✅

### Syntax Checks (Completed)
- ✅ P2PoolStats.qml - No errors
- ✅ Advanced.qml - No errors  
- ✅ Mining.qml - No errors
- ✅ P2PoolManager.h - No errors
- ✅ P2PoolManager.cpp - No errors

### Code Review Checklist

#### Backend (C++)
- ✅ `getStats()` method added to P2PoolManager.h
- ✅ `p2poolStats` signal declared with QVariantMap parameter
- ✅ Implementation reads from 4 stats files: pool, miner, stratum, network
- ✅ Proper file existence checks before reading
- ✅ JSON parsing with QJsonDocument
- ✅ Signal emission with aggregated stats

#### Frontend (QML)
- ✅ P2PoolStats.qml registered in qml.qrc
- ✅ Timer-based auto-refresh (3000ms)
- ✅ Four tabs implemented: Status, Peers, Workers, Bans
- ✅ Help buttons on each tab using FontAwesome.questionCircle
- ✅ Signal/slot connection to backend in Component.onCompleted
- ✅ Proper null-safety: `poolStats.property || 0`
- ✅ formatUptime() helper function for time display

#### Integration
- ✅ P2PoolStats view added to Advanced.qml states
- ✅ "View P2Pool Stats" button added to Mining.qml
- ✅ Button only visible when `persistentSettings.allow_p2pool_mining`
- ✅ Button only enabled when `appWindow.isMining`
- ✅ State navigation: Mining → P2PoolStats → Back to Mining

## Logic Flow Verification ✅

### User Journey
1. User enables P2Pool mining mode
2. User starts P2Pool mining
3. "View P2Pool Stats" button becomes enabled
4. User clicks button → navigates to P2PoolStats view
5. Dashboard loads and calls `p2poolManager.getStats()`
6. Backend reads stats files and emits `p2poolStats` signal
7. QML receives data via `updateStats()` function
8. UI displays metrics in active tab
9. Timer triggers refresh every 3 seconds
10. User can switch tabs to view different metrics
11. User can click help icons for explanations
12. User clicks "Back to Mining" to return

### Data Flow
```
P2Pool Process → Stats Files (JSON)
                     ↓
           P2PoolManager.getStats()
                     ↓
          Read pool/miner/stratum/network files
                     ↓
           Parse JSON → QVariantMap
                     ↓
           emit p2poolStats(statsMap)
                     ↓
           QML updateStats(stats)
                     ↓
          Update property bindings
                     ↓
            UI auto-refreshes
```

## File System Requirements

### Expected P2Pool Stats Files
Location: `{p2pool_path}/stats/local/`

1. **pool** - Pool-level statistics
   - Expected fields: height, connections, incoming_connections, peer_list_size, uptime, banned_peers
   - pool_statistics: hashrate, sidechainHeight, pplnsWindowSize

2. **miner** - Miner-specific statistics
   - Expected fields: current_hashrate, shares_found, block_reward_share_percent

3. **stratum** - Stratum server statistics  
   - Expected fields: connections, hashrate, shares_submitted, shares_failed, bans

4. **network** - Network-level statistics
   - Expected fields: (additional network metrics)

## Manual Testing Checklist

### Prerequisites
- [ ] Monero GUI compiled successfully
- [ ] P2Pool binary installed
- [ ] Local monerod running with ZMQ enabled
- [ ] Wallet created/opened

### Test Case 1: Dashboard Access
- [ ] Navigate to Mining page
- [ ] Verify "View P2Pool Stats" button is hidden in Solo mode
- [ ] Switch to P2Pool mode
- [ ] Verify button is visible but disabled (not mining)
- [ ] Start P2Pool mining
- [ ] Verify button becomes enabled
- [ ] Click button
- [ ] Verify navigation to P2PoolStats view

### Test Case 2: Status Tab
- [ ] Verify Status tab is selected by default
- [ ] Check "Your Hashrate" displays number
- [ ] Check "Pool Hashrate" displays number
- [ ] Check "Shares Found" displays count
- [ ] Check "Block Reward Share" displays percentage
- [ ] Check "Main Chain Height" displays block number
- [ ] Check "Side Chain Height" displays block number
- [ ] Check "PPLNS Window" displays block count
- [ ] Check "Uptime" displays formatted time
- [ ] Click help button
- [ ] Verify help popup appears with Status explanation

### Test Case 3: Peers Tab
- [ ] Click "Peers" tab button
- [ ] Verify tab becomes highlighted (primary style)
- [ ] Check "Total Connections" displays count
- [ ] Check "Incoming Connections" displays count
- [ ] Check "Outgoing Connections" displays calculated value
- [ ] Check "Peer List Size" displays count
- [ ] Click help button
- [ ] Verify help popup appears with Peers explanation

### Test Case 4: Workers Tab
- [ ] Click "Workers" tab button
- [ ] Verify tab becomes highlighted
- [ ] Check "Connected Workers" displays count
- [ ] Check "Total Hashrate" displays H/s
- [ ] Check "Shares Submitted" displays count
- [ ] Check "Shares Failed" displays count
- [ ] Click help button
- [ ] Verify help popup appears with Workers explanation

### Test Case 5: Bans Tab
- [ ] Click "Bans" tab button
- [ ] Verify tab becomes highlighted
- [ ] Check "Total Bans" displays count
- [ ] Check "Stratum Bans" displays count
- [ ] Verify appropriate message displays based on ban count
- [ ] Click help button
- [ ] Verify help popup appears with Bans explanation

### Test Case 6: Live Updates
- [ ] Stay on dashboard for 10+ seconds
- [ ] Verify metrics update without manual refresh
- [ ] Monitor "Your Hashrate" for changes
- [ ] Monitor "Shares Found" for increments
- [ ] Switch between tabs
- [ ] Verify updates continue on all tabs

### Test Case 7: Navigation
- [ ] Click "Back to Mining" button
- [ ] Verify navigation to Mining page
- [ ] Click "View P2Pool Stats" again
- [ ] Verify return to dashboard
- [ ] Verify last selected tab is preserved (or defaults to Status)

### Test Case 8: Edge Cases
- [ ] Stop P2Pool mining while on dashboard
- [ ] Verify dashboard handles missing stats gracefully
- [ ] Verify no crashes with 0 values
- [ ] Start mining again
- [ ] Verify dashboard resumes updating
- [ ] Test with fresh P2Pool instance (minimal stats)
- [ ] Verify null-safety works (no undefined errors)

### Test Case 9: UI/UX
- [ ] Verify all text is readable
- [ ] Verify colors match Monero GUI theme
- [ ] Check dark/light theme compatibility
- [ ] Verify tab buttons are clearly distinguishable
- [ ] Verify help icons are visible and clickable
- [ ] Check layout doesn't overflow on smaller windows
- [ ] Verify metrics align properly in GridLayout

## Expected Results

### Successful Test Indicators
✅ No QML runtime errors in console  
✅ No C++ exceptions or crashes  
✅ Metrics display real P2Pool data  
✅ Updates occur every 3 seconds  
✅ Tab switching is smooth and instant  
✅ Help popups display correct information  
✅ Navigation works both directions  
✅ UI is consistent with Monero GUI style  

### Common Issues to Watch For
⚠️ Stats files not created (P2Pool not fully started)  
⚠️ Permissions error reading stats directory  
⚠️ Null/undefined values showing in UI  
⚠️ Timer not triggering updates  
⚠️ Tab selection state not updating  
⚠️ Help button not responding  

## Performance Validation

### Memory
- [ ] Check memory usage before opening dashboard
- [ ] Monitor memory while dashboard is open
- [ ] Verify no memory leaks over 5+ minutes
- [ ] Close dashboard and verify memory is released

### CPU
- [ ] Verify timer doesn't cause CPU spikes
- [ ] Check file I/O doesn't block UI thread
- [ ] Ensure smooth tab switching (< 100ms)

## Build Instructions (For Full Testing)

### Windows Build
```powershell
cd 'c:\Users\goldie\Downloads\mr krabs\monero-gui'
git checkout feature/p2pool-dashboard
git submodule update --init --recursive
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -A x64 ..
cmake --build . --config Release
```

### Linux Build
```bash
cd ~/monero-gui
git checkout feature/p2pool-dashboard
make release
```

### macOS Build
```bash
cd ~/monero-gui
git checkout feature/p2pool-dashboard
./build.sh
```

## Test Environment

### Recommended Setup
- OS: Windows 10/11, Ubuntu 22.04, or macOS 13+
- RAM: 8GB minimum
- Disk: 200GB+ for full blockchain
- P2Pool: v4.11+
- Monerod: Latest version with ZMQ enabled

### Minimal Test Setup (Without Full Blockchain)
- Use testnet for faster sync
- Create mock stats files for UI testing
- Test navigation and UI without real mining

## Status: READY FOR TESTING

All code has been validated for syntax errors. The implementation is complete and awaiting:
1. Full compilation
2. Runtime testing with P2Pool
3. UI/UX validation
4. Performance profiling

---

**Testing Date:** December 18, 2024  
**Branch:** feature/p2pool-dashboard  
**Validation Status:** ✅ Syntax Validated, ⏳ Runtime Testing Pending
