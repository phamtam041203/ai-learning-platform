from __future__ import annotations

from typing import Any, Dict, List, Optional

import httpx

from app.core.config import settings

GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

INTAKE_QUESTION_BANK: List[Dict[str, Any]] = [
    {
        "id": "prog_logic",
        "type": "knowledge",
        "domain": "programming_foundations",
        "phase_targets": [1],
        "prompt": "Trong Python, vòng lặp nào phù hợp nhất khi bạn cần duyệt qua từng phần tử của một danh sách?",
        "options": [
            {"value": "a", "label": "A", "text": "for item in my_list"},
            {"value": "b", "label": "B", "text": "switch my_list"},
            {"value": "c", "label": "C", "text": "catch item in my_list"},
            {"value": "d", "label": "D", "text": "goto my_list"}
        ],
        "correct_answer": "a",
        "explanation": "Vòng lặp for là cách chuẩn để duyệt từng phần tử trong danh sách.",
    },
    {
        "id": "problem_solving",
        "type": "knowledge",
        "domain": "problem_solving",
        "phase_targets": [1, 2],
        "prompt": "Bước nào nên làm đầu tiên khi gặp một bài toán lập trình mới?",
        "options": [
            {"value": "a", "label": "A", "text": "Viết code ngay để thử"},
            {"value": "b", "label": "B", "text": "Phân tích input, output và chia nhỏ bài toán"},
            {"value": "c", "label": "C", "text": "Tìm thư viện bất kỳ để dùng"},
            {"value": "d", "label": "D", "text": "Chọn đáp án dài nhất"}
        ],
        "correct_answer": "b",
        "explanation": "Phân tích input, output và chia nhỏ bài toán giúp tránh viết sai hướng ngay từ đầu.",
    },
    {
        "id": "debugging_basics",
        "type": "knowledge",
        "domain": "problem_solving",
        "phase_targets": [1, 2],
        "prompt": "Khi chương trình chạy sai kết quả, bước xử lý hợp lý nhất là gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Xóa toàn bộ code và viết lại ngay"},
            {"value": "b", "label": "B", "text": "Kiểm tra input, từng bước xử lý và in log để tìm chỗ sai"},
            {"value": "c", "label": "C", "text": "Đổi tên biến hy vọng lỗi tự hết"},
            {"value": "d", "label": "D", "text": "Bỏ qua vì có thể máy lỗi"}
        ],
        "correct_answer": "b",
        "explanation": "Debug hiệu quả bắt đầu từ việc tái hiện lỗi và kiểm tra tuần tự dữ liệu, luồng xử lý.",
    },
    {
        "id": "oop_design",
        "type": "knowledge",
        "domain": "software_design",
        "phase_targets": [2, 3],
        "prompt": "Lợi ích chính của lập trình hướng đối tượng là gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Chỉ dùng cho game 3D"},
            {"value": "b", "label": "B", "text": "Tổ chức code theo đối tượng để tái sử dụng và dễ bảo trì"},
            {"value": "c", "label": "C", "text": "Không cần chia file"},
            {"value": "d", "label": "D", "text": "Thay thế hoàn toàn cơ sở dữ liệu"}
        ],
        "correct_answer": "b",
        "explanation": "OOP giúp mô hình hóa dữ liệu và hành vi, tăng khả năng tái sử dụng và bảo trì.",
    },
    {
        "id": "git_collaboration",
        "type": "knowledge",
        "domain": "software_design",
        "phase_targets": [2, 3],
        "prompt": "Trong làm việc nhóm, Git giúp ích điều gì quan trọng nhất?",
        "options": [
            {"value": "a", "label": "A", "text": "Tăng tốc độ internet"},
            {"value": "b", "label": "B", "text": "Quản lý phiên bản code và phối hợp thay đổi an toàn"},
            {"value": "c", "label": "C", "text": "Tự động sinh giao diện web"},
            {"value": "d", "label": "D", "text": "Thay thế hoàn toàn database"}
        ],
        "correct_answer": "b",
        "explanation": "Git hỗ trợ lưu lịch sử thay đổi, review code và phối hợp nhóm có kiểm soát.",
    },
    {
        "id": "database_sql",
        "type": "knowledge",
        "domain": "data_management",
        "phase_targets": [2, 3],
        "prompt": "Câu lệnh SQL nào dùng để lấy dữ liệu từ bảng students?",
        "options": [
            {"value": "a", "label": "A", "text": "FETCH ALL students"},
            {"value": "b", "label": "B", "text": "SELECT * FROM students"},
            {"value": "c", "label": "C", "text": "GET students"},
            {"value": "d", "label": "D", "text": "READ TABLE students"}
        ],
        "correct_answer": "b",
        "explanation": "SELECT là cú pháp chuẩn để truy vấn dữ liệu trong SQL.",
    },
    {
        "id": "database_relationship",
        "type": "knowledge",
        "domain": "data_management",
        "phase_targets": [2, 3],
        "prompt": "Khóa ngoại trong cơ sở dữ liệu dùng để làm gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Tăng kích thước bảng dữ liệu"},
            {"value": "b", "label": "B", "text": "Liên kết dữ liệu giữa các bảng"},
            {"value": "c", "label": "C", "text": "Mã hóa toàn bộ bản ghi"},
            {"value": "d", "label": "D", "text": "Xóa dữ liệu bị trùng"}
        ],
        "correct_answer": "b",
        "explanation": "Foreign key giúp đảm bảo quan hệ nhất quán giữa các bảng liên quan.",
    },
    {
        "id": "web_api",
        "type": "knowledge",
        "domain": "web_development",
        "phase_targets": [3, 4],
        "prompt": "Trong ứng dụng web, API thường đóng vai trò gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Lưu pin cho laptop"},
            {"value": "b", "label": "B", "text": "Kết nối frontend với dữ liệu hoặc dịch vụ backend"},
            {"value": "c", "label": "C", "text": "Thay thế hoàn toàn giao diện người dùng"},
            {"value": "d", "label": "D", "text": "Chỉ để cài CSS"}
        ],
        "correct_answer": "b",
        "explanation": "API là lớp giao tiếp giữa giao diện và dữ liệu hay logic xử lý phía server.",
    },
    {
        "id": "http_method",
        "type": "knowledge",
        "domain": "web_development",
        "phase_targets": [3, 4],
        "prompt": "Khi tạo mới dữ liệu qua REST API, HTTP method nào thường được dùng?",
        "options": [
            {"value": "a", "label": "A", "text": "GET"},
            {"value": "b", "label": "B", "text": "POST"},
            {"value": "c", "label": "C", "text": "TRACE"},
            {"value": "d", "label": "D", "text": "HEAD"}
        ],
        "correct_answer": "b",
        "explanation": "POST thường được dùng để tạo mới tài nguyên trong REST API.",
    },
    {
        "id": "frontend_state",
        "type": "knowledge",
        "domain": "web_development",
        "phase_targets": [3, 4],
        "prompt": "Trong ứng dụng frontend hiện đại, state thường được dùng để làm gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Lưu trữ trạng thái dữ liệu ảnh hưởng đến giao diện"},
            {"value": "b", "label": "B", "text": "Thay thế hoàn toàn backend"},
            {"value": "c", "label": "C", "text": "Biên dịch CSS sang HTML"},
            {"value": "d", "label": "D", "text": "Chỉ để đổi màu nút bấm ngẫu nhiên"}
        ],
        "correct_answer": "a",
        "explanation": "State giữ dữ liệu thay đổi theo tương tác và quyết định những gì cần render lại.",
    },
    {
        "id": "testing_quality",
        "type": "knowledge",
        "domain": "engineering_quality",
        "phase_targets": [4, 5],
        "prompt": "Mục tiêu quan trọng của kiểm thử phần mềm là gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Làm project dài hơn"},
            {"value": "b", "label": "B", "text": "Phát hiện lỗi sớm và tăng độ tin cậy của hệ thống"},
            {"value": "c", "label": "C", "text": "Giảm số lượng file source code"},
            {"value": "d", "label": "D", "text": "Bỏ qua bước review code"}
        ],
        "correct_answer": "b",
        "explanation": "Testing giúp phát hiện lỗi sớm, giảm rủi ro và cải thiện chất lượng hệ thống.",
    },
    {
        "id": "unit_test_scope",
        "type": "knowledge",
        "domain": "engineering_quality",
        "phase_targets": [4, 5],
        "prompt": "Unit test nên tập trung kiểm tra điều gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Một phần nhỏ, độc lập của chương trình"},
            {"value": "b", "label": "B", "text": "Toàn bộ hệ thống triển khai production"},
            {"value": "c", "label": "C", "text": "Tốc độ mạng của người dùng"},
            {"value": "d", "label": "D", "text": "Cấu hình màn hình của máy học viên"}
        ],
        "correct_answer": "a",
        "explanation": "Unit test kiểm tra các hàm, lớp hoặc module nhỏ một cách cô lập.",
    },
    {
        "id": "architecture_tradeoff",
        "type": "knowledge",
        "domain": "software_design",
        "phase_targets": [4, 5],
        "prompt": "Khi thiết kế hệ thống, trade-off nghĩa là gì?",
        "options": [
            {"value": "a", "label": "A", "text": "Một quyết định luôn tốt nhất cho mọi tình huống"},
            {"value": "b", "label": "B", "text": "Chấp nhận ưu điểm ở mặt này để đánh đổi với hạn chế ở mặt khác"},
            {"value": "c", "label": "C", "text": "Xóa bỏ mọi ràng buộc kỹ thuật"},
            {"value": "d", "label": "D", "text": "Không cần quan tâm đến hiệu năng hay bảo trì"}
        ],
        "correct_answer": "b",
        "explanation": "Thiết kế phần mềm luôn cần cân bằng giữa hiệu năng, đơn giản, chi phí và khả năng mở rộng.",
    },
    {
        "id": "style_pref",
        "type": "preference",
        "prompt": "Khi học một chủ đề mới, cách nào giúp bạn hiểu nhanh nhất?",
        "options": [
            {"value": "visual", "label": "A", "text": "Sơ đồ, hình minh họa, bản đồ kiến thức"},
            {"value": "reading", "label": "B", "text": "Đọc tài liệu, checklist và ghi chú"},
            {"value": "auditory", "label": "C", "text": "Nghe giải thích và trao đổi với trợ lý AI"},
            {"value": "kinesthetic", "label": "D", "text": "Làm thử bài tập và sửa sai ngay"}
        ],
    },
    {
        "id": "difficulty_pref",
        "type": "preference",
        "prompt": "Bạn muốn độ khó bài tập tiếp theo bắt đầu ở mức nào?",
        "options": [
            {"value": "easy", "label": "A", "text": "Nhẹ để xây lại nền tảng"},
            {"value": "medium", "label": "B", "text": "Vừa sức nhưng vẫn có thử thách"},
            {"value": "hard", "label": "C", "text": "Khó hơn để bứt tốc"}
        ],
    },
]


def get_intake_assessment_template() -> List[Dict[str, Any]]:
    template: List[Dict[str, Any]] = []
    for question in INTAKE_QUESTION_BANK:
        template.append({
            "id": question["id"],
            "type": question["type"],
            "domain": question.get("domain"),
            "phase_targets": question.get("phase_targets", []),
            "prompt": question["prompt"],
            "options": question["options"],
        })
    return template


class LearningPersonalizationService:
    def __init__(self) -> None:
        self.api_key = settings.GEMINI_API_KEY

    async def analyze_intake_assessment(self, answers: Dict[str, str], student_name: str, program: str) -> Dict[str, Any]:
        domain_scores: Dict[str, List[int]] = {}
        strengths: List[str] = []
        weaknesses: List[str] = []
        total_knowledge = 0
        correct_knowledge = 0

        for question in INTAKE_QUESTION_BANK:
            if question["type"] != "knowledge":
                continue

            total_knowledge += 1
            answer = (answers.get(question["id"]) or "").strip().lower()
            is_correct = answer == question["correct_answer"]
            domain_scores.setdefault(question["domain"], []).append(100 if is_correct else 0)

            if is_correct:
                correct_knowledge += 1

        averaged_domains = {
            domain: round(sum(values) / len(values), 2)
            for domain, values in domain_scores.items()
        }

        style = (answers.get("style_pref") or "visual").strip().lower() or "visual"
        preferred_difficulty = (answers.get("difficulty_pref") or "medium").strip().lower() or "medium"

        phase_readiness = self._build_phase_readiness(averaged_domains)
        unlocked_phase_ids = self._build_unlocked_phases(phase_readiness)
        overall_score = round((correct_knowledge / total_knowledge) * 100, 2) if total_knowledge else 0.0

        for domain, score in averaged_domains.items():
            label = self._domain_label(domain)
            if score >= 70:
                strengths.append(label)
            else:
                weaknesses.append(label)

        recommended_difficulty = self._recommended_difficulty(overall_score, preferred_difficulty)
        focus_skills = [self._domain_label(domain) for domain, score in sorted(averaged_domains.items(), key=lambda item: item[1])[:2]]

        fallback_summary = self._fallback_intake_summary(
            student_name=student_name,
            program=program,
            overall_score=overall_score,
            unlocked_phase_ids=unlocked_phase_ids,
            focus_skills=focus_skills,
            learning_style=style,
            recommended_difficulty=recommended_difficulty,
        )
        ai_summary = await self._generate_intake_summary(
            student_name=student_name,
            program=program,
            overall_score=overall_score,
            phase_readiness=phase_readiness,
            strengths=strengths,
            weaknesses=weaknesses,
            learning_style=style,
            recommended_difficulty=recommended_difficulty,
            fallback=fallback_summary,
        )

        return {
            "assessment_score": overall_score,
            "learning_style": style,
            "preferred_difficulty": preferred_difficulty,
            "recommended_difficulty": recommended_difficulty,
            "strengths": strengths,
            "weaknesses": weaknesses,
            "focus_skills": focus_skills,
            "unlocked_phase_ids": unlocked_phase_ids,
            "recommended_phase_id": unlocked_phase_ids[-1] if unlocked_phase_ids else 1,
            "stage_readiness": phase_readiness,
            "ai_summary": ai_summary,
            "next_actions": self._build_intake_actions(unlocked_phase_ids, focus_skills, style),
        }

    async def build_adaptive_feedback(
        self,
        *,
        student_name: str,
        course_name: str,
        lesson_title: str,
        percentage: float,
        passed: bool,
        incorrect_questions: List[Dict[str, Any]],
        supplementary_materials: List[Dict[str, Any]],
        preferred_difficulty: Optional[str] = None,
        learning_style: Optional[str] = None,
    ) -> Dict[str, Any]:
        weak_topics = self._extract_weak_topics(incorrect_questions)
        recommended_difficulty = self._recommended_difficulty(percentage, preferred_difficulty or "medium")
        next_steps = self._build_adaptive_actions(percentage, weak_topics)
        fallback_feedback = self._fallback_adaptive_feedback(
            student_name=student_name,
            percentage=percentage,
            weak_topics=weak_topics,
            recommended_difficulty=recommended_difficulty,
        )

        ai_feedback = await self._generate_adaptive_feedback(
            student_name=student_name,
            course_name=course_name,
            lesson_title=lesson_title,
            percentage=percentage,
            passed=passed,
            weak_topics=weak_topics,
            learning_style=learning_style or "visual",
            recommended_difficulty=recommended_difficulty,
            fallback=fallback_feedback,
        )

        return {
            "status": "reinforce" if percentage < 70 else "advance",
            "recommended_difficulty": recommended_difficulty,
            "adaptation_reason": self._adaptation_reason(percentage, weak_topics),
            "weak_topics": weak_topics,
            "next_steps": next_steps,
            "supplementary_materials": supplementary_materials,
            "incorrect_questions": incorrect_questions,
            "ai_feedback": ai_feedback,
        }

    def _build_phase_readiness(self, domain_scores: Dict[str, float]) -> List[Dict[str, Any]]:
        phase_scores = {
            1: round((domain_scores.get("programming_foundations", 0) + domain_scores.get("problem_solving", 0)) / 2, 2),
            2: round((domain_scores.get("problem_solving", 0) + domain_scores.get("software_design", 0) + domain_scores.get("data_management", 0)) / 3, 2),
            3: round((domain_scores.get("software_design", 0) + domain_scores.get("data_management", 0) + domain_scores.get("web_development", 0)) / 3, 2),
            4: round((domain_scores.get("web_development", 0) + domain_scores.get("engineering_quality", 0)) / 2, 2),
            5: round((domain_scores.get("engineering_quality", 0) * 0.7) + (domain_scores.get("software_design", 0) * 0.3), 2),
        }
        thresholds = {1: 35, 2: 50, 3: 62, 4: 75, 5: 85}
        names = {
            1: "Cơ sở ngành",
            2: "Nền tảng chuyên ngành",
            3: "Chuyên ngành CNPM",
            4: "Nâng cao",
            5: "Tốt nghiệp",
        }

        readiness: List[Dict[str, Any]] = []
        for phase_id in range(1, 6):
            score = phase_scores[phase_id]
            readiness.append({
                "phase_id": phase_id,
                "phase_name": names[phase_id],
                "readiness_score": score,
                "unlocked": score >= thresholds[phase_id],
                "reason": self._phase_reason(phase_id, score),
            })
        return readiness

    def _build_unlocked_phases(self, phase_readiness: List[Dict[str, Any]]) -> List[int]:
        unlocked: List[int] = []
        for readiness in phase_readiness:
            if readiness["unlocked"]:
                unlocked.append(readiness["phase_id"])
            else:
                break
        return unlocked or [1]

    def _domain_label(self, domain: str) -> str:
        labels = {
            "programming_foundations": "Lập trình cơ bản",
            "problem_solving": "Tư duy giải quyết vấn đề",
            "software_design": "Thiết kế phần mềm",
            "data_management": "Cơ sở dữ liệu",
            "web_development": "Phát triển web và API",
            "engineering_quality": "Kiểm thử và chất lượng phần mềm",
        }
        return labels.get(domain, domain)

    def _recommended_difficulty(self, score: float, preferred: str) -> str:
        if score < 45:
            return "easy"
        if score < 75:
            return "medium"
        if preferred == "hard":
            return "hard"
        return "medium" if score < 88 else "hard"

    def _build_intake_actions(self, unlocked_phase_ids: List[int], focus_skills: List[str], learning_style: str) -> List[str]:
        style_action = {
            "visual": "Xem roadmap 3D và bám theo từng chặng để học theo sơ đồ trực quan.",
            "reading": "Tạo checklist ngắn cho từng chặng và tóm tắt khái niệm sau mỗi buổi học.",
            "auditory": "Dùng AI tutor để hỏi lại từng khái niệm khó sau mỗi bài học.",
            "kinesthetic": "Làm ngay một bài quiz hoặc bài tập ngắn sau khi học xong mỗi phần.",
        }.get(learning_style, "Giữ nhịp học ổn định theo từng chặng nhỏ.")

        actions = [
            f"Bắt đầu từ giai đoạn {unlocked_phase_ids[-1]} và ưu tiên lấp lỗ hổng ở: {', '.join(focus_skills)}.",
            style_action,
            "Sau mỗi quiz, kiểm tra adaptive feedback để hệ thống điều chỉnh tài liệu bổ trợ và độ khó tiếp theo.",
        ]
        return actions

    def _extract_weak_topics(self, incorrect_questions: List[Dict[str, Any]]) -> List[str]:
        topics: List[str] = []
        for item in incorrect_questions[:4]:
            topic = item.get("topic") or item.get("question") or "Kiến thức cần củng cố"
            topics.append(topic)
        return topics

    def _build_adaptive_actions(self, percentage: float, weak_topics: List[str]) -> List[str]:
        actions = []
        if weak_topics:
            actions.append(f"Ôn lại ngay các phần: {', '.join(weak_topics[:3])}.")
        if percentage < 50:
            actions.append("Chuyển bài luyện tập tiếp theo về mức dễ để xây lại nền tảng.")
            actions.append("Làm lại quiz sau khi xem lại tài liệu trong 15-20 phút.")
        elif percentage < 70:
            actions.append("Giữ mức độ trung bình và thêm một bài luyện củng cố trước khi mở bài mới.")
            actions.append("Hỏi AI tutor các câu bạn sai để hiểu vì sao đáp án đúng.")
        else:
            actions.append("Bạn có thể tăng dần độ khó ở bài tiếp theo để giữ đà tiến bộ.")
            actions.append("Chọn 1 nội dung sai nhẹ để ôn lại nhanh trước khi sang bài mới.")
        return actions

    def _adaptation_reason(self, percentage: float, weak_topics: List[str]) -> str:
        if percentage < 50:
            return "Kết quả hiện tại cho thấy cần quay về mức nền tảng để tránh hổng kiến thức ở các phần tiếp theo."
        if percentage < 70:
            return f"Bạn đã nắm được một phần, nhưng vẫn còn lỗ hổng ở {', '.join(weak_topics[:2]) or 'một số khái niệm chính'}."
        return "Bạn đã đạt ngưỡng an toàn, hệ thống có thể tăng độ khó dần trong khi vẫn giữ một vòng ôn ngắn."

    def _phase_reason(self, phase_id: int, score: float) -> str:
        if score >= 80:
            return "Sẵn sàng tốt để mở rộng sang nội dung của chặng này."
        if score >= 60:
            return "Có thể mở khóa chặng này nhưng nên kèm bài luyện củng cố."
        if phase_id == 1:
            return "Cần củng cố lại nền tảng cốt lõi trước khi đi nhanh hơn."
        return "Chưa nên học sâu ở chặng này cho tới khi các kỹ năng trước đó ổn định hơn."

    def _fallback_intake_summary(
        self,
        *,
        student_name: str,
        program: str,
        overall_score: float,
        unlocked_phase_ids: List[int],
        focus_skills: List[str],
        learning_style: str,
        recommended_difficulty: str,
    ) -> str:
        return (
            f"{student_name} đang có mức sẵn sàng khoảng {overall_score}/100 cho chương trình {program}. "
            f"Hệ thống có thể mở khóa đến giai đoạn {unlocked_phase_ids[-1]} trên bản đồ 3D. "
            f"Những phần cần ưu tiên củng cố là {', '.join(focus_skills)}. "
            f"Phong cách học phù hợp nhất hiện tại là {learning_style}, và độ khó khởi đầu nên là {recommended_difficulty}."
        )

    def _fallback_adaptive_feedback(
        self,
        *,
        student_name: str,
        percentage: float,
        weak_topics: List[str],
        recommended_difficulty: str,
    ) -> str:
        weak_text = ", ".join(weak_topics[:3]) if weak_topics else "một số khái niệm trọng tâm"
        return (
            f"{student_name} vừa đạt {round(percentage, 1)}%. "
            f"Hệ thống phát hiện bạn còn yếu ở {weak_text}, nên bài tiếp theo sẽ nghiêng về mức {recommended_difficulty}. "
            f"Hãy xem lại tài liệu bổ trợ rồi làm một lượt luyện ngắn trước khi tiếp tục."
        )

    async def _generate_intake_summary(
        self,
        *,
        student_name: str,
        program: str,
        overall_score: float,
        phase_readiness: List[Dict[str, Any]],
        strengths: List[str],
        weaknesses: List[str],
        learning_style: str,
        recommended_difficulty: str,
        fallback: str,
    ) -> str:
        if not self.api_key:
            return fallback

        prompt = f"""
Bạn là AI coach học tập cho sinh viên ngành {program}.
Hãy viết bằng tiếng Việt tự nhiên, ngắn gọn, không markdown nặng.

Sinh viên: {student_name}
Điểm đầu vào: {overall_score}
Readiness theo chặng: {phase_readiness}
Điểm mạnh: {strengths}
Điểm yếu: {weaknesses}
Phong cách học: {learning_style}
Độ khó nên bắt đầu: {recommended_difficulty}

Yêu cầu:
- Viết 1 đoạn tóm tắt 3 đến 5 câu.
- Nêu rõ chặng nào nên bắt đầu trên bản đồ 3D.
- Nhắc 2 phần kiến thức cần bù trước.
""".strip()

        return await self._ask_gemini(prompt, fallback)

    async def _generate_adaptive_feedback(
        self,
        *,
        student_name: str,
        course_name: str,
        lesson_title: str,
        percentage: float,
        passed: bool,
        weak_topics: List[str],
        learning_style: str,
        recommended_difficulty: str,
        fallback: str,
    ) -> str:
        if not self.api_key:
            return fallback

        prompt = f"""
Bạn là AI tutor đang theo sát sinh viên trong nền tảng học tập.
Viết bằng tiếng Việt tự nhiên, trực tiếp, không dùng emoji.

Sinh viên: {student_name}
Khóa học: {course_name}
Bài học: {lesson_title}
Điểm quiz: {percentage}
Đạt: {passed}
Lỗ hổng kiến thức: {weak_topics}
Phong cách học: {learning_style}
Độ khó tiếp theo nên là: {recommended_difficulty}

Yêu cầu:
- Viết 3 đến 4 câu phản hồi cá nhân hóa.
- Nêu rõ cần ôn lại phần nào.
- Chỉ ra nên giảm hay tăng độ khó của bài tiếp theo.
""".strip()

        return await self._ask_gemini(prompt, fallback)

    async def _ask_gemini(self, prompt: str, fallback: str) -> str:
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{GEMINI_API_URL}?key={self.api_key}",
                    json={
                        "contents": [{"parts": [{"text": prompt}]}],
                        "generationConfig": {
                            "temperature": 0.5,
                            "maxOutputTokens": 500,
                        },
                    },
                    timeout=45.0,
                )

            if response.status_code != 200:
                return fallback

            data = response.json()
            candidates = data.get("candidates") or []
            if not candidates:
                return fallback

            parts = candidates[0].get("content", {}).get("parts") or []
            text = "\n".join(part.get("text", "") for part in parts if part.get("text"))
            return text.strip() or fallback
        except Exception:
            return fallback