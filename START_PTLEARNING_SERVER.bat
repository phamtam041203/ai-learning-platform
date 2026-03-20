@echo off
setlocal

set "ROOT=%~dp0"
set "DOCKER_EXE=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "DOCKER_DESKTOP=C:\Program Files\Docker\Docker\Docker Desktop.exe"
set "TUNNEL_PID_FILE=%ROOT%tools\cloudflared\stable-tunnel.pid"
set "PATH=C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\Docker\Docker\resources;C:\Program Files\Docker\Docker\com.docker.cli;%PATH%"

echo ========================================
echo  PTLEARNING SERVER STARTER
echo ========================================
echo.

if not exist "%DOCKER_EXE%" (
  echo Docker binary not found:
  echo %DOCKER_EXE%
  pause
  exit /b 1
)

if not exist "%ROOT%scripts\start.bat" (
  echo Missing script: %ROOT%scripts\start.bat
  pause
  exit /b 1
)

if not exist "%ROOT%scripts\start-cloudflare-stable-tunnel.bat" (
  echo Missing script: %ROOT%scripts\start-cloudflare-stable-tunnel.bat
  pause
  exit /b 1
)

echo [1/4] Checking Docker daemon...
"%DOCKER_EXE%" info >nul 2>&1
if errorlevel 1 (
  echo Docker is not ready. Starting Docker Desktop...
  if exist "%DOCKER_DESKTOP%" (
    start "Docker Desktop" "%DOCKER_DESKTOP%"
  ) else (
    echo Docker Desktop not found:
    echo %DOCKER_DESKTOP%
    pause
    exit /b 1
  )

  echo Waiting for Docker to become ready...
  set "READY="
  for /L %%I in (1,1,60) do (
    "%DOCKER_EXE%" info >nul 2>&1
    if not errorlevel 1 (
      set "READY=1"
      goto docker_ready
    )
    timeout /t 2 /nobreak >nul
  )

  echo Docker did not become ready in time.
  pause
  exit /b 1
)

:docker_ready
echo Docker is ready.
echo.

echo [2/4] Starting public application stack...
call "%ROOT%scripts\start.bat"
if errorlevel 1 (
  echo Failed to start public stack.
  pause
  exit /b 1
)
echo Public stack is up.
echo.

echo [3/4] Checking Cloudflare tunnel...
set "START_TUNNEL=1"
if exist "%TUNNEL_PID_FILE%" (
  set /p TUNNEL_PID=<"%TUNNEL_PID_FILE%"
  if not "%TUNNEL_PID%"=="" (
    tasklist /FI "PID eq %TUNNEL_PID%" | find "%TUNNEL_PID%" >nul 2>&1
    if not errorlevel 1 (
      echo Cloudflare tunnel is already running with PID %TUNNEL_PID%.
      set "START_TUNNEL=0"
    ) else (
      del "%TUNNEL_PID_FILE%" >nul 2>&1
    )
  )
)

if "%START_TUNNEL%"=="1" (
  echo Starting Cloudflare stable tunnel...
  call "%ROOT%scripts\start-cloudflare-stable-tunnel.bat"
  if errorlevel 1 (
    echo Failed to start Cloudflare tunnel.
    pause
    exit /b 1
  )
)
echo.

echo [4/4] Done.
echo Local:  http://localhost
echo Public: https://ptlearning.id.vn
echo.
echo You can close this window after checking the messages above.
pause
