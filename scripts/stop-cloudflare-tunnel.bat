@echo off
setlocal

set "ROOT=%~dp0.."
set "PID_FILE=%ROOT%\tools\cloudflared\stable-tunnel.pid"

if not exist "%PID_FILE%" (
  echo No stable tunnel pid file found. Trying to stop any cloudflared process.
  taskkill /IM cloudflared.exe /F >nul 2>nul
  exit /b 0
)

set /p PID=<"%PID_FILE%"
if "%PID%"=="" (
  echo PID file is empty.
  exit /b 1
)

taskkill /PID %PID% /F
del "%PID_FILE%" >nul 2>nul