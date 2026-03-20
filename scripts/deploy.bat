@echo off
setlocal

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.env.vps"
set "COMPOSE_FILE=%ROOT%\docker\docker-compose.vps.yml"
set "DOCKER_EXE=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "PATH=C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\Docker\Docker\resources;C:\Program Files\Docker\Docker\com.docker.cli;%PATH%"

if not exist "%DOCKER_EXE%" (
	echo Docker binary not found at "%DOCKER_EXE%".
	echo Install Docker Desktop or adjust the script path.
	exit /b 1
)

if not exist "%ENV_FILE%" (
	echo Missing %ENV_FILE%
	echo Copy .env.vps.example to .env.vps and edit PUBLIC_BASE_URL, passwords, and API keys first.
	exit /b 1
)

pushd "%ROOT%\docker"
"%DOCKER_EXE%" compose -f docker-compose.vps.yml --env-file "%ENV_FILE%" up -d --build
set "EXIT_CODE=%ERRORLEVEL%"
popd

if not "%EXIT_CODE%"=="0" exit /b %EXIT_CODE%

echo.
echo Deployment complete.
echo Open your app at the PUBLIC_BASE_URL configured in .env.vps.
echo If users access from the Internet, also ensure router port forwarding and Windows Firewall allow TCP 80.
