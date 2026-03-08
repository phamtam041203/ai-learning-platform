"""Teacher endpoints"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import Optional, List
from datetime import datetime
import os
import shutil
from pathlib import Path

from app.database import get_db
from app.dependencies import get_current_teacher
from app.models.user import User
from app.models.course import Course, Enrollment, Lesson
from app.models.assessment import Assessment, Question, Submission
from app.models.learning_activity import LearningActivity

router = APIRouter()

# Configuration
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

# ==================== TEACHER PROFILE ====================

@router.get("/profile")
async def get_teacher_profile(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get teacher profile information"""
    try:
        # Get teacher stats - simplified version
        total_courses = db.query(Course).filter(Course.teacher_id == user.id).count()
        
        return {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role,
            "stats": {
                "total_courses": total_courses,
                "total_students": 0,
                "pending_approvals": 0,
                "average_rating": 4.8
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


# ==================== COURSE MANAGEMENT ====================

@router.get("/courses")
async def get_teacher_courses(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get all courses created by teacher"""
    try:
        courses = db.query(Course).filter(Course.teacher_id == user.id).all()
        
        result = []
        for course in courses:
            result.append({
                "id": course.id,
                "title": course.title,
                "description": course.description,
                "category": course.category,
                "class_code": course.class_code,
                "enrolled_count": 0,
                "lessons_count": 0,
                "created_at": course.created_at.isoformat() if course.created_at else None
            })
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching courses: {str(e)}")


@router.post("/courses")
async def create_course(
    title: str = Form(...),
    description: str = Form(""),
    category: str = Form("programming"),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Create a new course"""
    try:
        # Generate unique class code
        import random
        import string
        class_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
        
        # Check if class code already exists
        while db.query(Course).filter(Course.class_code == class_code).first():
            class_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
        
        new_course = Course(
            title=title,
            description=description,
            category=category,
            teacher_id=user.id,
            class_code=class_code,
            created_at=datetime.utcnow()
        )
        
        db.add(new_course)
        db.commit()
        db.refresh(new_course)
        
        return {
            "id": new_course.id,
            "title": new_course.title,
            "description": new_course.description,
            "category": new_course.category,
            "class_code": new_course.class_code,
            "enrolled_count": 0,
            "lessons_count": 0,
            "created_at": new_course.created_at.isoformat()
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating course: {str(e)}")


@router.get("/courses/{course_id}")
async def get_course_detail(
    course_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get detailed course information"""
    try:
        course = db.query(Course).filter(
            Course.id == course_id,
            Course.teacher_id == user.id
        ).first()
        
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        # Get lessons
        lessons = db.query(Lesson).filter(Lesson.course_id == course_id).all()
        
        # Get assessments (quizzes/exams)
        assessments = db.query(Assessment).filter(
            Assessment.course_id == course_id
        ).all()
        
        # Get enrolled students
        enrollments = db.query(Enrollment).filter(
            Enrollment.course_id == course_id,
            Enrollment.status == "active"
        ).all()
        
        return {
            "course": {
                "id": course.id,
                "title": course.title,
                "description": course.description,
                "category": course.category,
                "class_code": course.class_code,
                "created_at": course.created_at.isoformat() if course.created_at else None
            },
            "lessons": [
                {
                    "id": lesson.id,
                    "title": lesson.title,
                    "description": lesson.description,
                    "file_path": lesson.file_path,
                    "video_url": lesson.video_url
                } for lesson in lessons
            ],
            "quizzes": [
                {
                    "id": assessment.id,
                    "title": assessment.title,
                    "description": assessment.description or "",
                    "questions_count": db.query(Question).filter(Question.assessment_id == assessment.id).count()
                } for assessment in assessments if assessment.assessment_type == "quiz"
            ],
            "enrolled_students": len(enrollments)
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching course detail: {str(e)}")


# ==================== LESSON MANAGEMENT ====================

@router.post("/lessons")
async def create_lesson(
    title: str = Form(...),
    description: str = Form(""),
    course_id: int = Form(...),
    file: Optional[UploadFile] = File(None),
    video_url: Optional[str] = Form(None),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Create a new lesson with optional file upload"""
    try:
        # Verify course belongs to teacher
        course = db.query(Course).filter(
            Course.id == course_id,
            Course.teacher_id == user.id
        ).first()
        
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        file_path = None
        if file:
            # Save uploaded file
            file_ext = os.path.splitext(file.filename)[1]
            timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
            filename = f"lesson_{course_id}_{timestamp}{file_ext}"
            file_path = UPLOAD_DIR / filename
            
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            
            file_path = str(file_path)
        
        new_lesson = Lesson(
            title=title,
            description=description,
            course_id=course_id,
            file_path=file_path,
            video_url=video_url,
            created_at=datetime.utcnow()
        )
        
        db.add(new_lesson)
        db.commit()
        db.refresh(new_lesson)
        
        return {
            "id": new_lesson.id,
            "title": new_lesson.title,
            "description": new_lesson.description,
            "file_path": new_lesson.file_path,
            "video_url": new_lesson.video_url,
            "created_at": new_lesson.created_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating lesson: {str(e)}")


# ==================== QUIZ MANAGEMENT ====================

@router.post("/quizzes/from-docx")
async def create_quiz_from_docx(
    title: str = Form(...),
    description: str = Form(""),
    course_id: int = Form(...),
    docx_file: UploadFile = File(...),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Create quiz from uploaded DOCX file - TODO: Implement DOCX parser"""
    # Temporarily disabled - need to implement DOCX parser
    raise HTTPException(
        status_code=501, 
        detail="Quiz creation from DOCX is not yet implemented. Please use the admin panel to create assessments."
    )


# ==================== STUDENT MANAGEMENT ====================

@router.get("/students")
async def get_teacher_students(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get all students enrolled in teacher's courses"""
    try:
        # Simplified version - just return empty list for now
        return []
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching students: {str(e)}")


# ==================== ENROLLMENT APPROVAL ====================

@router.get("/pending-approvals")
async def get_pending_approvals(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get all pending enrollment requests"""
    try:
        # Simplified version - return empty list for now
        return []
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching approvals: {str(e)}")


@router.post("/enrollments/{enrollment_id}/approve")
async def approve_enrollment(
    enrollment_id: int,
    approve: bool,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Approve or reject enrollment request"""
    try:
        # Get enrollment
        enrollment = db.query(Enrollment).join(Course).filter(
            Enrollment.id == enrollment_id,
            Course.teacher_id == user.id,
            Enrollment.status == "pending"
        ).first()
        
        if not enrollment:
            raise HTTPException(status_code=404, detail="Enrollment not found")
        
        # Update status
        enrollment.status = "active" if approve else "dropped"
        enrollment.enrolled_at = datetime.utcnow() if approve else None
        
        db.commit()
        
        return {
            "id": enrollment.id,
            "status": enrollment.status,
            "message": "Enrollment activated" if approve else "Enrollment dropped"
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating enrollment: {str(e)}")


# ==================== STATISTICS ====================

@router.get("/dashboard")
async def get_dashboard_stats(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db)
):
    """Get comprehensive dashboard statistics"""
    try:
        # Get basic stats
        total_courses = db.query(Course).filter(Course.teacher_id == user.id).count()
        
        # Use scalar() or default to 0
        total_students = db.query(func.count(Enrollment.id)).join(
            Course, Enrollment.course_id == Course.id
        ).filter(
            Course.teacher_id == user.id,
            Enrollment.status == "active"
        ).scalar() or 0
        
        # Count pending enrollments
        pending_approvals = db.query(Enrollment).join(
            Course, Enrollment.course_id == Course.id
        ).filter(
            Course.teacher_id == user.id,
            Enrollment.status == "pending"
        ).count()
        
        # Count lessons for this teacher's courses
        total_lessons = db.query(Lesson).join(Course).filter(
            Course.teacher_id == user.id
        ).count()
        
        # Count assessments (quizzes) for this teacher's courses
        total_quizzes = db.query(Assessment).join(Course).filter(
            Course.teacher_id == user.id,
            Assessment.assessment_type == "quiz"
        ).count()
        
        return {
            "teacher": {
                "id": user.id,
                "name": user.full_name,
                "email": user.email
            },
            "stats": {
                "total_courses": total_courses,
                "total_students": total_students,
                "pending_approvals": pending_approvals,
                "total_lessons": total_lessons,
                "total_quizzes": total_quizzes,
                "average_rating": 4.8  # Placeholder
            }
        }
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error fetching dashboard: {str(e)}")