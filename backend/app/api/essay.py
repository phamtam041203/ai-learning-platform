"""Essay/Assignment Submission API for lessons without MCQ quizzes (tự luận)"""
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional, List
from datetime import datetime
import os
import uuid
from pathlib import Path

from app.database import get_db
from app.models import User, Lesson, Course, Enrollment
from app.models.assessment import EssaySubmission
from app.models.user import UserRole
from app.dependencies import get_current_user

router = APIRouter()

# Upload directory for essay files
ESSAY_UPLOAD_DIR = Path("uploads/essays")
ESSAY_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Allowed file types for essay submission
ALLOWED_EXTENSIONS = {
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.txt': 'text/plain',
    '.zip': 'application/zip',
    '.rar': 'application/x-rar-compressed',
    '.py': 'text/x-python',
    '.java': 'text/x-java',
    '.js': 'text/javascript',
    '.html': 'text/html',
    '.css': 'text/css',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
}

MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB


@router.post("/lessons/{lesson_id}/essay-submit")
async def submit_essay(
    lesson_id: int,
    text_content: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Submit essay/assignment for a lesson.
    Students can either:
    1. Write text in the text box
    2. Upload a file
    3. Both write text and upload a file
    """
    # Check if lesson exists
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Bài học không tồn tại")
    
    # Check if student is enrolled in the course
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == current_user.id,
        Enrollment.course_id == lesson.course_id
    ).first()
    
    if not enrollment:
        raise HTTPException(status_code=403, detail="Bạn chưa đăng ký khóa học này")
    
    # Must have at least text or file
    if not text_content and not file:
        raise HTTPException(status_code=400, detail="Vui lòng nhập nội dung bài làm hoặc tải file lên")
    
    # Handle file upload
    file_url = None
    file_name = None
    file_type = None
    file_size = None
    
    if file:
        # Check file extension
        ext = Path(file.filename).suffix.lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400, 
                detail=f"Loại file không được hỗ trợ. Chỉ chấp nhận: {', '.join(ALLOWED_EXTENSIONS.keys())}"
            )
        
        # Read file content
        contents = await file.read()
        file_size = len(contents)
        
        # Check file size
        if file_size > MAX_FILE_SIZE:
            raise HTTPException(status_code=400, detail=f"File quá lớn. Giới hạn {MAX_FILE_SIZE // (1024*1024)}MB")
        
        # Generate unique filename
        unique_id = uuid.uuid4().hex[:8]
        safe_filename = f"essay_{current_user.id}_{lesson_id}_{unique_id}{ext}"
        file_path = ESSAY_UPLOAD_DIR / safe_filename
        
        # Save file
        with open(file_path, "wb") as f:
            f.write(contents)
        
        file_url = f"/uploads/essays/{safe_filename}"
        file_name = file.filename
        file_type = ALLOWED_EXTENSIONS.get(ext, file.content_type)
    
    # Check if submission already exists
    existing = db.query(EssaySubmission).filter(
        EssaySubmission.lesson_id == lesson_id,
        EssaySubmission.student_id == current_user.id
    ).first()
    
    if existing:
        # Update existing submission
        existing.text_content = text_content
        if file_url:
            # Delete old file if exists
            if existing.file_url:
                old_path = Path("." + existing.file_url)
                if old_path.exists():
                    old_path.unlink()
            existing.file_url = file_url
            existing.file_name = file_name
            existing.file_type = file_type
            existing.file_size = file_size
        existing.status = "submitted"
        existing.submitted_at = datetime.now()
        # Clear previous grading
        existing.score = None
        existing.feedback = None
        existing.graded_at = None
        existing.graded_by = None
        
        db.commit()
        db.refresh(existing)
        submission = existing
    else:
        # Create new submission
        submission = EssaySubmission(
            lesson_id=lesson_id,
            student_id=current_user.id,
            course_id=lesson.course_id,
            text_content=text_content,
            file_url=file_url,
            file_name=file_name,
            file_type=file_type,
            file_size=file_size,
            status="submitted"
        )
        db.add(submission)
        db.commit()
        db.refresh(submission)
    
    return {
        "success": True,
        "message": "Nộp bài thành công!",
        "submission": {
            "id": submission.id,
            "lesson_id": submission.lesson_id,
            "text_content": submission.text_content[:100] + "..." if submission.text_content and len(submission.text_content) > 100 else submission.text_content,
            "file_name": submission.file_name,
            "status": submission.status,
            "submitted_at": submission.submitted_at.isoformat() if submission.submitted_at else None
        }
    }


@router.get("/lessons/{lesson_id}/essay-submission")
async def get_my_essay_submission(
    lesson_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get current user's essay submission for a lesson"""
    submission = db.query(EssaySubmission).filter(
        EssaySubmission.lesson_id == lesson_id,
        EssaySubmission.student_id == current_user.id
    ).first()
    
    if not submission:
        return {"submission": None}
    
    # Get grader name
    grader_name = None
    if submission.graded_by:
        grader = db.query(User).filter(User.id == submission.graded_by).first()
        grader_name = grader.full_name if grader else None
    
    return {
        "submission": {
            "id": submission.id,
            "lesson_id": submission.lesson_id,
            "text_content": submission.text_content,
            "file_url": submission.file_url,
            "file_name": submission.file_name,
            "file_type": submission.file_type,
            "file_size": submission.file_size,
            "status": submission.status,
            "score": submission.score,
            "max_score": submission.max_score,
            "feedback": submission.feedback,
            "graded_by": grader_name,
            "submitted_at": submission.submitted_at.isoformat() if submission.submitted_at else None,
            "graded_at": submission.graded_at.isoformat() if submission.graded_at else None
        }
    }


# ==================== TEACHER ENDPOINTS ====================

@router.get("/teacher/courses/{course_id}/essay-submissions")
async def get_course_essay_submissions(
    course_id: int,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all essay submissions for a course (teacher only)"""
    if current_user.role not in [UserRole.TEACHER, UserRole.ADMIN]:
        raise HTTPException(status_code=403, detail="Chỉ giảng viên mới có thể xem bài nộp")
    
    # Get course info
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Khóa học không tồn tại")
    
    # Query submissions
    query = db.query(EssaySubmission).filter(EssaySubmission.course_id == course_id)
    
    if status:
        query = query.filter(EssaySubmission.status == status)
    
    submissions = query.order_by(EssaySubmission.submitted_at.desc()).all()
    
    result = []
    for sub in submissions:
        # Get student and lesson info
        student = db.query(User).filter(User.id == sub.student_id).first()
        lesson = db.query(Lesson).filter(Lesson.id == sub.lesson_id).first()
        
        result.append({
            "id": sub.id,
            "student_id": sub.student_id,
            "student_name": student.full_name if student else "Unknown",
            "student_email": student.email if student else None,
            "lesson_id": sub.lesson_id,
            "lesson_title": lesson.title if lesson else "Unknown",
            "lesson_order": lesson.order if lesson else 0,
            "text_content": sub.text_content[:200] + "..." if sub.text_content and len(sub.text_content) > 200 else sub.text_content,
            "has_file": bool(sub.file_url),
            "file_name": sub.file_name,
            "status": sub.status,
            "score": sub.score,
            "max_score": sub.max_score,
            "submitted_at": sub.submitted_at.isoformat() if sub.submitted_at else None,
            "graded_at": sub.graded_at.isoformat() if sub.graded_at else None
        })
    
    return {
        "course": {
            "id": course.id,
            "title": course.title or course.course_name,
            "code": course.course_code
        },
        "submissions": result,
        "total": len(result),
        "pending_count": len([s for s in result if s["status"] == "submitted"])
    }


@router.get("/teacher/essay-submissions/{submission_id}")
async def get_essay_submission_detail(
    submission_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed essay submission for grading (teacher only)"""
    if current_user.role not in [UserRole.TEACHER, UserRole.ADMIN]:
        raise HTTPException(status_code=403, detail="Chỉ giảng viên mới có thể xem chi tiết bài nộp")
    
    submission = db.query(EssaySubmission).filter(EssaySubmission.id == submission_id).first()
    if not submission:
        raise HTTPException(status_code=404, detail="Bài nộp không tồn tại")
    
    # Get related info
    student = db.query(User).filter(User.id == submission.student_id).first()
    lesson = db.query(Lesson).filter(Lesson.id == submission.lesson_id).first()
    course = db.query(Course).filter(Course.id == submission.course_id).first()
    
    return {
        "id": submission.id,
        "student": {
            "id": student.id,
            "name": student.full_name,
            "email": student.email
        } if student else None,
        "lesson": {
            "id": lesson.id,
            "title": lesson.title,
            "order": lesson.order
        } if lesson else None,
        "course": {
            "id": course.id,
            "title": course.title or course.course_name,
            "code": course.course_code
        } if course else None,
        "text_content": submission.text_content,
        "file_url": submission.file_url,
        "file_name": submission.file_name,
        "file_type": submission.file_type,
        "file_size": submission.file_size,
        "status": submission.status,
        "score": submission.score,
        "max_score": submission.max_score,
        "feedback": submission.feedback,
        "submitted_at": submission.submitted_at.isoformat() if submission.submitted_at else None,
        "graded_at": submission.graded_at.isoformat() if submission.graded_at else None
    }


@router.post("/teacher/essay-submissions/{submission_id}/grade")
async def grade_essay_submission(
    submission_id: int,
    score: float = Form(...),
    feedback: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Grade an essay submission (teacher only)"""
    if current_user.role not in [UserRole.TEACHER, UserRole.ADMIN]:
        raise HTTPException(status_code=403, detail="Chỉ giảng viên mới có thể chấm điểm")
    
    submission = db.query(EssaySubmission).filter(EssaySubmission.id == submission_id).first()
    if not submission:
        raise HTTPException(status_code=404, detail="Bài nộp không tồn tại")
    
    # Validate score
    if score < 0 or score > submission.max_score:
        raise HTTPException(
            status_code=400, 
            detail=f"Điểm phải từ 0 đến {submission.max_score}"
        )
    
    # Update submission
    submission.score = score
    submission.feedback = feedback
    submission.graded_by = current_user.id
    submission.graded_at = datetime.now()
    submission.status = "graded"
    
    db.commit()
    db.refresh(submission)
    
    return {
        "success": True,
        "message": "Chấm điểm thành công!",
        "submission": {
            "id": submission.id,
            "score": submission.score,
            "max_score": submission.max_score,
            "feedback": submission.feedback,
            "status": submission.status,
            "graded_at": submission.graded_at.isoformat()
        }
    }


@router.get("/teacher/pending-essays")
async def get_all_pending_essays(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all pending essay submissions across all courses (teacher only)"""
    if current_user.role not in [UserRole.TEACHER, UserRole.ADMIN]:
        raise HTTPException(status_code=403, detail="Chỉ giảng viên mới có thể xem bài chờ chấm")
    
    # For admin, get all pending. For teacher, get only their courses
    query = db.query(EssaySubmission).filter(EssaySubmission.status == "submitted")
    
    if current_user.role == UserRole.TEACHER:
        # Get teacher's courses
        teacher_course_ids = db.query(Course.id).filter(Course.teacher_id == current_user.id).all()
        teacher_course_ids = [c[0] for c in teacher_course_ids]
        query = query.filter(EssaySubmission.course_id.in_(teacher_course_ids))
    
    submissions = query.order_by(EssaySubmission.submitted_at.asc()).all()
    
    result = []
    for sub in submissions:
        student = db.query(User).filter(User.id == sub.student_id).first()
        lesson = db.query(Lesson).filter(Lesson.id == sub.lesson_id).first()
        course = db.query(Course).filter(Course.id == sub.course_id).first()
        
        result.append({
            "id": sub.id,
            "student_name": student.full_name if student else "Unknown",
            "lesson_title": lesson.title if lesson else "Unknown",
            "course_title": course.title or course.course_name if course else "Unknown",
            "course_code": course.course_code if course else None,
            "submitted_at": sub.submitted_at.isoformat() if sub.submitted_at else None,
            "has_file": bool(sub.file_url),
            "file_name": sub.file_name
        })
    
    return {
        "pending_count": len(result),
        "submissions": result
    }
