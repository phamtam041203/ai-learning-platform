"""
Analytics Service – learning progress tracking and early-warning detection.
"""
from __future__ import annotations

from datetime import datetime, timedelta
from typing import Dict, List

from sqlalchemy.orm import Session

from app.models.assessment import QuizResult, StudentSkillProfile
from app.models.course import Enrollment, LessonProgress

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
