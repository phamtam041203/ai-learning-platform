"""Read quiz PDF content to analyze format"""
import sys
sys.path.insert(0, '.')
import os

try:
    import fitz  # PyMuPDF
except ImportError:
    print("PyMuPDF not installed, trying pdfplumber...")
    import pdfplumber

quiz_path = r"D:\KLTN\ai-learning-platform\Courses\CoSoNganh\NhapMonCNTT\BaiTap"

# List files
files = os.listdir(quiz_path)
print(f"Files in {quiz_path}:")
for f in files:
    print(f"  - {f}")

# Read first quiz file
first_file = files[0] if files else None
if first_file:
    file_path = os.path.join(quiz_path, first_file)
    print(f"\n{'='*60}")
    print(f"Reading: {first_file}")
    print('='*60)
    
    try:
        doc = fitz.open(file_path)
        text = ""
        for page in doc:
            text += page.get_text()
        doc.close()
        print(text[:4000])
    except Exception as e:
        print(f"Error with fitz: {e}")
        try:
            import pdfplumber
            with pdfplumber.open(file_path) as pdf:
                for page in pdf.pages:
                    text = page.extract_text()
                    if text:
                        print(text[:4000])
                        break
        except Exception as e2:
            print(f"Error with pdfplumber: {e2}")
