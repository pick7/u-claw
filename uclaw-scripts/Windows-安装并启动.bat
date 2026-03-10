@echo off
chcp 65001 >nul 2>&1
title U-Claw - Install and Launch

echo.
echo   ========================================
echo     U-Claw v1.1
echo     Install and Launch (Windows)
echo   ========================================
echo.

set "USB_DIR=%~dp0"
set "ARCHIVE=%USB_DIR%U-Claw.tar.gz"
set "INSTALL_DIR=%USERPROFILE%\U-Claw"

REM Check archive
if not exist "%ARCHIVE%" (
    echo   [ERROR] U-Claw.tar.gz not found
    echo   Please ensure this script and the archive are in the same directory
    echo.
    pause
    exit /b 1
)

REM Check if already installed
if exist "%INSTALL_DIR%\openclaw\node_modules" (
    echo   U-Claw already installed at: %INSTALL_DIR%
    echo.
    echo   [1] Launch directly (skip extract)
    echo   [2] Reinstall (overwrite)
    echo.
    set /p choice="  Choose [1/2, default 1]: "
    if "%choice%"=="2" (
        echo.
        echo   Reinstalling...
        rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    ) else (
        echo.
        echo   Launching...
        goto :start
    )
)

REM Extract
echo.
echo   Extracting U-Claw to %INSTALL_DIR% ...
echo   This may take 1-2 minutes...
echo.

where tar >nul 2>&1
if %errorlevel%==0 (
    cd /d "%USERPROFILE%"
    tar xzf "%ARCHIVE%"
    if %errorlevel% neq 0 (
        echo   Extract failed! Please extract U-Claw.tar.gz manually
        echo   using 7-Zip or WinRAR to %USERPROFILE%
        pause
        exit /b 1
    )
) else (
    echo   tar command not available on this Windows version
    echo   Please extract U-Claw.tar.gz manually using 7-Zip or WinRAR
    echo   Extract to: %USERPROFILE%
    echo.
    echo   Then run: %INSTALL_DIR%\Windows-从U盘启动.bat
    pause
    exit /b 1
)

echo   Extract complete!
echo.

:start
REM Launch OpenClaw
echo   Starting OpenClaw...
echo.

cd /d "%INSTALL_DIR%"
call "%INSTALL_DIR%\Windows-从U盘启动.bat"
