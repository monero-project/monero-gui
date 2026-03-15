# Built-In I2P Router Integration

This document captures the plan and current implementation status for baking an
I2P router into the Monero GUI, mirroring the "one click" experience that Bisq
ships for Tor.

## Goals

1. **Turn-key connectivity** – users download the GUI, tick "Enable I2P", and
   the bundled router comes online without additional installs.
2. **Lifecycle owned by the GUI** – the same start/stop controls that wrap
   `monerod` also manage the router (process supervision, config dirs, logs).
3. **Automatic daemon wiring** – when the router is enabled the GUI passes the
   appropriate `--tx-proxy i2p,host:port` / inbound options to `monerod` and
   ensures wallet RPC traffic traverses the anonymous transport.
4. **Plugin-like boundaries** – the GUI spawns the router as an external
   binary (similar to `monerod`) so upstream I2P projects can iterate without
   requiring changes to the Qt codebase.

## Architecture Overview

```
+---------------------------+        +---------------------+
| Monero GUI (Qt/QML)       |        | Bundled I2P binary  |
|                           |        | (i2pd by default)   |
|  * Settings UI            |        |                     |
|  * Persistent settings    |  IPC   |  * Runs inside user |
|  * Daemon launch helpers  | <----> |    profile dir      |
|  * I2pManager (new)       |        |  * Exposes SOCKS,   |
+---------------------------+        |    HTTP and SAM     |
                                     +---------------------+
```

- **I2pManager** (C++): mirrors `DaemonManager` but tailored for a small helper
  process. It resolves the bundled binary, prepares arguments, owns the
  `QProcess`, streams logs to QML, exposes state via Q_PROPERTIES and signals,
  and provides helpers to derive a default data directory on every platform.
- **QML bindings**: `MoneroSettings` now stores router preferences (enable,
  ports, data dir, extra args, auto-start/stop). The settings page gains a new
  card that lets users toggle the router, edit ports, inspect status and
  launch the folder picker – all without touching the CLI.
- **Daemon glue**: before the GUI spawns `monerod` it ensures the router is up
  (respecting the settings) and auto-injects `--tx-proxy i2p,127.0.0.1:<sam>`
  when the user has not already provided a custom flag. That means one extra
  checkbox is enough to force monerod to talk over I2P.

## Router Lifecycle

1. **Startup:** if `i2pAutostart` is true the GUI calls `I2pManager::start()`
   as soon as the main window finishes loading. It also attempts to start the
   router right before launching `monerod`, surfacing any failures via the
   standard `informationPopup` dialog.
2. **Runtime supervision:** `I2pManager` stays attached to the process so it
   can emit `routerStarted`, `routerStopped`, `routerError`, and the merged log
   stream (`routerLog`). QML binds those signals to update the status string in
   the settings panel.
3. **Shutdown:** when `monerod` stops the GUI optionally tears down the router
   (controlled by `i2pAutoStopWithDaemon`). Users can also stop/start it on
   demand via the new button.

## Configuration Surfaces

- **Data directory:** defaults to the Qt `AppDataLocation` (`~/Library/Application
  Support/Monero/I2P`, `%APPDATA%/Monero/I2P`, etc.) but can be overridden via a
  folder picker. The GUI ensures the directory exists before launching.
- **Ports:** HTTP proxy, SOCKS proxy, and SAM ports are individually editable.
  The GUI validates ranges locally before persisting them to settings.
- **Extra arguments:** advanced users can append CLI flags that I2P power users
  might want (bandwidth, tunnels, reseed hosts, etc.) without waiting for the
  GUI to grow first-class toggles.
- **Anonymous inbound:** toggle "Share this node over I2P" to surface a form
  for your `.b32.i2p` server tunnel plus the local forwarding host/port and max
  peers. When enabled the GUI injects `--anonymous-inbound <address>,<host:port>[,<max>]`
  whenever the daemon starts, keeping the CLI syntax tucked away.
- **Router log & status:** a scrollable log tail (with copy + clear actions) and
  live status line help troubleshoot router launches or outbound connectivity
  directly from Settings ▸ Node.

## Packaging & Distribution

- Set `I2P_ROUTER_SOURCE` when running CMake to copy a vetted router binary into
  the final bundle (e.g. `cmake -DI2P_ROUTER_SOURCE=/path/to/i2pd ...`). If you
  drop binaries under `external/i2p/bin/<platform>/i2pd*`, the build will auto
  detect the matching file and use it without extra flags. The helper in
  `cmake/I2pBundler.cmake` takes care of renaming it to `i2pd`/`i2pd.exe` and
  making it executable on Unix platforms.
- Use `scripts/fetch-i2pd.sh --url <official-release>` to download the desired
  archive from https://github.com/PurpleI2P/i2pd/releases, extract the binary and
  place it under `external/i2p/bin/<platform>/i2pd`. The script prints the exact
  `I2P_ROUTER_SOURCE` path to feed into CMake, though this is optional when using
  the auto-detection mentioned above.
- The repo already contains staged layouts for macOS (`external/i2p/bin/darwin-macos/i2pd`),
  Linux (`external/i2p/bin/linux-x86_64/i2pd` from the Debian package) and Windows
  (`external/i2p/bin/win64/i2pd.exe`). Update them as new upstream releases arrive.
- During packaging the `monero_bundle_i2p` step copies the supplied router into
  the same directory as `monerod`, ensuring the GUI finds it at runtime without
  requiring end-users to install i2pd separately.
- The release checklist now includes: download/sign router binaries, point
  `I2P_ROUTER_SOURCE` at the verified artifact for each platform build, and keep
  hashes in your reproducible-build notes.

## Follow-Up Tasks

1. **Inbound tunnels UI** – expose `--anonymous-inbound` helpers so nodes can
   advertise hidden services by default.
2. **Health surfaced in UI** – extend the new log tail/controls in Settings ▸
   Node with richer status (uptime, bandwidth, tunnel count) sourced from SAM or
   i2pd metrics once available.
3. **End-to-end tests** – smoke tests that start the GUI, enable the router,
   and assert `monerod` receives the `--tx-proxy` flag.

With these scaffolding pieces in place the remaining work is largely about
packaging and incremental UX polish rather than fundamental architecture.
