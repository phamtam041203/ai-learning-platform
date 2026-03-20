"""
Test script for lesson API endpoint
"""
import requests
from pathlib import Path

# Test 1: List all lessons
print("=" * 60)
print("Test 1: List all lessons")
print("=" * 60)

try:
    response = requests.get("http://localhost:8000/api/lessons")
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Total lessons: {data['total']}")
        for lesson in data['lessons'][:3]:
            print(f"  - {lesson['name']}")
    else:
        print(f"Error: {response.text}")
except Exception as e:
    print(f"Exception: {e}")

# Test 2: Try to get a specific lesson file
print("\n" + "=" * 60)
print("Test 2: Get specific lesson file")
print("=" * 60)

file_name = "Lecture 00 - Course Introduction.pdf"
encoded_file = requests.utils.quote(file_name, safe='')
print(f"File name: {file_name}")
print(f"Encoded: {encoded_file}")
print(f"URL: http://localhost:8000/api/lessons/{encoded_file}")

try:
    response = requests.head(f"http://localhost:8000/api/lessons/{encoded_file}")
    print(f"Status: {response.status_code}")
    print(f"Headers: {dict(response.headers)}")
except Exception as e:
    print(f"Exception: {e}")

# Test 3: Check file path exists locally
print("\n" + "=" * 60)
print("Test 3: Check file path locally")
print("=" * 60)

lesson_dir = Path(r"D:\KLTN\ai-learning-platform\Courses\CNPM\Laptrinhungdungweb")
file_path = lesson_dir / file_name
print(f"Directory exists: {lesson_dir.exists()}")
print(f"File exists: {file_path.exists()}")
print(f"File path: {file_path}")

if file_path.exists():
    print(f"File size: {file_path.stat().st_size} bytes")
