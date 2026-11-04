@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools\fs-rpc-browser\bootstrap.ps1" start %*
set "result=%errorlevel%"
if not "%result%"=="0" pause
exit /b %result%
