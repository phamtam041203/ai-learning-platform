# backend/app/api/chatbot.py - Simplified version for AI Advisor
import base64
import io
import wave
import time
import hashlib

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
import logging
import httpx
import re
from pathlib import Path

from PyPDF2 import PdfReader

from app.database import get_db
from app.models.user import User
from app.api.auth import get_current_user
from app.services.student_advisor import StudentAdvisor
from app.core.config import settings
from app.models.course import Course, Enrollment, EnrollmentStatus, Lesson
from app.models.assessment import QuizResult

router = APIRouter()
logger = logging.getLogger(__name__)

# Get Gemini API key from settings
GEMINI_API_KEY = settings.GEMINI_API_KEY
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
GEMINI_TTS_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent"
LESSON_FILES_DIR = Path(__file__).resolve().parents[2] / "uploads" / "lessons"
GOOGLE_TTS_VOICE_PRESETS = {
    "female": {
        "voice_name": "Sulafat",
        "label": "Google AI Sulafat"
    },
    "male": {
        "voice_name": "Orus",
        "label": "Google AI Orus"
    }
}
TTS_CACHE_TTL_SECONDS = 1800
TTS_CACHE_MAX_ITEMS = 256
_tts_cache: dict[str, dict] = {}
_tts_http_client = httpx.AsyncClient(timeout=25.0)

LESSON_CHAT_STOP_WORDS = {
    "la", "là", "va", "và", "cua", "của", "cho", "trong", "khi", "voi", "với",
    "mot", "một", "nhung", "những", "cac", "các", "the", "thể", "nao", "nào",
    "nhu", "như", "toi", "tôi", "ban", "bạn", "em", "anh", "chi", "chị",
    "gi", "gì", "tai", "tại", "sao", "theo", "duoc", "được", "khong", "không",
    "hoc", "học", "bai", "bài", "nay", "này", "giup", "giúp", "giai", "giải",
    "thich", "thích", "ve", "về", "can", "cần", "hoi", "hỏi", "phan", "phần"
}

SUBSCRIPT_DIGITS_MAP = str.maketrans("₀₁₂₃₄₅₆₇₈₉", "0123456789")

# Debug: Print API key status at startup
print(f"🔑 Gemini API Key loaded: {bool(GEMINI_API_KEY)} (length: {len(GEMINI_API_KEY) if GEMINI_API_KEY else 0})")

class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None
    chat_type: str = "general"  # 'general', 'qa', 'explain', 'advisor'
    context_type: Optional[str] = None


class LessonChatMessage(BaseModel):
    message: str
    course_id: int
    lesson_id: int


class TutorSpeechRequest(BaseModel):
    text: str
    voice_gender: str = "female"


def _normalize_text(value: Optional[str]) -> str:
    if not value:
        return ""
    return re.sub(r"\s+", " ", value).strip()


def _build_tutor_tts_prompt(text: str, voice_gender: str) -> str:
    normalized_text = text.strip()
    profile = "nữ ấm" if voice_gender == "female" else "nam trầm vừa"

    return (
        f"Đọc tiếng Việt tự nhiên, tốc độ vừa, giọng {profile}. "
        f"Không thêm mở đầu/kết thúc. Nội dung: {normalized_text}"
    )


def _make_tts_cache_key(text: str, voice_gender: str) -> str:
    digest = hashlib.sha256(f"{voice_gender}:{text}".encode("utf-8")).hexdigest()
    return f"tts:{digest}"


def _get_cached_tts(cache_key: str) -> Optional[dict]:
    cached_item = _tts_cache.get(cache_key)
    if not cached_item:
        return None

    if cached_item["expires_at"] < time.time():
        _tts_cache.pop(cache_key, None)
        return None

    return cached_item["payload"]


def _set_cached_tts(cache_key: str, payload: dict) -> None:
    now = time.time()
    _tts_cache[cache_key] = {
        "payload": payload,
        "expires_at": now + TTS_CACHE_TTL_SECONDS,
        "created_at": now,
    }

    if len(_tts_cache) <= TTS_CACHE_MAX_ITEMS:
        return

    # Drop oldest cache entries when reaching cap.
    overflow = len(_tts_cache) - TTS_CACHE_MAX_ITEMS
    for key, _ in sorted(_tts_cache.items(), key=lambda item: item[1].get("created_at", 0))[:overflow]:
        _tts_cache.pop(key, None)


def _pcm_to_wav_bytes(pcm_bytes: bytes, channels: int = 1, sample_width: int = 2, rate: int = 24000) -> bytes:
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(sample_width)
        wav_file.setframerate(rate)
        wav_file.writeframes(pcm_bytes)
    return buffer.getvalue()


def _extract_audio_inline_data(result: dict) -> tuple[bytes, str]:
    candidates = result.get("candidates") or []
    if not candidates:
        raise HTTPException(status_code=502, detail="Gemini TTS returned no candidates")

    content = candidates[0].get("content", {})
    parts = content.get("parts") or []
    audio_part = next(
        (
            part.get("inlineData") or part.get("inline_data")
            for part in parts
            if (part.get("inlineData") or part.get("inline_data"))
        ),
        None
    )

    if not audio_part:
        raise HTTPException(status_code=502, detail="Gemini TTS returned no audio payload")

    encoded_audio = audio_part.get("data")
    mime_type = audio_part.get("mimeType") or audio_part.get("mime_type") or "audio/wav"
    if not encoded_audio:
        raise HTTPException(status_code=502, detail="Gemini TTS audio payload was empty")

    raw_audio = base64.b64decode(encoded_audio)
    lowered_mime = mime_type.lower()
    if "audio/wav" in lowered_mime or "audio/x-wav" in lowered_mime:
        return raw_audio, "audio/wav"

    if "audio/l16" in lowered_mime or "pcm" in lowered_mime:
        return _pcm_to_wav_bytes(raw_audio), "audio/wav"

    return raw_audio, mime_type


def _build_tts_error(response: httpx.Response) -> HTTPException:
    try:
        payload = response.json()
    except Exception:
        payload = {}

    error_data = payload.get("error") or {}
    raw_message = error_data.get("message") or response.text or "Gemini TTS request failed"
    details = error_data.get("details") or []

    retry_seconds = None
    for detail in details:
        if detail.get("@type") == "type.googleapis.com/google.rpc.RetryInfo":
            retry_delay = detail.get("retryDelay", "")
            digits = re.findall(r"\d+", retry_delay)
            if digits:
                retry_seconds = int(digits[0])
                break

    if response.status_code == 429:
        retry_hint = f" sau khoảng {retry_seconds} giây" if retry_seconds else " sau ít phút"
        return HTTPException(
            status_code=429,
            detail=f"Voice đang tạm hết quota. Hãy thử lại{retry_hint} hoặc chuyển sang chế độ trả lời bằng chữ."
        )

    return HTTPException(
        status_code=502,
        detail=f"Không thể tạo giọng đọc AI lúc này. Chi tiết: {raw_message}"
    )


async def _generate_tutor_speech(text: str, voice_gender: str) -> dict:
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="Gemini API key is not configured for TTS")

    cache_key = _make_tts_cache_key(text, voice_gender)
    cached_payload = _get_cached_tts(cache_key)
    if cached_payload:
        return cached_payload

    preset = GOOGLE_TTS_VOICE_PRESETS.get(voice_gender, GOOGLE_TTS_VOICE_PRESETS["female"])
    prompt = _build_tutor_tts_prompt(text, voice_gender)

    response = await _tts_http_client.post(
        GEMINI_TTS_API_URL,
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": GEMINI_API_KEY,
        },
        json={
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "responseModalities": ["AUDIO"],
                "speechConfig": {
                    "voiceConfig": {
                        "prebuiltVoiceConfig": {
                            "voiceName": preset["voice_name"]
                        }
                    }
                }
            }
        }
    )

    if response.status_code != 200:
        raise _build_tts_error(response)

    result = response.json()
    audio_bytes, mime_type = _extract_audio_inline_data(result)
    payload = {
        "audio_base64": base64.b64encode(audio_bytes).decode("utf-8"),
        "mime_type": mime_type,
        "voice_name": preset["voice_name"],
        "voice_label": preset["label"],
        "model": "gemini-2.5-flash-preview-tts"
    }

    _set_cached_tts(cache_key, payload)
    return payload


def _extract_pdf_text(pdf_file_name: Optional[str], max_pages: int = 4, max_chars: int = 6000) -> str:
    if not pdf_file_name:
        return ""

    file_path = (LESSON_FILES_DIR / pdf_file_name).resolve()
    lesson_dir = LESSON_FILES_DIR.resolve()
    if not str(file_path).startswith(str(lesson_dir)) or not file_path.exists():
        return ""

    try:
        reader = PdfReader(str(file_path))
        chunks = []
        total_chars = 0

        for page in reader.pages[:max_pages]:
            page_text = _normalize_text(page.extract_text() or "")
            if not page_text:
                continue

            remaining = max_chars - total_chars
            if remaining <= 0:
                break

            clipped = page_text[:remaining]
            chunks.append(clipped)
            total_chars += len(clipped)

        return "\n".join(chunks)
    except Exception as exc:
        logger.warning("Could not extract lesson PDF text for %s: %s", pdf_file_name, exc)
        return ""


def _build_lesson_context(course: Course, lesson: Lesson) -> str:
    parts = [
        f"Khóa học: {course.course_name}",
        f"Mã học phần: {course.course_code}",
        f"Bài học: {lesson.title}",
    ]

    if course.description:
        parts.append(f"Mô tả khóa học: {_normalize_text(course.description)}")
    if lesson.description:
        parts.append(f"Mô tả bài học: {_normalize_text(lesson.description)}")
    if lesson.content:
        parts.append(f"Nội dung bài học: {_normalize_text(lesson.content)}")

    pdf_text = _extract_pdf_text(lesson.pdf_file_name)
    if pdf_text:
        parts.append(f"Trích đoạn tài liệu PDF: {pdf_text}")

    return "\n\n".join(part for part in parts if part).strip()[:12000]


def _extract_keywords(message: str) -> list[str]:
    tokens = re.findall(r"\w+", message.lower(), flags=re.UNICODE)
    return [
        token for token in tokens
        if len(token) > 2 and token not in LESSON_CHAT_STOP_WORDS
    ]


def _normalize_numeric_question(message: str) -> str:
    return _normalize_text(message).translate(SUBSCRIPT_DIGITS_MAP).lower()


def _build_foundational_knowledge_answer(question: str) -> str:
    normalized_question = _normalize_numeric_question(question)

    if "nhị phân" in normalized_question and "thập phân" in normalized_question:
        decimal_matches = re.findall(r"(\d+)\s*(?:10|thập\s*phân)", normalized_question)
        decimal_value = None
        if decimal_matches:
            decimal_value = int(decimal_matches[0])
        else:
            standalone_numbers = [int(item) for item in re.findall(r"\d+", normalized_question)]
            if standalone_numbers:
                decimal_value = standalone_numbers[0]

        if decimal_value is not None:
            binary_value = format(decimal_value, "b")
            decomposition = "0" if decimal_value == 0 else " + ".join(
                str(2 ** power)
                for power in range(decimal_value.bit_length() - 1, -1, -1)
                if decimal_value & (1 << power)
            )
            return (
                f"Số thập phân {decimal_value} tương đương số nhị phân {binary_value}.\n\n"
                f"Có thể kiểm tra nhanh bằng cách tách {decimal_value} = {decomposition}, nên dạng nhị phân là {binary_value}."
            )

    return ""


def _find_relevant_snippets(question: str, context: str, limit: int = 3) -> list[str]:
    keywords = _extract_keywords(question)
    sentences = [
        _normalize_text(sentence)
        for sentence in re.split(r"(?<=[.!?])\s+|\n+", context)
        if _normalize_text(sentence)
    ]

    if not sentences:
        return []

    scored = []
    for sentence in sentences:
        lowered = sentence.lower()
        score = sum(1 for keyword in keywords if keyword in lowered)
        if score > 0:
            scored.append((score, len(sentence), sentence))

    scored.sort(key=lambda item: (-item[0], item[1]))
    unique_sentences = []
    seen = set()
    for _, _, sentence in scored:
        if sentence in seen:
            continue
        seen.add(sentence)
        unique_sentences.append(sentence)
        if len(unique_sentences) == limit:
            break

    return unique_sentences


def _build_local_lesson_answer(question: str, course: Course, lesson: Lesson, context: str) -> str:
    snippets = _find_relevant_snippets(question, context)

    if snippets:
        snippet_block = "\n".join(f"- {snippet}" for snippet in snippets)
        return (
            f"Dựa trên bài \"{lesson.title}\" của môn \"{course.course_name}\", phần liên quan nhất đến câu hỏi của em là:\n"
            f"{snippet_block}\n\n"
            "Nếu em muốn, hãy hỏi tiếp theo kiểu cụ thể hơn như: khái niệm này dùng để làm gì, ví dụ thực tế, hoặc so sánh với phần khác trong bài."
        )

    foundational_answer = _build_foundational_knowledge_answer(question)
    if foundational_answer:
        return (
            f"Trong bài \"{lesson.title}\" không nêu trực tiếp phần này, nhưng theo kiến thức nền chuẩn:\n"
            f"{foundational_answer}"
        )

    preview = _normalize_text(context)[:700]
    if preview:
        return (
            f"Hiện tại tôi chưa tìm được đoạn khớp trực tiếp với câu hỏi trong bài \"{lesson.title}\".\n\n"
            f"Nội dung bài đang có là: {preview}\n\n"
            "Em hãy hỏi cụ thể hơn bằng từ khóa có trong bài học để tôi bám sát nội dung hơn."
        )

    return (
        f"Bài \"{lesson.title}\" hiện chưa có đủ văn bản để tôi phân tích sâu. "
        "Em có thể mở tài liệu PDF của bài và hỏi theo một đoạn hoặc khái niệm cụ thể hơn."
    )


async def _ask_gemini_with_context(prompt: str) -> str:
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
            headers={"Content-Type": "application/json"},
            json={
                "contents": [{"parts": [{"text": prompt}]}],
                "generationConfig": {
                    "temperature": 0.4,
                    "maxOutputTokens": 2048,
                    "topP": 0.9,
                    "topK": 32
                }
            },
            timeout=45.0
        )

    if response.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Gemini API error: {response.text}")

    result = response.json()
    candidates = result.get("candidates") or []
    if not candidates:
        raise HTTPException(status_code=502, detail="Gemini returned no candidates")

    content = candidates[0].get("content", {})
    parts = content.get("parts") or []
    if not parts or "text" not in parts[0]:
        raise HTTPException(status_code=502, detail="Gemini returned no text content")

    return parts[0]["text"]

# ==========================================
# AI ADVISOR ENDPOINTS
# ==========================================

@router.get("/advisor/analyze")
async def analyze_student(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Analyze student profile and performance"""
    try:
        advisor = StudentAdvisor(db)
        analysis = advisor.analyze_student_profile(current_user.id)
        return analysis
    except Exception as e:
        logger.error(f"Analysis error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to analyze student: {str(e)}")

@router.post("/advisor/ask")
async def ask_advisor(
    request: ChatMessage,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Ask AI advisor for personalized advice"""
    try:
        advisor = StudentAdvisor(db)
        analysis = advisor.analyze_student_profile(current_user.id)
        advice = advisor.get_ai_advice(current_user.id, request.message)
        
        return {
            'question': request.message,
            'advice': advice,
            'analysis_summary': {
                'overall_score': analysis['overall_score'],
                'strengths_count': len(analysis['strengths']),
                'weaknesses_count': len(analysis['weaknesses']),
                'recommendations_count': len(analysis['recommendations'])
            }
        }
    except Exception as e:
        logger.error(f"Advisor ask error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get advice: {str(e)}")


@router.post("/lesson-assistant")
async def ask_lesson_assistant(
    request: LessonChatMessage,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Answer a student's question using the current lesson context."""
    course = db.query(Course).filter(Course.id == request.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    lesson = db.query(Lesson).filter(
        Lesson.id == request.lesson_id,
        Lesson.course_id == request.course_id,
        Lesson.is_published == True
    ).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == current_user.id,
        Enrollment.course_id == request.course_id,
        Enrollment.status.in_([EnrollmentStatus.ACTIVE, EnrollmentStatus.COMPLETED, EnrollmentStatus.PENDING])
    ).first()

    if not enrollment and not lesson.is_free_preview:
        raise HTTPException(status_code=403, detail="Bạn cần ghi danh khóa học để dùng AI trong bài học này")

    lesson_context = _build_lesson_context(course, lesson)
    local_answer = _build_local_lesson_answer(request.message, course, lesson, lesson_context)

    if not GEMINI_API_KEY:
        return {
            "answer": local_answer,
            "source": "local_lesson_context",
            "lesson": {
                "id": lesson.id,
                "title": lesson.title,
                "course_name": course.course_name
            }
        }

    prompt = f"""Bạn là trợ lý AI đang hỗ trợ sinh viên ngay trong lúc học bài.

NGUYÊN TẮC:
- Ưu tiên trả lời dựa trên ngữ cảnh bài học được cung cấp bên dưới.
- Nếu câu hỏi là kiến thức nền, kiến thức phổ thông hoặc khái niệm chuẩn liên quan đến môn học, được phép dùng kiến thức chuẩn bên ngoài bài để trả lời.
- Khi dùng kiến thức ngoài bài, phải nói rõ đó là phần giải thích mở rộng, không gắn nhầm là nguyên văn từ bài học.
- Chỉ nói là "không đủ dữ liệu" khi câu hỏi cần chi tiết đặc thù của đúng bài học/tài liệu hiện tại mà ngữ cảnh không có.
- Trả lời bằng tiếng Việt, ngắn gọn, dễ hiểu, tập trung vào câu hỏi.
- Khi phù hợp, dùng gạch đầu dòng hoặc ví dụ ngắn.
- Xuất ra văn bản thuần, không dùng Markdown như **đậm**, *nghiêng*, # tiêu đề, hoặc ```code```.
- Không bịa thông tin đặc thù của bài học, khóa học, giảng viên hoặc tài liệu khi không có dữ liệu.

THÔNG TIN KHÓA HỌC:
- Khóa học: {course.course_name}
- Mã học phần: {course.course_code}
- Bài học: {lesson.title}

NGỮ CẢNH BÀI HỌC:
{lesson_context or 'Không có văn bản bài học khả dụng.'}

CÂU HỎI CỦA SINH VIÊN:
{request.message}

Hãy trả lời ngay bây giờ."""

    try:
        answer = await _ask_gemini_with_context(prompt)
        return {
            "answer": answer,
            "source": "gemini_lesson_context",
            "lesson": {
                "id": lesson.id,
                "title": lesson.title,
                "course_name": course.course_name
            }
        }
    except Exception as exc:
        logger.error("Lesson assistant error: %s", exc)
        return {
            "answer": local_answer,
            "source": "local_lesson_context",
            "fallback_reason": str(exc),
            "lesson": {
                "id": lesson.id,
                "title": lesson.title,
                "course_name": course.course_name
            }
        }


@router.post("/tts")
async def generate_tutor_speech(
    request: TutorSpeechRequest,
    current_user: User = Depends(get_current_user)
):
    """Generate Google Gemini TTS audio for tutor replies."""
    del current_user

    normalized_text = request.text.strip()
    if not normalized_text:
        raise HTTPException(status_code=400, detail="Text is required for speech generation")

    return await _generate_tutor_speech(normalized_text, request.voice_gender)

@router.post("/gemini")
async def ask_gemini(
    request: ChatMessage,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Debug log
        logger.info(f"Gemini request from user {current_user.id}: {request.message[:50]}...")
        logger.info(f"API Key configured: {bool(GEMINI_API_KEY)} (length: {len(GEMINI_API_KEY) if GEMINI_API_KEY else 0})")
        
        # Check if API key is configured
        if not GEMINI_API_KEY or GEMINI_API_KEY == '':
            logger.warning("Gemini API key not configured, falling back to local advisor")
            # Fallback to local advisor
            advisor = StudentAdvisor(db)
            advice = advisor.get_ai_advice(current_user.id, request.message)
            return {
                'answer': advice,
                'source': 'local',
                'message': 'Gemini API key not configured. Using local advisor.'
            }
        
        # Get student context
        advisor = StudentAdvisor(db)
        analysis = advisor.analyze_student_profile(current_user.id)

        # Lấy thông tin sinh viên đầy đủ
        student_info = analysis.get('student_info', {})
        student_name = student_info.get('name', 'Sinh viên')
        student_id_str = student_info.get('student_id', 'N/A')
        student_major = student_info.get('major', 'Chưa xác định')
        student_specialization = student_info.get('specialization', 'Chưa chọn')

        perf = analysis.get('performance_summary', {})
        overall = analysis.get('overall_score', {})

        # --- Lấy tên khóa học thực tế ---
        enrolled_courses_rows = (
            db.query(Enrollment, Course)
            .join(Course, Enrollment.course_id == Course.id)
            .filter(Enrollment.student_id == current_user.id)
            .order_by(Enrollment.enrolled_at.desc())
            .limit(10)
            .all()
        )
        if enrolled_courses_rows:
            course_lines = []
            for enr, crs in enrolled_courses_rows:
                if enr.progress >= 100:
                    status = "✅ Hoàn thành"
                elif enr.progress > 0:
                    status = f"🔄 {enr.progress}% (đang học)"
                else:
                    status = "🆕 Chưa bắt đầu"
                course_lines.append(f"  • [{crs.course_code}] {crs.course_name} — {status}")
            courses_context = "\n".join(course_lines)
        else:
            courses_context = "  (Chưa đăng ký khóa học nào)"

        # --- Lấy kết quả quiz gần đây ---
        recent_quiz_rows = (
            db.query(QuizResult, Lesson)
            .join(Lesson, QuizResult.lesson_id == Lesson.id)
            .filter(QuizResult.user_id == current_user.id)
            .order_by(QuizResult.completed_at.desc())
            .limit(8)
            .all()
        )
        if recent_quiz_rows:
            quiz_lines = []
            for qr, les in recent_quiz_rows:
                mark = "✅" if qr.score >= 70 else "❌"
                quiz_lines.append(
                    f"  • {les.title}: {qr.score:.0f}% ({qr.correct_answers}/{qr.total_questions} câu đúng) {mark}"
                )
            quizzes_context = "\n".join(quiz_lines)
        else:
            quizzes_context = "  (Chưa làm quiz nào)"

        # --- Gợi ý hành động ---
        recs = analysis.get('recommendations', [])
        recs_lines = [f"  • {r['title']}: {r['description']}" for r in recs[:3]]
        recs_context = "\n".join(recs_lines) if recs_lines else "  (Không có gợi ý đặc biệt)"

        context = f"""Bạn là AI Learning Advisor của Đại học Văn Lang — trợ lý học tập cá nhân hóa. Bạn đang tư vấn trực tiếp cho sinh viên dưới đây. Hãy trả lời DỰA TRÊN DỮ LIỆU THỰC CỦA SINH VIÊN NÀY, không nói chung chung.

👤 SINH VIÊN: {student_name} (MSSV: {student_id_str})
📚 Ngành: {student_major} | Chuyên ngành: {student_specialization}

━━━━ KHÓA HỌC ĐANG THEO HỌC ━━━━
{courses_context}

━━━━ KẾT QUẢ QUIZ GẦN ĐÂY ━━━━
{quizzes_context}

━━━━ TỔNG QUAN THÀNH TÍCH ━━━━
• Điểm tổng thể: {overall.get('overall_score', 0)}/100 ({overall.get('grade', 'N/A')})
• Hoàn thành: {perf.get('completed_courses', 0)}/{perf.get('total_courses', 0)} khóa ({perf.get('completion_rate', 0)}%)
• Quiz: {perf.get('passed_quizzes', 0)}/{perf.get('total_quizzes', 0)} đạt (TB: {perf.get('average_quiz_score', 0):.1f}%)
• Giờ học: {perf.get('total_study_hours', 0)}h

💪 ĐIỂM MẠNH:
{chr(10).join([f"  • {s['category']}: {s['description']}" for s in analysis['strengths'][:3]]) if analysis['strengths'] else "  • Chưa có đủ dữ liệu để đánh giá"}

⚠️ CẦN CẢI THIỆN:
{chr(10).join([f"  • {w['category']}: {w['description']}" for w in analysis['weaknesses'][:3]]) if analysis['weaknesses'] else "  • Không có điểm yếu rõ ràng"}

🎯 GỢI Ý ƯU TIÊN:
{recs_context}

━━━━━━━━━━━━━━━━━━━━━━
❓ CÂU HỎI CỦA SINH VIÊN: "{request.message}"
━━━━━━━━━━━━━━━━━━━━━━

HƯỚNG DẪN TRẢ LỜI:
1. Xưng hô: Gọi sinh viên bằng tên "{student_name.split()[-1]}"
2. Tham chiếu đúng tên khóa học, tên bài quiz CỤ THỂ từ dữ liệu trên
3. CHỈ RÕ con số thực tế (điểm số, tỷ lệ hoàn thành) khi liên quan
4. Đưa ra lời khuyên HÀNH ĐỘNG được ngay (ví dụ: "Em nên ôn lại bài X vì điểm quiz chỉ đạt 45%")
5. Nếu sinh viên chưa có dữ liệu (0 khóa học / 0 quiz), hướng dẫn cụ thể cách bắt đầu
6. Dùng emoji cho sinh động, trả lời NGẮN GỌN và TẬP TRUNG

TRẢ LỜI (Tiếng Việt):"""

        # Call Gemini API
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
                headers={
                    "Content-Type": "application/json"
                },
                json={
                    "contents": [{
                        "parts": [{"text": context}]
                    }],
                    "generationConfig": {
                        "temperature": 0.8,
                        "maxOutputTokens": 8192,
                        "topP": 0.95,
                        "topK": 40
                    },
                    "safetySettings": [
                        {
                            "category": "HARM_CATEGORY_HARASSMENT",
                            "threshold": "BLOCK_NONE"
                        },
                        {
                            "category": "HARM_CATEGORY_HATE_SPEECH",
                            "threshold": "BLOCK_NONE"
                        },
                        {
                            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                            "threshold": "BLOCK_NONE"
                        },
                        {
                            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                            "threshold": "BLOCK_NONE"
                        }
                    ]
                },
                timeout=60.0
            )
            
            if response.status_code != 200:
                logger.error(f"Gemini API error: {response.status_code} - {response.text}")
                # Fallback to local advisor
                advice = advisor.get_ai_advice(current_user.id, request.message)
                return {
                    'answer': advice,
                    'source': 'local',
                    'message': 'Gemini unavailable. Using local advisor.'
                }
            
            result = response.json()
            
            # Extract answer from Gemini response
            if 'candidates' in result and len(result['candidates']) > 0:
                candidate = result['candidates'][0]
                
                # Check if response was blocked or incomplete
                finish_reason = candidate.get('finishReason', 'UNKNOWN')
                logger.info(f"Gemini finish reason: {finish_reason}")
                
                if finish_reason == 'SAFETY':
                    logger.warning("Response blocked by safety filters")
                    # Fallback to local advisor
                    advice = advisor.get_ai_advice(current_user.id, request.message)
                    return {
                        'answer': advice,
                        'source': 'local',
                        'message': 'Response filtered. Using local advisor.'
                    }
                
                # Extract the text
                if 'content' in candidate and 'parts' in candidate['content']:
                    answer = candidate['content']['parts'][0]['text']
                    
                    # If stopped due to max tokens, add indicator
                    if finish_reason == 'MAX_TOKENS':
                        answer += "\n\n[Câu trả lời bị cắt do quá dài. Vui lòng hỏi cụ thể hơn.]"
                        logger.warning("Response truncated due to MAX_TOKENS")
                else:
                    raise Exception("No content in Gemini response")
            else:
                raise Exception("Invalid Gemini response format")
            
            return {
                'answer': answer,
                'source': 'gemini',
                'model': 'gemini-2.5-flash',
                'tokens_used': result.get('usageMetadata', {}).get('totalTokenCount', 0),
                'finish_reason': finish_reason
            }
            
    except httpx.TimeoutException:
        logger.error("Gemini API timeout")
        # Fallback to local advisor
        advisor = StudentAdvisor(db)
        advice = advisor.get_ai_advice(current_user.id, request.message)
        return {
            'answer': advice,
            'source': 'local',
            'message': 'Gemini timeout. Using local advisor.'
        }
    except Exception as e:
        logger.error(f"Gemini error: {e}")
        # Fallback to local advisor
        advisor = StudentAdvisor(db)
        advice = advisor.get_ai_advice(current_user.id, request.message)
        return {
            'answer': advice,
            'source': 'local',
            'message': f'Gemini error: {str(e)}. Using local advisor.'
        }
