@echo off
REM Quick launcher for MSYS2 MinGW 64-bit with build instructions
REM Run this from Windows PowerShell/CMD

echo ========================================================
echo   Monero GUI I2P Integration - Build Launcher
echo ========================================================
echo.
echo This will open MSYS2 MinGW 64-bit terminal
echo and navigate to your project directory.
echo.
echo After it opens, run one of these commands:
echo.
echo   Option 1 - Use the helper script:
echo     bash build_i2p.sh
echo.
echo   Option 2 - Build manually:
echo     make release-win64
echo.
echo ========================================================
echo.
pause

REM Launch MSYS2 MinGW 64-bit in the project directory
C:\msys64\msys2_shell.cmd -mingw64 -defterm -here -no-start
