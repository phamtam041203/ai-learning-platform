@echo off
setlocal

set "ROOT=%~dp0.."
set "ENV_FILE=%ROOT%\.env.vps"
set "DOCKER_EXE=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
set "PATH=C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\Docker\Docker\resources;C:\Program Files\Docker\Docker\com.docker.cli;%PATH%"

pushd "%ROOT%\docker"
"%DOCKER_EXE%" compose -f docker-compose.vps.yml --env-file "%ENV_FILE%" down
set "EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %EXIT_CODE%
