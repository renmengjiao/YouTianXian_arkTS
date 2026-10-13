@echo off
setlocal

set "TASK_IDE=D:\devocode\DevEco Studio"
set "NODE_HOME=%TASK_IDE%\tools\node"
set "JAVA_HOME=%TASK_IDE%\jbr"
set "DEVECO_SDK_HOME=%TASK_IDE%\sdk"
set "PATH=%NODE_HOME%;%JAVA_HOME%\bin;%PATH%"

cd /d "%~dp0.."
if errorlevel 1 exit /b 1

if not exist ".hvigor\logs" mkdir ".hvigor\logs"
set "TASK_LOG=%CD%\.hvigor\logs\build-api26.log"

"%NODE_HOME%\node.exe" ^
  "%TASK_IDE%\tools\hvigor\bin\hvigorw.js" ^
  --mode module ^
  -p product=default ^
  -p module=default@default ^
  -p buildMode=debug ^
  assembleHap ^
  --no-daemon ^
  > "%TASK_LOG%" 2>&1

set "TASK_EXIT=%ERRORLEVEL%"
type "%TASK_LOG%"
echo.
echo Build exit code: %TASK_EXIT%
echo Build log: %TASK_LOG%

exit /b %TASK_EXIT%
