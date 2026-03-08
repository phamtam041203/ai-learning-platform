"""
Run script cho Backend
Sử dụng: python run.py
"""
import importlib
import os
import subprocess
import sys

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

PROJECT_PYTHON = os.path.join(
    os.path.dirname(__file__),
    "venv",
    "Scripts",
    "python.exe"
)


def ensure_project_python():
    current_python = os.path.abspath(sys.executable)
    expected_python = os.path.abspath(PROJECT_PYTHON)

    if not os.path.exists(expected_python):
        return

    if current_python.lower() == expected_python.lower():
        return

    print("ℹ️ Detected a different Python environment.")
    print(f"   Current : {current_python}")
    print(f"   Project : {expected_python}")
    print("   Restarting with the backend project environment...")
    subprocess.run([expected_python, __file__], check=True)
    raise SystemExit(0)


def validate_startup_imports():
    try:
        importlib.import_module("app.main")
    except ModuleNotFoundError as exc:
        missing_module = exc.name or "unknown"
        print("❌ Backend startup failed: missing Python dependency")
        print(f"   Missing module: {missing_module}")
        print(f"   Python executable: {sys.executable}")
        print("   Recommended command:")
        print("   .\\venv\\Scripts\\python.exe run.py")
        print("   Or install dependencies into the active interpreter:")
        print("   pip install -r requirements.txt")
        raise

if __name__ == "__main__":
    ensure_project_python()

    import uvicorn

    print("="*60)
    print("🎓 ĐỒ ÁN TỐT NGHIỆP - ĐẠI HỌC VĂN LANG")
    print("   Phát triển ứng dụng AI trong Cá nhân hóa học tập")
    print("="*60)
    print("📍 Server: http://localhost:8000")
    print("📖 API Docs: http://localhost:8000/docs")
    print("🔄 Auto-reload: Enabled")
    print("="*60)
    print()

    validate_startup_imports()
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    )