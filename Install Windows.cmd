@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools\fs-rpc-browser\bootstrap.ps1" install
set "result=%errorlevel%"
pause
exit /b %result%
