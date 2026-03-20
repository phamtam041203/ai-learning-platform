@echo off
setlocal

set "ROOT=%~dp0.."
set "EXAMPLE_FILE=%ROOT%\.env.vps.example"
set "TARGET_FILE=%ROOT%\.env.vps"

if exist "%TARGET_FILE%" (
	echo %TARGET_FILE% already exists.
	exit /b 0
)

copy "%EXAMPLE_FILE%" "%TARGET_FILE%" >nul
echo Created %TARGET_FILE%
echo Edit PUBLIC_BASE_URL, POSTGRES_PASSWORD, SECRET_KEY, and API keys before deploying.
