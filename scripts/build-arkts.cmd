@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Action Build
exit /b %ERRORLEVEL%
