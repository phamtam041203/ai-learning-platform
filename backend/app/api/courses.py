"""
Course, Enrollment and Grade API endpoints - FIXED VERSION
"""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from jose import JWTError, jwt
from typing import Optional, List
from datetime import datetime
from pathlib import Path
import re

from app.database import get_db
from app.models import (
    User, UserRole, StudentProfile,
    Course, Enrollment, Lesson, LessonProgress, Material,
    Assessment, Submission, CourseLevel, EnrollmentStatus, Question,
    EssaySubmission
)
from app.models.assessment import QuizResult
from app.core.config import settings
from app.api.auth import get_current_user_optional
from app.services.learning_personalization import LearningPersonalizationService
from app.services.curriculum_rules import (
    load_cnpm_curriculum,
    get_curriculum_codes,
    get_user_curriculum_state,
    validate_enrollment
)

router = APIRouter(
    prefix="/courses",
    tags=["Courses"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")
LESSON_LINK_PATTERN = re.compile(r"^\[\[lesson_id:(\d+)\]\]\s*", re.IGNORECASE)
LESSON_ACTIVITY_PATTERN = re.compile(r"^\[\[activity_type:(quiz|essay)\]\]\s*", re.IGNORECASE)


def _extract_lesson_id_from_assessment(assessment: Assessment) -> int | None:
    instructions = assessment.instructions or ""
    match = LESSON_LINK_PATTERN.match(instructions)
    if match:
        return int(match.group(1))
    return None


def _get_visible_instructions(assessment: Assessment) -> str:
    instructions = assessment.instructions or ""
    return LESSON_LINK_PATTERN.sub("", instructions, count=1).strip()


def _extract_lesson_activity_type(lesson: Lesson) -> str | None:
    content = lesson.content or ""
    match = LESSON_ACTIVITY_PATTERN.match(content)
    if match:
        return match.group(1).lower()
    return None


def _get_visible_lesson_content(lesson: Lesson) -> str:
    content = lesson.content or ""
    return LESSON_ACTIVITY_PATTERN.sub("", content, count=1).strip()


def _resolve_quiz_pass_requirement(quiz: Assessment) -> tuple[float, float]:
    max_score = float(quiz.max_score or 0)
    raw_passing_score = float(quiz.passing_score or 0)

    if max_score <= 0:
        return 0.0, 70.0

    if raw_passing_score <= 0:
        return round(max_score * 0.7, 2), 70.0

    if raw_passing_score <= max_score:
        return raw_passing_score, round((raw_passing_score / max_score) * 100, 2)

    if raw_passing_score <= 100:
        return round((raw_passing_score / 100) * max_score, 2), raw_passing_score

    return round(max_score * 0.7, 2), 70.0


def _get_lesson_file_kind(file_name: str | None) -> str | None:
    if not file_name:
        return None
    extension = Path(file_name).suffix.lower()
    return extension[1:] if extension else None


# ============================================
# HELPER: Get current user
# ============================================
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception

    return user


# ============================================
# HELPER: Get student profile (ADDED)
# ============================================
def get_student_profile(db: Session, user: User) -> StudentProfile:
    """Get student profile from user"""
    if user.role != UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Not a student")

    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == user.id
    ).first()

    if not profile:
        raise HTTPException(status_code=404, detail="Student profile not found")

    return profile


# ============================================
# COURSE ENDPOINTS
# ============================================

@router.get("")
async def get_courses(
    major: Optional[str] = None,
    level: Optional[str] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get all courses with filters"""
    query = db.query(Course).filter(Course.is_active == True)

    # Filter by major
    if major:
        query = query.filter(Course.major == major)

    # Filter by level
    if level:
        query = query.filter(Course.level == level)

    # Search
    if search:
        query = query.filter(
            (Course.course_name.ilike(f"%{search}%")) |
            (Course.course_code.ilike(f"%{search}%"))
        )

    # Get total
    total = query.count()

    # Pagination
    offset = (page - 1) * limit
    courses = query.order_by(desc(Course.is_featured), Course.course_code).offset(offset).limit(limit).all()

    return {
        "courses": [
            {
                "id": c.id,
                "course_code": c.course_code,
                "course_name": c.course_name,
                "description": c.description,
                "major": c.major,
                "credit_hours": c.credit_hours,
                "level": c.level.value if c.level else None,
                "semester": c.semester,
                "thumbnail": c.thumbnail,
                "is_featured": c.is_featured,
                "enrolled_count": db.query(Enrollment).filter(Enrollment.course_id == c.id).count(),
                "lesson_count": db.query(Lesson).filter(Lesson.course_id == c.id).count()
            }
            for c in courses
        ],
        "total": total,
        "page": page,
        "limit": limit,
        "pages": (total + limit - 1) // limit
    }


@router.get("/majors")
async def get_majors(db: Session = Depends(get_db)):
    """Get all available majors with course count"""
    majors = db.query(
        Course.major,
        func.count(Course.id).label("course_count")
    ).group_by(Course.major).all()

    major_names = {
        "CNTT": "Công nghệ thông tin",
        "KTPM": "Kỹ thuật phần mềm",
        "HTTT": "Hệ thống thông tin",
        "MMT": "Mạng máy tính",
        "KHMT": "Khoa học máy tính",
        "ATTT": "An toàn thông tin",
        "TTNT": "Trí tuệ nhân tạo"
    }

    return [
        {
            "code": m.major,
            "name": major_names.get(m.major, m.major),
            "course_count": m.course_count
        }
        for m in majors if m.major
    ]


@router.post("/create-sample-courses")
async def create_sample_courses(db: Session = Depends(get_db)):
    """Create sample courses for each specialization (Admin only)"""
    try:
        # Sample courses for CNPM specialization
        sample_courses = [
            {
                "course_code": "CNPM-101",
                "course_name": "Cơ sở lập trình",
                "description": "Kiến thức cơ bản về lập trình",
                "major": "CNTT",
                "specialization": "CNPM",
                "credit_hours": 3,
                "level": CourseLevel.BEGINNER,
                "duration_weeks": 15
            },
            {
                "course_code": "CNPM-102",
                "course_name": "Lập trình hướng đối tượng",
                "description": "OOP concepts and implementation",
                "major": "CNTT",
                "specialization": "CNPM",
                "credit_hours": 4,
                "level": CourseLevel.INTERMEDIATE,
                "duration_weeks": 15
            },
            {
                "course_code": "CNPM-103",
                "course_name": "Cơ sở dữ liệu",
                "description": "Database design and SQL",
                "major": "CNTT",
                "specialization": "CNPM",
                "credit_hours": 3,
                "level": CourseLevel.INTERMEDIATE,
                "duration_weeks": 15
            },
        ]

        # Sample courses for CNDL specialization
        sample_courses.extend([
            {
                "course_code": "CNDL-101",
                "course_name": "Thiết kế web cơ bản",
                "description": "HTML, CSS, JavaScript",
                "major": "CNTT",
                "specialization": "CNDL",
                "credit_hours": 3,
                "level": CourseLevel.BEGINNER,
                "duration_weeks": 15
            },
            {
                "course_code": "CNDL-102",
                "course_name": "Frontend advanced",
                "description": "React, Vue, Angular",
                "major": "CNTT",
                "specialization": "CNDL",
                "credit_hours": 4,
                "level": CourseLevel.INTERMEDIATE,
                "duration_weeks": 15
            },
        ])

        # Sample courses for ANM specialization
        sample_courses.extend([
            {
                "course_code": "ANM-101",
                "course_name": "Mạng máy tính cơ bản",
                "description": "Network fundamentals",
                "major": "CNTT",
                "specialization": "ANM",
                "credit_hours": 3,
                "level": CourseLevel.BEGINNER,
                "duration_weeks": 15
            },
            {
                "course_code": "ANM-102",
                "course_name": "An ninh mạng",
                "description": "Network security",
                "major": "CNTT",
                "specialization": "ANM",
                "credit_hours": 4,
                "level": CourseLevel.ADVANCED,
                "duration_weeks": 15
            },
        ])

        # Insert courses
        created_count = 0
        for course_data in sample_courses:
            # Check if course already exists
            existing = db.query(Course).filter(Course.course_code == course_data["course_code"]).first()
            if not existing:
                course = Course(**course_data)
                db.add(course)
                created_count += 1

        db.commit()

        return {
            "message": f"Created {created_count} sample courses",
            "created_count": created_count,
            "total_courses": len(sample_courses)
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/my-courses")
async def get_my_courses(
    status_filter: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get enrolled courses for current student"""
    # Get student profile for validation
    profile = get_student_profile(db, current_user)

    # Use current_user.id because Enrollment.student_id references User.id
    query = db.query(Enrollment).filter(Enrollment.student_id == current_user.id)

    if status_filter:
        query = query.filter(Enrollment.status == status_filter)

    enrollments = query.all()

    result = []
    for e in enrollments:
        course = db.query(Course).filter(Course.id == e.course_id).first()
        if course:
            total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            result.append({
                "enrollment_id": e.id,
                "course": {
                    "id": course.id,
                    "course_code": course.course_code,
                    "course_name": course.course_name,
                    "major": course.major,
                    "credit_hours": course.credit_hours,
                    "level": course.level.value if course.level else None
                },
                "progress": e.progress,
                "completed_lessons": e.completed_lessons,
                "total_lessons": total_lessons,
                "status": e.status.value if e.status else None,
                "grades": {
                    "midterm": e.midterm_score,
                    "final": e.final_score,
                    "assignment": e.assignment_score,
                    "total": e.total_score,
                    "letter": e.grade_letter
                },
                "enrolled_at": e.enrolled_at.isoformat() if e.enrolled_at else None,
                "last_accessed": e.last_accessed.isoformat() if e.last_accessed else None
            })

    return result


@router.get("/{course_id}")
async def get_course_detail(
    course_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_optional)
):
    """Get course detail with lessons and user progress"""
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(404, "Course not found")

    # Get lessons
    lessons = db.query(Lesson).filter(
        Lesson.course_id == course_id,
        Lesson.is_published == True
    ).order_by(Lesson.order).all()

    # Get user's quiz results if logged in
    quiz_results_map = {}
    if current_user:
        from app.models.assessment import QuizResult
        quiz_results = db.query(QuizResult).filter(
            QuizResult.user_id == current_user.id,
            QuizResult.lesson_id.in_([l.id for l in lessons])
        ).all()
        
        # Map lesson_id -> best quiz result
        for qr in quiz_results:
            if qr.lesson_id not in quiz_results_map or qr.score > quiz_results_map[qr.lesson_id].score:
                quiz_results_map[qr.lesson_id] = qr

    # Get assessments
    assessments = db.query(Assessment).filter(
        Assessment.course_id == course_id,
        Assessment.is_published == True
    ).all()

    # Get materials
    materials = db.query(Material).filter(Material.course_id == course_id).all()
    
    # Calculate user progress if logged in
    user_progress = None
    if current_user:
        total_lessons = len(lessons)
        completed_lessons = len(quiz_results_map)
        progress_percent = int((completed_lessons / total_lessons * 100)) if total_lessons > 0 else 0
        
        user_progress = {
            "total_lessons": total_lessons,
            "completed_lessons": completed_lessons,
            "progress_percent": progress_percent
        }

    return {
        "course": {
            "id": course.id,
            "course_code": course.course_code,
            "course_name": course.course_name,
            "description": course.description,
            "major": course.major,
            "credit_hours": course.credit_hours,
            "level": course.level.value if course.level else None,
            "semester": course.semester,
            "duration_weeks": course.duration_weeks,
            "max_students": course.max_students,
            "thumbnail": course.thumbnail
        },
        "lessons": [
            {
                "id": l.id,
                "title": l.title,
                "description": l.description,
                "duration_minutes": l.duration_minutes,
                "order": l.order,
                "is_free_preview": l.is_free_preview,
                "pdf_file_name": l.pdf_file_name,
                "quiz_result": {
                    "completed": l.id in quiz_results_map,
                    "score": quiz_results_map[l.id].score if l.id in quiz_results_map else None,
                    "correct_answers": quiz_results_map[l.id].correct_answers if l.id in quiz_results_map else None,
                    "total_questions": quiz_results_map[l.id].total_questions if l.id in quiz_results_map else None,
                } if current_user else None
            }
            for l in lessons
        ],
        "assessments": [
            {
                "id": a.id,
                "title": a.title,
                "type": a.assessment_type.value if a.assessment_type else None,
                "max_score": a.max_score,
                "weight": a.weight,
                "due_date": a.due_date.isoformat() if a.due_date else None,
                "attachment_url": getattr(a, "attachment_url", None),
                "attachment_name": getattr(a, "attachment_name", None)
            }
            for a in assessments
        ],
        "materials": [
            {
                "id": m.id,
                "title": m.title,
                "type": m.material_type,
                "file_url": m.file_url
            }
            for m in materials
        ],
        "stats": {
            "enrolled_count": db.query(Enrollment).filter(Enrollment.course_id == course_id).count(),
            "lesson_count": len(lessons),
            "total_duration": sum(l.duration_minutes or 0 for l in lessons)
        },
        "user_progress": user_progress
    }


@router.post("/{course_id}/enroll")
async def enroll_course(
    course_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Enroll in a course - FIXED"""
    # Get student profile first
    profile = get_student_profile(db, current_user)

    # Check course exists
    course = db.query(Course).filter(Course.id == course_id, Course.is_active == True).first()
    if not course:
        raise HTTPException(404, "Course not found")

    # Check already enrolled - Use current_user.id (Enrollment.student_id references users.id)
    existing = db.query(Enrollment).filter(
        Enrollment.student_id == current_user.id,
        Enrollment.course_id == course_id
    ).first()

    if existing:
        raise HTTPException(400, "Already enrolled in this course")

    # Curriculum gating for CNPM students
    if profile.specialization in ["CNPM", None, ""]:
        curriculum = load_cnpm_curriculum()
        curriculum_codes = set(get_curriculum_codes(curriculum))
        if course.course_code in curriculum_codes:
            curriculum_state = get_user_curriculum_state(db, current_user.id, curriculum)
            allowed, reason = validate_enrollment(course.course_code, curriculum_state)
            if not allowed:
                if reason == "stage_locked":
                    raise HTTPException(400, "Chưa mở giai đoạn học cho môn này")
                if reason == "elective_limit":
                    raise HTTPException(400, "Bạn đã chọn đủ 2 môn tự chọn")
                if reason == "prerequisites":
                    raise HTTPException(400, "Chưa hoàn thành môn tiên quyết")
                raise HTTPException(400, "Không thể đăng ký môn này")

    # Check max students
    enrolled_count = db.query(Enrollment).filter(Enrollment.course_id == course_id).count()
    if course.max_students and enrolled_count >= course.max_students:
        raise HTTPException(400, "Course is full")

    # Create enrollment - Use current_user.id (Enrollment.student_id references users.id)
    enrollment = Enrollment(
        student_id=current_user.id,
        course_id=course_id,
        status=EnrollmentStatus.ACTIVE,
        progress=0,
        completed_lessons=0
    )
    db.add(enrollment)
    db.commit()

    return {
        "message": "Đăng ký khóa học thành công",
        "enrollment_id": enrollment.id
    }


# ============================================
# GRADE & STATISTICS ENDPOINTS
# ============================================

@router.get("/my-grades/summary")
async def get_grades_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get grade summary for current student - FIXED"""
    # Get student profile first
    profile = get_student_profile(db, current_user)

    # Use profile.id
    enrollments = db.query(Enrollment).filter(
        Enrollment.student_id == profile.id,
        Enrollment.total_score != None
    ).all()

    if not enrollments:
        return {
            "gpa": 0,
            "total_credits": 0,
            "completed_courses": 0,
            "courses": []
        }

    # Calculate GPA (scale 4.0)
    total_points = 0
    total_credits = 0
    courses_data = []

    for e in enrollments:
        course = db.query(Course).filter(Course.id == e.course_id).first()
        if course and e.total_score:
            credits = course.credit_hours or 3
            gpa_4 = convert_to_gpa_4(e.total_score)
            total_points += gpa_4 * credits
            total_credits += credits

            courses_data.append({
                "course_code": course.course_code,
                "course_name": course.course_name,
                "credits": credits,
                "midterm": e.midterm_score,
                "final": e.final_score,
                "assignment": e.assignment_score,
                "total_10": e.total_score,
                "letter": e.grade_letter,
                "gpa_4": gpa_4
            })

    gpa = round(total_points / total_credits, 2) if total_credits > 0 else 0

    return {
        "gpa": gpa,
        "gpa_10": round(sum(e.total_score for e in enrollments if e.total_score) / len(enrollments), 2),
        "total_credits": total_credits,
        "completed_courses": len([e for e in enrollments if e.status == EnrollmentStatus.COMPLETED]),
        "in_progress_courses": len([e for e in enrollments if e.status == EnrollmentStatus.ACTIVE]),
        "courses": courses_data
    }


def convert_to_gpa_4(score_10: float) -> float:
    """Convert 10-point scale to 4.0 GPA"""
    if score_10 >= 9.0:
        return 4.0
    elif score_10 >= 8.5:
        return 3.7
    elif score_10 >= 8.0:
        return 3.5
    elif score_10 >= 7.0:
        return 3.0
    elif score_10 >= 6.5:
        return 2.5
    elif score_10 >= 5.5:
        return 2.0
    elif score_10 >= 5.0:
        return 1.5
    elif score_10 >= 4.0:
        return 1.0
    else:
        return 0.0


@router.get("/my-stats/learning")
async def get_learning_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get learning statistics for current student - FIXED"""
    # Get student profile first
    profile = get_student_profile(db, current_user)

    # Use profile.id
    enrollments = db.query(Enrollment).filter(
        Enrollment.student_id == profile.id
    ).all()

    # Calculate stats
    total_courses = len(enrollments)
    completed_courses = len([e for e in enrollments if e.status == EnrollmentStatus.COMPLETED])
    total_time = sum(e.total_time_spent or 0 for e in enrollments)
    total_lessons_completed = sum(e.completed_lessons or 0 for e in enrollments)

    # Get all lessons for enrolled courses
    course_ids = [e.course_id for e in enrollments]
    total_lessons = db.query(Lesson).filter(Lesson.course_id.in_(course_ids)).count() if course_ids else 0

    # Average progress
    avg_progress = round(sum(e.progress or 0 for e in enrollments) / total_courses, 1) if total_courses > 0 else 0

    # Average score
    graded_enrollments = [e for e in enrollments if e.total_score]
    avg_score = round(sum(e.total_score for e in graded_enrollments) / len(graded_enrollments), 1) if graded_enrollments else 0

    # Get submissions count - Use profile.id
    submissions = db.query(Submission).filter(
        Submission.student_id == profile.id
    ).count()

    return {
        "total_courses": total_courses,
        "completed_courses": completed_courses,
        "in_progress_courses": total_courses - completed_courses,
        "total_time_hours": round(total_time / 60, 1),
        "total_lessons_completed": total_lessons_completed,
        "total_lessons": total_lessons,
        "average_progress": avg_progress,
        "average_score": avg_score,
        "total_submissions": submissions,
        "completion_rate": round(completed_courses / total_courses * 100, 1) if total_courses > 0 else 0
    }


@router.get("/by-major/{major}")
async def get_courses_by_major(
    major: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get courses by major with enrollment status - FIXED"""
    # Get student profile first
    profile = get_student_profile(db, current_user)

    courses = db.query(Course).filter(
        Course.major == major,
        Course.is_active == True
    ).order_by(Course.course_code).all()

    result = []
    for c in courses:
        # Check if enrolled - Use current_user.id (Enrollment.student_id references users.id)
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == current_user.id,
            Enrollment.course_id == c.id
        ).first()

        result.append({
            "id": c.id,
            "course_code": c.course_code,
            "course_name": c.course_name,
            "description": c.description,
            "credit_hours": c.credit_hours,
            "level": c.level.value if c.level else None,
            "is_enrolled": enrollment is not None,
            "progress": enrollment.progress if enrollment else 0,
            "grade": enrollment.grade_letter if enrollment else None,
            "lesson_count": db.query(Lesson).filter(Lesson.course_id == c.id).count()
        })

    return result


# ============================================
# LESSONS & QUIZZES
# ============================================
@router.get("/{course_id}/lessons")
async def get_course_lessons(
    course_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all lessons for a course"""
    # Check course exists
    course = db.query(Course).filter(Course.id == course_id, Course.is_active == True).first()
    if not course:
        raise HTTPException(404, "Course not found")

    # Get lessons ordered by lesson order
    lessons = db.query(Lesson).filter(
        Lesson.course_id == course_id,
        Lesson.is_published == True
    ).order_by(Lesson.order).all()

    course_quizzes = db.query(Assessment).filter(
        Assessment.course_id == course_id,
        Assessment.assessment_type == "quiz"
    ).all()

    quizzes_by_lesson_id = {}
    for quiz in course_quizzes:
        linked_lesson_id = _extract_lesson_id_from_assessment(quiz)
        if linked_lesson_id is not None and linked_lesson_id not in quizzes_by_lesson_id:
            quizzes_by_lesson_id[linked_lesson_id] = quiz

    quiz_results_map = {}
    if lessons:
        quiz_results = db.query(QuizResult).filter(
            QuizResult.user_id == current_user.id,
            QuizResult.lesson_id.in_([lesson.id for lesson in lessons])
        ).all()

        for quiz_result in quiz_results:
            existing_result = quiz_results_map.get(quiz_result.lesson_id)
            if existing_result is None or (quiz_result.score or 0) > (existing_result.score or 0):
                quiz_results_map[quiz_result.lesson_id] = quiz_result

    result = []
    for lesson in lessons:
        visible_content = _get_visible_lesson_content(lesson)
        activity_type = _extract_lesson_activity_type(lesson)
        lesson_quiz = quizzes_by_lesson_id.get(lesson.id)
        lesson_quiz_result = quiz_results_map.get(lesson.id)

        if activity_type is None:
            activity_type = "quiz" if lesson_quiz or lesson_quiz_result else "essay"

        result.append({
            "id": lesson.id,
            "title": lesson.title,
            "description": lesson.description,
            "content": visible_content,
            "order": lesson.order,
            "duration_minutes": lesson.duration_minutes,
            "is_published": lesson.is_published,
            "course_name": course.course_name,
            "pdf_file_name": lesson.pdf_file_name,
            "file_kind": _get_lesson_file_kind(lesson.pdf_file_name),
            "pdf_url": f"/api/lessons/{lesson.pdf_file_name}" if lesson.pdf_file_name else None,
            "activity_type": activity_type,
            "has_quiz": activity_type == "quiz",
            "quiz_result": {
                "completed": lesson_quiz_result is not None,
                "score": lesson_quiz_result.score if lesson_quiz_result else None,
                "correct_answers": lesson_quiz_result.correct_answers if lesson_quiz_result else None,
                "total_questions": lesson_quiz_result.total_questions if lesson_quiz_result else None,
                "completed_at": lesson_quiz_result.completed_at.isoformat() if lesson_quiz_result and lesson_quiz_result.completed_at else None
            },
            "created_at": lesson.created_at.isoformat() if lesson.created_at else None
        })

    return result


@router.get("/{course_id}/lessons/{lesson_id}")
async def get_lesson_detail(
    course_id: int,
    lesson_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get lesson detail with quiz"""
    # Check lesson exists
    lesson = db.query(Lesson).filter(
        Lesson.id == lesson_id,
        Lesson.course_id == course_id,
        Lesson.is_published == True
    ).first()
    
    if not lesson:
        raise HTTPException(404, "Lesson not found")

    file_kind = _get_lesson_file_kind(lesson.pdf_file_name)

    # Get all quizzes for this course
    quizzes = db.query(Assessment).filter(
        Assessment.course_id == course_id,
        Assessment.assessment_type == "quiz"
    ).order_by(Assessment.id).all()
    
    # Find quiz that matches this lesson
    matched_quiz = None
    
    # Strategy 0: Match by explicit lesson metadata
    for quiz in quizzes:
        if _extract_lesson_id_from_assessment(quiz) == lesson_id:
            matched_quiz = quiz
            break

    # Strategy 1: Match by lesson order (quiz index)
    if lesson.order and lesson.order <= len(quizzes):
        if matched_quiz is None:
            matched_quiz = quizzes[lesson.order - 1]  # Quiz index 0 = Lesson order 1
    
    # Strategy 2: Match by title containing order number
    if not matched_quiz:
        for q in quizzes:
            q_title_lower = q.title.lower()
            # Match patterns like "quiz 01", "bài 1", "chapter 1"
            order_patterns = [
                f"quiz {lesson.order:02d}",  # quiz 01
                f"quiz {lesson.order}",       # quiz 1
                f"bài {lesson.order}",
                f"chapter {lesson.order}",
                f"chương {lesson.order}",
            ]
            for pattern in order_patterns:
                if pattern in q_title_lower:
                    matched_quiz = q
                    break
            if matched_quiz:
                break
    
    # Strategy 3: Match by similar title
    if not matched_quiz and lesson.title:
        lesson_keywords = lesson.title.lower().split()[:3]  # First 3 words
        for q in quizzes:
            q_title_lower = q.title.lower()
            matches = sum(1 for kw in lesson_keywords if kw in q_title_lower)
            if matches >= 2:
                matched_quiz = q
                break

    # Check for existing essay submission
    essay_submission = db.query(EssaySubmission).filter(
        EssaySubmission.lesson_id == lesson_id,
        EssaySubmission.student_id == current_user.id
    ).first()
    
    # Build essay submission info
    essay_submission_info = None
    if essay_submission:
        grader_name = None
        if essay_submission.graded_by:
            grader = db.query(User).filter(User.id == essay_submission.graded_by).first()
            grader_name = grader.full_name if grader else None
            
        essay_submission_info = {
            "id": essay_submission.id,
            "text_content": essay_submission.text_content,
            "file_url": essay_submission.file_url,
            "file_name": essay_submission.file_name,
            "status": essay_submission.status,
            "score": essay_submission.score,
            "max_score": essay_submission.max_score,
            "feedback": essay_submission.feedback,
            "graded_by": grader_name,
            "submitted_at": essay_submission.submitted_at.isoformat() if essay_submission.submitted_at else None,
            "graded_at": essay_submission.graded_at.isoformat() if essay_submission.graded_at else None
        }

    lesson_activity_type = _extract_lesson_activity_type(lesson)
    if lesson_activity_type is None:
        lesson_activity_type = "quiz" if matched_quiz else "essay"

    if lesson_activity_type == "essay":
        matched_quiz = None

    visible_content = _get_visible_lesson_content(lesson)

    result = {
        "id": lesson.id,
        "title": lesson.title,
        "description": lesson.description,
        "content": visible_content,
        "order": lesson.order,
        "file_name": lesson.pdf_file_name,
        "file_kind": file_kind,
        "file_extension": f".{file_kind}" if file_kind else None,
        "file_url": f"/api/lessons/{lesson.pdf_file_name}" if lesson.pdf_file_name else None,
        "can_preview_inline": file_kind == "pdf",
        "pdf_url": f"/api/lessons/{lesson.pdf_file_name}" if lesson.pdf_file_name else None,
        "activity_type": lesson_activity_type,
        "essay_prompt": visible_content if lesson_activity_type == "essay" else None,
        "quiz": None,
        "essay_submission": essay_submission_info,
        "has_quiz": False,  # Will be set to True if quiz found
        "supports_essay": lesson_activity_type == "essay"
    }

    if matched_quiz:
        # Get quiz questions
        questions = db.query(Question).filter(
            Question.assessment_id == matched_quiz.id
        ).order_by(Question.order).all()

        question_list = []
        for q in questions:
            question_list.append({
                "id": q.id,
                "question_text": q.question_text,
                "question_type": q.question_type,
                "option_a": q.option_a,
                "option_b": q.option_b,
                "option_c": q.option_c,
                "option_d": q.option_d,
                "points": q.points,
                "order": q.order
            })

        result["quiz"] = {
            "id": matched_quiz.id,
            "title": matched_quiz.title,
            "description": matched_quiz.description,
            "instructions": _get_visible_instructions(matched_quiz),
            "max_score": matched_quiz.max_score,
            "passing_score": matched_quiz.passing_score,
            "duration_minutes": matched_quiz.duration_minutes,
            "questions": question_list
        }
        result["has_quiz"] = len(question_list) > 0

    return result


@router.post("/{course_id}/lessons/{lesson_id}/quiz-submit")
async def submit_quiz(
    course_id: int,
    lesson_id: int,
    answers: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Submit quiz answers and calculate score"""
    # Get student profile
    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()
    
    if not profile:
        raise HTTPException(404, "Student profile not found")

    # Get lesson
    lesson = db.query(Lesson).filter(
        Lesson.id == lesson_id,
        Lesson.course_id == course_id
    ).first()
    
    if not lesson:
        raise HTTPException(404, "Lesson not found")

    lesson_activity_type = _extract_lesson_activity_type(lesson)
    if lesson_activity_type == "essay":
        raise HTTPException(400, "Bài học này dùng cho tự luận, không có quiz trắc nghiệm để nộp")

    # Get quiz - first prefer direct lesson link metadata, then fall back to legacy matching.
    quiz_title_pattern = f"QUIZ {lesson.order:02d}" if lesson.order else None
    quiz = None

    lesson_linked_quizzes = db.query(Assessment).filter(
        Assessment.course_id == course_id,
        Assessment.assessment_type == "quiz"
    ).order_by(Assessment.id).all()

    for candidate in lesson_linked_quizzes:
        if _extract_lesson_id_from_assessment(candidate) == lesson_id:
            quiz = candidate
            break
    
    if not quiz and quiz_title_pattern:
        quiz = db.query(Assessment).filter(
            Assessment.course_id == course_id,
            Assessment.title.contains(quiz_title_pattern),
            Assessment.assessment_type == "quiz"
        ).first()
    
    # Fallback: try matching by lesson title
    if not quiz:
        quiz = db.query(Assessment).filter(
            Assessment.course_id == course_id,
            Assessment.title.contains(lesson.title),
            Assessment.assessment_type == "quiz"
        ).first()
    
    # Fallback 2: get quiz by order
    if not quiz and lesson.order:
        quizzes = db.query(Assessment).filter(
            Assessment.course_id == course_id,
            Assessment.assessment_type == "quiz"
        ).order_by(Assessment.id).all()
        if lesson.order <= len(quizzes):
            quiz = quizzes[lesson.order - 1]

    if not quiz:
        raise HTTPException(404, f"Quiz not found for lesson '{lesson.title}'")

    # Get questions
    questions = db.query(Question).filter(
        Question.assessment_id == quiz.id
    ).all()

    # Calculate score
    correct_count = 0
    correct_answers_count = 0
    total_points = sum(q.points for q in questions)
    incorrect_questions = []
    
    print(f"[QUIZ GRADING] Total questions: {len(questions)}, Total points: {total_points}")
    print(f"[QUIZ GRADING] Received answers: {answers}")
    
    for question in questions:
        question_id = str(question.id)
        if question_id in answers:
            user_answer = answers[question_id].strip().lower() if isinstance(answers[question_id], str) else str(answers[question_id])
            correct_answer = question.correct_answer.strip().lower() if isinstance(question.correct_answer, str) else str(question.correct_answer)
            
            print(f"[QUIZ GRADING] Q{question_id}: User='{user_answer}' vs Correct='{correct_answer}' -> Match: {user_answer == correct_answer}")
            
            if user_answer == correct_answer:
                correct_count += question.points
                correct_answers_count += 1
            else:
                incorrect_questions.append({
                    "question": question.question_text,
                    "topic": question.explanation or question.question_text,
                    "correct_answer": question.correct_answer,
                    "student_answer": user_answer,
                    "explanation": question.explanation,
                })
        else:
            incorrect_questions.append({
                "question": question.question_text,
                "topic": question.explanation or question.question_text,
                "correct_answer": question.correct_answer,
                "student_answer": None,
                "explanation": question.explanation,
            })

    score = (correct_count / total_points * quiz.max_score) if total_points > 0 else 0
    percentage = (correct_count / total_points * 100) if total_points > 0 else 0
    required_score, required_percentage = _resolve_quiz_pass_requirement(quiz)
    passed = score >= required_score
    
    print(f"[QUIZ GRADING] Correct points: {correct_count}/{total_points} -> Score: {score}/{quiz.max_score} ({percentage}%)")

    # Create submission record
    import json
    from datetime import datetime
    submission = Submission(
        assessment_id=quiz.id,
        student_id=current_user.id,  # Use user_id, not profile.id
        answers_json=json.dumps(answers),
        score=score,
        max_score=quiz.max_score,
        percentage=percentage
    )
    db.add(submission)

    quiz_result = db.query(QuizResult).filter(
        QuizResult.user_id == current_user.id,
        QuizResult.lesson_id == lesson_id
    ).first()

    if quiz_result:
        quiz_result.score = round(percentage, 2)
        quiz_result.total_questions = len(questions)
        quiz_result.correct_answers = correct_answers_count
        quiz_result.completed_at = datetime.now()
    else:
        quiz_result = QuizResult(
            user_id=current_user.id,
            lesson_id=lesson_id,
            score=round(percentage, 2),
            total_questions=len(questions),
            correct_answers=correct_answers_count,
            completed_at=datetime.now(),
        )
        db.add(quiz_result)
    
    # Create or update lesson progress
    lesson_progress = db.query(LessonProgress).filter(
        LessonProgress.student_id == current_user.id,
        LessonProgress.lesson_id == lesson_id
    ).first()
    
    if not lesson_progress:
        lesson_progress = LessonProgress(
            student_id=current_user.id,
            lesson_id=lesson_id,
            is_completed=False
        )
        db.add(lesson_progress)
    
    # Mark lesson as completed only when the quiz pass requirement is met.
    if passed:
        lesson_progress.is_completed = True
        lesson_progress.completed_at = datetime.now()
    
    # Update enrollment progress and grade
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == current_user.id,
        Enrollment.course_id == course_id
    ).first()
    
    if enrollment:
        # Calculate overall course progress
        total_lessons = db.query(Lesson).filter(Lesson.course_id == course_id).count()
        if total_lessons > 0:
            completed_lessons = db.query(LessonProgress).filter(
                LessonProgress.student_id == current_user.id,
                LessonProgress.lesson_id.in_(
                    db.query(Lesson.id).filter(Lesson.course_id == course_id)
                ),
                LessonProgress.is_completed == True
            ).count()
            enrollment.progress = int((completed_lessons / total_lessons) * 100)
        
        # Calculate average grade from all quiz submissions for this course
        course_submissions = db.query(Submission).join(Assessment).filter(
            Assessment.course_id == course_id,
            Submission.student_id == current_user.id  # Use user_id
        ).all()
        
        if course_submissions:
            avg_percentage = sum(s.percentage for s in course_submissions) / len(course_submissions)
            enrollment.total_score = round(avg_percentage, 2)
        
        # Mark as completed if progress is 100%
        if enrollment.progress >= 100:
            enrollment.status = EnrollmentStatus.COMPLETED
            enrollment.completed_at = datetime.now()

    supplementary_materials = []
    lesson_materials = db.query(Material).filter(
        Material.course_id == course_id,
        ((Material.lesson_id == lesson_id) | (Material.lesson_id.is_(None)))
    ).order_by(Material.order.asc(), Material.id.asc()).limit(3).all()

    for material in lesson_materials:
        supplementary_materials.append({
            "title": material.title,
            "description": material.description or "Tài liệu bổ trợ được gợi ý cho phần kiến thức bạn vừa làm sai.",
            "type": material.material_type or "document",
            "url": material.file_url,
        })

    if lesson.pdf_file_name and not any(item["type"] == "lesson_pdf" for item in supplementary_materials):
        supplementary_materials.append({
            "title": f"Tài liệu PDF: {lesson.title}",
            "description": "Xem lại PDF của bài học hiện tại để củng cố khái niệm cốt lõi.",
            "type": "lesson_pdf",
            "url": None,
        })

    supplementary_materials.append({
        "title": "Hỏi VLU Mentor",
        "description": "Nhờ tutor AI giải thích lại các câu sai hoặc ví dụ tương tự ngay trong bài học.",
        "type": "ai_tutor",
        "url": None,
    })

    service = LearningPersonalizationService()
    adaptive_feedback = await service.build_adaptive_feedback(
        student_name=current_user.full_name,
        course_name=lesson.course.course_name if lesson.course else f"Course {course_id}",
        lesson_title=lesson.title,
        percentage=round(percentage, 2),
        passed=passed,
        incorrect_questions=incorrect_questions,
        supplementary_materials=supplementary_materials[:4],
        preferred_difficulty=profile.preferred_difficulty,
        learning_style=profile.learning_style,
    )

    # --- Update per-skill confidence ---
    from app.services.analytics_service import get_course_skill_domain, update_skill_profile
    if lesson.course:
        skill_domain = get_course_skill_domain(lesson.course)
        update_skill_profile(db, current_user.id, skill_domain, correct_answers_count, len(questions))

    # --- Remedial lesson suggestions (only when score < 70%) ---
    remedial_lessons = []
    if percentage < 70 and lesson.order and lesson.order > 1:
        earlier = (
            db.query(Lesson)
            .filter(
                Lesson.course_id == course_id,
                Lesson.order < lesson.order,
                Lesson.is_published == True,
            )
            .order_by(desc(Lesson.order))
            .limit(2)
            .all()
        )
        for rl in earlier:
            remedial_lessons.append({
                "lesson_id": rl.id,
                "title": rl.title,
                "order": rl.order,
                "course_id": course_id,
            })

    db.commit()

    return {
        "success": True,
        "score": round(score, 2),
        "percentage": round(percentage, 2),
        "max_score": quiz.max_score,
        "passed": passed,
        "passing_score": round(required_score, 2),
        "passing_percentage": round(required_percentage, 2),
        "course_progress": enrollment.progress if enrollment else 0,
        "course_grade": enrollment.total_score if enrollment else None,
        "correct_answers": correct_answers_count,
        "total_questions": len(questions),
        "adaptive_learning": adaptive_feedback,
        "remedial_lessons": remedial_lessons,
        "message": "Quiz submitted successfully!"
    }
