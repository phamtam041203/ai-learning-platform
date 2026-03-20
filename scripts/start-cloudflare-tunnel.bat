@echo off
setlocal

set "ROOT=%~dp0.."
set "CLOUDFLARED=%ROOT%\tools\cloudflared\cloudflared.exe"

if not exist "%CLOUDFLARED%" (
  echo Missing cloudflared binary at "%CLOUDFLARED%".
  echo Download it first or ask Copilot to install it.
  exit /b 1
)

if exist "%USERPROFILE%\.cloudflared\config.yml" (
  echo Quick Tunnel may fail because "%USERPROFILE%\.cloudflared\config.yml" exists.
  echo Rename that file temporarily if the tunnel does not start.
)

"%CLOUDFLARED%" tunnel --url http://localhost:80 --no-autoupdate