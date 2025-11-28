# Translation Update Summary for I2P Feature

## Overview
This document summarizes the translation updates made for the new I2P (Invisible Internet Project) feature in the Monero GUI.

## Date
$(date)

## New Translatable Strings Added

### From QML Files (pages/settings/SettingsI2P.qml)

1. **UI Labels:**
   - "I2P Node"
   - "Custom node"
   - "Create I2P Node (Recommended)"
   - "Connection status:"
   - "Connected"
   - "Not connected"

2. **Dialog Messages:**
   - "Enter your system password to set up I2P"
   - "Enter Password"
   - "Create I2P Node"
   - "Setting up your I2P node..."
   - "Did you know?"
   - "Cancel"

3. **Status Messages:**
   - "I2P node created successfully. Connecting..."
   - "Failed to set up I2P node. Please check logs or try again."
   - "Success"
   - "Error"
   - "Initializing..."

4. **Fun Facts (Educational Content):**
   - "Monero launched in April 2014 as a fork of the Bytecoin codebase."
   - "Ring signatures and stealth addresses hide the origin and destination of every transaction in Monero."
   - "Running your own node enhances your privacy and contributes to the network's decentralization."
   - "I2P (Invisible Internet Project) is a decentralized anonymizing network layer for secure communication."
   - "Monero uses ring signatures to mix your transaction with others, making it untraceable."
   - "I2P provides end-to-end encryption and routes traffic through multiple nodes for anonymity."
   - "Monero's privacy features are mandatory, not optional - every transaction is private by default."
   - "I2P nodes help strengthen the network by providing more routing options and redundancy."

### From C++ Files (src/i2p/I2PNodeManager.cpp)

1. **Status Messages:**
   - "I2P disabled"
   - "Connected to I2P"
   - "I2P enabled, waiting for node setup…"
   - "I2P setup script not found: %1"
   - "Starting I2P node setup…"
   - "Node setup cancelled"
   - "I2P node created and connected"
   - "I2P setup finished (check logs)"
   - "I2P setup failed (exit code %1)"
   - "I2P setup process error"

## Translation Files Updated

### Base Template File
- `translations/monero-core.ts` - Updated with all new strings

### Next Steps for Translators

1. **Update Language Files:**
   - All language-specific `.ts` files (e.g., `monero-core_en.ts`, `monero-core_fr.ts`, etc.) should be updated using `lupdate`
   - Run: `lupdate -extensions cpp,h,qml -no-obsolete -locations relative -recursive . -ts translations/monero-core_<lang>.ts`

2. **Translate New Strings:**
   - Open each language file in Qt Linguist or a text editor
   - Translate all strings marked as "unfinished"
   - Save the files

3. **Build Translations:**
   - The CMake build system will automatically compile `.ts` files to `.qm` files during the build process
   - Or manually run: `lrelease translations/monero-core_<lang>.ts`

## Verification

To verify translations are working:

1. Build the project
2. Launch the GUI
3. Navigate to Settings → Node → I2P section
4. Switch languages in the GUI settings
5. Verify all I2P-related strings appear in the selected language

## Commands Used

```bash
# Update base translation template
lupdate -extensions cpp,h,qml -no-obsolete -locations relative -recursive . -ts translations/monero-core.ts

# Update specific language (example for French)
lupdate -extensions cpp,h,qml -no-obsolete -locations relative -recursive . -ts translations/monero-core_fr.ts

# Build translations (done automatically by CMake, or manually)
lrelease translations/monero-core_<lang>.ts
```

## Notes

- All user-facing strings in QML use `qsTr()` wrapper
- All user-facing strings in C++ use `tr()` wrapper
- The translation system is integrated with Qt's translation framework
- Translations are embedded in the application binary via CMake

