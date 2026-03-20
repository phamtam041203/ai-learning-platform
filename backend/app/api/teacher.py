"""Teacher endpoints."""

from datetime import datetime
from io import BytesIO
from pathlib import Path
import json
import logging
import re
import shutil
import uuid

from docx import Document
from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, Request, UploadFile
import httpx
from pydantic import BaseModel, Field, ValidationError
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_teacher
from app.models.assessment import Assessment, AssessmentType, Question, QuizResult, Submission
from app.models.course import Course, Enrollment, EnrollmentStatus, Lesson, LessonProgress
from app.models.teacher_chat import TeacherStudentChatHistory
from app.models.user import StudentProfile, TeacherProfile, User
from app.core.config import settings
from app.services.analytics_service import compute_teacher_analytics

router = APIRouter()
logger = logging.getLogger(__name__)

GEMINI_API_KEY = settings.GEMINI_API_KEY
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

LESSON_UPLOAD_DIR = Path(__file__).resolve().parents[2] / "uploads" / "lessons"
QUIZ_UPLOAD_DIR = Path(__file__).resolve().parents[2] / "uploads" / "quizzes"
LESSON_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
QUIZ_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

QUESTION_PATTERN = re.compile(r"^(?:câu|question)\s*\d+\s*[:.)-]?\s*(.+)$", re.IGNORECASE)
OPTION_PATTERN = re.compile(r"^([A-D])\s*[:.)-]\s*(.+)$", re.IGNORECASE)
ANSWER_PATTERN = re.compile(r"^(?:đáp án|dap an|answer)\s*[:.-]\s*([A-D])\b", re.IGNORECASE)
EXPLANATION_PATTERN = re.compile(r"^(?:giải thích|giai thich|explanation)\s*[:.-]\s*(.+)$", re.IGNORECASE)
LESSON_LINK_PATTERN = re.compile(r"^\[\[lesson_id:(\d+)\]\]\s*", re.IGNORECASE)
LESSON_ACTIVITY_PATTERN = re.compile(r"^\[\[activity_type:(quiz|essay)\]\]\s*", re.IGNORECASE)
ALLOWED_LESSON_EXTENSIONS = {".pdf", ".doc", ".docx", ".ppt", ".pptx"}


class TeacherCoursePayload(BaseModel):
    title: str = Field(min_length=1)
    description: str = ""
    category: str = "programming"


class EnrollmentApprovalRequest(BaseModel):
    approve: bool


class TeacherStudentChatRequest(BaseModel):
    student_id: int
    message: str = Field(min_length=3, max_length=1200)
    course_id: int | None = None


class TeacherInterventionPlanRequest(BaseModel):
    student_id: int
    course_id: int | None = None


class TeacherQuizQuestionRequest(BaseModel):
    question_text: str
    option_a: str
    option_b: str
    option_c: str
    option_d: str
    correct_answer: str
    explanation: str = ""
    points: float = 1.0


class TeacherQuizCreateRequest(BaseModel):
    course_id: int
    lesson_id: int | None = None
    title: str
    description: str = ""
    is_published: bool = False
    questions: list[TeacherQuizQuestionRequest]


class TeacherQuizUpdateRequest(BaseModel):
    lesson_id: int | None = None
    title: str
    description: str = ""
    is_published: bool = False
    questions: list[TeacherQuizQuestionRequest]


def _generate_course_code(db: Session) -> str:
    while True:
        candidate = f"GV-{uuid.uuid4().hex[:8].upper()}"
        exists = db.query(Course).filter(Course.course_code == candidate).first()
        if not exists:
            return candidate


def _normalize_text(value: object, default: str = "") -> str:
    if value is None:
        return default
    if isinstance(value, str):
        return value
    return str(value)


async def _extract_request_data(request: Request) -> dict:
    content_type = (request.headers.get("content-type") or "").lower()

    if "application/json" in content_type:
        try:
            payload = await request.json()
        except Exception as exc:
            raise HTTPException(status_code=400, detail=f"Dữ liệu JSON không hợp lệ: {exc}") from exc
        if not isinstance(payload, dict):
            raise HTTPException(status_code=400, detail="Dữ liệu khóa học phải là object JSON")
        return payload

    if "multipart/form-data" in content_type or "application/x-www-form-urlencoded" in content_type:
        form_data = await request.form()
        return dict(form_data)

    try:
        payload = await request.json()
        if isinstance(payload, dict):
            return payload
    except Exception:
        pass

    form_data = await request.form()
    if form_data:
        return dict(form_data)

    return {}


def _parse_teacher_course_payload(raw_payload: dict) -> TeacherCoursePayload:
    normalized_payload = {
        "title": _normalize_text(
            raw_payload.get("title")
            or raw_payload.get("course_name")
            or raw_payload.get("name")
        ).strip(),
        "description": _normalize_text(
            raw_payload.get("description")
            or raw_payload.get("course_description")
        ).strip(),
        "category": _normalize_text(
            raw_payload.get("category")
            or raw_payload.get("specialization")
            or raw_payload.get("major")
            or "programming"
        ).strip() or "programming",
    }

    try:
        return TeacherCoursePayload.model_validate(normalized_payload)
    except ValidationError as exc:
        details = []
        for error in exc.errors():
            location = ".".join(str(item) for item in error.get("loc", [])) or "payload"
            details.append({
                "field": location,
                "message": error.get("msg", "Dữ liệu không hợp lệ"),
            })
        raise HTTPException(status_code=422, detail=details) from exc


def _serialize_course(course: Course, enrolled_count: int = 0, lessons_count: int = 0) -> dict:
    category = course.specialization or course.major or "general"
    return {
        "id": course.id,
        "title": course.course_name,
        "course_name": course.course_name,
        "description": course.description,
        "category": category,
        "class_code": course.course_code,
        "course_code": course.course_code,
        "major": course.major,
        "specialization": course.specialization,
        "credit_hours": course.credit_hours,
        "enrolled_count": enrolled_count,
        "lessons_count": lessons_count,
        "lesson_count": lessons_count,
        "created_at": course.created_at.isoformat() if course.created_at else None,
    }


def _parse_docx_questions(file_bytes: bytes) -> list[dict]:
    document = Document(BytesIO(file_bytes))
    lines = [paragraph.text.strip() for paragraph in document.paragraphs if paragraph.text.strip()]

    questions: list[dict] = []
    current: dict | None = None
    current_option: str | None = None

    for line in lines:
        question_match = QUESTION_PATTERN.match(line)
        option_match = OPTION_PATTERN.match(line)
        answer_match = ANSWER_PATTERN.match(line)
        explanation_match = EXPLANATION_PATTERN.match(line)

        if question_match:
            if current and current.get("question_text"):
                questions.append(current)
            current = {
                "question_text": question_match.group(1).strip(),
                "options": {},
                "correct_answer": None,
                "explanation": None,
            }
            current_option = None
            continue

        if current is None:
            continue

        if option_match:
            option_key = option_match.group(1).lower()
            current["options"][option_key] = option_match.group(2).strip()
            current_option = option_key
            continue

        if answer_match:
            current["correct_answer"] = answer_match.group(1).lower()
            current_option = None
            continue

        if explanation_match:
            current["explanation"] = explanation_match.group(1).strip()
            current_option = None
            continue

        if current_option and current_option in current["options"]:
            current["options"][current_option] = f"{current['options'][current_option]} {line}".strip()
        else:
            current["question_text"] = f"{current['question_text']} {line}".strip()

    if current and current.get("question_text"):
        questions.append(current)

    return questions


def _calculate_average_score(db: Session, student_id: int, course_id: int) -> float | None:
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student_id,
        Enrollment.course_id == course_id,
    ).first()
    if enrollment and enrollment.total_score is not None:
        return float(enrollment.total_score)

    lesson_ids = [lesson_id for (lesson_id,) in db.query(Lesson.id).filter(Lesson.course_id == course_id).all()]
    if not lesson_ids:
        return None

    quiz_scores = db.query(QuizResult.score).filter(
        QuizResult.user_id == student_id,
        QuizResult.lesson_id.in_(lesson_ids),
    ).all()
    values = [float(score) for (score,) in quiz_scores if score is not None]
    if values:
        return sum(values) / len(values)

    assessment_scores = db.query(Submission.score).join(Assessment).filter(
        Submission.student_id == student_id,
        Assessment.course_id == course_id,
        Submission.score.is_not(None),
    ).all()
    values = [float(score) for (score,) in assessment_scores if score is not None]
    if values:
        return sum(values) / len(values)

    return None


def _teacher_stats(db: Session, teacher_id: int) -> dict:
    total_courses = db.query(Course).filter(Course.teacher_id == teacher_id).count()
    total_students = db.query(func.count(func.distinct(Enrollment.student_id))).join(
        Course, Enrollment.course_id == Course.id
    ).filter(
        Course.teacher_id == teacher_id,
        Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING]),
    ).scalar() or 0
    pending_approvals = db.query(Enrollment).join(
        Course, Enrollment.course_id == Course.id
    ).filter(
        Course.teacher_id == teacher_id,
        Enrollment.status == EnrollmentStatus.PENDING,
    ).count()
    total_lessons = db.query(Lesson).join(Course).filter(Course.teacher_id == teacher_id).count()
    total_quizzes = db.query(Assessment).join(Course).filter(
        Course.teacher_id == teacher_id,
        Assessment.assessment_type == AssessmentType.QUIZ,
    ).count()

    return {
        "total_courses": total_courses,
        "total_students": total_students,
        "pending_approvals": pending_approvals,
        "total_lessons": total_lessons,
        "total_quizzes": total_quizzes,
        "average_rating": 4.8,
    }


def _build_teacher_student_snapshot(
    db: Session,
    teacher_id: int,
    student_id: int,
    course_id: int | None = None,
) -> dict:
    def _score_to_percent(score: float | None) -> float | None:
        if score is None:
            return None
        numeric = float(score)
        if numeric <= 10:
            numeric *= 10
        return max(0.0, min(100.0, numeric))

    enrollment_query = db.query(Enrollment).join(Course).filter(
        Enrollment.student_id == student_id,
        Course.teacher_id == teacher_id,
        Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING]),
    )

    if course_id is not None:
        enrollment_query = enrollment_query.filter(Enrollment.course_id == course_id)

    enrollments = enrollment_query.order_by(Enrollment.enrolled_at.desc()).all()
    if not enrollments:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy sinh viên trong khóa học do bạn phụ trách",
        )

    student = db.query(User).filter(User.id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student_id).first()

    course_snapshots: list[dict] = []
    progress_values: list[float] = []
    score_values: list[float] = []
    course_ids: list[int] = []
    for enrollment in enrollments:
        course = db.query(Course).filter(Course.id == enrollment.course_id).first()
        if not course:
            continue

        avg_score = _calculate_average_score(db, student_id, course.id)
        avg_score_percent = _score_to_percent(avg_score)
        progress = float(enrollment.progress or 0)

        course_ids.append(course.id)
        progress_values.append(progress)
        if avg_score_percent is not None:
            score_values.append(float(avg_score_percent))

        course_snapshots.append({
            "course_id": course.id,
            "course_name": course.course_name,
            "course_code": course.course_code,
            "status": enrollment.status.value if hasattr(enrollment.status, "value") else str(enrollment.status),
            "progress": round(progress, 2),
            "average_score": round(float(avg_score_percent), 2) if avg_score_percent is not None else None,
        })

    lesson_ids = [lesson_id for (lesson_id,) in db.query(Lesson.id).filter(Lesson.course_id.in_(course_ids)).all()]
    recent_quizzes: list[dict] = []
    if lesson_ids:
        quiz_rows = db.query(QuizResult).filter(
            QuizResult.user_id == student_id,
            QuizResult.lesson_id.in_(lesson_ids),
        ).order_by(QuizResult.completed_at.desc(), QuizResult.id.desc()).limit(8).all()

        for row in quiz_rows:
            recent_quizzes.append({
                "score": round(float(_score_to_percent(float(row.score or 0)) or 0), 2),
                "completed_at": row.completed_at.isoformat() if row.completed_at else None,
                "lesson_id": row.lesson_id,
            })

    avg_progress = round(sum(progress_values) / len(progress_values), 2) if progress_values else 0.0
    avg_score = round(sum(score_values) / len(score_values), 2) if score_values else None
    completed_courses = sum(1 for item in course_snapshots if (item.get("progress") or 0) >= 100)

    risk_level = "low"
    if avg_progress < 50 or (avg_score is not None and avg_score < 60):
        risk_level = "high"
    elif avg_progress < 75 or (avg_score is not None and avg_score < 75):
        risk_level = "medium"

    return {
        "student": {
            "id": student.id,
            "student_id": profile.student_id if profile else None,
            "full_name": student.full_name,
            "email": student.email,
            "major": profile.major if profile else None,
            "specialization": profile.specialization if profile else None,
        },
        "teacher_scope": {
            "course_count": len(course_snapshots),
            "completed_courses": completed_courses,
            "average_progress": avg_progress,
            "average_score": avg_score,
            "risk_level": risk_level,
        },
        "courses": course_snapshots,
        "recent_quizzes": recent_quizzes,
    }


def _build_teacher_actions(snapshot: dict) -> list[str]:
    scope = snapshot.get("teacher_scope", {})
    avg_progress = float(scope.get("average_progress") or 0)
    avg_score = scope.get("average_score")
    risk_level = scope.get("risk_level")

    actions: list[str] = []
    if risk_level == "high":
        actions.append("Hẹn 1 buổi trao đổi 1-1 trong tuần này để tìm nguyên nhân học chậm")
        actions.append("Giao mục tiêu ngắn hạn: hoàn thành 1 bài học + 1 quiz trước buổi sau")
    elif risk_level == "medium":
        actions.append("Theo dõi tiến độ theo tuần và nhắc nhở lịch học cố định")
        actions.append("Cho làm lại quiz các phần điểm thấp để củng cố kiến thức")
    else:
        actions.append("Duy trì nhịp học hiện tại và giao thêm bài tập nâng cao phù hợp")

    if avg_score is not None and avg_score < 70:
        actions.append("Ưu tiên ôn tập nội dung nền tảng trước khi mở rộng nội dung mới")
    if avg_progress < 60:
        actions.append("Chia nhỏ mục tiêu theo từng ngày để tăng tỉ lệ hoàn thành")

    return actions[:3]


def _build_7_day_checklist(snapshot: dict) -> list[dict]:
    scope = snapshot.get("teacher_scope", {})
    student = snapshot.get("student", {})
    risk_level = scope.get("risk_level", "low")
    avg_progress = float(scope.get("average_progress") or 0)
    avg_score = scope.get("average_score")
    course_name = (snapshot.get("courses") or [{}])[0].get("course_name", "môn đang học")

    score_note = "chưa có điểm" if avg_score is None else f"điểm TB {avg_score:.1f}"
    intensity = "cao" if risk_level == "high" else ("vừa" if risk_level == "medium" else "duy trì")

    day_items = [
        (1, "Đánh giá nhanh", [
            f"Trao đổi 1-1 với {student.get('full_name') or 'sinh viên'} trong 15-20 phút",
            f"Xác nhận trở ngại chính ở {course_name} (kiến thức nền, thời gian, thái độ học)",
            f"Thống nhất mục tiêu tuần: tăng tiến độ từ {avg_progress:.0f}% lên mốc cao hơn",
        ]),
        (2, "Củng cố nền tảng", [
            "Giao 1 phần lý thuyết trọng tâm cần ôn lại",
            "Yêu cầu ghi chú 5 ý chính sau khi học",
            f"Kiểm tra ngắn 5-10 câu để đo lại mức hiểu ({score_note})",
        ]),
        (3, "Luyện tập có hướng dẫn", [
            "Cho làm 1 bài quiz/bài tập ngắn có phản hồi ngay",
            "Chỉ ra 2 lỗi điển hình và cách sửa",
            "Đặt mốc hoàn thành trong ngày, không dồn bài",
        ]),
        (4, "Theo dõi tiến độ", [
            "Rà soát tiến độ bài học đã giao",
            "Nếu chưa đạt, chia nhỏ mục tiêu theo từng khung 25 phút",
            f"Nhắc lịch học cố định theo mức can thiệp {intensity}",
        ]),
        (5, "Ứng dụng thực hành", [
            "Giao 1 nhiệm vụ áp dụng kiến thức vào tình huống thực tế",
            "Yêu cầu sinh viên trình bày cách làm ngắn gọn",
            "Đánh dấu phần còn hổng để sửa trong ngày 6",
        ]),
        (6, "Đánh giá lại", [
            "Tổ chức kiểm tra nhanh/quiz lại phần đã ôn",
            "So sánh kết quả trước và sau can thiệp",
            "Chốt 2 hành động cần duy trì cho tuần kế tiếp",
        ]),
        (7, "Tổng kết tuần", [
            "Tổng kết tiến bộ theo tiến độ + điểm",
            "Phản hồi tích cực và chỉ ra điểm ưu tiên tuần sau",
            "Xác nhận kế hoạch duy trì nhịp học tối thiểu 30-45 phút/ngày",
        ]),
    ]

    return [
        {
            "day": day,
            "title": title,
            "items": items,
        }
        for day, title, items in day_items
    ]


async def _ask_gemini_teacher_advisor(question: str, snapshot: dict) -> str | None:
    if not GEMINI_API_KEY:
        return None

    safe_snapshot = {
        "student": snapshot.get("student"),
        "teacher_scope": snapshot.get("teacher_scope"),
        "courses": snapshot.get("courses"),
        "recent_quizzes": snapshot.get("recent_quizzes"),
    }

    prompt = f"""Bạn là trợ lý AI dành cho giảng viên đại học.

MỤC TIÊU:
- Trả lời tự nhiên, ngắn gọn, thực tế, có hành động cụ thể cho giảng viên.

GUARDRAILS BẮT BUỘC:
- Chỉ dùng dữ liệu trong DATA SNAPSHOT bên dưới.
- Không bịa số liệu, không suy diễn ngoài dữ liệu.
- Nếu dữ liệu chưa đủ, phải nói rõ "chưa đủ dữ liệu" và đề xuất bước thu thập thêm.
- Không đưa kết luận chẩn đoán y tế/tâm lý.
- Giữ giọng chuyên nghiệp, hỗ trợ ra quyết định sư phạm.

DATA SNAPSHOT:
{json.dumps(safe_snapshot, ensure_ascii=False)}

CÂU HỎI CỦA GIẢNG VIÊN:
{question}

YÊU CẦU TRẢ LỜI:
- Tối đa 6 câu.
- Có 1-3 hành động ưu tiên.
"""

    try:
        async with httpx.AsyncClient(timeout=35.0) as client:
            response = await client.post(
                f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
                headers={"Content-Type": "application/json"},
                json={
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "temperature": 0.35,
                        "maxOutputTokens": 900,
                        "topP": 0.9,
                        "topK": 32,
                    },
                },
            )

        if response.status_code != 200:
            logger.warning("Gemini teacher advisor error: %s", response.text)
            return None

        payload = response.json()
        candidates = payload.get("candidates") or []
        if not candidates:
            return None
        parts = (candidates[0].get("content") or {}).get("parts") or []
        if not parts or "text" not in parts[0]:
            return None
        return str(parts[0]["text"]).strip()
    except Exception as exc:
        logger.warning("Gemini teacher advisor failed: %s", exc)
        return None


def _save_teacher_chat_history(
    db: Session,
    *,
    teacher_id: int,
    student_id: int,
    course_id: int | None,
    message: str,
    response: str,
    response_source: str,
    request_type: str = "chat",
    checklist: list[dict] | None = None,
) -> None:
    entry = TeacherStudentChatHistory(
        teacher_id=teacher_id,
        student_id=student_id,
        course_id=course_id,
        request_type=request_type,
        message=message,
        response=response,
        response_source=response_source,
        checklist_json=json.dumps(checklist, ensure_ascii=False) if checklist else None,
    )
    try:
        db.add(entry)
        db.commit()
    except Exception as exc:
        db.rollback()
        logger.warning("Failed to save teacher chat history: %s", exc)


def _serialize_teacher_chat_history(entry: TeacherStudentChatHistory) -> dict:
    checklist: list[dict] = []
    if entry.checklist_json:
        try:
            loaded = json.loads(entry.checklist_json)
            if isinstance(loaded, list):
                checklist = loaded
        except Exception:
            checklist = []

    return {
        "id": entry.id,
        "teacher_id": entry.teacher_id,
        "student_id": entry.student_id,
        "course_id": entry.course_id,
        "request_type": entry.request_type,
        "message": entry.message,
        "response": entry.response,
        "response_source": entry.response_source,
        "checklist": checklist,
        "created_at": entry.created_at.isoformat() if entry.created_at else None,
    }


def _answer_teacher_student_question(snapshot: dict, question: str) -> str:
    q = (question or "").strip().lower()
    student = snapshot.get("student", {})
    scope = snapshot.get("teacher_scope", {})
    courses = snapshot.get("courses", [])
    recent_quizzes = snapshot.get("recent_quizzes", [])

    name = student.get("full_name") or "sinh viên"
    avg_progress = scope.get("average_progress", 0)
    avg_score = scope.get("average_score")
    risk_level = scope.get("risk_level", "low")
    actions = _build_teacher_actions(snapshot)

    risk_vi = {"low": "thấp", "medium": "trung bình", "high": "cao"}.get(risk_level, "chưa xác định")
    score_text = f"{avg_score:.1f}/100" if isinstance(avg_score, (int, float)) else "chưa đủ dữ liệu"

    summary_block = (
        f"Tổng quan {name}:\n"
        f"- Tiến độ trung bình: {avg_progress:.1f}%\n"
        f"- Điểm trung bình: {score_text}\n"
        f"- Mức rủi ro: {risk_vi}"
    )

    if any(keyword in q for keyword in ["điểm mạnh", "mạnh", "khả năng học tốt", "học tốt hơn"]):
        high_progress_courses = [
            item.get("course_name")
            for item in courses
            if float(item.get("progress") or 0) >= 85
        ]
        strengths_text = ", ".join(high_progress_courses[:3]) if high_progress_courses else "chưa nổi bật rõ theo dữ liệu hiện tại"
        return (
            f"{summary_block}\n"
            f"Điểm mạnh hiện tại: {strengths_text}.\n"
            f"Đề xuất cho giảng viên: {actions[0] if actions else 'duy trì theo dõi định kỳ'}"
        )

    if any(keyword in q for keyword in ["yếu", "điểm yếu", "yếu ở đâu", "hổng"]):
        weakest_course = min(courses, key=lambda item: float(item.get("average_score") or 101), default=None)
        weak_text = (
            f"{weakest_course.get('course_name')} (điểm {weakest_course.get('average_score', 0):.1f}/100)"
            if weakest_course and weakest_course.get("average_score") is not None
            else "chưa đủ dữ liệu để xác định môn yếu nhất"
        )
        return (
            f"{summary_block}\n"
            f"Điểm cần cải thiện: {weak_text}.\n"
            f"Hành động ưu tiên: {actions[0] if actions else 'tổ chức buổi trao đổi ngắn để xác định khó khăn chính'}"
        )

    if any(keyword in q for keyword in ["nguy cơ", "rủi ro", "cảnh báo"]):
        return (
            f"{summary_block}\n"
            f"Gợi ý ưu tiên: {actions[0] if actions else 'tiếp tục theo dõi thêm 1 tuần'}"
        )

    if any(keyword in q for keyword in ["điểm", "quiz", "kết quả", "học lực"]):
        recent_scores = [f"{float(item.get('score') or 0):.1f}" for item in recent_quizzes[:3]]
        recent_text = ", ".join(recent_scores) if recent_scores else "chưa có dữ liệu quiz gần đây"
        return (
            f"{summary_block}\n"
            f"Điểm quiz gần nhất: {recent_text}.\n"
            f"Hành động đề xuất: {actions[0] if actions else 'duy trì nhịp học ổn định'}."
        )

    if any(keyword in q for keyword in ["tiến độ", "hoàn thành", "chậm", "nhanh"]):
        course_bits = [
            f"{item.get('course_name')}: {float(item.get('progress') or 0):.1f}%"
            for item in courses[:4]
        ]
        course_text = "; ".join(course_bits) if course_bits else "chưa có khóa học trong phạm vi theo dõi"
        return (
            f"{summary_block}\n"
            f"Chi tiết theo môn: {course_text}.\n"
            f"Khuyến nghị: {actions[0] if actions else 'duy trì theo dõi định kỳ'}"
        )

    if any(keyword in q for keyword in ["nên", "đề xuất", "kế hoạch", "can thiệp", "hỗ trợ"]):
        bullet_text = "\n".join([f"- {item}" for item in actions]) if actions else "- Tiếp tục theo dõi kết quả theo tuần"
        return (
            f"{summary_block}\n"
            f"Kế hoạch hỗ trợ đề xuất:\n{bullet_text}"
        )

    return (
        f"{summary_block}\n"
        "Bạn có thể hỏi rõ hơn theo hướng: tiến độ theo môn, điểm quiz, điểm yếu, điểm mạnh, hoặc kế hoạch can thiệp."
    )


def _is_truncated_gemini_answer(answer: str | None) -> bool:
    if not answer:
        return True

    text = answer.strip()
    if len(text) < 40:
        return True

    low = text.lower()
    trailing_fragments = (
        ",", ":", "-", "(",
        " là", " và", " nhưng", " mặc dù", " do", " ở", " trong", " vì", " của", " cho",
    )
    if low.endswith(trailing_fragments):
        return True

    # Require a proper sentence ending to reduce half-finished outputs.
    if text[-1] not in ".!?":
        return True

    return False


def _serialize_quiz(assessment: Assessment, db: Session) -> dict:
    questions = db.query(Question).filter(Question.assessment_id == assessment.id).order_by(Question.order, Question.id).all()
    lesson_id = _extract_lesson_id_from_assessment(assessment)
    lesson_title = None
    if lesson_id is not None:
        lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
        lesson_title = lesson.title if lesson else None
    return {
        "id": assessment.id,
        "course_id": assessment.course_id,
        "lesson_id": lesson_id,
        "lesson_title": lesson_title,
        "title": assessment.title,
        "description": assessment.description or "",
        "instructions": _get_visible_instructions(assessment),
        "is_published": assessment.is_published,
        "max_score": assessment.max_score,
        "questions_count": len(questions),
        "attachment_name": assessment.attachment_name,
        "created_at": assessment.created_at.isoformat() if assessment.created_at else None,
        "questions": [
            {
                "id": question.id,
                "question_text": question.question_text,
                "option_a": question.option_a,
                "option_b": question.option_b,
                "option_c": question.option_c,
                "option_d": question.option_d,
                "correct_answer": question.correct_answer,
                "explanation": question.explanation,
                "points": question.points,
                "order": question.order,
            }
            for question in questions
        ],
    }


@router.get("/profile")
async def get_teacher_profile(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    profile = db.query(TeacherProfile).filter(TeacherProfile.user_id == user.id).first()
    return {
        "id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role.value if hasattr(user.role, "value") else user.role,
        "teacher_profile": {
            "teacher_id": profile.teacher_id if profile else None,
            "department": profile.department if profile else None,
            "position": profile.position if profile else None,
            "specialization": profile.specialization if profile else None,
            "phone": profile.phone if profile else None,
        },
        "stats": _teacher_stats(db, user.id),
    }


@router.get("/dashboard")
async def get_dashboard_stats(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    return {
        "teacher": {
            "id": user.id,
            "name": user.full_name,
            "email": user.email,
        },
        "stats": _teacher_stats(db, user.id),
    }


@router.get("/analytics")
async def get_teacher_analytics(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    return compute_teacher_analytics(db, user.id)


@router.get("/courses")
async def get_teacher_courses(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    courses = db.query(Course).filter(Course.teacher_id == user.id).order_by(Course.created_at.desc()).all()

    result = []
    for course in courses:
        enrolled_count = db.query(Enrollment).filter(
            Enrollment.course_id == course.id,
            Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING]),
        ).count()
        lessons_count = db.query(Lesson).filter(Lesson.course_id == course.id).count()
        result.append(_serialize_course(course, enrolled_count=enrolled_count, lessons_count=lessons_count))

    return result


@router.post("/courses")
async def create_course(
    request: Request,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    payload = _parse_teacher_course_payload(await _extract_request_data(request))
    title = payload.title.strip()
    if not title:
        raise HTTPException(status_code=400, detail="Tên khóa học không được để trống")

    course = Course(
        course_code=_generate_course_code(db),
        course_name=title,
        description=payload.description.strip(),
        teacher_id=user.id,
        major="Teacher Managed",
        specialization=payload.category.strip() or "programming",
        credit_hours=3,
        duration_weeks=15,
        is_active=True,
        created_at=datetime.utcnow(),
    )

    try:
        db.add(course)
        db.commit()
        db.refresh(course)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating course: {exc}")

    return _serialize_course(course, enrolled_count=0, lessons_count=0)


@router.put("/courses/{course_id}")
async def update_course(
    course_id: int,
    request: Request,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    payload = _parse_teacher_course_payload(await _extract_request_data(request))
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    course.course_name = payload.title.strip()
    course.description = payload.description.strip()
    course.specialization = payload.category.strip() or course.specialization
    course.updated_at = datetime.utcnow()

    try:
        db.commit()
        db.refresh(course)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating course: {exc}")

    enrolled_count = db.query(Enrollment).filter(Enrollment.course_id == course.id).count()
    lessons_count = db.query(Lesson).filter(Lesson.course_id == course.id).count()
    return _serialize_course(course, enrolled_count=enrolled_count, lessons_count=lessons_count)


@router.delete("/courses/{course_id}")
async def delete_course(
    course_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    try:
        db.delete(course)
        db.commit()
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting course: {exc}")

    return {"success": True, "message": "Đã xóa khóa học thành công"}


@router.get("/courses/{course_id}")
async def get_course_detail(
    course_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    lessons = db.query(Lesson).filter(Lesson.course_id == course_id).order_by(Lesson.order, Lesson.id).all()
    assessments = db.query(Assessment).filter(Assessment.course_id == course_id).order_by(Assessment.created_at.desc()).all()
    enrollments = db.query(Enrollment).filter(
        Enrollment.course_id == course_id,
        Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING]),
    ).all()

    quiz_counts_by_lesson: dict[int, int] = {}
    for assessment in assessments:
        if assessment.assessment_type == AssessmentType.QUIZ:
            lesson_id = _extract_lesson_id_from_assessment(assessment)
            if lesson_id is not None:
                quiz_counts_by_lesson[lesson_id] = quiz_counts_by_lesson.get(lesson_id, 0) + 1

    return {
        "course": _serialize_course(course, enrolled_count=len(enrollments), lessons_count=len(lessons)),
        "lessons": [_serialize_lesson(lesson, quiz_count=quiz_counts_by_lesson.get(lesson.id, 0)) for lesson in lessons],
        "quizzes": [_serialize_quiz(assessment, db) for assessment in assessments if assessment.assessment_type == AssessmentType.QUIZ],
        "enrolled_students": len(enrollments),
    }


@router.post("/lessons")
async def create_lesson(
    title: str = Form(...),
    description: str = Form(""),
    course_id: int = Form(...),
    activity_type: str = Form("quiz"),
    activity_prompt: str = Form(""),
    file: UploadFile | None = File(None),
    video_url: str | None = Form(None),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    normalized_activity_type = _normalize_lesson_activity_type(activity_type)
    visible_content = activity_prompt.strip()
    if normalized_activity_type == "essay" and not visible_content:
        raise HTTPException(status_code=400, detail="Bài học tự luận cần có yêu cầu hoặc đề bài")

    stored_filename = None
    if file and file.filename:
        extension = Path(file.filename).suffix.lower()
        if extension not in ALLOWED_LESSON_EXTENSIONS:
            allowed_text = ", ".join(sorted(ALLOWED_LESSON_EXTENSIONS))
            raise HTTPException(status_code=400, detail=f"Chỉ hỗ trợ file tài liệu: {allowed_text}")

        safe_name = f"lesson_{course_id}_{uuid.uuid4().hex}{extension}"
        destination = LESSON_UPLOAD_DIR / safe_name
        with destination.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        stored_filename = safe_name

    next_order = (db.query(func.max(Lesson.order)).filter(Lesson.course_id == course_id).scalar() or 0) + 1
    lesson = Lesson(
        course_id=course_id,
        title=title.strip(),
        description=description.strip(),
        content=_build_lesson_content(normalized_activity_type, visible_content),
        video_url=video_url.strip() if video_url else None,
        pdf_file_name=stored_filename,
        order=next_order,
        created_at=datetime.utcnow(),
    )

    try:
        db.add(lesson)
        db.commit()
        db.refresh(lesson)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating lesson: {exc}")

    return _serialize_lesson(lesson, quiz_count=0)


@router.post("/quizzes/from-docx")
async def create_quiz_from_docx(
    title: str = Form(...),
    description: str = Form(""),
    course_id: int = Form(...),
    lesson_id: int | None = Form(None),
    docx_file: UploadFile = File(...),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    if lesson_id is not None:
        lesson = db.query(Lesson).filter(
            Lesson.id == lesson_id,
            Lesson.course_id == course_id,
        ).first()
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found")

    if not docx_file.filename or not docx_file.filename.lower().endswith(".docx"):
        raise HTTPException(status_code=400, detail="Chỉ hỗ trợ file .docx")

    file_bytes = await docx_file.read()
    if not file_bytes:
        raise HTTPException(status_code=400, detail="File DOCX rỗng")

    stored_name = f"quiz_{course_id}_{uuid.uuid4().hex}.docx"
    with (QUIZ_UPLOAD_DIR / stored_name).open("wb") as buffer:
        buffer.write(file_bytes)

    parsed_questions = _parse_docx_questions(file_bytes)
    assessment = Assessment(
        course_id=course_id,
        title=title.strip(),
        description=description.strip(),
        instructions=_build_lesson_quiz_instructions(lesson_id),
        assessment_type=AssessmentType.QUIZ,
        is_published=False,
        max_score=float(len(parsed_questions) or 10),
        passing_score=_default_quiz_passing_score(float(len(parsed_questions) or 10)),
        attachment_url=f"/uploads/quizzes/{stored_name}",
        attachment_name=docx_file.filename,
        created_at=datetime.utcnow(),
    )

    try:
        db.add(assessment)
        db.flush()

        for index, item in enumerate(parsed_questions, start=1):
            options = item.get("options", {})
            question = Question(
                assessment_id=assessment.id,
                question_text=item.get("question_text", "Câu hỏi chưa có nội dung"),
                question_type="multiple_choice",
                option_a=options.get("a"),
                option_b=options.get("b"),
                option_c=options.get("c"),
                option_d=options.get("d"),
                correct_answer=item.get("correct_answer"),
                explanation=item.get("explanation"),
                points=1.0,
                order=index,
            )
            db.add(question)

        db.commit()
        db.refresh(assessment)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating quiz: {exc}")

    return {
        "id": assessment.id,
        "title": assessment.title,
        "description": assessment.description,
        "questions_count": len(parsed_questions),
        "attachment_name": assessment.attachment_name,
        "is_published": assessment.is_published,
        "message": "Tạo quiz thành công" if parsed_questions else "Đã tạo quiz nhưng chưa tách được câu hỏi từ file DOCX",
    }


@router.get("/courses/{course_id}/quizzes")
async def get_course_quizzes(
    course_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    quizzes = db.query(Assessment).filter(
        Assessment.course_id == course_id,
        Assessment.assessment_type == AssessmentType.QUIZ,
    ).order_by(Assessment.created_at.desc()).all()

    return {
        "course": _serialize_course(course),
        "quizzes": [_serialize_quiz(quiz, db) for quiz in quizzes],
    }


@router.get("/quizzes/{quiz_id}")
async def get_quiz_detail(
    quiz_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    quiz = db.query(Assessment).join(Course).filter(
        Assessment.id == quiz_id,
        Assessment.assessment_type == AssessmentType.QUIZ,
        Course.teacher_id == user.id,
    ).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")

    return _serialize_quiz(quiz, db)


@router.post("/quizzes")
async def create_quiz_manual(
    payload: TeacherQuizCreateRequest,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == payload.course_id,
        Course.teacher_id == user.id,
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    if payload.lesson_id is not None:
        lesson = db.query(Lesson).filter(
            Lesson.id == payload.lesson_id,
            Lesson.course_id == payload.course_id,
        ).first()
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found")
    if not payload.questions:
        raise HTTPException(status_code=400, detail="Quiz phải có ít nhất một câu hỏi")

    assessment = Assessment(
        course_id=payload.course_id,
        title=payload.title.strip(),
        description=payload.description.strip(),
        instructions=_build_lesson_quiz_instructions(payload.lesson_id),
        assessment_type=AssessmentType.QUIZ,
        is_published=payload.is_published,
        max_score=float(sum(question.points for question in payload.questions)),
        passing_score=_default_quiz_passing_score(float(sum(question.points for question in payload.questions))),
        created_at=datetime.utcnow(),
    )

    try:
        db.add(assessment)
        db.flush()
        for index, item in enumerate(payload.questions, start=1):
            db.add(Question(
                assessment_id=assessment.id,
                question_text=item.question_text.strip(),
                question_type="multiple_choice",
                option_a=item.option_a.strip(),
                option_b=item.option_b.strip(),
                option_c=item.option_c.strip(),
                option_d=item.option_d.strip(),
                correct_answer=item.correct_answer.strip().lower(),
                explanation=item.explanation.strip(),
                points=item.points,
                order=index,
            ))
        db.commit()
        db.refresh(assessment)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating quiz: {exc}")

    return _serialize_quiz(assessment, db)


@router.put("/quizzes/{quiz_id}")
async def update_quiz(
    quiz_id: int,
    payload: TeacherQuizUpdateRequest,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    quiz = db.query(Assessment).join(Course).filter(
        Assessment.id == quiz_id,
        Assessment.assessment_type == AssessmentType.QUIZ,
        Course.teacher_id == user.id,
    ).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    if payload.lesson_id is not None:
        lesson = db.query(Lesson).filter(
            Lesson.id == payload.lesson_id,
            Lesson.course_id == quiz.course_id,
        ).first()
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found")
    if not payload.questions:
        raise HTTPException(status_code=400, detail="Quiz phải có ít nhất một câu hỏi")

    quiz.title = payload.title.strip()
    quiz.description = payload.description.strip()
    quiz.instructions = _build_lesson_quiz_instructions(payload.lesson_id, _get_visible_instructions(quiz))
    quiz.is_published = payload.is_published
    quiz.max_score = float(sum(question.points for question in payload.questions))
    quiz.passing_score = _default_quiz_passing_score(quiz.max_score)
    quiz.updated_at = datetime.utcnow()

    try:
        db.query(Question).filter(Question.assessment_id == quiz.id).delete()
        db.flush()
        for index, item in enumerate(payload.questions, start=1):
            db.add(Question(
                assessment_id=quiz.id,
                question_text=item.question_text.strip(),
                question_type="multiple_choice",
                option_a=item.option_a.strip(),
                option_b=item.option_b.strip(),
                option_c=item.option_c.strip(),
                option_d=item.option_d.strip(),
                correct_answer=item.correct_answer.strip().lower(),
                explanation=item.explanation.strip(),
                points=item.points,
                order=index,
            ))
        db.commit()
        db.refresh(quiz)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating quiz: {exc}")

    return _serialize_quiz(quiz, db)


@router.delete("/quizzes/{quiz_id}")
async def delete_quiz(
    quiz_id: int,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    quiz = db.query(Assessment).join(Course).filter(
        Assessment.id == quiz_id,
        Assessment.assessment_type == AssessmentType.QUIZ,
        Course.teacher_id == user.id,
    ).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")

    try:
        db.delete(quiz)
        db.commit()
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting quiz: {exc}")

    return {"success": True, "message": "Đã xóa quiz thành công"}


@router.get("/students")
async def get_teacher_students(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    enrollments = db.query(Enrollment).join(Course).filter(
        Course.teacher_id == user.id,
        Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING]),
    ).order_by(Enrollment.enrolled_at.desc()).all()

    student_map: dict[int, dict] = {}
    for enrollment in enrollments:
        student = db.query(User).filter(User.id == enrollment.student_id).first()
        course = db.query(Course).filter(Course.id == enrollment.course_id).first()
        if not student or not course:
            continue

        progress = enrollment.progress or 0
        if progress == 0:
            total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            if total_lessons > 0:
                completed_lessons = db.query(LessonProgress).join(Lesson).filter(
                    Lesson.course_id == course.id,
                    LessonProgress.student_id == student.id,
                    LessonProgress.is_completed == True,
                ).count()
                progress = round((completed_lessons / total_lessons) * 100)

        average_score = _calculate_average_score(db, student.id, course.id)
        profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()

        if student.id not in student_map:
            student_map[student.id] = {
                "id": student.id,
                "student_id": profile.student_id if profile else None,
                "full_name": student.full_name,
                "email": student.email,
                "major": profile.major if profile else None,
                "year": profile.intake_year if profile else None,
                "course_title": course.course_name,
                "progress": progress,
                "average_score": average_score,
                "progress_values": [],
                "grade_values": [],
                "enrolled_courses": [],
                "completed_courses": 0,
                "courses": [],
                "enrolled_at": enrollment.enrolled_at,
            }

        student_entry = student_map[student.id]
        student_entry["enrolled_courses"].append(course.id)
        student_entry["courses"].append({
            "id": course.id,
            "title": course.course_name,
            "course_code": course.course_code,
            "progress": progress,
            "grade": average_score,
            "status": enrollment.status.value if hasattr(enrollment.status, "value") else str(enrollment.status),
        })
        student_entry["progress_values"].append(progress)
        if average_score is not None:
            student_entry["grade_values"].append(float(average_score))
        if enrollment.status == EnrollmentStatus.COMPLETED or (enrollment.progress or 0) >= 100:
            student_entry["completed_courses"] += 1
        if enrollment.enrolled_at and (
            student_entry["enrolled_at"] is None or enrollment.enrolled_at < student_entry["enrolled_at"]
        ):
            student_entry["enrolled_at"] = enrollment.enrolled_at

    results = []
    for student_entry in student_map.values():
        progress_values = student_entry.pop("progress_values")
        grade_values = student_entry.pop("grade_values")
        progress_avg = round(sum(progress_values) / len(progress_values)) if progress_values else 0
        grade_avg = (sum(grade_values) / len(grade_values)) if grade_values else None

        student_entry["progress_avg"] = progress_avg
        student_entry["grade_avg"] = grade_avg
        student_entry["progress"] = progress_avg
        student_entry["average_score"] = grade_avg
        student_entry["enrolled_at"] = student_entry["enrolled_at"].isoformat() if student_entry["enrolled_at"] else None
        results.append(student_entry)

    results.sort(key=lambda item: item["full_name"].lower())
    return results


@router.post("/students/advisor/ask")
async def ask_teacher_student_advisor(
    payload: TeacherStudentChatRequest,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    snapshot = _build_teacher_student_snapshot(
        db=db,
        teacher_id=user.id,
        student_id=payload.student_id,
        course_id=payload.course_id,
    )

    local_answer = _answer_teacher_student_question(snapshot, payload.message)
    gemini_answer = await _ask_gemini_teacher_advisor(payload.message, snapshot)

    if _is_truncated_gemini_answer(gemini_answer):
        answer = local_answer
        source = "local"
    else:
        answer = gemini_answer or local_answer
        source = "gemini" if gemini_answer else "local"

    _save_teacher_chat_history(
        db,
        teacher_id=user.id,
        student_id=payload.student_id,
        course_id=payload.course_id,
        message=payload.message,
        response=answer,
        response_source=source,
        request_type="chat",
    )

    return {
        "answer": answer,
        "source": source,
        "student": snapshot.get("student"),
        "teacher_scope": snapshot.get("teacher_scope"),
        "courses": snapshot.get("courses"),
        "recent_quizzes": snapshot.get("recent_quizzes"),
        "suggested_questions": [
            "Sinh viên này đang có rủi ro gì?",
            "Nên can thiệp thế nào trong 1 tuần tới?",
            "Điểm yếu chính hiện tại là gì?",
        ],
    }


@router.get("/students/{student_id}/advisor/history")
async def get_teacher_student_advisor_history(
    student_id: int,
    course_id: int | None = Query(default=None),
    limit: int = Query(default=60, ge=1, le=200),
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    # Validate teacher has access to this student in teacher scope.
    _build_teacher_student_snapshot(
        db=db,
        teacher_id=user.id,
        student_id=student_id,
        course_id=course_id,
    )

    history_query = db.query(TeacherStudentChatHistory).filter(
        TeacherStudentChatHistory.teacher_id == user.id,
        TeacherStudentChatHistory.student_id == student_id,
    )
    if course_id is not None:
        history_query = history_query.filter(TeacherStudentChatHistory.course_id == course_id)

    rows = history_query.order_by(TeacherStudentChatHistory.created_at.desc()).limit(limit).all()
    rows.reverse()

    return {
        "student_id": student_id,
        "items": [_serialize_teacher_chat_history(row) for row in rows],
    }


@router.post("/students/advisor/plan-7-days")
async def generate_teacher_intervention_plan(
    payload: TeacherInterventionPlanRequest,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    snapshot = _build_teacher_student_snapshot(
        db=db,
        teacher_id=user.id,
        student_id=payload.student_id,
        course_id=payload.course_id,
    )
    checklist = _build_7_day_checklist(snapshot)
    student_name = (snapshot.get("student") or {}).get("full_name") or "sinh viên"
    response_text = f"Đã tạo checklist can thiệp 7 ngày cho {student_name}."

    _save_teacher_chat_history(
        db,
        teacher_id=user.id,
        student_id=payload.student_id,
        course_id=payload.course_id,
        message="Tạo kế hoạch can thiệp 7 ngày",
        response=response_text,
        response_source="rule",
        request_type="plan_7_days",
        checklist=checklist,
    )

    return {
        "student": snapshot.get("student"),
        "teacher_scope": snapshot.get("teacher_scope"),
        "checklist": checklist,
        "message": response_text,
    }


@router.get("/pending-approvals")
async def get_pending_approvals(
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    enrollments = db.query(Enrollment).join(Course).filter(
        Course.teacher_id == user.id,
        Enrollment.status == EnrollmentStatus.PENDING,
    ).order_by(Enrollment.enrolled_at.desc()).all()

    result = []
    for enrollment in enrollments:
        student = db.query(User).filter(User.id == enrollment.student_id).first()
        course = db.query(Course).filter(Course.id == enrollment.course_id).first()
        if not student or not course:
            continue
        result.append({
            "id": enrollment.id,
            "student_id": student.id,
            "student_name": student.full_name,
            "student_email": student.email,
            "course_id": course.id,
            "course_title": course.course_name,
            "course_code": course.course_code,
            "created_at": enrollment.enrolled_at.isoformat() if enrollment.enrolled_at else None,
        })

    return result


@router.post("/enrollments/{enrollment_id}/approve")
async def approve_enrollment(
    enrollment_id: int,
    payload: EnrollmentApprovalRequest,
    user: User = Depends(get_current_teacher),
    db: Session = Depends(get_db),
):
    enrollment = db.query(Enrollment).join(Course).filter(
        Enrollment.id == enrollment_id,
        Course.teacher_id == user.id,
        Enrollment.status == EnrollmentStatus.PENDING,
    ).first()
    if not enrollment:
        raise HTTPException(status_code=404, detail="Enrollment not found")

    enrollment.status = EnrollmentStatus.ACTIVE if payload.approve else EnrollmentStatus.DROPPED
    enrollment.enrolled_at = datetime.utcnow() if payload.approve else enrollment.enrolled_at

    try:
        db.commit()
        db.refresh(enrollment)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating enrollment: {exc}")

    status_value = enrollment.status.value if hasattr(enrollment.status, "value") else str(enrollment.status)
    return {
        "id": enrollment.id,
        "status": status_value,
        "message": "Đã duyệt yêu cầu ghi danh" if payload.approve else "Đã từ chối yêu cầu ghi danh",
    }


def _build_lesson_quiz_instructions(lesson_id: int | None, visible_instructions: str = "") -> str:
    cleaned_instructions = (visible_instructions or "").strip()
    if lesson_id is None:
        return cleaned_instructions
    if cleaned_instructions:
        return f"[[lesson_id:{lesson_id}]]\n{cleaned_instructions}"
    return f"[[lesson_id:{lesson_id}]]"


def _normalize_lesson_activity_type(value: str | None) -> str:
    normalized = (value or "").strip().lower()
    if normalized in {"quiz", "essay"}:
        return normalized
    raise HTTPException(status_code=400, detail="Loại bài học phải là 'quiz' hoặc 'essay'")


def _build_lesson_content(activity_type: str, visible_content: str = "") -> str:
    cleaned_content = (visible_content or "").strip()
    if cleaned_content:
        return f"[[activity_type:{activity_type}]]\n{cleaned_content}"
    return f"[[activity_type:{activity_type}]]"


def _extract_lesson_activity_type(lesson: Lesson) -> str | None:
    content = lesson.content or ""
    match = LESSON_ACTIVITY_PATTERN.match(content)
    if match:
        return match.group(1).lower()
    return None


def _get_visible_lesson_content(lesson: Lesson) -> str:
    content = lesson.content or ""
    return LESSON_ACTIVITY_PATTERN.sub("", content, count=1).strip()


def _default_quiz_passing_score(max_score: float) -> float:
    return round(max_score * 0.7, 2)


def _extract_lesson_id_from_assessment(assessment: Assessment) -> int | None:
    instructions = assessment.instructions or ""
    match = LESSON_LINK_PATTERN.match(instructions)
    if match:
        return int(match.group(1))
    return None


def _get_visible_instructions(assessment: Assessment) -> str:
    instructions = assessment.instructions or ""
    return LESSON_LINK_PATTERN.sub("", instructions, count=1).strip()


def _get_lesson_file_kind(file_name: str | None) -> str | None:
    if not file_name:
        return None
    extension = Path(file_name).suffix.lower()
    return extension[1:] if extension else None


def _serialize_lesson(lesson: Lesson, quiz_count: int = 0) -> dict:
    file_kind = _get_lesson_file_kind(lesson.pdf_file_name)
    activity_type = _extract_lesson_activity_type(lesson) or ("quiz" if quiz_count > 0 else "essay")
    visible_content = _get_visible_lesson_content(lesson)
    return {
        "id": lesson.id,
        "title": lesson.title,
        "description": lesson.description,
        "content": visible_content,
        "pdf_file_name": lesson.pdf_file_name,
        "file_name": lesson.pdf_file_name,
        "file_kind": file_kind,
        "file_extension": f".{file_kind}" if file_kind else None,
        "file_path": f"/api/lessons/{lesson.pdf_file_name}" if lesson.pdf_file_name else None,
        "activity_type": activity_type,
        "essay_prompt": visible_content if activity_type == "essay" else None,
        "video_url": lesson.video_url,
        "order": lesson.order,
        "duration_minutes": lesson.duration_minutes,
        "quiz_count": quiz_count,
        "created_at": lesson.created_at.isoformat() if lesson.created_at else None,
    }