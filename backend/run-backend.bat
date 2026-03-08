@echo off
setlocal

cd /d "%~dp0"

if not exist "venv\Scripts\python.exe" (
    echo [ERROR] Khong tim thay Python trong backend\venv
    echo Hay tao hoac cai dat lai virtual environment cho backend.
    pause
    exit /b 1
)

echo ============================================================
echo BACKEND - AI Learning Platform
echo Python: %CD%\venv\Scripts\python.exe
echo Server: http://localhost:8000
echo Docs  : http://localhost:8000/docs
echo ============================================================
echo.

"venv\Scripts\python.exe" run.py

endlocal