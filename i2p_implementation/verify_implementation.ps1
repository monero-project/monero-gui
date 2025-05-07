# PowerShell script to verify that I2P methods have been properly applied to wallet2.cpp
$ErrorActionPreference = "Stop"

# Define color codes for output
$GREEN = [char]27 + "[32m"
$RED = [char]27 + "[31m"
$YELLOW = [char]27 + "[33m"
$RESET = [char]27 + "[0m"

# Configuration
$MONERO_GUI_DIR = (Get-Location).Path
if ($MONERO_GUI_DIR.EndsWith("i2p_implementation")) {
    $MONERO_GUI_DIR = (Split-Path -Parent $MONERO_GUI_DIR)
}

$wallet2_cpp = "$MONERO_GUI_DIR/monero/src/wallet/wallet2.cpp"
Write-Host "Looking for wallet2.cpp at: $wallet2_cpp"

# Function to write a success message
function Write-Success {
    param (
        [string]$text
    )
    
    Write-Host "$GREEN[SUCCESS]$RESET $text"
}

# Function to write an error message
function Write-ErrorMsg {
    param (
        [string]$text
    )
    
    Write-Host "$RED[ERROR]$RESET $text"
}

# Function to write a section header
function Write-Header {
    param (
        [string]$text
    )
    
    Write-Host "$YELLOW$text$RESET"
}

Write-Header "`nVerifying I2P implementation in wallet2.cpp...`n"

# Check if wallet2.cpp exists
if (-not (Test-Path $wallet2_cpp)) {
    Write-ErrorMsg "Could not find wallet2.cpp at: $wallet2_cpp"
    exit 1
}

# Read the content of wallet2.cpp
try {
    $wallet2_content = Get-Content $wallet2_cpp -Raw -ErrorAction Stop
    Write-Success "Successfully read wallet2.cpp"
}
catch {
    Write-ErrorMsg "Error reading wallet2.cpp: $_"
    exit 1
}

# Define the methods to check for
$methods = @(
    @{ Name = "set_i2p_enabled"; Pattern = "bool wallet2::set_i2p_enabled\(bool enabled\)"; Description = "I2P enablement method" },
    @{ Name = "set_i2p_options"; Pattern = "bool wallet2::set_i2p_options\(const std::string &options\)"; Description = "I2P options configuration method" },
    @{ Name = "parse_i2p_options"; Pattern = "bool wallet2::parse_i2p_options\("; Description = "I2P options parsing method" },
    @{ Name = "init_i2p_connection"; Pattern = "bool wallet2::init_i2p_connection\("; Description = "I2P connection initialization method" },
    @{ Name = "discover_i2p_peers"; Pattern = "bool wallet2::discover_i2p_peers\("; Description = "I2P peer discovery method" }
)

# Check for each method
$all_methods_found = $true
foreach ($method in $methods) {
    if ($wallet2_content -match $method.Pattern) {
        Write-Success "Found $($method.Name) implementation in wallet2.cpp"
    } else {
        Write-ErrorMsg "Missing $($method.Name) implementation in wallet2.cpp"
        $all_methods_found = $false
    }
}

# Special checks for the check_connection method
$check_connection_found = $false

# Check if the file contains the I2P comment
if ($wallet2_content -match "// If I2P is enabled") {
    Write-Success "Found I2P peer discovery comment in check_connection method"
    $check_connection_found = $true
}

# Check if the file contains the m_i2p_enabled check
elseif ($wallet2_content -match "if\s*\(\s*m_i2p_enabled\s*\)") {
    Write-Success "Found I2P peer discovery check in check_connection method"
    $check_connection_found = $true
}

# Check if the file contains the discover_i2p_peers call
elseif ($wallet2_content -match "discover_i2p_peers\(\)") {
    Write-Success "Found discover_i2p_peers call in check_connection method"
    $check_connection_found = $true
}

if (!$check_connection_found) {
    Write-ErrorMsg "Missing I2P peer discovery call in check_connection method"
    $all_methods_found = $false
}

# Output the final status
Write-Header "`nVerification Complete`n"
if ($all_methods_found) {
    Write-Success "All I2P methods have been successfully implemented in wallet2.cpp"
    exit 0
} else {
    Write-ErrorMsg "Some I2P methods are missing from wallet2.cpp"
    Write-Host "You may need to run apply_changes.ps1 to update the implementation"
    exit 1
} 