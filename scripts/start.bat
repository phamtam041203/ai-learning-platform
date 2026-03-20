@echo off
setlocal

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.env.vps"
set "DOCKER_EXE=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "PATH=C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\Docker\Docker\resources;C:\Program Files\Docker\Docker\com.docker.cli;%PATH%"

if not exist "%ENV_FILE%" (
	echo Missing %ENV_FILE%
	exit /b 1
)

pushd "%ROOT%\docker"
"%DOCKER_EXE%" compose -f docker-compose.vps.yml --env-file "%ENV_FILE%" up -d
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
