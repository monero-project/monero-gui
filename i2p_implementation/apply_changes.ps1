# PowerShell script to add I2P implementation to wallet2.cpp

# Define the target files
$script_dir = Get-Location
$monero_gui_dir = if ((Get-Location).Path -match "i2p_implementation$") { Split-Path -Parent (Get-Location).Path } else { (Get-Location).Path }
$wallet2_cpp = "$monero_gui_dir/monero/src/wallet/wallet2.cpp"

Write-Host "Script directory: $script_dir"
Write-Host "Monero GUI directory: $monero_gui_dir"
Write-Host "Target wallet2.cpp path: $wallet2_cpp"

# Check if wallet2.cpp exists
if (-not (Test-Path $wallet2_cpp)) {
    Write-Host "Error: Cannot find wallet2.cpp at: $wallet2_cpp"
    exit 1
}

# Read the content of wallet2.cpp
$wallet2_content = Get-Content $wallet2_cpp -Raw

# Step 1: Add the I2P methods after the set_proxy method
$set_proxy_pattern = "bool wallet2::set_proxy\(const std::string &address\)\s*\{\s*return m_http_client->set_proxy\(address\);\s*\}"
$set_i2p_enabled_content = Get-Content "$script_dir/set_i2p_enabled.cpp" -Raw
$set_i2p_options_content = Get-Content "$script_dir/set_i2p_options.cpp" -Raw
$parse_i2p_options_content = Get-Content "$script_dir/parse_i2p_options.cpp" -Raw
$init_i2p_connection_content = Get-Content "$script_dir/init_i2p_connection.cpp" -Raw
$discover_i2p_peers_content = Get-Content "$script_dir/discover_i2p_peers.cpp" -Raw

$i2p_methods = @"
//----------------------------------------------------------------------------------------------------
$set_i2p_enabled_content
//----------------------------------------------------------------------------------------------------
$set_i2p_options_content
//----------------------------------------------------------------------------------------------------
$parse_i2p_options_content
//----------------------------------------------------------------------------------------------------
$init_i2p_connection_content
//----------------------------------------------------------------------------------------------------
$discover_i2p_peers_content
//----------------------------------------------------------------------------------------------------
"@

$wallet2_content = $wallet2_content -replace "$set_proxy_pattern(\s*//----------------------------------------------------------------------------------------------------)", "$&`n$i2p_methods"

# Step 2: Modify the check_connection method to call discover_i2p_peers when I2P is enabled
$check_connection_pattern = "if \(version\)\s*\*version = m_rpc_version;\s*\s*return true;"
$check_connection_new = Get-Content "$script_dir/check_connection.cpp" -Raw

$wallet2_content = $wallet2_content -replace $check_connection_pattern, $check_connection_new

# Write the modified content back to wallet2.cpp
Set-Content $wallet2_cpp $wallet2_content

Write-Host "Applied I2P implementation changes to wallet2.cpp" 