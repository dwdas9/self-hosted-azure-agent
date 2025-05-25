@echo off
echo.
echo ========================================
echo Azure DevOps Self-Hosted Agent Setup
echo ========================================
echo.
echo This will start the PowerShell setup script.
echo Make sure you have Docker installed and running!
echo.
pause
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup-agent.ps1"
pause
