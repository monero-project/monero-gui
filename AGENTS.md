1. Project Goal
We are performing a "world-class" migration of the Monero GUI to the C++23 standard  and the Qt 6.7 framework. All development MUST be conducted on this M3-native (arm64) environment. The objectives are code correctness, modernization, security, and performance.   

2. Architectural & Code Style Rules
C++ Standard: C++23. All new code MUST use C++23 features. All refactored code MUST be modernized to C++23.   

Qt Standard: Qt 6.7. All Qt 5 deprecated APIs are FORBIDDEN.   

Qt6:: namespaces MUST be used in CMake.

QtQuick.Controls 2 MUST be used. QtQuick.Controls 1 is removed.   

var properties MUST be used instead of variant.   

Modern QML layouts (GridLayout, Grid) are PREFERRED over Row, Column, and Anchors.   

Error-Free Mandate: All C++ code MUST compile without warnings and pass all clang-tidy checks.   

I2P Architecture: The I2P stack consists of:

The i2pd router, built as a static library (via Git submodule).   

The libsam3 C library  (via vcpkg) for SAM v3  communication.   

A new C++/Qt SAMManager class that wraps libsam3 for RAII and signal/slot integration.

The existing I2PManager , which orchestrates the i2pd library and SAMManager.   

3. Build & Test Commands (M3-Native)
**Configure (The "Ground-Truth" Command):**bash cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++17"

Build:

Bash

cmake --build build
Run (The "Live View"):

./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui ```

Run Tests:

Bash

cd build && ctest --output-on-failure
4. Commit Message Format
Commits MUST be "humanized," clear, and descriptive.

Use the format: type(scope): subject

type: feat, fix, refactor, build, style, test.

scope: qml, cmake, i2p, wallet, etc.

Example: refactor(qml): migrate Transfer.qml to use modern GridLayout


---
