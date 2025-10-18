# I2P Integration for Monero GUI

This implementation adds I2P (Invisible Internet Project) routing support to the Monero GUI wallet, allowing users to route their Monero transactions through the I2P anonymous network with simple one-click operation.

## 🎯 Project Goals

- **One-click I2P activation** - Users can enable I2P routing via a checkbox in settings
- **Automatic i2pd management** - GUI downloads, installs, and manages the i2pd router
- **Cross-platform support** - Works on Windows, Linux, and macOS
- **User-friendly** - No command-line configuration required
- **Secure** - Binary verification, sandboxed execution, proper error handling

## 🏗️ Architecture

### Components

1. **I2PManager** (`src/i2p/I2PManager.{h,cpp}`)
   - Core class managing i2pd binary lifecycle
   - Handles download, installation, start/stop
   - Monitors router status and health
   - Provides QML-accessible interface

2. **SettingsI2P.qml** (planned)
   - User interface for I2P configuration
   - Status display and controls
   - Remote node management

3. **Integration with monerod**
   - Configures monerod to use I2P SOCKS proxy
   - Manages peer connections to I2P nodes

### Design Pattern

This implementation follows the same pattern as the existing `P2PoolManager`:
- External binary management (not embedded library)
- Async operations with `FutureScheduler`
- QML property bindings for reactive UI
- Platform-specific handling via Qt abstractions

## 📦 How It Works

### Installation Flow

```
1. User opens Monero GUI Settings
   ↓
2. Navigates to I2P section
   ↓
3. Clicks "Enable I2P" checkbox
   ↓
4. If not installed:
   a. GUI downloads i2pd binary from GitHub
   b. Verifies SHA256 hash
   c. Extracts to application data directory
   d. Sets executable permissions (Unix)
   ↓
5. GUI generates i2pd.conf file
   ↓
6. Starts i2pd process
   ↓
7. Monitors log output for status
   ↓
8. When router is ready:
   a. Configures monerod with --proxy flag
   b. Adds I2P remote node as peer
   ↓
9. Transactions now route through I2P!
```

### File Structure

```
~/.config/monero-gui/          (Linux)
%APPDATA%/monero-gui/          (Windows)
~/Library/Application Support/monero-gui/  (macOS)
└── i2pd/
    ├── i2pd(.exe)             # i2pd binary
    ├── data/
    │   ├── i2pd.conf          # Generated configuration
    │   ├── i2pd.log           # Router logs
    │   ├── netDb/             # Router database
    │   └── certificates/      # SSL certificates
    └── (other i2pd files)
```

## 🔧 Configuration

### Generated i2pd.conf

The GUI automatically generates an optimized configuration:

```ini
[network]
bandwidth = P              # Unlimited bandwidth

[socks]
enabled = true
address = 127.0.0.1
port = 4447               # SOCKS proxy port

[http]
enabled = true            # For browsing I2P sites
address = 127.0.0.1
port = 4444

[upnp]
enabled = true            # Auto NAT traversal

# Disabled features (reduce overhead)
[sam]
enabled = false
[bob]
enabled = false
[i2pcontrol]
enabled = false
```

### monerod Integration

When I2P is enabled, monerod is launched with:

```bash
monerod \
  --proxy 127.0.0.1:4447 \
  --add-peer <i2p-node-address>.b32.i2p:18081
```

## 🌐 Known I2P Remote Nodes

The implementation includes a fallback list of verified I2P Monero nodes:

```cpp
// TODO: Populate with community-verified nodes
static const QStringList KNOWN_I2P_NODES = {
    // Format: "xyz...abc.b32.i2p:18081"
};
```

Users can:
1. Enter their own I2P node address
2. Select from the known nodes list
3. Let the GUI use defaults automatically

## 🚀 Building

### Prerequisites

- Qt 5.15+
- CMake 3.16+
- C++14 compiler
- OpenSSL
- All standard Monero GUI build dependencies

### Build Steps

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/monero-gui.git
cd monero-gui
git checkout feature/i2p-binary-manager

# Update submodules
git submodule update --init --recursive

# Build
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### Windows Build

```powershell
# Use the standard Monero GUI Windows build process
# The I2P manager will be included automatically
```

## 🧪 Testing

### Manual Testing

1. Build the modified GUI
2. Launch and navigate to Settings > I2P
3. Click "Install I2P Router"
4. Wait for download and installation
5. Enable I2P checkbox
6. Verify router starts (check status)
7. Enter or select an I2P remote node
8. Attempt to sync blockchain via I2P

### Expected Behavior

- **First run**: Downloads i2pd (~5-10 MB)
- **Startup time**: 2-5 minutes for I2P network integration
- **Steady state**: Router running, ~50-100 MB RAM usage
- **Shutdown**: Graceful termination within 10 seconds

### Troubleshooting

**Router won't start:**
- Check log file: `~/.config/monero-gui/i2pd/data/i2pd.log`
- Verify port 4447 is not in use
- Check firewall settings

**Can't connect to remote node:**
- Verify I2P router shows "Running" status
- Test connection with known-good node
- Check if remote node is actually online

**Slow sync:**
- I2P is inherently slower than clearnet (expected)
- Router needs 5-10 minutes to build tunnels
- Try different remote nodes

## 📚 API Reference

### QML Interface

```qml
// Properties
i2pManager.installed    // bool - Is i2pd installed?
i2pManager.running      // bool - Is i2pd running?
i2pManager.status       // string - Human-readable status
i2pManager.version      // string - Installed i2pd version

// Methods
i2pManager.download()                      // Download and install
i2pManager.start("127.0.0.1:4447")        // Start router
i2pManager.stop()                          // Stop router
i2pManager.getStatus()                     // Update status
i2pManager.testConnection(nodeAddress)     // Test connection
i2pManager.getKnownNodes()                 // Get node list

// Signals
onI2pDownloadProgress(int percent)
onI2pDownloadSuccess()
onI2pDownloadFailure(int errorCode)
onI2pRouterReady()
onI2pStatusChanged(int status, string message)
```

### C++ Interface

See `src/i2p/I2PManager.h` for detailed API documentation.

## 🐛 Known Limitations

1. **Bootstrap node discovery**: Cannot auto-discover I2P nodes (requires network upgrade)
2. **Simple Mode**: Only works in Advanced Mode currently
3. **First-time setup**: User must provide or select I2P remote node
4. **Sync speed**: Slower than clearnet (inherent to I2P)
5. **NAT issues**: May not work behind symmetric NAT without UPnP

## 🔮 Future Enhancements

### Short-term
- [ ] Auto-update i2pd binary
- [ ] More sophisticated node discovery
- [ ] Bandwidth usage statistics
- [ ] Connection quality indicator

### Long-term
- [ ] SAM protocol support in monerod
- [ ] I2P bootstrap node discovery (network upgrade)
- [ ] Simple Mode support
- [ ] Built-in I2P address book

## 🤝 Contributing

This implementation is being developed as part of the [Monero Bounties](https://bounties.monero.social/posts/32/) program.

### Development Process

1. Work happens on `feature/i2p-binary-manager` branch
2. Regular progress updates in `PROGRESS.md`
3. Code follows existing Monero GUI style
4. All changes documented
5. Testing on all platforms before PR

### Code Style

- Follow existing Monero GUI conventions
- Use Qt abstractions for cross-platform code
- Document all public methods
- Include error handling
- Add debug logging

## 📄 License

Same as Monero GUI (BSD 3-Clause)

## 🙏 Credits

- **i2pd team**: For the excellent I2P router implementation
- **Monero core team**: For the solid foundation
- **preland**: For pioneering work on I2P integration
- **Bounty contributors**: For funding this development

## 📞 Contact

- GitHub Issues: For bugs and feature requests
- Matrix: #monero-gui:monero.social
- Reddit: r/Monero

---

**Status**: 🚧 In Development (Phase 1 - Week 1)  
**Last Updated**: October 17, 2025  
**Target Completion**: February 2026
