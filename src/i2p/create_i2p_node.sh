#!/bin/bash
set -e  # Exit on error

echo "STATUS:Starting I2P node setup..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
    OS_TYPE="windows"
elif [[ "$OSTYPE" == *"android"* ]] || [[ -n "$ANDROID_ROOT" ]]; then
    OS_TYPE="android"
else
    echo "STATUS:Error: Unsupported operating system: $OSTYPE"
    exit 1
fi

install_packages() {
    case "$OS_TYPE" in
        "macos")
            brew install i2pd wget gpg
            ;;
        "linux")
            # Detect Linux distribution
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y i2pd wget gpg bzip2
            elif command -v yum &> /dev/null; then
                sudo yum install -y i2pd wget gnupg2 bzip2
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm i2pd wget gnupg bzip2
            fi
            ;;
        "windows")
            # Windows: Use Chocolatey or manual installation
            if command -v choco &> /dev/null; then
                choco install i2pd wget gpg4win -y
            else
                echo "STATUS:Please install i2pd manually on Windows"
            fi
            ;;
        "android")
            # Android: Very limited - may need root or Termux
            echo "STATUS:Android requires special setup (Termux or root)"
            ;;
    esac
}

setup_monero_paths() {
    case "$OS_TYPE" in
        "macos")
            MONERO_HOME="$HOME/Library/Application Support/Monero"
            ;;
        "linux")
            # Use XDG standard if available, otherwise fallback to .bitmonero
            if [ -n "$XDG_DATA_HOME" ]; then
                MONERO_HOME="$XDG_DATA_HOME/monero"
            else
                MONERO_HOME="$HOME/.bitmonero"
            fi
            ;;
        "windows")
            # Windows: Use APPDATA environment variable
            # In bash on Windows (Git Bash/Cygwin), APPDATA is usually set
            if [ -n "$APPDATA" ]; then
                MONERO_HOME="$APPDATA/Monero"
            elif [ -n "$LOCALAPPDATA" ]; then
                MONERO_HOME="$LOCALAPPDATA/Monero"
            else
                # Fallback for WSL or if variables not set
                MONERO_HOME="$HOME/AppData/Roaming/Monero"
            fi
            ;;
        "android")
            MONERO_HOME="$HOME/Monero"
            ;;
        *)
            # Default fallback
            MONERO_HOME="$HOME/.monero"
            ;;
    esac

    # Set derived paths (same for all platforms)
    MONERO_DATA="$MONERO_HOME/.bitmonero"
    MONERO_CONFIG="$MONERO_HOME/monerod.conf"
    MONERO_LOG="$MONERO_HOME/monerod.log"
    MONERO_PID="$MONERO_HOME/monerod.pid"
}

normalize_path() {
    local path="$1"
    case "$OS_TYPE" in
        "windows")
            # Convert Unix-style path to Windows if needed
            # Git Bash handles this automatically, but Cygwin may need conversion
            if [[ "$path" == /c/* ]] || [[ "$path" == /cygdrive/* ]]; then
                # Already in Windows format or Cygwin format
                echo "$path"
            else
                echo "$path"
            fi
            ;;
        *)
            echo "$path"
            ;;
    esac
}

install_monero_binary() {
    local MONERO_BINARY=""
    local INSTALL_DIR=""
    local BINARY_NAME="monerod"

    case "$OS_TYPE" in
        "macos")
            # macOS: Look for monero-*-macos-* directory or monerod binary
            if [ -d "monero-"*"-macos-"* ]; then
                MONERO_DIR=$(ls -d monero-*-macos-* 2>/dev/null | head -1)
                MONERO_BINARY="$MONERO_DIR/monerod"
                INSTALL_DIR="/usr/local/bin"
            elif [ -f "monerod" ]; then
                MONERO_BINARY="monerod"
                INSTALL_DIR="/usr/local/bin"
            fi
            ;;
        "linux")
            # Linux: Look for monero-*-linux-* directory or monerod binary
            if [ -d "monero-"*"-linux-"* ]; then
                MONERO_DIR=$(ls -d monero-*-linux-* 2>/dev/null | head -1)
                MONERO_BINARY="$MONERO_DIR/monerod"
                INSTALL_DIR="/usr/local/bin"
            elif [ -f "monerod" ]; then
                MONERO_BINARY="monerod"
                INSTALL_DIR="/usr/local/bin"
            fi
            ;;
        "windows")
            # Windows: Look for monero-*-win64-* directory or .exe files
            BINARY_NAME="monerod.exe"
            if [ -d "monero-"*"-win64-"* ]; then
                MONERO_DIR=$(ls -d monero-*-win64-* 2>/dev/null | head -1)
                MONERO_BINARY="$MONERO_DIR/monerod.exe"
                # Windows: Use Program Files or a user directory
                if [ -n "$ProgramFiles" ]; then
                    INSTALL_DIR="$ProgramFiles/Monero"
                else
                    INSTALL_DIR="$HOME/AppData/Local/Monero"
                fi
            elif [ -f "monerod.exe" ]; then
                MONERO_BINARY="monerod.exe"
                if [ -n "$ProgramFiles" ]; then
                    INSTALL_DIR="$ProgramFiles/Monero"
                else
                    INSTALL_DIR="$HOME/AppData/Local/Monero"
                fi
            fi
            ;;
        "android")
            # Android: Usually just a binary file
            if [ -f "monerod" ]; then
                MONERO_BINARY="monerod"
                INSTALL_DIR="$HOME/.local/bin"
            fi
            ;;
    esac

    # Install the binary if found
    if [ -n "$MONERO_BINARY" ] && [ -f "$MONERO_BINARY" ]; then
        echo "STATUS:Installing Monero binary..."

        # Create install directory if it doesn't exist
        case "$OS_TYPE" in
            "windows")
                mkdir -p "$INSTALL_DIR"
                cp "$MONERO_BINARY" "$INSTALL_DIR/$BINARY_NAME"
                # Windows doesn't need chmod, but ensure it's executable

                # Check if directory is in PATH, if not, suggest adding it
                if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
                    echo "STATUS:Note: $INSTALL_DIR is not in your PATH"
                    echo "STATUS:You may need to add it manually or use full path to monerod.exe"
                fi
                ;;
            *)
                # Unix-like systems (macOS, Linux, Android)
                echo "$SUDO_PASSWORD" | sudo -S mkdir -p "$INSTALL_DIR" 2>/dev/null || mkdir -p "$INSTALL_DIR"
                echo "$SUDO_PASSWORD" | sudo -S cp "$MONERO_BINARY" "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null || cp "$MONERO_BINARY" "$INSTALL_DIR/$BINARY_NAME"
                echo "$SUDO_PASSWORD" | sudo -S chmod +x "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null || chmod +x "$INSTALL_DIR/$BINARY_NAME"
                ;;
        esac

        # Clean up extracted directory if it was a tarball
        if [ -n "$MONERO_DIR" ] && [ -d "$MONERO_DIR" ]; then
            rm -rf "$MONERO_DIR"
        fi

        # Verify installation
        if command -v "$BINARY_NAME" &> /dev/null || [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
            echo "STATUS:Monero binary installed successfully to $INSTALL_DIR"
            return 0
        else
            echo "STATUS:Warning: Binary copied but may not be in PATH"
            return 1
        fi
    else
        echo "STATUS:Warning: Monero binary not found in download"
        return 1
    fi
}

start_i2pd_service() {
    case "$OS_TYPE" in
        "macos")
            echo "STATUS:Starting i2pd service..."
            brew services start i2pd || {
                echo "STATUS:Starting i2pd manually..."
                i2pd --daemon --conf="$I2PD_CONFIG_DIR" || {
                    echo "STATUS:Warning: Could not start i2pd as daemon"
                    echo "STATUS:You may need to start i2pd manually"
                    return 1
                }
            }
            ;;
        "linux")
            echo "STATUS:Starting i2pd service..."
            # Try systemd first
            if systemctl is-active --quiet i2pd 2>/dev/null; then
                echo "STATUS:i2pd service is already running"
            elif systemctl start i2pd 2>/dev/null; then
                echo "STATUS:i2pd service started via systemd"
                # Enable to start on boot
                echo "$SUDO_PASSWORD" | sudo -S systemctl enable i2pd 2>/dev/null || true
            else
                # Fallback to manual daemon start
                echo "STATUS:Starting i2pd manually..."
                echo "$SUDO_PASSWORD" | sudo -S i2pd --daemon --conf="$I2PD_CONFIG_DIR" 2>/dev/null || i2pd --daemon --conf="$I2PD_CONFIG_DIR" || {
                    echo "STATUS:Warning: Could not start i2pd as daemon"
                    echo "STATUS:You may need to start i2pd manually: sudo i2pd --daemon"
                    return 1
                }
            fi
            ;;
        "windows")
            echo "STATUS:Starting i2pd service..."
            # Windows: Try to start as Windows Service (if installed as service)
            if net start i2pd 2>/dev/null; then
                echo "STATUS:i2pd service started via Windows Service Manager"
            else
                # Fallback: Start as background process
                echo "STATUS:Starting i2pd as background process..."
                # On Windows, use start command or run in background
                if command -v start &> /dev/null; then
                    start /B i2pd.exe --daemon --conf="$I2PD_CONFIG_DIR" || {
                        echo "STATUS:Warning: Could not start i2pd"
                        echo "STATUS:You may need to start i2pd manually"
                        return 1
                    }
                else
                    # Git Bash/Cygwin: Run in background
                    i2pd --daemon --conf="$I2PD_CONFIG_DIR" || {
                        echo "STATUS:Warning: Could not start i2pd as daemon"
                        echo "STATUS:You may need to start i2pd manually"
                        return 1
                    }
                fi
            fi
            ;;
        "android")
            echo "STATUS:Starting i2pd service..."
            # Android: Usually run as daemon or via Termux services
            i2pd --daemon --conf="$I2PD_CONFIG_DIR" || {
                echo "STATUS:Warning: Could not start i2pd as daemon"
                echo "STATUS:You may need to start i2pd manually or use Termux services"
                return 1
            }
            ;;
    esac
}

get_monerod_binary_path() {
    case "$OS_TYPE" in
        "windows")
            # Windows: Check common locations
            if command -v monerod.exe &> /dev/null; then
                command -v monerod.exe
            elif [ -f "$ProgramFiles/Monero/monerod.exe" ]; then
                echo "$ProgramFiles/Monero/monerod.exe"
            elif [ -f "$HOME/AppData/Local/Monero/monerod.exe" ]; then
                echo "$HOME/AppData/Local/Monero/monerod.exe"
            else
                echo "monerod.exe"  # Fallback - hope it's in PATH
            fi
            ;;
        *)
            # Unix-like systems (macOS, Linux, Android)
            if command -v monerod &> /dev/null; then
                command -v monerod
            elif [ -f "/usr/local/bin/monerod" ]; then
                echo "/usr/local/bin/monerod"
            else
                echo "monerod"  # Fallback - hope it's in PATH
            fi
            ;;
    esac
}


create_and_start_monerod_service() {
    local MONEROD_BINARY=$(get_monerod_binary_path)

    case "$OS_TYPE" in
        "macos")
            echo "STATUS:Creating monerod launchd service..."

            LAUNCHD_PLIST="$HOME/Library/LaunchAgents/org.monero.monerod.plist"

            cat > "$LAUNCHD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.monero.monerod</string>
    <key>ProgramArguments</key>
    <array>
        <string>$MONEROD_BINARY</string>
        <string>--config-file</string>
        <string>$MONERO_CONFIG</string>
        <string>--pidfile</string>
        <string>$MONERO_PID</string>
        <string>--detach</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>$MONERO_LOG</string>
    <key>StandardErrorPath</key>
    <string>$MONERO_LOG</string>
    <key>WorkingDirectory</key>
    <string>$MONERO_HOME</string>
</dict>
</plist>
EOF

            echo "STATUS:Loading monerod service..."
            launchctl load "$LAUNCHD_PLIST" 2>/dev/null || {
                echo "STATUS:Service may already be loaded, attempting to unload first..."
                launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
                launchctl load "$LAUNCHD_PLIST"
            }

            echo "STATUS:Starting monerod service..."
            launchctl start org.monero.monerod || {
                echo "STATUS:Warning: Could not start monerod via launchctl"
                echo "STATUS:You may need to start monerod manually"
                return 1
            }
            ;;
        "linux")
            echo "STATUS:Creating monerod systemd service..."

            SYSTEMD_SERVICE="/etc/systemd/system/monerod.service"

            # Create systemd service file
            echo "$SUDO_PASSWORD" | sudo -S tee "$SYSTEMD_SERVICE" > /dev/null <<EOF
[Unit]
Description=Monero Full Node (Mainnet) with I2P
After=network.target i2pd.service
Requires=i2pd.service

[Service]
Type=forking
PIDFile=$MONERO_PID
ExecStart=$MONEROD_BINARY --config-file=$MONERO_CONFIG --pidfile $MONERO_PID --detach
Restart=on-failure
RestartSec=30

User=$USER
Group=$USER

RuntimeDirectory=monero
RuntimeDirectoryMode=0710
StateDirectory=monero
StateDirectoryMode=0710
LogsDirectory=monero
LogsDirectoryMode=0710
ConfigurationDirectory=monero
ConfigurationDirectoryMode=0710

PrivateTmp=true
ProtectSystem=full
ProtectHome=true
NoNewPrivileges=true

StandardOutput=append:$MONERO_LOG
StandardError=append:$MONERO_LOG
WorkingDirectory=$MONERO_HOME

[Install]
WantedBy=multi-user.target
EOF

            echo "STATUS:Reloading systemd daemon..."
            echo "$SUDO_PASSWORD" | sudo -S systemctl daemon-reload

            echo "STATUS:Enabling monerod service..."
            echo "$SUDO_PASSWORD" | sudo -S systemctl enable monerod

            echo "STATUS:Starting monerod service..."
            echo "$SUDO_PASSWORD" | sudo -S systemctl start monerod || {
                echo "STATUS:Warning: Could not start monerod via systemctl"
                echo "STATUS:You may need to start monerod manually: sudo systemctl start monerod"
                return 1
            }
            ;;
        "windows")
            echo "STATUS:Creating monerod Windows Service..."

            # Windows: Use NSSM (Non-Sucking Service Manager) if available, or create a batch script
            if command -v nssm &> /dev/null; then
                echo "STATUS:Installing monerod as Windows Service using NSSM..."
                nssm install monerod "$MONEROD_BINARY" --config-file "$MONERO_CONFIG" --pidfile "$MONERO_PID" --detach || {
                    echo "STATUS:Warning: Could not install monerod service via NSSM"
                    echo "STATUS:You may need to install NSSM or start monerod manually"
                    return 1
                }
                nssm start monerod || {
                    echo "STATUS:Warning: Could not start monerod service"
                    return 1
                }
            else
                # Fallback: Create a startup script or run in background
                echo "STATUS:NSSM not found, creating startup script..."
                STARTUP_SCRIPT="$MONERO_HOME/start_monerod.bat"
                cat > "$STARTUP_SCRIPT" <<EOF
@echo off
cd /d "$MONERO_HOME"
"$MONEROD_BINARY" --config-file "$MONERO_CONFIG" --pidfile "$MONERO_PID" --detach
EOF
                echo "STATUS:Note: Created startup script at $STARTUP_SCRIPT"
                echo "STATUS:You may need to run this script manually or add it to Windows startup"
                echo "STATUS:Starting monerod in background..."
                start /B cmd /c "$STARTUP_SCRIPT" || {
                    echo "STATUS:Warning: Could not start monerod"
                    return 1
                }
            fi
            ;;
        "android")
            echo "STATUS:Creating monerod startup script for Android..."

            # Android: Create a simple startup script (no system service management)
            STARTUP_SCRIPT="$MONERO_HOME/start_monerod.sh"
            cat > "$STARTUP_SCRIPT" <<EOF
#!/bin/bash
cd "$MONERO_HOME"
$MONEROD_BINARY --config-file "$MONERO_CONFIG" --pidfile "$MONERO_PID" --detach
EOF
            chmod +x "$STARTUP_SCRIPT"

            echo "STATUS:Starting monerod in background..."
            nohup "$STARTUP_SCRIPT" > "$MONERO_LOG" 2>&1 & || {
                echo "STATUS:Warning: Could not start monerod"
                echo "STATUS:You may need to run: $STARTUP_SCRIPT"
                return 1
            }
            ;;
    esac
}

# Function to check if a process is running (platform-specific)
is_process_running() {
    local process_name="$1"

    case "$OS_TYPE" in
        "windows")
            # Windows: Use tasklist command
            # Try both with and without .exe extension
            if tasklist /FI "IMAGENAME eq ${process_name}" 2>/dev/null | grep -q "${process_name}" 2>/dev/null; then
                return 0  # Process is running
            elif [ "${process_name%.exe}" != "$process_name" ]; then
                # Already has .exe, try without it
                local name_no_ext="${process_name%.exe}"
                if tasklist /FI "IMAGENAME eq ${name_no_ext}" 2>/dev/null | grep -q "${name_no_ext}" 2>/dev/null; then
                    return 0
                fi
            else
                # No .exe, try with .exe
                if tasklist /FI "IMAGENAME eq ${process_name}.exe" 2>/dev/null | grep -q "${process_name}.exe" 2>/dev/null; then
                    return 0
                fi
            fi
            return 1  # Process is not running
            ;;
        *)
            # Unix-like systems (macOS, Linux, Android): Use pgrep
            if pgrep -x "$process_name" > /dev/null 2>&1; then
                return 0  # Process is running
            else
                return 1  # Process is not running
            fi
            ;;
    esac
}

# Function to run a command with timeout (platform-specific)
run_with_timeout() {
    local timeout_seconds="$1"
    shift  # Remove first argument, rest are the command

    case "$OS_TYPE" in
        "windows")
            # Windows: timeout command has different syntax
            # Note: Windows timeout /t waits for user input, so we need a different approach
            # Use PowerShell's Start-Job with timeout or a workaround
            # For simplicity, we'll just run the command without timeout on Windows
            # (Windows processes can be killed manually if needed)
            "$@" 2>/dev/null
            return $?
            ;;
        *)
            # Unix-like systems (macOS, Linux, Android): Use timeout command
            timeout "$timeout_seconds" "$@" 2>/dev/null
            return $?
            ;;
    esac
}

case "$OS_TYPE" in
    "macos")
        if ! command -v brew &> /dev/null; then
            echo "STATUS:Installing Homebrew..."
            echo "PASSWORD_PROMPT:Enter your macOS password to install Homebrew"
            read -s SUDO_PASSWORD
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "STATUS:Homebrew is already installed"
            echo "PASSWORD_PROMPT:Enter your macOS password for package installation"
            read -s SUDO_PASSWORD
        fi
        echo "STATUS:Updating Homebrew..."
        brew update
        ;;
    "linux")
        echo "PASSWORD_PROMPT:Enter sudo password for package installation"
        read -s SUDO_PASSWORD
        ;;
    "windows")
        # Windows may not need password prompt for Chocolatey
        echo "STATUS:Installing packages on Windows..."
        ;;
    "android")
        echo "STATUS:Setting up Android environment..."
        ;;
esac

echo "STATUS:Installing i2pd and required tools..."
install_packages

# Platform-specific firewall message
case "$OS_TYPE" in
    "macos")
        echo "STATUS:Configuring macOS firewall..."
        echo "STATUS:Note: macOS firewall configuration should be done through System Preferences"
        ;;
    "linux")
        echo "STATUS:Configuring firewall (if UFW is installed)..."
        echo "STATUS:Note: I2P tunnels handle port forwarding, so no manual port opening is needed"
        ;;
    "windows")
        echo "STATUS:Configuring Windows Firewall..."
        echo "STATUS:Note: I2P tunnels handle port forwarding, so no manual port opening is needed"
        ;;
    "android")
        echo "STATUS:Note: I2P tunnels handle port forwarding, no firewall configuration needed"
        ;;
esac

echo "STATUS:Creating Monero directories..."

setup_monero_paths

mkdir -p "$MONERO_DATA"
mkdir -p "$MONERO_HOME"

echo "STATUS:Downloading Monero binaries..."
cd ~

if [ ! -f "download_monero_binaries.sh" ]; then
    wget -q https://gist.githubusercontent.com/sethforprivacy/ad5848767d9319520a6905b7111dc021/raw/download_monero_binaries.sh || {
        echo "STATUS:Error: Could not download Monero binaries script"
        exit 1
    }
    chmod +x download_monero_binaries.sh
fi

echo "STATUS:Running Monero download script..."
./download_monero_binaries.sh || {
    echo "STATUS:Warning: Download script may not support this platform directly"
    echo "STATUS:Please download Monero binaries manually from getmonero.org"
    case "$OS_TYPE" in
        "windows")
            echo "STATUS:Extract and place monerod.exe in a directory in your PATH"
            ;;
        *)
            echo "STATUS:Extract and place monerod in /usr/local/bin/ or a directory in your PATH"
            ;;
    esac
}

install_monero_binary

BINARY_NAME="monerod"
if [ "$OS_TYPE" = "windows" ]; then
    BINARY_NAME="monerod.exe"
fi

if ! command -v "$BINARY_NAME" &> /dev/null; then
    echo "STATUS:Error: $BINARY_NAME not found in PATH"
    case "$OS_TYPE" in
        "windows")
            echo "STATUS:Please ensure $BINARY_NAME is installed and in your PATH"
            echo "STATUS:Or add the installation directory to your PATH environment variable"
            ;;
        *)
            echo "STATUS:Please install $BINARY_NAME manually to /usr/local/bin/ or add to PATH"
            ;;
    esac
    exit 1
fi
echo "STATUS:Configuring i2pd server tunnels..."

case "$OS_TYPE" in
    "windows")
        # Windows: Use APPDATA or LOCALAPPDATA
        if [ -n "$APPDATA" ]; then
            I2PD_CONFIG_DIR="$APPDATA/i2pd"
        elif [ -n "$LOCALAPPDATA" ]; then
            I2PD_CONFIG_DIR="$LOCALAPPDATA/i2pd"
        else
            I2PD_CONFIG_DIR="$HOME/.i2pd"
        fi
        ;;
    *)
        # Unix-like systems (macOS, Linux, Android)
        I2PD_CONFIG_DIR="$HOME/.i2pd"
        ;;
esac
I2PD_TUNNELS_DIR="$I2PD_CONFIG_DIR/tunnels.d"
I2PD_DATA_DIR="$I2PD_CONFIG_DIR"

mkdir -p "$I2PD_TUNNELS_DIR"
mkdir -p "$I2PD_DATA_DIR"

cat > "$I2PD_TUNNELS_DIR/monero-p2p.conf" <<'EOF'
[monero-p2p]
type = server
port = 18084
keys = monero-p2p.dat
EOF

cat > "$I2PD_TUNNELS_DIR/monero-rpc.conf" <<'EOF'
[monero-rpc]
type = server
port = 18089
keys = monero-rpc.dat
EOF

start_i2pd_service
echo "STATUS:Waiting for i2pd tunnels to initialize..."
sleep 10

I2P_P2P_ADDRESS=""

MAX_WAIT=60
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if [ -f "$I2PD_DATA_DIR/monero-p2p.dat" ]; then
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    echo "STATUS:Waiting for I2P tunnel keys... ($WAITED/$MAX_WAIT seconds)"
done

if [ ! -f "$I2PD_DATA_DIR/monero-p2p.dat" ]; then
    echo "STATUS:Warning: I2P tunnel keys not found after waiting"
    echo "STATUS:Continuing anyway - address may need to be retrieved manually"
else
    echo "STATUS:I2P tunnel keys created successfully"
fi

echo "STATUS:Retrieving I2P tunnel addresses..."
I2P_P2P_ADDRESS=$(curl -s http://127.0.0.1:7070/tunnels 2>/dev/null | grep -oE 'monero-p2p[^"]*\.b32\.i2p' | head -1 || echo "")

if [ -z "$I2P_P2P_ADDRESS" ]; then
    I2PD_LOG="$I2PD_DATA_DIR/i2pd.log"
    if [ -f "$I2PD_LOG" ]; then
        I2P_P2P_ADDRESS=$(grep -oE '[a-z2-7]{52}\.b32\.i2p' "$I2PD_LOG" | grep -v "^$" | head -1 || echo "")
    fi
fi

if [ -z "$I2P_P2P_ADDRESS" ]; then
    echo "STATUS:Warning: Could not automatically determine I2P P2P address"
    echo "STATUS:You may need to check i2pd web console at http://127.0.0.1:7070"
    echo "STATUS:Or check i2pd logs in: $I2PD_DATA_DIR"
fi

echo "STATUS:Configuring monerod for I2P..."

cat > "$MONERO_CONFIG" <<EOF
# Data directory (blockchain db and indices)
data-dir=$MONERO_DATA

# Log file
log-file=$MONERO_LOG

# P2P configuration
p2p-bind-ip=0.0.0.0
p2p-bind-port=18080

# RPC configuration
rpc-restricted-bind-ip=0.0.0.0
rpc-restricted-bind-port=18089
no-igd=1
no-zmq=1
enable-dns-blocklist=1

# I2P Configuration - THIS IS THE KEY PART
# tx-proxy tells monerod to use i2pd's SOCKS proxy for outbound I2P connections
tx-proxy=i2p,127.0.0.1:4447
EOF

if [ -n "$I2P_P2P_ADDRESS" ]; then
    echo "anonymous-inbound=$I2P_P2P_ADDRESS:18084,127.0.0.1:18084,25" >> "$MONERO_CONFIG"
    echo "STATUS:Configured I2P P2P tunnel: $I2P_P2P_ADDRESS"
else
    echo "# anonymous-inbound=<your-b32.i2p-address>:18084,127.0.0.1:18084,25" >> "$MONERO_CONFIG"
    echo "STATUS:Please manually add your I2P address to $MONERO_CONFIG"
    echo "STATUS:Get your b32.i2p address from: http://127.0.0.1:7070 (i2pd web console)"
fi

echo "STATUS:Adding trusted I2P nodes..."
TRUSTED_NODES=(
    "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089"
    "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089"
    "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089"
    "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089"
)

for node in "${TRUSTED_NODES[@]}"; do
    echo "TRUSTED_NODE:$node"
done

create_and_start_monerod_service

echo "STATUS:Waiting for services to initialize..."
sleep 10

if is_process_running "i2pd"; then
    echo "STATUS:i2pd service is running"
else
    echo "STATUS:Warning: i2pd service may not be running properly"
    case "$OS_TYPE" in
        "macos")
            echo "STATUS:Try: brew services start i2pd"
            ;;
        "linux")
            echo "STATUS:Try: sudo systemctl start i2pd"
            ;;
        "windows")
            echo "STATUS:Try starting i2pd manually or check Windows Services"
            ;;
        "android")
            echo "STATUS:Try: i2pd --daemon"
            ;;
    esac
fi

# Check for monerod (handle .exe on Windows)
if [ "$OS_TYPE" = "windows" ]; then
    MONEROD_PROCESS="monerod.exe"
else
    MONEROD_PROCESS="monerod"
fi

if is_process_running "$MONEROD_PROCESS"; then
    echo "STATUS:monerod service is running"
    echo "STATUS:Waiting for I2P tunnel connection..."
    sleep 20  # Give I2P time to establish tunnels

    if run_with_timeout 5 monerod status | grep -q "Height:"; then
        echo "STATUS:CONNECTED"
    else
        echo "STATUS:Monero daemon started, but I2P connection may still be initializing"
        echo "STATUS:Check $MONERO_LOG for details"
    fi
else
    echo "STATUS:Error: monerod service failed to start"
    echo "STATUS:Check $MONERO_LOG for details"
    echo "STATUS:Try running manually: monerod --config-file=$MONERO_CONFIG"
    exit 1
fi

echo "STATUS:I2P node setup complete"
echo "STATUS:Monero config: $MONERO_CONFIG"
echo "STATUS:Monero log: $MONERO_LOG"
exit 0
