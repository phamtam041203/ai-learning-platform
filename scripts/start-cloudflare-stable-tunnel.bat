@echo off
setlocal

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.cloudflare-tunnel.env"
set "CLOUDFLARED=%ROOT%\tools\cloudflared\cloudflared.exe"
set "CONFIG_FILE=%ROOT%\tools\cloudflared\config.stable.yml"
set "PID_FILE=%ROOT%\tools\cloudflared\stable-tunnel.pid"
set "LOG_FILE=%ROOT%\tools\cloudflared\stable-tunnel.log"

if not exist "%ENV_FILE%" (
  echo Missing %ENV_FILE%
  exit /b 1
)

if not exist "%CONFIG_FILE%" (
  echo Missing %CONFIG_FILE%
  echo Run scripts\cloudflare-create-stable-tunnel.bat first.
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
  if not "%%A"=="" set "%%A=%%B"
)

start "cloudflare-stable-tunnel" /min cmd /c ""%CLOUDFLARED%" tunnel --config "%CONFIG_FILE%" --pidfile "%PID_FILE%" --logfile "%LOG_FILE%" --no-autoupdate run %CF_TUNNEL_NAME%"
echo Started stable Cloudflare Tunnel for %CF_TUNNEL_NAME%.
echo Log: %LOG_FILE%