# Cursor Agents for Monero GUI Upgrade

## General Rules
- Always use C++23 features where beneficial (e.g., std::ranges for TransactionHistoryModel, std::expected for error handling in Wallet.cpp).
- For Qt 6.10/QML: Use QML modules like QtQuick 2.17, avoid deprecated QtQuick.Controls 1; prefer signals/slots over callbacks.
- Docker-First: Suggest changes to CMakeLists.txt/Dockerfiles for cross-platform; never assume native builds.
- Error-Free: Generate code with static_asserts, Q_INVOKABLE for QML exposure, and unit tests via QtTest.
- Security: For crypto (Monero), use libsodium for all crypto ops; add const-correctness, no raw pointers.
- Prompt Style: Be verbose, reference files (e.g., "In src/libwalletqt/Wallet.cpp"), suggest diffs.

## Upgrade Agent
- Focus: Port Qt5 -> Qt6 (e.g., replace QQuickView with QQmlApplicationEngine), C++17 -> C++23 (e.g., coroutines in network.cpp).
- Output: Multi-file Composer edits + tests.

## I2P Agent
- Integrate via libi2pd (C++ wrapper); toggle in Settings.qml.

## Security Agent
- Add features like TOTP 2FA, hardware attestation.