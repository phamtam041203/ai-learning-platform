@echo off
setlocal

set "ROOT=%~dp0.."
set "CLOUDFLARED=%ROOT%\tools\cloudflared\cloudflared.exe"

if not exist "%CLOUDFLARED%" (
  echo Missing cloudflared binary.
  exit /b 1
)

"%CLOUDFLARED%" tunnel login