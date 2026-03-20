@echo off
setlocal

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.cloudflare-tunnel.env"
set "OUT_FILE=%ROOT%\tools\cloudflared\public-url.txt"

if not exist "%ENV_FILE%" (
  echo Missing %ENV_FILE%
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
  if not "%%A"=="" set "%%A=%%B"
)

if "%CF_TUNNEL_URL%"=="" (
  if "%CF_TUNNEL_HOSTNAME%"=="" (
    echo Missing CF_TUNNEL_URL or CF_TUNNEL_HOSTNAME in %ENV_FILE%
    exit /b 1
  )
  set "CF_TUNNEL_URL=https://%CF_TUNNEL_HOSTNAME%"
)

> "%OUT_FILE%" echo %CF_TUNNEL_URL%
echo Wrote %CF_TUNNEL_URL% to %OUT_FILE%