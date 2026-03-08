"""Admin endpoints"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Optional, List
from datetime import datetime
from pathlib import Path
import os
import shutil

from app.database import get_db
from app.dependencies import get_current_admin
from app.models.user import User, UserRole, StudentProfile, TeacherProfile, LoginHistory
from app.models.course import Course, Enrollment, LessonProgress, Lesson
from app.models.assessment import Assessment, AssessmentType, Submission, QuizResult, GradeHistory
from app.utils.security import get_password_hash

router = APIRouter(prefix="/admin", tags=["Admin"])

UPLOAD_DIR = Path("uploads")
ASSESSMENT_UPLOAD_DIR = UPLOAD_DIR / "assessments"
ASSESSMENT_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def generate_student_id(db: Session, intake_year: int) -> str:
    """
    Generate unique student ID: 2174802XXXXKXX
    Example: 21748020001K27
    """
    if intake_year < 20 or intake_year > 99:
        raise HTTPException(400, "Invalid intake year. Must be between 20 and 99.")

    prefix = "2174802"
    suffix = f"K{intake_year}"

    try:
        count = db.query(StudentProfile).filter(
            StudentProfile.intake_year == intake_year
        ).count()

        new_number = count + 1
        student_id = f"{prefix}{new_number:04d}{suffix}"
        return student_id
    except Exception:
        import random
        random_num = random.randint(1, 9999)
        return f"{prefix}{random_num:04d}{suffix}"


def normalize_assessment_type(value: str) -> AssessmentType:
    try:
        return AssessmentType(value)
    except Exception:
        valid_types = ", ".join([t.value for t in AssessmentType])
        raise HTTPException(400, f"Invalid assessment_type. Must be one of: {valid_types}")


@router.get("/overview")
async def get_admin_overview(
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Get admin overview stats"""
    total_users = db.query(User).count()
    total_students = db.query(User).filter(User.role == UserRole.STUDENT).count()
    total_teachers = db.query(User).filter(User.role == UserRole.TEACHER).count()
    total_courses = db.query(Course).count()
    total_assessments = db.query(Assessment).count()
    active_users = db.query(User).filter(User.is_active == True).count()

    return {
        "total_users": total_users,
        "total_students": total_students,
        "total_teachers": total_teachers,
        "total_courses": total_courses,
        "total_assessments": total_assessments,
        "active_users": active_users
    }


@router.get("/teachers")
async def list_teachers(
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """List all teachers"""
    teachers = db.query(User, TeacherProfile).join(
        TeacherProfile, TeacherProfile.user_id == User.id
    ).filter(User.role == UserRole.TEACHER).all()

    return [
        {
            "id": u.id,
            "email": u.email,
            "full_name": u.full_name,
            "is_active": u.is_active,
            "created_at": u.created_at.isoformat() if u.created_at else None,
            "teacher_profile": {
                "teacher_id": p.teacher_id,
                "department": p.department,
                "position": p.position,
                "specialization": p.specialization,
                "phone": p.phone,
                "office_location": p.office_location,
                "years_of_experience": p.years_of_experience
            }
        }
        for u, p in teachers
    ]


@router.get("/students")
async def list_students(
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """List all students"""
    students = db.query(User, StudentProfile).join(
        StudentProfile, StudentProfile.user_id == User.id
    ).filter(User.role == UserRole.STUDENT).all()

    return [
        {
            "id": u.id,
            "email": u.email,
            "full_name": u.full_name,
            "is_active": u.is_active,
            "created_at": u.created_at.isoformat() if u.created_at else None,
            "student_profile": {
                "student_id": p.student_id,
                "major": p.major,
                "specialization": p.specialization,
                "class_name": p.class_name,
                "intake_year": p.intake_year,
                "phone": p.phone,
                "education_type": p.education_type
            }
        }
        for u, p in students
    ]


@router.post("/teachers")
async def create_teacher(
    email: str = Form(...),
    password: str = Form(...),
    full_name: str = Form(...),
    teacher_id: str = Form(...),
    department: str = Form(...),
    position: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    specialization: Optional[str] = Form(None),
    office_location: Optional[str] = Form(None),
    bio: Optional[str] = Form(None),
    years_of_experience: Optional[int] = Form(None),
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Create teacher account"""
    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        raise HTTPException(400, "Email already exists")

    existing_teacher = db.query(TeacherProfile).filter(
        TeacherProfile.teacher_id == teacher_id
    ).first()
    if existing_teacher:
        raise HTTPException(400, "Teacher ID already exists")

    new_user = User(
        email=email,
        hashed_password=get_password_hash(password),
        full_name=full_name,
        role=UserRole.TEACHER,
        is_active=True
    )
    db.add(new_user)
    db.flush()

    profile = TeacherProfile(
        user_id=new_user.id,
        teacher_id=teacher_id,
        department=department,
        position=position,
        specialization=specialization,
        phone=phone,
        office_location=office_location,
        bio=bio,
        years_of_experience=years_of_experience
    )
    db.add(profile)
    db.commit()
    db.refresh(new_user)
    db.refresh(profile)

    return {
        "id": new_user.id,
        "email": new_user.email,
        "full_name": new_user.full_name,
        "is_active": new_user.is_active,
        "teacher_profile": {
            "teacher_id": profile.teacher_id,
            "department": profile.department,
            "position": profile.position,
            "specialization": profile.specialization,
            "phone": profile.phone,
            "office_location": profile.office_location,
            "years_of_experience": profile.years_of_experience
        }
    }


@router.post("/students")
async def create_student(
    email: str = Form(...),
    password: str = Form(...),
    full_name: str = Form(...),
    major: str = Form(...),
    intake_year: int = Form(...),
    specialization: Optional[str] = Form(None),
    class_name: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    education_type: Optional[str] = Form("0"),
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Create student account with auto-generated student_id"""
    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        raise HTTPException(400, "Email already exists")

    student_id = generate_student_id(db, intake_year)

    new_user = User(
        email=email,
        hashed_password=get_password_hash(password),
        full_name=full_name,
        role=UserRole.STUDENT,
        is_active=True
    )
    db.add(new_user)
    db.flush()

    profile = StudentProfile(
        user_id=new_user.id,
        student_id=student_id,
        major=major,
        specialization=specialization,
        class_name=class_name,
        intake_year=intake_year,
        phone=phone,
        education_type=education_type
    )
    db.add(profile)
    db.commit()
    db.refresh(new_user)
    db.refresh(profile)

    return {
        "id": new_user.id,
        "email": new_user.email,
        "full_name": new_user.full_name,
        "is_active": new_user.is_active,
        "student_profile": {
            "student_id": profile.student_id,
            "major": profile.major,
            "specialization": profile.specialization,
            "class_name": profile.class_name,
            "intake_year": profile.intake_year,
            "phone": profile.phone,
            "education_type": profile.education_type
        }
    }


@router.patch("/users/{user_id}/status")
async def update_user_status(
    user_id: int,
    is_active: bool = Form(...),
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Activate/deactivate user"""
    target_user = db.query(User).filter(User.id == user_id).first()
    if not target_user:
        raise HTTPException(404, "User not found")

    target_user.is_active = is_active
    db.commit()
    db.refresh(target_user)

    return {
        "id": target_user.id,
        "is_active": target_user.is_active
    }


@router.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Delete user and related data"""
    target_user = db.query(User).filter(User.id == user_id).first()
    if not target_user:
        raise HTTPException(404, "User not found")

    try:
        # If teacher, detach courses
        if target_user.role == UserRole.TEACHER:
            db.query(Course).filter(Course.teacher_id == target_user.id).update({
                Course.teacher_id: None
            })

        # Remove related profiles
        db.query(StudentProfile).filter(StudentProfile.user_id == target_user.id).delete()
        db.query(TeacherProfile).filter(TeacherProfile.user_id == target_user.id).delete()

        # Remove student-related records
        db.query(Enrollment).filter(Enrollment.student_id == target_user.id).delete()
        db.query(LessonProgress).filter(LessonProgress.student_id == target_user.id).delete()
        db.query(Submission).filter(Submission.student_id == target_user.id).delete()
        db.query(QuizResult).filter(QuizResult.user_id == target_user.id).delete()
        db.query(GradeHistory).filter(GradeHistory.student_id == target_user.id).delete()
        db.query(LoginHistory).filter(LoginHistory.user_id == target_user.id).delete()

        db.delete(target_user)
        db.commit()

        return {"success": True, "deleted_user_id": user_id}
    except Exception as e:
        db.rollback()
        raise HTTPException(500, f"Delete user error: {str(e)}")


@router.get("/courses")
async def list_courses(
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """List all courses"""
    courses = db.query(Course).all()
    return [
        {
            "id": c.id,
            "course_code": c.course_code,
            "course_name": c.course_name,
            "major": c.major,
            "specialization": c.specialization,
            "is_active": c.is_active
        }
        for c in courses
    ]


@router.get("/assessments")
async def list_assessments(
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """List all assessments"""
    assessments = db.query(Assessment, Course).join(
        Course, Course.id == Assessment.course_id
    ).order_by(Assessment.created_at.desc()).all()

    return [
        {
            "id": a.id,
            "title": a.title,
            "description": a.description,
            "assessment_type": a.assessment_type.value if a.assessment_type else None,
            "max_score": a.max_score,
            "weight": a.weight,
            "due_date": a.due_date.isoformat() if a.due_date else None,
            "is_published": a.is_published,
            "attachment_url": a.attachment_url,
            "attachment_name": a.attachment_name,
            "course": {
                "id": c.id,
                "course_code": c.course_code,
                "course_name": c.course_name
            }
        }
        for a, c in assessments
    ]


@router.post("/assessments")
async def create_assessment(
    course_id: int = Form(...),
    title: str = Form(...),
    description: str = Form(""),
    instructions: str = Form(""),
    assessment_type: str = Form("assignment"),
    max_score: float = Form(10.0),
    weight: float = Form(1.0),
    passing_score: float = Form(5.0),
    due_date: Optional[str] = Form(None),
    start_date: Optional[str] = Form(None),
    duration_minutes: Optional[int] = Form(None),
    is_published: bool = Form(False),
    allow_late_submission: bool = Form(True),
    late_penalty_percent: float = Form(10.0),
    max_attempts: int = Form(1),
    attachment: Optional[UploadFile] = File(None),
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Create assessment with optional attachment upload"""
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(404, "Course not found")

    attachment_url = None
    attachment_name = None

    if attachment:
        file_ext = os.path.splitext(attachment.filename)[1]
        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        filename = f"assessment_{course_id}_{timestamp}{file_ext}"
        file_path = ASSESSMENT_UPLOAD_DIR / filename

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(attachment.file, buffer)

        attachment_url = str(file_path)
        attachment_name = attachment.filename

    parsed_due_date = datetime.fromisoformat(due_date) if due_date else None
    parsed_start_date = datetime.fromisoformat(start_date) if start_date else None

    new_assessment = Assessment(
        course_id=course_id,
        title=title,
        description=description,
        instructions=instructions,
        assessment_type=normalize_assessment_type(assessment_type),
        max_score=max_score,
        weight=weight,
        passing_score=passing_score,
        due_date=parsed_due_date,
        start_date=parsed_start_date,
        duration_minutes=duration_minutes,
        is_published=is_published,
        allow_late_submission=allow_late_submission,
        late_penalty_percent=late_penalty_percent,
        max_attempts=max_attempts,
        attachment_url=attachment_url,
        attachment_name=attachment_name
    )

    db.add(new_assessment)
    db.commit()
    db.refresh(new_assessment)

    return {
        "id": new_assessment.id,
        "title": new_assessment.title,
        "assessment_type": new_assessment.assessment_type.value if new_assessment.assessment_type else None,
        "max_score": new_assessment.max_score,
        "weight": new_assessment.weight,
        "due_date": new_assessment.due_date.isoformat() if new_assessment.due_date else None,
        "is_published": new_assessment.is_published,
        "attachment_url": new_assessment.attachment_url,
        "attachment_name": new_assessment.attachment_name,
        "course_id": new_assessment.course_id
    }


# ============================================
# STUDENT PROGRESS MANAGEMENT (for testing)
# ============================================

@router.get("/students/{student_id}/enrollments")
async def get_student_enrollments(
    student_id: int,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Get all enrollments for a student"""
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    enrollments = db.query(Enrollment).filter(Enrollment.student_id == student_id).all()
    
    result = []
    for e in enrollments:
        course = db.query(Course).filter(Course.id == e.course_id).first()
        result.append({
            "id": e.id,
            "course_id": e.course_id,
            "course_code": course.course_code if course else None,
            "course_name": course.course_name if course else None,
            "status": e.status.value if e.status else "active",
            "progress": e.progress or 0,
            "completed_at": e.completed_at.isoformat() if e.completed_at else None,
            "total_score": e.total_score,
            "grade_letter": e.grade_letter
        })
    
    return {
        "student_id": student_id,
        "student_name": student.full_name,
        "student_email": student.email,
        "enrollments": result
    }


@router.post("/students/{student_id}/complete-course/{course_id}")
async def admin_complete_course(
    student_id: int,
    course_id: int,
    score: float = 8.0,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Admin: Mark a course as completed for a student (for testing purposes)"""
    # Verify student exists
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    # Verify course exists
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(404, "Course not found")
    
    # Get or create enrollment
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student_id,
        Enrollment.course_id == course_id
    ).first()
    
    if not enrollment:
        # Create enrollment first
        from app.models.course import EnrollmentStatus
        enrollment = Enrollment(
            student_id=student_id,
            course_id=course_id,
            status=EnrollmentStatus.COMPLETED,
            progress=100,
            completed_at=datetime.utcnow(),
            total_score=score,
            grade_letter=_calculate_grade(score)
        )
        db.add(enrollment)
    else:
        # Update existing enrollment
        from app.models.course import EnrollmentStatus
        enrollment.status = EnrollmentStatus.COMPLETED
        enrollment.progress = 100
        enrollment.completed_at = datetime.utcnow()
        enrollment.total_score = score
        enrollment.grade_letter = _calculate_grade(score)
    
    db.commit()
    
    return {
        "success": True,
        "message": f"Course '{course.course_name}' marked as completed for student {student.full_name}",
        "enrollment": {
            "course_id": course_id,
            "course_code": course.course_code,
            "progress": 100,
            "total_score": score,
            "grade_letter": _calculate_grade(score),
            "completed_at": enrollment.completed_at.isoformat()
        }
    }


@router.post("/students/{student_id}/complete-phase/{phase_id}")
async def admin_complete_phase(
    student_id: int,
    phase_id: int,
    score: float = 8.0,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Admin: Mark all courses in a phase as completed (for testing curriculum progression)"""
    from app.services.curriculum_rules import load_cnpm_curriculum
    
    # Verify student exists
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    # Load curriculum
    curriculum = load_cnpm_curriculum()
    
    # Find phase
    phase = None
    for p in curriculum.get("phases", []):
        if p["id"] == phase_id:
            phase = p
            break
    
    if not phase:
        raise HTTPException(404, f"Phase {phase_id} not found in curriculum")
    
    completed_courses = []
    
    # Get all courses in this phase (required + elective)
    required_courses = phase.get("required_courses", [])
    elective_courses = phase.get("elective_courses", [])
    min_elective = phase.get("elective_min_select", 0)
    
    # Fallback to old structure
    if not required_courses and not elective_courses:
        required_courses = phase.get("courses", [])
    
    # Complete all required courses
    for course_code in required_courses:
        course = db.query(Course).filter(Course.course_code == course_code).first()
        if not course:
            print(f"⚠️ [ADMIN COMPLETE-PHASE] Course not found: {course_code}")
            continue
        
        print(f"✓ [ADMIN COMPLETE-PHASE] Completing required course: {course_code} - {course.course_name}")
        
        # Get or create enrollment
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id == course.id
        ).first()
        
        if not enrollment:
            from app.models.course import EnrollmentStatus
            enrollment = Enrollment(
                student_id=student_id,
                course_id=course.id,
                status=EnrollmentStatus.COMPLETED,
                progress=100,
                completed_at=datetime.utcnow(),
                total_score=score,
                grade_letter=_calculate_grade(score)
            )
            db.add(enrollment)
        else:
            from app.models.course import EnrollmentStatus
            enrollment.status = EnrollmentStatus.COMPLETED
            enrollment.progress = 100
            enrollment.completed_at = datetime.utcnow()
            enrollment.total_score = score
            enrollment.grade_letter = _calculate_grade(score)
        
        completed_courses.append({
            "course_code": course_code,
            "course_name": course.course_name,
            "type": "required"
        })
    
    # Complete first N elective courses (based on min_elective)
    for idx, course_code in enumerate(elective_courses):
        if idx >= min_elective:
            break
            
        course = db.query(Course).filter(Course.course_code == course_code).first()
        if not course:
            print(f"⚠️ [ADMIN COMPLETE-PHASE] Elective course not found: {course_code}")
            continue
        
        print(f"✓ [ADMIN COMPLETE-PHASE] Completing elective course: {course_code} - {course.course_name}")
        
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id == course.id
        ).first()
        
        if not enrollment:
            from app.models.course import EnrollmentStatus
            enrollment = Enrollment(
                student_id=student_id,
                course_id=course.id,
                status=EnrollmentStatus.COMPLETED,
                progress=100,
                completed_at=datetime.utcnow(),
                total_score=score,
                grade_letter=_calculate_grade(score)
            )
            db.add(enrollment)
        else:
            from app.models.course import EnrollmentStatus
            enrollment.status = EnrollmentStatus.COMPLETED
            enrollment.progress = 100
            enrollment.completed_at = datetime.utcnow()
            enrollment.total_score = score
            enrollment.grade_letter = _calculate_grade(score)
        
        completed_courses.append({
            "course_code": course_code,
            "course_name": course.course_name,
            "type": "elective"
        })
    
    db.commit()
    
    return {
        "success": True,
        "message": f"Phase {phase_id} ({phase['name']}) completed for student {student.full_name}",
        "phase_id": phase_id,
        "phase_name": phase["name"],
        "completed_courses": completed_courses,
        "required_count": len(required_courses),
        "elective_count": min_elective,
        "total_courses": len(completed_courses)
    }


@router.post("/students/{student_id}/reset-progress")
async def admin_reset_progress(
    student_id: int,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Admin: Reset all course progress for a student"""
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    # Delete all enrollments
    deleted = db.query(Enrollment).filter(Enrollment.student_id == student_id).delete()
    db.commit()
    
    return {
        "success": True,
        "message": f"Reset progress for student {student.full_name}",
        "enrollments_deleted": deleted
    }


@router.get("/students/{student_id}/courses/{course_id}/lessons")
async def get_student_course_lessons(
    student_id: int,
    course_id: int,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Get detailed lesson and quiz progress for a student in a course"""
    from app.models.assessment import QuizResult
    
    # Verify student exists
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    # Verify course exists
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(404, "Course not found")
    
    # Get all lessons for this course
    lessons = db.query(Lesson).filter(Lesson.course_id == course_id).order_by(Lesson.order).all()
    
    result = []
    for lesson in lessons:
        # Get lesson progress
        lesson_progress = db.query(LessonProgress).filter(
            LessonProgress.student_id == student_id,
            LessonProgress.lesson_id == lesson.id
        ).first()
        
        # Get quiz result
        quiz_result = db.query(QuizResult).filter(
            QuizResult.user_id == student_id,
            QuizResult.lesson_id == lesson.id
        ).first()
        
        result.append({
            "id": lesson.id,
            "title": lesson.title,
            "order": lesson.order,
            "has_quiz": lesson.pdf_file_name is not None,
            "is_completed": lesson_progress.is_completed if lesson_progress else False,
            "completed_at": lesson_progress.completed_at.isoformat() if lesson_progress and lesson_progress.completed_at else None,
            "quiz_result": {
                "score": quiz_result.score if quiz_result else None,
                "total_questions": quiz_result.total_questions if quiz_result else None,
                "correct_answers": quiz_result.correct_answers if quiz_result else None,
                "completed_at": quiz_result.completed_at.isoformat() if quiz_result else None,
                "passed": quiz_result.score >= 70 if quiz_result else False
            } if quiz_result else None
        })
    
    return {
        "student_id": student_id,
        "student_name": student.full_name,
        "course_id": course_id,
        "course_name": course.course_name,
        "course_code": course.course_code,
        "total_lessons": len(lessons),
        "lessons": result
    }


@router.post("/students/{student_id}/courses/{course_id}/complete-all-quizzes")
async def admin_complete_all_quizzes(
    student_id: int,
    course_id: int,
    score: float = 100.0,
    user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """Admin: Auto-complete all quizzes in a course with max score (for testing)"""
    from app.models.assessment import QuizResult
    from app.models.course import EnrollmentStatus
    
    print(f"\n🔧 [ADMIN COMPLETE-ALL-QUIZZES] Starting for student_id={student_id}, course_id={course_id}, score={score}")
    
    # Verify student exists
    student = db.query(User).filter(User.id == student_id, User.role == UserRole.STUDENT).first()
    if not student:
        raise HTTPException(404, "Student not found")
    
    # Verify course exists
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(404, "Course not found")
    
    print(f"   Student: {student.full_name} ({student.email})")
    print(f"   Course: {course.course_code} - {course.course_name}")
    
    # Get all lessons for this course
    lessons = db.query(Lesson).filter(Lesson.course_id == course_id).all()
    print(f"   Found {len(lessons)} lessons in course")
    
    completed_quizzes = []
    
    # Complete quizzes for all lessons (if any exist)
    for lesson in lessons:
        # Check if quiz result already exists
        existing_result = db.query(QuizResult).filter(
            QuizResult.user_id == student_id,
            QuizResult.lesson_id == lesson.id
        ).first()
        
        if existing_result:
            # Update existing result to max score
            existing_result.score = score
            existing_result.correct_answers = existing_result.total_questions
            existing_result.completed_at = datetime.utcnow()
        else:
            # Create new quiz result with max score
            quiz_result = QuizResult(
                user_id=student_id,
                lesson_id=lesson.id,
                score=score,
                total_questions=10,  # Default
                correct_answers=10,
                completed_at=datetime.utcnow()
            )
            db.add(quiz_result)
        
        # Ensure lesson progress exists and is completed
        lesson_progress = db.query(LessonProgress).filter(
            LessonProgress.student_id == student_id,
            LessonProgress.lesson_id == lesson.id
        ).first()
        
        if not lesson_progress:
            lesson_progress = LessonProgress(
                student_id=student_id,
                lesson_id=lesson.id,
                is_completed=True,
                completed_at=datetime.utcnow()
            )
            db.add(lesson_progress)
        else:
            lesson_progress.is_completed = True
            lesson_progress.completed_at = datetime.utcnow()
        
        completed_quizzes.append({
            "lesson_id": lesson.id,
            "lesson_title": lesson.title,
            "score": score
        })
    
    print(f"   Completed {len(completed_quizzes)} quiz results")
    
    # Get or create enrollment
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student_id,
        Enrollment.course_id == course_id
    ).first()
    
    print(f"   Existing enrollment: {enrollment is not None}")
    
    if not enrollment:
        print(f"   Creating NEW enrollment as COMPLETED")
        # Create new enrollment as completed
        enrollment = Enrollment(
            student_id=student_id,
            course_id=course_id,
            status=EnrollmentStatus.COMPLETED,
            progress=100,
            completed_at=datetime.utcnow(),
            total_score=score / 10,  # Convert to 10-point scale
            grade_letter=_calculate_grade(score / 10)
        )
        db.add(enrollment)
    else:
        print(f"   Updating EXISTING enrollment to COMPLETED")
        # Update existing enrollment to completed
        enrollment.status = EnrollmentStatus.COMPLETED
        enrollment.progress = 100
        enrollment.completed_at = datetime.utcnow()
        enrollment.total_score = score / 10
        enrollment.grade_letter = _calculate_grade(score / 10)
    
    db.commit()
    print(f"✅ [ADMIN COMPLETE-ALL-QUIZZES] Success! Enrollment status: {enrollment.status}, Grade: {enrollment.grade_letter}\n")
    
    # Build success message
    if len(lessons) > 0:
        message = f"Đã hoàn thành tất cả {len(completed_quizzes)} bài quiz với điểm {score}% cho sinh viên {student.full_name}"
    else:
        message = f"Đã đánh dấu khóa học hoàn thành (không có bài học) với điểm {score / 10:.1f}/10 cho sinh viên {student.full_name}"
    
    return {
        "success": True,
        "message": message,
        "course_code": course.course_code,
        "course_name": course.course_name,
        "completed_quizzes": completed_quizzes,
        "lessons_count": len(lessons),
        "enrollment_status": "completed",
        "grade": _calculate_grade(score / 10)
    }


def _calculate_grade(score: float) -> str:
    """Calculate letter grade from score"""
    if score >= 9.0:
        return "A+"
    elif score >= 8.5:
        return "A"
    elif score >= 8.0:
        return "B+"
    elif score >= 7.0:
        return "B"
    elif score >= 6.5:
        return "C+"
    elif score >= 5.5:
        return "C"
    elif score >= 5.0:
        return "D+"
    elif score >= 4.0:
        return "D"
    else:
        return "F"
