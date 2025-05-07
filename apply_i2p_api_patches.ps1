#!/usr/bin/env pwsh
# Script to apply I2P API patches to the Monero wallet API

$ErrorActionPreference = "Stop"

Write-Host "Applying I2P API patches to Monero wallet API..." -ForegroundColor Cyan

# Define the patch files and their targets
$patches = @{
    "src/wallet/api/patches/wallet.h.patch" = "monero/src/wallet/api/wallet.h";
    "src/wallet/api/patches/wallet.cpp.patch" = "monero/src/wallet/api/wallet.cpp";
    "src/wallet/api/patches/wallet_manager.h.patch" = "monero/src/wallet/api/wallet_manager.h";
    "src/wallet/api/patches/wallet_manager.cpp.patch" = "monero/src/wallet/api/wallet_manager.cpp";
}

# Ensure the patches directory exists
$patchesDir = "src/wallet/api/patches"
if (-not (Test-Path $patchesDir)) {
    New-Item -Path $patchesDir -ItemType Directory -Force | Out-Null
    Write-Host "Created patches directory: $patchesDir" -ForegroundColor Yellow
}

# Apply each patch
foreach ($patchFile in $patches.Keys) {
    $targetFile = $patches[$patchFile]
    
    # Check if the patch file exists
    if (-not (Test-Path $patchFile)) {
        Write-Error "Patch file not found: $patchFile"
        continue
    }
    
    # Check if the target file exists
    if (-not (Test-Path $targetFile)) {
        Write-Error "Target file not found: $targetFile"
        continue
    }
    
    # Apply the patch using git apply
    Write-Host "Applying patch: $patchFile to $targetFile" -ForegroundColor Yellow
    try {
        # Use git apply with specific target path
        git apply --whitespace=fix $patchFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successfully applied patch" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Failed to apply patch with git apply" -ForegroundColor Red
            
            # Fallback to manual patch application for simple additions
            try {
                $patchContent = Get-Content $patchFile -Raw
                $targetContent = Get-Content $targetFile -Raw
                
                # Extract the additions from the patch
                $additions = [regex]::Matches($patchContent, '(?m)^\+[^+].*$') | ForEach-Object { $_.Value.Substring(1) }
                
                if ($additions.Count -gt 0) {
                    Write-Host "  Attempting manual patch application..." -ForegroundColor Yellow
                    
                    # Find insertion points and add the new code
                    $newContent = $targetContent
                    foreach ($addition in $additions) {
                        # Look for context in the patch
                        $contextBefore = [regex]::Match($patchContent, "(?m)^\s.*$addition").Value
                        if ($contextBefore) {
                            $newContent = $newContent.Replace($contextBefore, "$contextBefore`n$addition")
                        } else {
                            # Just append to the end of the file
                            $newContent += "`n$addition"
                        }
                    }
                    
                    # Write the modified content back to the target file
                    Set-Content -Path $targetFile -Value $newContent
                    Write-Host "  ✓ Successfully applied patch manually" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ Failed to extract additions from patch" -ForegroundColor Red
                }
            } catch {
                Write-Host "  ✗ Manual patch application failed: $_" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "  ✗ Error applying patch: $_" -ForegroundColor Red
    }
}

Write-Host "I2P API patches application completed!" -ForegroundColor Cyan 