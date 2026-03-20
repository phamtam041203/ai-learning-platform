"""
Analytics Service – learning progress tracking and early-warning detection.
"""
from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timedelta
from typing import Dict, List

from sqlalchemy.orm import Session

from app.models.assessment import QuizResult, StudentSkillProfile, Submission, Assessment
from app.models.course import Course, Enrollment, EnrollmentStatus, Lesson, LessonProgress
from app.models.user import StudentProfile, User

SKILL_LABEL_MAP: Dict[str, str] = {
    "programming_foundations": "Nền tảng lập trình",
    "problem_solving": "Giải quyết vấn đề",
    "software_design": "Thiết kế phần mềm",
    "data_management": "Quản lý dữ liệu",
    "web_development": "Phát triển web",
    "engineering_quality": "Chất lượng kỹ thuật",
    "security": "Bảo mật thông tin",
}

# (keyword_substrings, skill_id) – checked case-insensitively
_COURSE_SKILL_RULES: List[tuple] = [
    (["CSDL", "SQL", "DATA", "DATABASE", "CƠ SỞ DỮ LIỆU"], "data_management"),
    (["WEB", "HTML", "CSS", "JAVASCRIPT", "REACT", "PHP", "NODEJS", "DJANGO", "FLASK", "PHÁT TRIỂN WEB", "LẬP TRÌNH WEB"], "web_development"),
    (["CNPM", "PTPM", "KTPM", "AGILE", "SCRUM", "PHẦN MỀM", "SOFTWARE"], "software_design"),
    (["CTDL", "PTTT", "GIẢI THUẬT", "ĐỆ QUY", "CẤU TRÚC DỮ LIỆU", "ALGORITHM"], "problem_solving"),
    (["KTHD", "KIỂM THỬ", "TESTING", "TEST", "QUALITY"], "engineering_quality"),
    (["ANM", "BẢO MẬT", "SECURITY", "MÃ HÓA", "CRYPTOGRAPHY", "NETWORK SECURITY"], "security"),
]


def get_course_skill_domain(course) -> str:
    """Derive skill domain from a Course ORM object."""
    combined = ((course.course_code or "") + " " + (course.course_name or "")).upper()
    for keywords, skill_id in _COURSE_SKILL_RULES:
        for kw in keywords:
            if kw in combined:
                return skill_id
    return "programming_foundations"


def update_skill_profile(
    db: Session,
    student_id: int,
    skill_id: str,
    correct: int,
    total: int,
) -> None:
    """
    Update per-skill confidence for a student using an exponential moving average.
    EMA: new_confidence = 0.7 * old + 0.3 * (correct/total)
    """
    if total == 0:
        return

    new_score = correct / total
    existing = (
        db.query(StudentSkillProfile)
        .filter(
            StudentSkillProfile.student_id == student_id,
            StudentSkillProfile.skill_id == skill_id,
        )
        .first()
    )

    if existing:
        existing.confidence = round(0.7 * existing.confidence + 0.3 * new_score, 3)
        existing.attempts += total
        existing.correct += correct
    else:
        db.add(
            StudentSkillProfile(
                student_id=student_id,
                skill_id=skill_id,
                confidence=round(new_score, 3),
                attempts=total,
                correct=correct,
            )
        )


def compute_student_analytics(db: Session, student_id: int) -> Dict:
    """
    Compute comprehensive learning analytics and risk level for a student.

    Returns
    -------
    dict with keys:
        risk_level          "low" | "medium" | "high"
        warning_messages    list[str]
        days_inactive       int
        avg_recent_score    float  (0-100)
        quiz_count          int
        quiz_trend          list[{date, score}]
        weak_skills         list[{id, label, confidence}]
        strong_skills       list[{id, label, confidence}]
        recommendation      str
    """
    now = datetime.now()

    # --- Recent quiz results (last 5) ---
    recent_quizzes: List[QuizResult] = (
        db.query(QuizResult)
        .filter(QuizResult.user_id == student_id)
        .order_by(QuizResult.completed_at.desc())
        .limit(5)
        .all()
    )

    # --- Quiz trend over last 30 days ---
    thirty_days_ago = now - timedelta(days=30)
    quiz_history: List[QuizResult] = (
        db.query(QuizResult)
        .filter(
            QuizResult.user_id == student_id,
            QuizResult.completed_at >= thirty_days_ago,
        )
        .order_by(QuizResult.completed_at.asc())
        .all()
    )
    quiz_trend = [
        {"date": qr.completed_at.strftime("%Y-%m-%d"), "score": round(qr.score, 1)}
        for qr in quiz_history
    ]

    # --- Days since last activity ---
    candidate_dates = []
    if recent_quizzes and recent_quizzes[0].completed_at:
        candidate_dates.append(recent_quizzes[0].completed_at)
    last_progress = (
        db.query(LessonProgress)
        .filter(LessonProgress.student_id == student_id)
        .order_by(LessonProgress.updated_at.desc())
        .first()
    )
    if last_progress and last_progress.updated_at:
        candidate_dates.append(last_progress.updated_at)

    # Strip timezone info to avoid offset-naive vs offset-aware comparison
    naive_dates = [d.replace(tzinfo=None) if d.tzinfo else d for d in candidate_dates]
    days_inactive = (now - max(naive_dates)).days if naive_dates else 0

    # --- Average recent score ---
    avg_score = (
        sum(qr.score for qr in recent_quizzes) / len(recent_quizzes)
        if recent_quizzes
        else 0.0
    )

    # --- Risk determination ---
    risk_level = "low"
    warning_messages: List[str] = []

    if days_inactive >= 7:
        risk_level = "high"
        warning_messages.append(
            f"Bạn chưa học trong {days_inactive} ngày. Hãy quay lại học ngay!"
        )
    elif days_inactive >= 4:
        if risk_level == "low":
            risk_level = "medium"
        warning_messages.append(
            f"Bạn đã nghỉ {days_inactive} ngày rồi. Đừng để mất đà nhé!"
        )

    if len(recent_quizzes) >= 3:
        last3_avg = sum(qr.score for qr in recent_quizzes[:3]) / 3
        if last3_avg < 50:
            risk_level = "high"
            warning_messages.append(
                f"Điểm 3 bài quiz gần nhất trung bình chỉ {last3_avg:.0f}%. Cần ôn lại kiến thức nền!"
            )
        elif last3_avg < 70:
            if risk_level == "low":
                risk_level = "medium"
            warning_messages.append(
                f"Điểm quiz trung bình đạt {last3_avg:.0f}%. Hãy xem lại phần còn yếu."
            )

    # --- Skill profiles ---
    skill_profiles: List[StudentSkillProfile] = (
        db.query(StudentSkillProfile)
        .filter(StudentSkillProfile.student_id == student_id)
        .all()
    )

    weak_skills = sorted(
        [
            {
                "id": sp.skill_id,
                "label": SKILL_LABEL_MAP.get(sp.skill_id, sp.skill_id),
                "confidence": round(sp.confidence * 100),
            }
            for sp in skill_profiles
            if sp.confidence < 0.6
        ],
        key=lambda x: x["confidence"],
    )
    strong_skills = sorted(
        [
            {
                "id": sp.skill_id,
                "label": SKILL_LABEL_MAP.get(sp.skill_id, sp.skill_id),
                "confidence": round(sp.confidence * 100),
            }
            for sp in skill_profiles
            if sp.confidence >= 0.7
        ],
        key=lambda x: x["confidence"],
        reverse=True,
    )

    return {
        "risk_level": risk_level,
        "warning_messages": warning_messages,
        "days_inactive": days_inactive,
        "avg_recent_score": round(avg_score, 1),
        "quiz_count": len(recent_quizzes),
        "quiz_trend": quiz_trend,
        "weak_skills": weak_skills[:3],
        "strong_skills": strong_skills[:3],
        "recommendation": _build_recommendation(risk_level, weak_skills, days_inactive),
    }


def _build_recommendation(
    risk_level: str, weak_skills: List[Dict], days_inactive: int
) -> str:
    if days_inactive >= 7:
        return "Ưu tiên 1: Quay lại học ngay hôm nay, dù chỉ 15 phút."
    if risk_level == "high" and weak_skills:
        return f"Ôn lại '{weak_skills[0]['label']}' ngay – đây là điểm yếu nhất của bạn."
    if weak_skills:
        return f"Tập trung cải thiện '{weak_skills[0]['label']}' trong tuần này."
    if risk_level == "medium":
        return "Cố gắng học đều đặn mỗi ngày để cải thiện điểm quiz."
    return "Tiếp tục duy trì nhịp học hiện tại – bạn đang làm tốt!"


RISK_PRIORITY = {"low": 0, "medium": 1, "high": 2}


def _safe_percentage(value: float | None, max_score: float | None = None) -> float | None:
    if value is None:
        return None

    score = float(value)
    if max_score and max_score > 0:
        maximum = float(max_score)
        if score <= maximum:
            return round((score / maximum) * 100, 1)

    if score <= 10:
        return round(score * 10, 1)

    return round(max(0.0, min(score, 100.0)), 1)


def _course_risk_snapshot(
    progress: float,
    average_score: float | None,
    days_inactive: int,
    enrollment_status: str,
) -> dict:
    reasons: list[str] = []
    risk_score = 0

    if enrollment_status == EnrollmentStatus.PENDING.value:
        risk_score += 1
        reasons.append("Đăng ký học phần đang chờ duyệt nên sinh viên chưa vào nhịp học.")

    if progress < 25:
        risk_score += 3
        reasons.append(f"Tiến độ chỉ đạt {progress:.0f}%.")
    elif progress < 50:
        risk_score += 2
        reasons.append(f"Tiến độ mới đạt {progress:.0f}%.")

    if average_score is not None:
        if average_score < 50:
            risk_score += 3
            reasons.append(f"Điểm trung bình hiện ở mức {average_score:.0f}%.")
        elif average_score < 65:
            risk_score += 2
            reasons.append(f"Điểm trung bình mới đạt {average_score:.0f}%.")

    if days_inactive >= 10:
        risk_score += 3
        reasons.append(f"Không có hoạt động học tập trong {days_inactive} ngày.")
    elif days_inactive >= 5:
        risk_score += 1
        reasons.append(f"Nhịp học bị gián đoạn {days_inactive} ngày.")

    if risk_score >= 5:
        risk_level = "high"
    elif risk_score >= 2:
        risk_level = "medium"
    else:
        risk_level = "low"

    return {
        "risk_level": risk_level,
        "risk_score": risk_score,
        "reasons": reasons[:3],
    }


def _merge_risk_levels(*levels: str) -> str:
    return max(levels, key=lambda item: RISK_PRIORITY.get(item, 0)) if levels else "low"


def compute_teacher_analytics(db: Session, teacher_id: int) -> Dict:
    teacher_courses = (
        db.query(Course)
        .filter(Course.teacher_id == teacher_id)
        .order_by(Course.created_at.desc())
        .all()
    )

    course_ids = [course.id for course in teacher_courses]
    if not course_ids:
        return {
            "overview": {
                "total_courses": 0,
                "total_students": 0,
                "students_on_track": 0,
                "students_at_risk": 0,
                "high_risk_students": 0,
                "inactive_students": 0,
                "avg_progress": 0,
                "avg_score": 0,
                "completion_rate": 0,
            },
            "risk_distribution": [
                {"level": "low", "label": "Ổn định", "count": 0},
                {"level": "medium", "label": "Cần chú ý", "count": 0},
                {"level": "high", "label": "Nguy cơ rớt môn", "count": 0},
            ],
            "top_performers": [],
            "at_risk_students": [],
            "course_insights": [],
            "action_summary": {
                "needs_intervention_now": 0,
                "needs_follow_up": 0,
                "best_performers": 0,
            },
        }

    enrollments = (
        db.query(Enrollment)
        .filter(
            Enrollment.course_id.in_(course_ids),
            Enrollment.status.in_([
                EnrollmentStatus.ACTIVE,
                EnrollmentStatus.COMPLETED,
                EnrollmentStatus.PENDING,
            ]),
        )
        .all()
    )

    student_ids = sorted({enrollment.student_id for enrollment in enrollments})
    students = db.query(User).filter(User.id.in_(student_ids)).all() if student_ids else []
    profiles = (
        db.query(StudentProfile).filter(StudentProfile.user_id.in_(student_ids)).all()
        if student_ids
        else []
    )

    user_map = {student.id: student for student in students}
    profile_map = {profile.user_id: profile for profile in profiles}
    lesson_counts_by_course = defaultdict(int)
    for lesson in db.query(Lesson).filter(Lesson.course_id.in_(course_ids)).all():
        lesson_counts_by_course[lesson.course_id] += 1

    completed_lessons_by_key = defaultdict(int)
    last_progress_at_by_key = {}
    if student_ids:
        lesson_progress_rows = (
            db.query(LessonProgress, Lesson.course_id)
            .join(Lesson, LessonProgress.lesson_id == Lesson.id)
            .filter(Lesson.course_id.in_(course_ids), LessonProgress.student_id.in_(student_ids))
            .all()
        )
        for progress, course_id in lesson_progress_rows:
            key = (progress.student_id, course_id)
            if progress.is_completed:
                completed_lessons_by_key[key] += 1
            if progress.updated_at:
                current = last_progress_at_by_key.get(key)
                if current is None or progress.updated_at > current:
                    last_progress_at_by_key[key] = progress.updated_at

    quiz_scores_by_key = defaultdict(list)
    last_quiz_at_by_key = {}
    if student_ids:
        quiz_rows = (
            db.query(QuizResult, Lesson.course_id)
            .join(Lesson, QuizResult.lesson_id == Lesson.id)
            .filter(Lesson.course_id.in_(course_ids), QuizResult.user_id.in_(student_ids))
            .all()
        )
        for result, course_id in quiz_rows:
            key = (result.user_id, course_id)
            quiz_scores_by_key[key].append(float(result.score))
            if result.completed_at:
                current = last_quiz_at_by_key.get(key)
                if current is None or result.completed_at > current:
                    last_quiz_at_by_key[key] = result.completed_at

    submission_scores_by_key = defaultdict(list)
    last_submission_at_by_key = {}
    if student_ids:
        submission_rows = (
            db.query(Submission, Assessment.course_id, Assessment.max_score)
            .join(Assessment, Submission.assessment_id == Assessment.id)
            .filter(Assessment.course_id.in_(course_ids), Submission.student_id.in_(student_ids))
            .all()
        )
        for submission, course_id, max_score in submission_rows:
            key = (submission.student_id, course_id)
            normalized = _safe_percentage(submission.score, submission.max_score or max_score)
            if normalized is not None:
                submission_scores_by_key[key].append(normalized)

            event_time = submission.graded_at or submission.submitted_at
            if event_time:
                current = last_submission_at_by_key.get(key)
                if current is None or event_time > current:
                    last_submission_at_by_key[key] = event_time

    student_course_rows = defaultdict(list)
    course_rows_map = defaultdict(list)

    for enrollment in enrollments:
        course = next((item for item in teacher_courses if item.id == enrollment.course_id), None)
        student = user_map.get(enrollment.student_id)
        if not course or not student:
            continue

        key = (enrollment.student_id, enrollment.course_id)
        total_lessons = lesson_counts_by_course.get(enrollment.course_id, 0)
        completed_lessons = completed_lessons_by_key.get(key, 0)

        progress = float(enrollment.progress or 0)
        if progress <= 0 and total_lessons > 0:
            progress = round((completed_lessons / total_lessons) * 100, 1)

        average_score = _safe_percentage(enrollment.total_score)
        if average_score is None and submission_scores_by_key.get(key):
            scores = submission_scores_by_key[key]
            average_score = round(sum(scores) / len(scores), 1)
        if average_score is None and quiz_scores_by_key.get(key):
            scores = quiz_scores_by_key[key]
            average_score = round(sum(scores) / len(scores), 1)

        activity_dates = [
            enrollment.last_accessed,
            last_progress_at_by_key.get(key),
            last_quiz_at_by_key.get(key),
            last_submission_at_by_key.get(key),
            enrollment.completed_at,
            enrollment.enrolled_at,
        ]
        normalized_dates = [
            item.replace(tzinfo=None) if item and item.tzinfo else item
            for item in activity_dates
            if item is not None
        ]
        last_activity = max(normalized_dates) if normalized_dates else None
        days_inactive = (datetime.now() - last_activity).days if last_activity else 0

        course_risk = _course_risk_snapshot(
            progress=progress,
            average_score=average_score,
            days_inactive=days_inactive,
            enrollment_status=enrollment.status.value if hasattr(enrollment.status, "value") else str(enrollment.status),
        )

        row = {
            "course_id": course.id,
            "course_name": course.course_name,
            "course_code": course.course_code,
            "progress": round(progress, 1),
            "average_score": average_score,
            "days_inactive": days_inactive,
            "status": enrollment.status.value if hasattr(enrollment.status, "value") else str(enrollment.status),
            "risk_level": course_risk["risk_level"],
            "risk_score": course_risk["risk_score"],
            "risk_reasons": course_risk["reasons"],
            "completed_lessons": completed_lessons,
            "total_lessons": total_lessons,
        }
        student_course_rows[enrollment.student_id].append(row)
        course_rows_map[course.id].append(row)

    analytics_cache = {
        student_id: compute_student_analytics(db, student_id)
        for student_id in student_course_rows.keys()
    }

    student_cards = []
    for student_id, rows in student_course_rows.items():
        student = user_map.get(student_id)
        profile = profile_map.get(student_id)
        analytics = analytics_cache.get(student_id, {})
        progress_values = [row["progress"] for row in rows]
        score_values = [row["average_score"] for row in rows if row["average_score"] is not None]
        avg_progress = round(sum(progress_values) / len(progress_values), 1) if progress_values else 0
        avg_score = round(sum(score_values) / len(score_values), 1) if score_values else None
        most_at_risk_course = max(rows, key=lambda item: (item["risk_score"], item["days_inactive"], -item["progress"]))
        overall_risk = _merge_risk_levels(
            analytics.get("risk_level", "low"),
            most_at_risk_course["risk_level"],
        )
        days_inactive = max([row["days_inactive"] for row in rows] + [analytics.get("days_inactive", 0)])
        engagement_score = max(0.0, 100.0 - min(days_inactive, 30) * 3.2)
        base_score = avg_score if avg_score is not None else avg_progress
        performance_index = round((base_score * 0.55) + (avg_progress * 0.3) + (engagement_score * 0.15), 1)

        warning_messages = []
        for message in analytics.get("warning_messages", []):
            if message not in warning_messages:
                warning_messages.append(message)
        for reason in most_at_risk_course.get("risk_reasons", []):
            if reason not in warning_messages:
                warning_messages.append(reason)

        student_cards.append({
            "id": student.id,
            "student_id": profile.student_id if profile else None,
            "full_name": student.full_name,
            "email": student.email,
            "major": profile.major if profile else None,
            "year": profile.intake_year if profile else None,
            "risk_level": overall_risk,
            "risk_score": most_at_risk_course["risk_score"] + RISK_PRIORITY.get(analytics.get("risk_level", "low"), 0),
            "avg_progress": avg_progress,
            "avg_score": avg_score,
            "days_inactive": days_inactive,
            "performance_index": performance_index,
            "warning_messages": warning_messages[:4],
            "recommendation": analytics.get("recommendation") or "Theo dõi thêm tiến độ học tập trong tuần này.",
            "weak_skills": analytics.get("weak_skills", []),
            "strong_skills": analytics.get("strong_skills", []),
            "course_count": len(rows),
            "courses": rows,
            "most_at_risk_course": {
                "course_id": most_at_risk_course["course_id"],
                "course_name": most_at_risk_course["course_name"],
                "progress": most_at_risk_course["progress"],
                "average_score": most_at_risk_course["average_score"],
            },
        })

    top_performers = [
        {
            **student,
            "highlight": (
                student["strong_skills"][0]["label"]
                if student["strong_skills"]
                else "Duy trì kết quả ổn định"
            ),
        }
        for student in sorted(
            [item for item in student_cards if item["risk_level"] == "low"],
            key=lambda item: (item["performance_index"], item["avg_score"] or 0, item["avg_progress"]),
            reverse=True,
        )[:5]
    ]

    at_risk_students = sorted(
        [item for item in student_cards if item["risk_level"] != "low"],
        key=lambda item: (
            RISK_PRIORITY.get(item["risk_level"], 0),
            item["risk_score"],
            -(item["avg_score"] or 0),
            -item["avg_progress"],
        ),
        reverse=True,
    )[:10]

    course_insights = []
    for course in teacher_courses:
        rows = course_rows_map.get(course.id, [])
        progress_values = [row["progress"] for row in rows]
        score_values = [row["average_score"] for row in rows if row["average_score"] is not None]
        completed_count = len([row for row in rows if row["status"] == EnrollmentStatus.COMPLETED.value or row["progress"] >= 100])
        high_risk_count = len([row for row in rows if row["risk_level"] == "high"])
        medium_risk_count = len([row for row in rows if row["risk_level"] == "medium"])
        inactive_count = len([row for row in rows if row["days_inactive"] >= 5])
        course_insights.append({
            "course_id": course.id,
            "course_name": course.course_name,
            "course_code": course.course_code,
            "students_count": len(rows),
            "avg_progress": round(sum(progress_values) / len(progress_values), 1) if progress_values else 0,
            "avg_score": round(sum(score_values) / len(score_values), 1) if score_values else None,
            "completion_rate": round((completed_count / len(rows)) * 100, 1) if rows else 0,
            "high_risk_students": high_risk_count,
            "medium_risk_students": medium_risk_count,
            "inactive_students": inactive_count,
            "attention_needed": high_risk_count + medium_risk_count,
        })

    avg_progress = round(
        sum(student["avg_progress"] for student in student_cards) / len(student_cards), 1
    ) if student_cards else 0
    scored_students = [student["avg_score"] for student in student_cards if student["avg_score"] is not None]
    avg_score = round(sum(scored_students) / len(scored_students), 1) if scored_students else 0
    high_risk_students = len([student for student in student_cards if student["risk_level"] == "high"])
    medium_risk_students = len([student for student in student_cards if student["risk_level"] == "medium"])
    low_risk_students = len([student for student in student_cards if student["risk_level"] == "low"])
    inactive_students = len([student for student in student_cards if student["days_inactive"] >= 5])

    return {
        "overview": {
            "total_courses": len(teacher_courses),
            "total_students": len(student_cards),
            "students_on_track": low_risk_students,
            "students_at_risk": medium_risk_students + high_risk_students,
            "high_risk_students": high_risk_students,
            "inactive_students": inactive_students,
            "avg_progress": avg_progress,
            "avg_score": avg_score,
            "completion_rate": round(
                sum(course["completion_rate"] for course in course_insights) / len(course_insights), 1
            ) if course_insights else 0,
        },
        "risk_distribution": [
            {"level": "low", "label": "Ổn định", "count": low_risk_students},
            {"level": "medium", "label": "Cần chú ý", "count": medium_risk_students},
            {"level": "high", "label": "Nguy cơ rớt môn", "count": high_risk_students},
        ],
        "top_performers": top_performers,
        "at_risk_students": at_risk_students,
        "course_insights": sorted(course_insights, key=lambda item: (item["high_risk_students"], item["attention_needed"], -(item["avg_score"] or 0)), reverse=True),
        "action_summary": {
            "needs_intervention_now": high_risk_students,
            "needs_follow_up": medium_risk_students,
            "best_performers": len(top_performers),
        },
    }
