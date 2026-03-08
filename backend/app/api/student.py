from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import Optional

from app.database import get_db
from app.api.auth import get_current_user
from app.models import (
    User,
    UserRole,
    StudentProfile,
    Enrollment,
    Course,
    EnrollmentStatus,
    Lesson,
    LessonProgress,
    Submission,
    Assessment
)
from app.models.assessment import QuizResult, StudentSkillProfile
from app.schemas.auth import SetSpecializationRequest
from app.services.learning_personalization import (
    LearningPersonalizationService,
    get_intake_assessment_template,
)

router = APIRouter(
    prefix="/student",
    tags=["Student"]
)

from app.services.curriculum_rules import (
    load_cnpm_curriculum,
    get_curriculum_codes,
    get_user_curriculum_state,
    get_allowed_course_codes,
    get_course_lock_status
)


def get_student_profile(db: Session, user: User) -> StudentProfile:
    if user.role != UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Not a student")

    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == user.id
    ).first()

    if not profile:
        raise HTTPException(status_code=404, detail="Student profile not found")

    return profile


def convert_score_to_gpa(score_10: float | None) -> float:
    if score_10 is None:
        return 0.0
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
    return 0.0


class IntakeAssessmentSubmission(BaseModel):
    answers: dict[str, str]


# =====================================================
# 📚 MY COURSES
# =====================================================
@router.get("/my-courses")
def get_my_courses(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get student's courses"""
    try:
        return []
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 📚 COURSES BY SPECIALIZATION
# =====================================================
@router.get("/specialization-courses")
def get_courses_by_specialization(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get all courses for student's specialization + all enrolled courses with enrollment status"""
    try:
        # Get student profile
        profile = get_student_profile(db, user)
        
        # Get student's enrollments (use user.id, not profile.id)
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == user.id
        ).all()
        enrolled_course_ids = {e.course_id for e in enrollments}
        
        # Determine completed course codes
        completed_course_ids = {
            e.course_id for e in enrollments
            if e.status == EnrollmentStatus.COMPLETED or (e.progress or 0) >= 100
        }
        completed_courses = []
        if completed_course_ids:
            completed_courses = db.query(Course).filter(
                Course.id.in_(list(completed_course_ids))
            ).all()
        completed_codes = {c.course_code for c in completed_courses}

        # Build curriculum-driven course list for CNPM
        course_dict = {}
        specialization_map = {
            "Công nghệ phần mềm": "CNPM",
            "Cong nghe phan mem": "CNPM",
            "CNPM": "CNPM"
        }
        normalized_specialization = specialization_map.get(profile.specialization, profile.specialization)

        curriculum_state = None
        if normalized_specialization in ["CNPM", None, ""]:
            curriculum = load_cnpm_curriculum()
            curriculum_codes = get_curriculum_codes(curriculum)
            curriculum_state = get_user_curriculum_state(db, user.id, curriculum)

            allowed_codes = get_allowed_course_codes(
                curriculum,
                curriculum_state.get("completed_codes", set()),
                curriculum_state.get("enrolled_codes", set())
            )

            # Always include enrolled courses (any phase)
            enrolled_codes = set()
            if enrolled_course_ids:
                enrolled_courses = db.query(Course).filter(
                    Course.id.in_(list(enrolled_course_ids))
                ).all()
                enrolled_codes = {c.course_code for c in enrolled_courses}

            codes_to_fetch = set(curriculum_codes) & (allowed_codes | enrolled_codes)
            if codes_to_fetch:
                cnpm_courses = db.query(Course).filter(
                    Course.course_code.in_(list(codes_to_fetch)),
                    Course.is_active == True
                ).all()
                course_dict = {c.id: c for c in cnpm_courses}
        else:
            # Fallback to old behavior for other specializations
            spec_courses = []
            if profile.specialization:
                spec_courses = db.query(Course).filter(
                    Course.specialization == profile.specialization,
                    Course.is_active == True
                ).all()
            course_dict = {c.id: c for c in spec_courses}
        
        # Add any enrolled courses outside the specialization
        enrolled_course_ids_list = list(enrolled_course_ids)
        if enrolled_course_ids_list:
            enrolled_courses = db.query(Course).filter(
                Course.id.in_(enrolled_course_ids_list),
                Course.is_active == True
            ).all()
            for c in enrolled_courses:
                if c.id not in course_dict:
                    course_dict[c.id] = c
        
        courses = list(course_dict.values())
        
        result = []
        for course in courses:
            # Get enrollment to check status
            enrollment = next((e for e in enrollments if e.course_id == course.id), None)
            is_completed = enrollment and (enrollment.status == EnrollmentStatus.COMPLETED or (enrollment.progress or 0) >= 100)
            
            # Calculate progress
            progress = 0
            if course.id in enrolled_course_ids:
                # Get total lessons
                total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
                if total_lessons > 0:
                    # Get completed lessons
                    completed_lessons = db.query(LessonProgress).filter(
                        LessonProgress.student_id == user.id,
                        LessonProgress.lesson_id.in_(
                            db.query(Lesson.id).filter(Lesson.course_id == course.id)
                        ),
                        LessonProgress.is_completed == True
                    ).count()
                    progress = int((completed_lessons / total_lessons) * 100)
                elif is_completed:
                    # Khóa học không có lessons nhưng đã complete thì hiển thị 100%
                    progress = 100
            
            lock_info = {"is_locked": False, "lock_reason": None}
            course_meta = None
            if curriculum_state:
                lock_info = get_course_lock_status(course.course_code, curriculum_state)
                course_meta = curriculum_state.get("course_by_code", {}).get(course.course_code)

            result.append({
                "id": course.id,
                "course_code": course.course_code,
                "course_name": course.course_name,
                "description": course.description,
                "major": course.major,
                "specialization": course.specialization,
                "credit_hours": course.credit_hours,
                "level": course.level.value if course.level else "beginner",
                "duration_weeks": course.duration_weeks,
                "thumbnail": course.thumbnail,
                "created_at": course.created_at.isoformat() if course.created_at else None,
                "is_enrolled": course.id in enrolled_course_ids,
                "progress": progress,
                "enrolled_count": db.query(Enrollment).filter(Enrollment.course_id == course.id).count(),
                "is_locked": lock_info.get("is_locked"),
                "lock_reason": lock_info.get("lock_reason"),
                "course_type": course_meta.get("type") if course_meta else None,
                "phase_id": curriculum_state.get("phase_by_code", {}).get(course.course_code, {}).get("id") if curriculum_state else None,
                "phase_name": curriculum_state.get("phase_by_code", {}).get(course.course_code, {}).get("name") if curriculum_state else None
            })
        
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 🧭 CURRICULUM ROADMAP (CNPM)
# =====================================================
@router.get("/curriculum-status")
def get_curriculum_status(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get full curriculum roadmap with status per course"""
    try:
        profile = get_student_profile(db, user)

        specialization_map = {
            "Công nghệ phần mềm": "CNPM",
            "Cong nghe phan mem": "CNPM",
            "CNPM": "CNPM"
        }
        normalized_specialization = specialization_map.get(profile.specialization, profile.specialization)
        if normalized_specialization not in ["CNPM", None, ""]:
            raise HTTPException(status_code=400, detail="Curriculum roadmap chỉ hỗ trợ CNPM")

        curriculum = load_cnpm_curriculum()
        curriculum_codes = get_curriculum_codes(curriculum)

        curriculum_state = get_user_curriculum_state(db, user.id, curriculum)
        completed_codes = curriculum_state.get("completed_codes", set())
        enrolled_codes = curriculum_state.get("enrolled_codes", set())

        courses = db.query(Course).filter(
            Course.course_code.in_(curriculum_codes)
        ).all()
        course_by_code = {c.course_code: c for c in courses}

        enrollments = []
        if courses:
            enrollments = db.query(Enrollment).filter(
                Enrollment.student_id == user.id,
                Enrollment.course_id.in_([c.id for c in courses])
            ).all()
        enrollment_by_course_id = {e.course_id: e for e in enrollments}

        phases_payload = []
        phases = curriculum.get("phases", [])
        course_details = curriculum.get("course_details", {})

        for idx, phase in enumerate(phases):
            # Support new structure with required_courses and elective_courses
            required_courses = phase.get("required_courses", [])
            elective_courses = phase.get("elective_courses", [])
            elective_min_select = phase.get("elective_min_select", 0)
            
            # Fallback to old structure
            if not required_courses and not elective_courses:
                raw_courses = phase.get("courses", [])
                for c in raw_courses:
                    if isinstance(c, str):
                        required_courses.append(c)
                    elif isinstance(c, dict):
                        required_courses.append(c.get("code", ""))
            
            # Build course list for required
            required_courses_payload = []
            for course_code in required_courses:
                course = course_by_code.get(course_code)
                course_meta = course_details.get(course_code, {"name": course_code, "credit_hours": 3})
                course_name = course.course_name if course else course_meta.get("name", course_code)
                course_credit = course.credit_hours if course else course_meta.get("credit_hours", 3)

                is_enrolled = course_code in enrolled_codes
                is_completed = course_code in completed_codes
                progress = 0

                if course and course.id in enrollment_by_course_id:
                    total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
                    if total_lessons > 0:
                        completed_lessons = db.query(LessonProgress).filter(
                            LessonProgress.student_id == user.id,
                            LessonProgress.lesson_id.in_(
                                db.query(Lesson.id).filter(Lesson.course_id == course.id)
                            ),
                            LessonProgress.is_completed == True
                        ).count()
                        progress = int((completed_lessons / total_lessons) * 100)
                    elif is_completed:
                        # Khóa học không có lessons nhưng đã complete thì hiển thị 100%
                        progress = 100

                lock_info = get_course_lock_status(course_code, curriculum_state)

                required_courses_payload.append({
                    "code": course_code,
                    "name": course_name,
                    "type": "required",
                    "credit_hours": course_credit,
                    "course_id": course.id if course else None,
                    "is_enrolled": is_enrolled,
                    "is_completed": is_completed,
                    "progress": progress,
                    "is_locked": lock_info.get("is_locked"),
                    "lock_reason": lock_info.get("lock_reason")
                })
            
            # Build course list for electives
            elective_courses_payload = []
            for course_code in elective_courses:
                course = course_by_code.get(course_code)
                course_meta = course_details.get(course_code, {"name": course_code, "credit_hours": 3})
                course_name = course.course_name if course else course_meta.get("name", course_code)
                course_credit = course.credit_hours if course else course_meta.get("credit_hours", 3)

                is_enrolled = course_code in enrolled_codes
                is_completed = course_code in completed_codes
                progress = 0

                if course and course.id in enrollment_by_course_id:
                    total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
                    if total_lessons > 0:
                        completed_lessons = db.query(LessonProgress).filter(
                            LessonProgress.student_id == user.id,
                            LessonProgress.lesson_id.in_(
                                db.query(Lesson.id).filter(Lesson.course_id == course.id)
                            ),
                            LessonProgress.is_completed == True
                        ).count()
                        progress = int((completed_lessons / total_lessons) * 100)
                    elif is_completed:
                        # Khóa học không có lessons nhưng đã complete thì hiển thị 100%
                        progress = 100

                lock_info = get_course_lock_status(course_code, curriculum_state)

                elective_courses_payload.append({
                    "code": course_code,
                    "name": course_name,
                    "type": "elective",
                    "credit_hours": course_credit,
                    "course_id": course.id if course else None,
                    "is_enrolled": is_enrolled,
                    "is_completed": is_completed,
                    "progress": progress,
                    "is_locked": lock_info.get("is_locked"),
                    "lock_reason": lock_info.get("lock_reason")
                })

            # Calculate completion status
            all_phase_codes = required_courses + elective_courses
            completed_required = [code for code in required_courses if code in completed_codes]
            completed_electives = [code for code in elective_courses if code in completed_codes]
            
            required_all_done = len(completed_required) == len(required_courses)
            elective_enough = len(completed_electives) >= elective_min_select
            phase_completed = required_all_done and elective_enough

            is_active = idx == curriculum_state.get("active_phase_index", 0)
            
            # Combine all courses for backward compatibility
            all_courses = required_courses_payload + elective_courses_payload

            phases_payload.append({
                "id": phase.get("id"),
                "name": phase.get("name"),
                "description": phase.get("description"),
                "is_completed": phase_completed,
                "is_active": is_active,
                "required_courses": required_courses_payload,
                "elective_courses": elective_courses_payload,
                "elective_min_select": elective_min_select,
                "required_completed": len(completed_required),
                "required_total": len(required_courses),
                "elective_completed": len(completed_electives),
                "courses": all_courses  # For backward compatibility
            })

        active_index = curriculum_state.get("active_phase_index", 0)
        active_phase = phases[active_index] if active_index < len(phases) else None

        return {
            "program": curriculum.get("program"),
            "specialization": normalized_specialization,
            "active_phase": {
                "id": active_phase.get("id") if active_phase else None,
                "name": active_phase.get("name") if active_phase else None,
                "index": active_index
            },
            "elective": {
                "min_select": curriculum_state.get("elective_min_select", 0),
                "selected": list(curriculum_state.get("selected_electives", set())),
                "completed": list(curriculum_state.get("completed_electives", set()))
            },
            "phases": phases_payload
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 🧠 PERSONALIZED ROADMAP / INTAKE ASSESSMENT
# =====================================================
@router.get("/personalization/intake-assessment")
def get_intake_assessment():
    """Return the intake assessment template used to personalize the roadmap."""
    return {
        "program": "CNPM",
        "questions": get_intake_assessment_template(),
    }


@router.post("/personalization/intake-assessment")
async def analyze_intake_assessment(
    payload: IntakeAssessmentSubmission,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Analyze student intake answers and generate AI-based unlock hints for the 3D roadmap."""
    try:
        profile = get_student_profile(db, user)

        specialization_map = {
            "Công nghệ phần mềm": "CNPM",
            "Cong nghe phan mem": "CNPM",
            "CNPM": "CNPM"
        }
        normalized_specialization = specialization_map.get(profile.specialization, profile.specialization)
        program = normalized_specialization or "CNPM"

        service = LearningPersonalizationService()
        analysis = await service.analyze_intake_assessment(
            answers=payload.answers,
            student_name=user.full_name,
            program=program,
        )

        profile.learning_style = analysis.get("learning_style")
        profile.preferred_difficulty = analysis.get("recommended_difficulty")
        db.commit()

        recommended_course_hints = []
        curriculum = load_cnpm_curriculum()
        curriculum_state = get_user_curriculum_state(db, user.id, curriculum)
        completed_codes = curriculum_state.get("completed_codes", set())
        unlocked_phase_ids = set(analysis.get("unlocked_phase_ids", []))
        course_details = curriculum.get("course_details", {})

        for phase in curriculum.get("phases", []):
            phase_id = phase.get("id")
            if phase_id not in unlocked_phase_ids:
                continue

            phase_courses = [
                *phase.get("required_courses", []),
                *phase.get("elective_courses", []),
            ]
            for course_code in phase_courses:
                if course_code in completed_codes:
                    continue

                lock_info = get_course_lock_status(course_code, curriculum_state)
                recommended_course_hints.append({
                    "phase_id": phase_id,
                    "phase_name": phase.get("name"),
                    "course_code": course_code,
                    "course_name": course_details.get(course_code, {}).get("name", course_code),
                    "is_locked": lock_info.get("is_locked"),
                    "lock_reason": lock_info.get("lock_reason"),
                })

                if len(recommended_course_hints) >= 6:
                    break

            if len(recommended_course_hints) >= 6:
                break

        return {
            "program": program,
            "analysis": {
                **analysis,
                "recommended_course_hints": recommended_course_hints,
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 📊 DASHBOARD
# =====================================================
@router.get("/dashboard")
def get_dashboard(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get student dashboard data"""
    try:
        profile = get_student_profile(db, user)
        
        # Get student's enrollments (NOT filtered by specialization) - use user.id
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == user.id
        ).all()
        enrolled_course_ids = {e.course_id for e in enrollments}
        
        # Get all enrolled courses (regardless of specialization)
        enrolled_course_ids_list = list(enrolled_course_ids)
        courses = []
        if enrolled_course_ids_list:
            courses = db.query(Course).filter(
                Course.id.in_(enrolled_course_ids_list),
                Course.is_active == True
            ).all()
        
        # Build recent courses list
        recent_courses = []
        for course in courses:
            # Get enrollment to check if completed
            enrollment = next((e for e in enrollments if e.course_id == course.id), None)
            is_completed = enrollment and (enrollment.status == EnrollmentStatus.COMPLETED or (enrollment.progress or 0) >= 100)
            
            # Calculate progress
            progress = 0
            total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            if total_lessons > 0:
                completed_lessons = db.query(LessonProgress).filter(
                    LessonProgress.student_id == user.id,
                    LessonProgress.lesson_id.in_(
                        db.query(Lesson.id).filter(Lesson.course_id == course.id)
                    ),
                    LessonProgress.is_completed == True
                ).count()
                progress = int((completed_lessons / total_lessons) * 100)
            elif is_completed:
                # Khóa học không có lessons nhưng đã complete thì hiển thị 100%
                progress = 100
            
            recent_courses.append({
                "id": course.id,
                "course_code": course.course_code,
                "course_name": course.course_name,
                "description": course.description,
                "credit_hours": course.credit_hours,
                "level": course.level.value if course.level else "beginner",
                "thumbnail": course.thumbnail,
                "progress": progress
            })
        
        # Calculate stats
        total_courses = len(recent_courses)
        in_progress = len([c for c in recent_courses if c['progress'] > 0 and c['progress'] < 100])
        completed_courses = len([c for c in recent_courses if c['progress'] == 100])
        avg_progress = int(sum(c['progress'] for c in recent_courses) / total_courses) if total_courses > 0 else 0
        
        return {
            "student": {
                "id": user.id,
                "name": user.full_name,
                "email": user.email,
                "specialization": profile.specialization
            },
            "stats": {
                "total_courses": total_courses,
                "completed_courses": completed_courses,
                "in_progress": in_progress,
                "hours_spent": 0,
                "avg_progress": avg_progress
            },
            "recent_courses": recent_courses
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 📝 GRADES
# =====================================================
@router.get("/grades")
def get_grades(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get student grades for all enrolled courses"""
    try:
        profile = get_student_profile(db, user)
        
        # Get all enrollments with course info
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == user.id
        ).all()
        
        grades = []
        for enrollment in enrollments:
            course = db.query(Course).filter(Course.id == enrollment.course_id).first()
            if not course:
                continue
            
            # Get all quiz submissions for this course
            submissions = db.query(Submission).join(Assessment).filter(
                Assessment.course_id == course.id,
                Submission.student_id == profile.id
            ).order_by(Submission.submitted_at.desc()).all()
            
            # Calculate average score
            avg_score = 0
            if submissions:
                avg_score = sum(s.percentage for s in submissions) / len(submissions)
            
            # Calculate progress
            is_completed = enrollment.status == EnrollmentStatus.COMPLETED or (enrollment.progress or 0) >= 100
            total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            completed_lessons = 0
            progress = 0
            
            if total_lessons > 0:
                completed_lessons = db.query(LessonProgress).filter(
                    LessonProgress.student_id == user.id,
                    LessonProgress.lesson_id.in_(
                        db.query(Lesson.id).filter(Lesson.course_id == course.id)
                    ),
                    LessonProgress.is_completed == True
                ).count()
                progress = int((completed_lessons / total_lessons) * 100)
            elif is_completed:
                # Khóa học không có lessons nhưng đã complete thì hiển thị 100%
                progress = 100
            
            grades.append({
                "course_id": course.id,
                "course_code": course.course_code,
                "course_name": course.course_name,
                "credit_hours": course.credit_hours,
                "grade": round(avg_score, 2) if submissions else None,
                "progress": progress,
                "completed_lessons": completed_lessons,
                "total_lessons": total_lessons,
                "quiz_count": len(submissions),
                "status": enrollment.status.value if enrollment.status else "enrolled",
                "enrolled_at": enrollment.enrolled_at.isoformat() if enrollment.enrolled_at else None
            })
        
        return grades
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 📈 STATISTICS
# =====================================================
@router.get("/statistics")
def get_statistics(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    profile = get_student_profile(db, user)

    enrollments = db.query(Enrollment).filter(
        Enrollment.student_id == profile.id
    ).all()

    total_courses = len(enrollments)
    completed = len([e for e in enrollments if e.status == EnrollmentStatus.COMPLETED])

    total_time = sum(e.total_time_spent or 0 for e in enrollments)

    course_ids = [e.course_id for e in enrollments]
    total_lessons = (
        db.query(Lesson).filter(Lesson.course_id.in_(course_ids)).count()
        if course_ids else 0
    )
    
    # Đếm số bài quiz DUY NHẤT đã làm (không tính làm lại)
    # Sử dụng distinct() để chỉ đếm mỗi lesson_id một lần
    completed_lessons = (
        db.query(QuizResult.lesson_id)
        .filter(QuizResult.user_id == user.id)
        .distinct()
        .count()
    )

    return {
        "overview": {
            "total_courses": total_courses,
            "completed_courses": completed,
            "completion_rate": round(completed / total_courses * 100, 1) if total_courses else 0
        },
        "time": {
            "total_hours": round(total_time / 60, 1)
        },
        "lessons": {
            "completed": completed_lessons,
            "total": total_lessons
        }
    }


# =====================================================
# 🎯 RECOMMENDED COURSES
# =====================================================
@router.get("/courses/recommended")
def get_recommended_courses(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get AI-powered recommended courses for student based on progress and performance"""
    try:
        # Get student profile (optional - may not exist)
        profile = db.query(StudentProfile).filter(
            StudentProfile.user_id == user.id
        ).first()
        specialization = profile.specialization if profile else None
        
        # Get student's enrollments and performance
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == user.id
        ).all()
        
        enrolled_course_ids = [e.course_id for e in enrollments]
        completed_course_ids = [e.course_id for e in enrollments if e.status == EnrollmentStatus.COMPLETED]
        
        print(f"🔍 [RECOMMENDATIONS] Student has {len(enrollments)} enrollments, {len(completed_course_ids)} completed")
        
        # Get all available courses not yet completed (can recommend active courses too)
        # Only exclude completed courses, not all enrollments
        available_courses = db.query(Course).filter(
            ~Course.id.in_(completed_course_ids) if completed_course_ids else True,
            Course.is_active == True
        ).all()
        
        print(f"🔍 [RECOMMENDATIONS] Found {len(available_courses)} available courses after filtering")
        
        # Calculate recommendation scores for each course
        recommendations = []
        
        for course in available_courses:
            score = 0
            reasons = []
            
            # 1. Specialization match (highest priority)
            if specialization and course.major == specialization:
                score += 40
                reasons.append(f"Phù hợp với chuyên ngành {specialization} của bạn")
            
            # 2. Course is available for beginners
            if len(completed_course_ids) < 3:
                score += 20
                reasons.append("Phù hợp để bắt đầu học")
            
            # 3. Student performance in similar courses
            similar_enrollments = [e for e in enrollments if e.course.major == course.major and e.total_score]
            if similar_enrollments:
                avg_score = sum(e.total_score for e in similar_enrollments) / len(similar_enrollments)
                if avg_score >= 80:
                    score += 20
                    reasons.append(f"Bạn học tốt các môn {course.major} (TB: {avg_score:.0f}%)")
                elif avg_score >= 60:
                    score += 10
                    reasons.append(f"Có nền tảng về {course.major}")
            
            # 4. Course popularity and rating
            enrollment_count = db.query(Enrollment).filter(
                Enrollment.course_id == course.id
            ).count()
            if enrollment_count > 50:
                score += 10
                reasons.append(f"Môn học phổ biến ({enrollment_count}+ sinh viên)")
            
            # Only recommend if score is meaningful
            if score >= 20:
                recommendations.append({
                    "id": course.id,
                    "title": course.course_name,
                    "description": course.description or (reasons[0] if reasons else "Môn học được đề xuất"),
                    "major": course.major,
                    "credit_hours": course.credit_hours,
                    "score": min(score, 100),  # Cap at 100
                    "reasons": reasons,
                    "icon": _get_course_icon(course.major),
                    "color": _get_course_color(course.major),
                    "instructor": None  # Will be populated later if needed
                })
            else:
                print(f"⚠️ [RECOMMENDATIONS] Skipping {course.course_code} (score: {score} < 20)")
        
        print(f"✅ [RECOMMENDATIONS] Generated {len(recommendations)} recommendations")
        
        # Sort by score descending and return top 6
        recommendations.sort(key=lambda x: x['score'], reverse=True)
        
        return {
            "recommendations": recommendations[:6],
            "total": len(recommendations),
            "student_info": {
                "specialization": specialization,
                "completed_courses": len(completed_course_ids),
                "active_courses": len([e for e in enrollments if e.status == EnrollmentStatus.ACTIVE])
            }
        }
    except Exception as e:
        print(f"Error getting recommendations: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


def _get_course_icon(major: str) -> str:
    """Get emoji icon for course major"""
    icons = {
        'CNPM': '💻',
        'CNDL': '🌐', 
        'ANM': '🎨',
        'IT': '🖥️',
        'CS': '⚡'
    }
    return icons.get(major, '📚')


def _get_course_color(major: str) -> str:
    """Get color for course major"""
    colors = {
        'CNPM': '#667eea',
        'CNDL': '#764ba2',
        'ANM': '#f093fb',
        'IT': '#4facfe',
        'CS': '#43e97b'
    }
    return colors.get(major, '#667eea')

# =====================================================
# 🎓 SET SPECIALIZATION
# =====================================================
@router.post("/set-specialization")
def set_specialization(
    request: SetSpecializationRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Set student specialization (CNPM, CNDL, ANM)"""
    print(f"\n🎓 [SET-SPECIALIZATION] Request received")
    print(f"   User: {user.email} (ID: {user.id})")
    print(f"   Requested specialization: {request.specialization}")
    
    try:
        profile = get_student_profile(db, user)
        
        specialization = request.specialization
        valid_specializations = ['CNPM', 'CNDL', 'ANM']
        
        if specialization not in valid_specializations:
            raise HTTPException(
                status_code=400, 
                detail=f"Invalid specialization. Must be one of: {', '.join(valid_specializations)}"
            )
        
        profile.specialization = specialization
        db.commit()
        
        return {
            "message": f"Specialization set to {specialization}",
            "specialization": specialization,
            "student_id": profile.student_id
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# 🧠 SKILL PROFILE
# =====================================================
@router.get("/skill-profile")
def get_skill_profile(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Return per-skill confidence scores for the authenticated student."""
    from app.services.analytics_service import SKILL_LABEL_MAP
    skill_profiles = (
        db.query(StudentSkillProfile)
        .filter(StudentSkillProfile.student_id == user.id)
        .order_by(StudentSkillProfile.skill_id)
        .all()
    )
    return {
        "skills": [
            {
                "skill_id": sp.skill_id,
                "label": SKILL_LABEL_MAP.get(sp.skill_id, sp.skill_id),
                "confidence": round(sp.confidence * 100),
                "attempts": sp.attempts,
                "correct": sp.correct,
                "last_updated": sp.last_updated.isoformat() if sp.last_updated else None,
            }
            for sp in skill_profiles
        ]
    }


# =====================================================
# 📊 LEARNING ANALYTICS & EARLY WARNING
# =====================================================
@router.get("/learning-analytics")
def get_learning_analytics(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Return learning analytics and risk level for the authenticated student."""
    from app.services.analytics_service import compute_student_analytics
    return compute_student_analytics(db, user.id)


# =====================================================
# 📅 STUDY PLANNER
# =====================================================
class StudyPlanRequest(BaseModel):
    goal: Optional[str] = None


@router.post("/study-plan")
async def generate_study_plan(
    request: StudyPlanRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Generate a personalised 4-week study plan via Gemini."""
    import json
    import httpx
    from app.core.config import settings
    from app.services.analytics_service import compute_student_analytics, SKILL_LABEL_MAP

    profile = get_student_profile(db, user)
    analytics = compute_student_analytics(db, user.id)

    enrollments = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id == user.id,
            Enrollment.status == EnrollmentStatus.ACTIVE,
        )
        .limit(5)
        .all()
    )
    courses_info = []
    for e in enrollments:
        c = db.query(Course).filter(Course.id == e.course_id).first()
        if c:
            courses_info.append(f"{c.course_name} (tiến độ: {e.progress}%)")

    weak_labels = [s["label"] for s in analytics.get("weak_skills", [])]
    goal = request.goal or "Hoàn thành các môn học hiện tại với điểm tốt"

    prompt = f"""Bạn là AI Study Planner cho sinh viên Việt Nam. Hãy tạo kế hoạch học tập 4 tuần.

Thông tin sinh viên:
- Tên: {user.full_name}
- Mục tiêu: {goal}
- Khóa đang học: {', '.join(courses_info) if courses_info else 'Chưa có'}
- Kỹ năng cần cải thiện: {', '.join(weak_labels) if weak_labels else 'Không có'}
- Điểm quiz trung bình gần đây: {analytics.get('avg_recent_score', 0):.0f}%
- Mức rủi ro học tập: {analytics.get('risk_level', 'low')}

Trả về đúng JSON sau, không thêm markdown fence, chỉ JSON thuần:
{{
  "goal": "mục tiêu cụ thể hóa",
  "summary": "tóm tắt kế hoạch 1-2 câu",
  "weeks": [
    {{
      "week": 1,
      "theme": "chủ đề tuần",
      "daily_tasks": [
        {{"day": "Thứ 2", "task": "mô tả nhiệm vụ ngắn gọn", "duration": "30 phút"}},
        {{"day": "Thứ 4", "task": "mô tả nhiệm vụ ngắn gọn", "duration": "45 phút"}},
        {{"day": "Thứ 7", "task": "mô tả nhiệm vụ ngắn gọn", "duration": "60 phút"}}
      ]
    }}
  ],
  "reminders": [
    {{"skill": "tên kỹ năng", "review_in_days": 3, "tip": "gợi ý ôn tập ngắn gọn"}}
  ]
}}"""

    GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                GEMINI_API_URL,
                headers={"Content-Type": "application/json", "x-goog-api-key": settings.GEMINI_API_KEY},
                json={"contents": [{"role": "user", "parts": [{"text": prompt}]}]},
            )
        if resp.status_code == 200:
            raw_text = (
                resp.json()
                .get("candidates", [{}])[0]
                .get("content", {})
                .get("parts", [{}])[0]
                .get("text", "")
            )
            # Strip markdown fences if present
            raw_text = raw_text.strip()
            if raw_text.startswith("```"):
                raw_text = "\n".join(raw_text.split("\n")[1:])
            if raw_text.endswith("```"):
                raw_text = "\n".join(raw_text.split("\n")[:-1])
            plan = json.loads(raw_text.strip())
        else:
            raise ValueError("Gemini API error")
    except Exception:
        # Fallback plan
        plan = _fallback_study_plan(goal, weak_labels, analytics.get("risk_level", "low"))

    return {"plan": plan, "generated_at": datetime.now().isoformat()}


def _fallback_study_plan(goal: str, weak_labels: list, risk_level: str) -> dict:
    tasks_w1 = [
        {"day": "Thứ 2", "task": "Xem lại bài học gần nhất và ghi chú điểm chưa hiểu", "duration": "30 phút"},
        {"day": "Thứ 4", "task": "Làm quiz ôn tập bài trước", "duration": "30 phút"},
        {"day": "Thứ 7", "task": "Đọc tài liệu bổ sung cho chủ đề yếu nhất", "duration": "45 phút"},
    ]
    tasks_w2 = [
        {"day": "Thứ 2", "task": "Học bài mới – đọc kỹ nội dung và PDF đính kèm", "duration": "45 phút"},
        {"day": "Thứ 4", "task": "Hỏi VLU Mentor về điểm khó trong bài", "duration": "20 phút"},
        {"day": "Thứ 7", "task": "Làm quiz bài mới, xem lại câu sai", "duration": "40 phút"},
    ]
    reminders = [
        {"skill": lb, "review_in_days": 3 + i * 4, "tip": f"Ôn lại '{lb}' bằng cách làm quiz liên quan"}
        for i, lb in enumerate(weak_labels[:3])
    ] if weak_labels else [
        {"skill": "Kiến thức tổng quát", "review_in_days": 7, "tip": "Điểm lại toàn bộ bài đã học trong tuần"}
    ]
    return {
        "goal": goal,
        "summary": "Kế hoạch 4 tuần tập trung ôn tập và học đều đặn mỗi ngày.",
        "weeks": [
            {"week": 1, "theme": "Ôn tập & củng cố nền tảng", "daily_tasks": tasks_w1},
            {"week": 2, "theme": "Học bài mới & thực hành quiz", "daily_tasks": tasks_w2},
            {"week": 3, "theme": "Ôn lại điểm yếu & cải thiện điểm số", "daily_tasks": tasks_w1},
            {"week": 4, "theme": "Tổng kết & kiểm tra lại toàn bộ", "daily_tasks": tasks_w2},
        ],
        "reminders": reminders,
    }