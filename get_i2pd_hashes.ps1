# Script to Download i2pd Binaries and Calculate SHA256 Hashes
# Run this in PowerShell to get the hashes needed for I2PManager.cpp

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  i2pd v2.54.0 SHA256 Hash Calculator" -ForegroundColor Cyan
Write-Host "  For Monero GUI I2P Integration" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Create temporary directory
$tempDir = "$env:TEMP\i2pd_hashes_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "[INFO] Created temporary directory: $tempDir" -ForegroundColor Green
Write-Host ""

# Define download URLs and filenames
$downloads = @(
    @{
        Name = "Windows (MinGW x64)"
        URL = "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_win64_mingw.zip"
        FileName = "i2pd_win64_mingw.zip"
        Platform = "Windows"
    },
    @{
        Name = "Linux (x86_64)"
        URL = "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_linux_amd64.tar.gz"
        FileName = "i2pd_linux_amd64.tar.gz"
        Platform = "Linux"
    },
    @{
        Name = "macOS (Intel x64)"
        URL = "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos.tar.gz"
        FileName = "i2pd_macos_x64.tar.gz"
        Platform = "macOS x64"
    },
    @{
        Name = "macOS (Apple Silicon ARM64)"
        URL = "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos_arm64.tar.gz"
        FileName = "i2pd_macos_arm64.tar.gz"
        Platform = "macOS ARM64"
    }
)

# Results storage
$results = @()

# Download and hash each file
foreach ($download in $downloads) {
    Write-Host "[DOWNLOAD] $($download.Name)..." -ForegroundColor Yellow
    $filePath = Join-Path $tempDir $download.FileName
    
    try {
        # Download file
        Invoke-WebRequest -Uri $download.URL -OutFile $filePath -UseBasicParsing
        
        # Get file size
        $fileSize = (Get-Item $filePath).Length / 1MB
        Write-Host "  Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
        
        # Calculate SHA256
        Write-Host "  Calculating SHA256..." -ForegroundColor Cyan
        $hash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash.ToLower()
        Write-Host "  Hash: $hash" -ForegroundColor Green
        Write-Host ""
        
        # Store result
        $results += @{
            Platform = $download.Platform
            Name = $download.Name
            FileName = $download.FileName
            Hash = $hash
            Size = [math]::Round($fileSize, 2)
        }
    }
    catch {
        Write-Host "  ERROR: Failed to download or hash file" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Display results summary
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    Write-Host "Platform: $($result.Platform)" -ForegroundColor Yellow
    Write-Host "File:     $($result.FileName)" -ForegroundColor White
    Write-Host "Size:     $($result.Size) MB" -ForegroundColor White
    Write-Host "SHA256:   $($result.Hash)" -ForegroundColor Green
    Write-Host ""
}

# Generate C++ code snippet
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  C++ CODE FOR I2PManager.cpp" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Replace the getExpectedHash() function with:" -ForegroundColor Yellow
Write-Host ""

$windowsHash = ($results | Where-Object { $_.Platform -eq "Windows" }).Hash
$linuxHash = ($results | Where-Object { $_.Platform -eq "Linux" }).Hash
$macX64Hash = ($results | Where-Object { $_.Platform -eq "macOS x64" }).Hash
$macARM64Hash = ($results | Where-Object { $_.Platform -eq "macOS ARM64" }).Hash

$cppCode = @"
QString I2PManager::getExpectedHash() const
{
    // SHA256 hashes for i2pd v2.54.0
    // Verified from official i2pd GitHub releases on $(Get-Date -Format 'yyyy-MM-dd')
    
#ifdef Q_OS_WIN
    return "$windowsHash"; // Windows MinGW x64
#elif defined(Q_OS_MACOS)
    #if defined(__aarch64__) || defined(__arm64__)
    return "$macARM64Hash"; // macOS Apple Silicon
    #else
    return "$macX64Hash"; // macOS Intel
    #endif
#elif defined(Q_OS_LINUX)
    return "$linuxHash"; // Linux x86_64
#else
    return ""; // Unsupported platform
#endif
}
"@

Write-Host $cppCode -ForegroundColor White
Write-Host ""

# Save to file
$outputFile = Join-Path $tempDir "I2PManager_hashes.cpp"
$cppCode | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "[SAVED] C++ code saved to: $outputFile" -ForegroundColor Green
Write-Host ""

# Generate git commit message
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  SUGGESTED GIT COMMIT MESSAGE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$commitMsg = @"
feat: Add verified SHA256 hashes for i2pd 2.54.0 binaries

Updated getExpectedHash() in I2PManager.cpp with real SHA256
checksums for all supported platforms:
- Windows (MinGW x64): $($windowsHash.Substring(0,16))...
- Linux (x86_64): $($linuxHash.Substring(0,16))...
- macOS (Intel): $($macX64Hash.Substring(0,16))...
- macOS (ARM64): $($macARM64Hash.Substring(0,16))...

All hashes verified by downloading from official i2pd GitHub releases:
https://github.com/PurpleI2P/i2pd/releases/tag/2.54.0

This enables secure hash verification for downloaded i2pd binaries.
"@

Write-Host $commitMsg -ForegroundColor White
Write-Host ""

# Save commit message
$commitFile = Join-Path $tempDir "commit_message.txt"
$commitMsg | Out-File -FilePath $commitFile -Encoding UTF8
Write-Host "[SAVED] Commit message saved to: $commitFile" -ForegroundColor Green
Write-Host ""

# Instructions
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copy the C++ code from: $outputFile" -ForegroundColor Yellow
Write-Host "2. Open: src/i2p/I2PManager.cpp" -ForegroundColor Yellow
Write-Host "3. Replace getExpectedHash() function (lines ~155-170)" -ForegroundColor Yellow
Write-Host "4. Save the file" -ForegroundColor Yellow
Write-Host "5. Commit changes:" -ForegroundColor Yellow
Write-Host "   git add src/i2p/I2PManager.cpp" -ForegroundColor White
Write-Host "   git commit -F `"$commitFile`"" -ForegroundColor White
Write-Host ""
Write-Host "[INFO] Temporary files saved in: $tempDir" -ForegroundColor Cyan
Write-Host "[INFO] You can delete this directory after copying the hashes" -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  DONE!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
