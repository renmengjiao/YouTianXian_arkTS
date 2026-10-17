@echo off
setlocal
set "TASK_ACTION=Run"
if not "%~2"=="" goto usage
if "%~1"=="" goto run
if /I "%~1"=="--check" set "TASK_ACTION=Check"
if /I "%~1"=="--install" set "TASK_ACTION=Install"
if /I "%~1"=="--build" set "TASK_ACTION=Run"
if /I "%~1"=="--no-maximize" set "TASK_ACTION=Run"
if /I "%~1"=="--check" goto run
if /I "%~1"=="--install" goto run
if /I "%~1"=="--build" goto run
if /I "%~1"=="--no-maximize" goto run
:usage
echo Usage: start-aligned.cmd [--check ^| --build ^| --install ^| --no-maximize]
exit /b 1
:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" -Action %TASK_ACTION%
exit /b %ERRORLEVEL%
