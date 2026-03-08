"""
Quick test of the lesson directory
"""
from pathlib import Path

lesson_dir = Path(r"D:\KLTN\ai-learning-platform\Courses\CNPM\Laptrinhungdungweb")
print(f"Directory exists: {lesson_dir.exists()}")
print(f"Is directory: {lesson_dir.is_dir()}")

if lesson_dir.exists():
    files = list(lesson_dir.glob("*.pdf"))
    print(f"Total files: {len(files)}")
    for f in files[:3]:
        print(f"  - {f.name}")
