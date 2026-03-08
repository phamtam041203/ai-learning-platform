"""
Script to convert PPTX files to PDF using Microsoft PowerPoint (Windows only)
Requires: Microsoft PowerPoint installed on the system
"""
import os
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

def convert_pptx_to_pdf_windows():
    """Convert all PPTX files to PDF using PowerPoint COM automation"""
    try:
        import comtypes.client
    except ImportError:
        print("❌ comtypes not installed. Installing...")
        os.system(f"{sys.executable} -m pip install comtypes")
        import comtypes.client
    
    # Path to lesson files
    lessons_dir = Path(__file__).resolve().parents[1] / "uploads" / "lessons"
    
    if not lessons_dir.exists():
        print(f"❌ Lessons directory not found: {lessons_dir}")
        return
    
    # Find all PPTX files
    pptx_files = list(lessons_dir.glob("*.pptx")) + list(lessons_dir.glob("*.ppt"))
    
    if not pptx_files:
        print("ℹ️ No PPTX/PPT files found to convert")
        return
    
    print(f"📂 Found {len(pptx_files)} PowerPoint files to convert")
    print(f"📍 Directory: {lessons_dir}")
    print("-" * 60)
    
    # Initialize PowerPoint
    powerpoint = None
    try:
        powerpoint = comtypes.client.CreateObject("PowerPoint.Application")
        powerpoint.Visible = 1  # Required to avoid some conversion issues
        
        converted = 0
        skipped = 0
        failed = 0
        
        for pptx_path in pptx_files:
            pdf_path = pptx_path.with_suffix(".pdf")
            
            # Skip if PDF already exists and is newer than PPTX
            if pdf_path.exists():
                if pdf_path.stat().st_mtime >= pptx_path.stat().st_mtime:
                    print(f"⏭️ Skipping (PDF exists): {pptx_path.name}")
                    skipped += 1
                    continue
            
            print(f"🔄 Converting: {pptx_path.name}")
            
            try:
                # Open presentation
                presentation = powerpoint.Presentations.Open(
                    str(pptx_path),
                    ReadOnly=True,
                    Untitled=False,
                    WithWindow=False
                )
                
                # Save as PDF (32 = ppSaveAsPDF)
                presentation.SaveAs(str(pdf_path), 32)
                presentation.Close()
                
                print(f"   ✅ Created: {pdf_path.name}")
                converted += 1
                
            except Exception as e:
                print(f"   ❌ Failed: {str(e)}")
                failed += 1
        
        print("-" * 60)
        print(f"📊 Summary:")
        print(f"   ✅ Converted: {converted}")
        print(f"   ⏭️ Skipped: {skipped}")
        print(f"   ❌ Failed: {failed}")
        
    except Exception as e:
        print(f"❌ Error initializing PowerPoint: {e}")
        print("\n💡 Make sure Microsoft PowerPoint is installed on this system.")
        
    finally:
        if powerpoint:
            try:
                powerpoint.Quit()
            except:
                pass


def convert_pptx_to_pdf_libreoffice():
    """Alternative: Convert using LibreOffice (cross-platform)"""
    import subprocess
    
    # Path to lesson files
    lessons_dir = Path(__file__).resolve().parents[1] / "uploads" / "lessons"
    
    if not lessons_dir.exists():
        print(f"❌ Lessons directory not found: {lessons_dir}")
        return
    
    # Find LibreOffice
    libreoffice_paths = [
        r"C:\Program Files\LibreOffice\program\soffice.exe",
        r"C:\Program Files (x86)\LibreOffice\program\soffice.exe",
        "/usr/bin/libreoffice",
        "/usr/bin/soffice"
    ]
    
    libreoffice = None
    for path in libreoffice_paths:
        if os.path.exists(path):
            libreoffice = path
            break
    
    if not libreoffice:
        print("❌ LibreOffice not found. Please install LibreOffice.")
        return
    
    # Find all PPTX files
    pptx_files = list(lessons_dir.glob("*.pptx")) + list(lessons_dir.glob("*.ppt"))
    
    if not pptx_files:
        print("ℹ️ No PPTX/PPT files found to convert")
        return
    
    print(f"📂 Found {len(pptx_files)} PowerPoint files to convert")
    print(f"📍 Using LibreOffice: {libreoffice}")
    print("-" * 60)
    
    converted = 0
    skipped = 0
    failed = 0
    
    for pptx_path in pptx_files:
        pdf_path = pptx_path.with_suffix(".pdf")
        
        # Skip if PDF already exists
        if pdf_path.exists():
            if pdf_path.stat().st_mtime >= pptx_path.stat().st_mtime:
                print(f"⏭️ Skipping (PDF exists): {pptx_path.name}")
                skipped += 1
                continue
        
        print(f"🔄 Converting: {pptx_path.name}")
        
        try:
            result = subprocess.run([
                libreoffice,
                "--headless",
                "--convert-to", "pdf",
                "--outdir", str(lessons_dir),
                str(pptx_path)
            ], capture_output=True, text=True, timeout=120)
            
            if result.returncode == 0 and pdf_path.exists():
                print(f"   ✅ Created: {pdf_path.name}")
                converted += 1
            else:
                print(f"   ❌ Failed: {result.stderr}")
                failed += 1
                
        except subprocess.TimeoutExpired:
            print(f"   ❌ Timeout")
            failed += 1
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
            failed += 1
    
    print("-" * 60)
    print(f"📊 Summary:")
    print(f"   ✅ Converted: {converted}")
    print(f"   ⏭️ Skipped: {skipped}")
    print(f"   ❌ Failed: {failed}")


if __name__ == "__main__":
    print("=" * 60)
    print("🔄 PPTX to PDF Converter")
    print("=" * 60)
    
    # Try PowerPoint first (Windows), fallback to LibreOffice
    if sys.platform == "win32":
        print("\n📌 Using Microsoft PowerPoint (Windows)...")
        try:
            convert_pptx_to_pdf_windows()
        except Exception as e:
            print(f"\n⚠️ PowerPoint failed: {e}")
            print("\n📌 Trying LibreOffice as fallback...")
            convert_pptx_to_pdf_libreoffice()
    else:
        print("\n📌 Using LibreOffice (Linux/Mac)...")
        convert_pptx_to_pdf_libreoffice()
    
    print("\n✅ Done!")
