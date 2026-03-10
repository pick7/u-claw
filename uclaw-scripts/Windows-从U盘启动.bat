@echo off
chcp 65001 >nul 2>&1
title U-Claw - OpenClaw Launcher

echo.
echo   ========================================
echo     U-Claw v1.1
echo     OpenClaw One-Click Launcher (Windows)
echo   ========================================
echo.
echo   Recommended: temporary PC / no local install
echo.

set "UCLAW_DIR=%~dp0"
set "OPENCLAW_DIR=%UCLAW_DIR%openclaw"
set "NODE_DIR=%UCLAW_DIR%runtime\node-win-x64"
set "NODE_BIN=%NODE_DIR%\node.exe"
set "NPM_BIN=%NODE_DIR%\npm.cmd"
set "PORTABLE_HOME=%UCLAW_DIR%portable-home"
set "PORTABLE_STATE_DIR=%PORTABLE_HOME%\.openclaw"
set "PORTABLE_CONFIG_PATH=%PORTABLE_STATE_DIR%\openclaw.json"

set "OPENCLAW_HOME=%PORTABLE_HOME%"
set "OPENCLAW_STATE_DIR=%PORTABLE_STATE_DIR%"
set "OPENCLAW_CONFIG_PATH=%PORTABLE_CONFIG_PATH%"

if not exist "%PORTABLE_STATE_DIR%" mkdir "%PORTABLE_STATE_DIR%"

if not exist "%NODE_BIN%" (
    echo   [ERROR] Node.js not found
    echo   Please ensure runtime\node-win-x64 directory is complete
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('"%NODE_BIN%" --version') do set NODE_VER=%%v
echo   Node.js: %NODE_VER%
echo.

set "PATH=%NODE_DIR%;%NODE_DIR%\node_modules\.bin;%PATH%"

if not exist "%OPENCLAW_DIR%\node_modules" (
    echo   First run - installing dependencies...
    echo   Using China mirror, please wait...
    echo.
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" install --registry=https://registry.npmmirror.com
    echo.
    echo   Dependencies installed!
    echo.
)

if not exist "%OPENCLAW_DIR%\dist" (
    echo   First run - building...
    cd /d "%OPENCLAW_DIR%"
    call "%NPM_BIN%" run build
    echo.
)

cd /d "%OPENCLAW_DIR%"

REM First run: auto-create minimal config (skip onboard)
if not exist "%PORTABLE_CONFIG_PATH%" (
    echo   First run - initializing config...
    if not exist "%PORTABLE_STATE_DIR%" mkdir "%PORTABLE_STATE_DIR%"
    echo {"gateway":{"mode":"local","auth":{"token":"uclaw"}}} > "%PORTABLE_CONFIG_PATH%"
    echo   Config initialized
    echo.
)

echo   Starting OpenClaw...
echo   DO NOT close this window!
echo.
echo   ----------------------------------------
echo   Browser will open automatically.
echo   First time setup in web console:
echo     1. Choose AI model (DeepSeek / Kimi / Qwen)
echo     2. Connect chat platform (QQ / Feishu / DingTalk)
echo   ----------------------------------------
echo.

start "" http://127.0.0.1:18789/#token=uclaw
"%NODE_BIN%" openclaw.mjs gateway run --allow-unconfigured --force

echo.
echo   OpenClaw stopped. You can safely remove the USB drive.
pause
