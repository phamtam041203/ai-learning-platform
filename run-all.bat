@echo off
echo ===============================
echo AI Learning Platform - RUN ALL
echo ===============================

echo Starting Backend...
start cmd /k "cd /d backend && call run-backend.bat"

timeout /t 3 >nul

echo Starting Frontend...
start cmd /k "cd frontend && npm run dev"

echo ===============================
echo DONE - Servers are running
echo ===============================

pause
