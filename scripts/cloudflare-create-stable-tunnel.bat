@echo off
setlocal EnableDelayedExpansion

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.cloudflare-tunnel.env"
set "CLOUDFLARED=%ROOT%\tools\cloudflared\cloudflared.exe"
set "CF_DIR=%USERPROFILE%\.cloudflared"
set "OUTPUT_JSON=%ROOT%\tools\cloudflared\create-output.json"
set "CONFIG_FILE=%ROOT%\tools\cloudflared\config.stable.yml"

if not exist "%ENV_FILE%" (
  echo Missing %ENV_FILE%
  echo Copy .cloudflare-tunnel.env.example to .cloudflare-tunnel.env and set CF_TUNNEL_HOSTNAME first.
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
  if not "%%A"=="" set "%%A=%%B"
)

if "%CF_TUNNEL_NAME%"=="" (
  echo CF_TUNNEL_NAME is missing.
  exit /b 1
)

if "%CF_TUNNEL_HOSTNAME%"=="" (
  echo CF_TUNNEL_HOSTNAME is missing.
  exit /b 1
)

if not exist "%CF_DIR%" mkdir "%CF_DIR%"

"%CLOUDFLARED%" tunnel create --output json %CF_TUNNEL_NAME% > "%OUTPUT_JSON%"
if errorlevel 1 exit /b %errorlevel%

for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$json = Get-Content -Raw '%OUTPUT_JSON%' | ConvertFrom-Json; Write-Output ('ID=' + $json.id); Write-Output ('CRED=' + $json.credentials_file)"`) do (
  set "%%i"
)

if "!ID!"=="" (
  echo Could not extract tunnel ID from %OUTPUT_JSON%
  exit /b 1
)

(
  echo tunnel: !ID!
  echo credentials-file: !CRED!
  echo.
  echo ingress:
  echo   - hostname: %CF_TUNNEL_HOSTNAME%
  echo     service: http://localhost:80
  echo   - service: http_status:404
) > "%CONFIG_FILE%"

"%CLOUDFLARED%" tunnel route dns %CF_TUNNEL_NAME% %CF_TUNNEL_HOSTNAME%
if errorlevel 1 exit /b %errorlevel%

echo Stable tunnel created.
echo Tunnel name: %CF_TUNNEL_NAME%
echo Hostname: %CF_TUNNEL_HOSTNAME%
echo Config file: %CONFIG_FILE%