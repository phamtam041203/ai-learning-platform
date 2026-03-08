"""
Lesson API Router - Serve lesson PDF files and lesson data
"""
from fastapi import APIRouter, HTTPException, Response
import os
from pathlib import Path

router = APIRouter()

# Path to lesson files directory
LESSON_FILES_DIR = Path(__file__).resolve().parents[2] / "uploads" / "lessons"


@router.options("/lessons/{file_name}")
async def options_lesson_file(file_name: str):
    """Handle CORS preflight requests for PDF files"""
    return Response(
        status_code=200,
        headers={
            "Access-Control-Allow-Origin": "http://localhost:3000",
            "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Max-Age": "86400"
        }
    )


# Supported file extensions and their MIME types
SUPPORTED_EXTENSIONS = {
    '.pdf': 'application/pdf',
    '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.ppt': 'application/vnd.ms-powerpoint'
}

@router.get("/lessons")
async def list_lessons():
    """
    List all available lesson files (PDF, PPTX)
    Path: /api/lessons
    """
    try:
        print(f"DEBUG: LESSON_FILES_DIR = {LESSON_FILES_DIR}")
        print(f"DEBUG: LESSON_FILES_DIR.exists() = {LESSON_FILES_DIR.exists()}")
        
        if not LESSON_FILES_DIR.exists():
            print("ERROR: Lesson directory not found")
            raise HTTPException(status_code=404, detail="Lesson directory not found")
        
        print("DEBUG: Attempting to glob lesson files...")
        lesson_files = []
        
        # Get all supported file types
        for ext in SUPPORTED_EXTENSIONS.keys():
            for file_path in sorted(LESSON_FILES_DIR.glob(f"*{ext}")):
                print(f"DEBUG: Found file: {file_path.name}")
                lesson_files.append({
                    "name": file_path.name,
                    "size": file_path.stat().st_size,
                    "type": ext[1:],  # Remove the dot
                    "url": f"/api/lessons/{file_path.name}"
                })
        
        # Sort by name
        lesson_files.sort(key=lambda x: x["name"])
        
        print(f"DEBUG: Total files found: {len(lesson_files)}")
        return {
            "total": len(lesson_files),
            "lessons": lesson_files
        }
    
    except HTTPException as e:
        print(f"DEBUG: HTTPException raised: {e}")
        raise e
    except Exception as e:
        print(f"DEBUG: Exception raised: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error listing lessons: {str(e)}")


@router.get("/lessons/{file_name}")
async def get_lesson_file(file_name: str):
    """
    Serve lesson files (PDF, PPTX)
    Path: /api/lessons/{file_name}
    Example: /api/lessons/Lecture%2000%20-%20Course%20Introduction.pdf
    """
    try:
        print(f"DEBUG get_lesson_file: Requested file: {file_name}")
        
        # Decode the file name and validate it
        file_path = LESSON_FILES_DIR / file_name
        print(f"DEBUG: file_path = {file_path}")
        
        # Security check: ensure file path is within the lesson directory
        file_path = file_path.resolve()
        lesson_dir_resolved = LESSON_FILES_DIR.resolve()
        print(f"DEBUG: resolved file_path = {file_path}")
        print(f"DEBUG: lesson_dir_resolved = {lesson_dir_resolved}")
        
        if not str(file_path).startswith(str(lesson_dir_resolved)):
            raise HTTPException(status_code=403, detail="Access denied: Invalid file path")
        
        # Check if file exists
        if not file_path.exists():
            print(f"DEBUG: File not found: {file_path}")
            raise HTTPException(status_code=404, detail=f"File not found: {file_name}")
        
        print(f"DEBUG: File exists, size = {file_path.stat().st_size}")
        
        # Check if it's a supported file type
        file_ext = file_path.suffix.lower()
        print(f"DEBUG: file_ext = {file_ext}")
        
        if file_ext not in SUPPORTED_EXTENSIONS:
            raise HTTPException(
                status_code=400, 
                detail=f"Unsupported file type. Allowed: {', '.join(SUPPORTED_EXTENSIONS.keys())}"
            )
        
        # Get MIME type
        media_type = SUPPORTED_EXTENSIONS[file_ext]
        print(f"DEBUG: media_type = {media_type}")
        
        # Read file content and return with CORS headers
        with open(file_path, "rb") as f:
            content = f.read()
        
        print(f"DEBUG: Read {len(content)} bytes")
        
        # Use ASCII-safe filename for Content-Disposition header
        from urllib.parse import quote
        safe_filename = quote(file_name)
        
        return Response(
            content=content,
            media_type=media_type,
            headers={
                "Access-Control-Allow-Origin": "http://localhost:3000",
                "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
                "Access-Control-Allow-Headers": "*",
                "Content-Disposition": f"inline; filename*=UTF-8''{safe_filename}",
                "Cache-Control": "public, max-age=3600"
            }
        )
    
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error serving file: {str(e)}")
