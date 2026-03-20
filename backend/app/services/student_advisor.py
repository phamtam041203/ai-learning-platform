"""
AI Student Advisor Service
Analyzes student performance and provides personalized recommendations
"""
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from app.models.course import Enrollment, Course, Lesson
from app.models.assessment import QuizResult
from app.models.user import User, StudentProfile

class StudentAdvisor:
    """AI-powered student academic advisor"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def analyze_student_profile(self, user_id: int) -> Dict:
        """
        Phân tích toàn diện hồ sơ sinh viên
        Returns comprehensive student analysis
        """
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "User not found"}
        
        profile = self.db.query(StudentProfile).filter(
            StudentProfile.user_id == user_id
        ).first()
        
        # Get enrollments
        enrollments = self.db.query(Enrollment).filter(
            Enrollment.student_id == user_id
        ).all()
        
        # Get quiz results
        quiz_results = self.db.query(QuizResult).filter(
            QuizResult.user_id == user_id
        ).all()
        
        # Analyze performance
        performance_analysis = self._analyze_performance(enrollments, quiz_results)
        strengths = self._identify_strengths(quiz_results, enrollments)
        weaknesses = self._identify_weaknesses(quiz_results, enrollments)
        recommendations = self._generate_recommendations(
            strengths, weaknesses, enrollments, profile
        )
        dashboard_summary = self._build_dashboard_summary(
            performance_analysis,
            strengths,
            weaknesses,
            recommendations
        )
        
        return {
            "student_info": {
                "name": user.full_name,
                "email": user.email,
                "student_id": profile.student_id if profile else None,
                "major": profile.major if profile else None,
                "specialization": profile.specialization if profile else None
            },
            "performance_summary": performance_analysis,
            "strengths": strengths,
            "weaknesses": weaknesses,
            "recommendations": recommendations,
            "dashboard_summary": dashboard_summary,
            "overall_score": self._calculate_overall_score(quiz_results, enrollments)
        }
    
    def _analyze_performance(
        self, 
        enrollments: List[Enrollment], 
        quiz_results: List[QuizResult]
    ) -> Dict:
        """Phân tích hiệu suất học tập"""
        total_courses = len(enrollments)
        completed_courses = sum(
            1 for e in enrollments if e.progress >= 100
        )
        in_progress_courses = total_courses - completed_courses
        
        # Quiz performance
        total_quizzes = len(quiz_results)
        passed_quizzes = sum(
            1 for q in quiz_results if q.score >= 70
        )
        avg_quiz_score = (
            sum(q.score for q in quiz_results) / total_quizzes
            if total_quizzes > 0 else 0
        )
        
        # Study time
        total_study_time = sum(
            e.total_time_spent or 0 for e in enrollments
        )
        
        return {
            "total_courses": total_courses,
            "completed_courses": completed_courses,
            "in_progress_courses": in_progress_courses,
            "studied_courses": total_courses,
            "completion_rate": round(
                (completed_courses / total_courses * 100) if total_courses > 0 else 0, 
                2
            ),
            "total_quizzes": total_quizzes,
            "passed_quizzes": passed_quizzes,
            "quiz_pass_rate": round(
                (passed_quizzes / total_quizzes * 100) if total_quizzes > 0 else 0,
                2
            ),
            "average_quiz_score": round(avg_quiz_score, 2),
            "total_study_hours": round(total_study_time / 3600, 1)
        }
    
    def _identify_strengths(
        self, 
        quiz_results: List[QuizResult],
        enrollments: List[Enrollment]
    ) -> List[Dict]:
        """Xác định điểm mạnh của sinh viên"""
        strengths = []
        
        # High quiz scores
        high_score_quizzes = [
            q for q in quiz_results if q.score >= 85
        ]
        if len(high_score_quizzes) >= 3:
            strengths.append({
                "category": "Kết quả quiz xuất sắc",
                "description": f"Bạn đã đạt điểm cao (≥85%) trong {len(high_score_quizzes)} bài quiz",
                "level": "excellent"
            })
        
        # Fast learner
        fast_completions = [
            e for e in enrollments 
            if e.progress >= 50 and (e.total_time_spent or 0) < 7200  # < 2 hours
        ]
        if fast_completions:
            strengths.append({
                "category": "Học nhanh",
                "description": f"Bạn hoàn thành nhanh {len(fast_completions)} khóa học",
                "level": "good"
            })
        
        # Consistent performance
        if quiz_results:
            scores = [q.score for q in quiz_results]
            if len(scores) >= 5:
                variance = sum((x - sum(scores)/len(scores))**2 for x in scores) / len(scores)
                if variance < 100:  # Low variance = consistent
                    strengths.append({
                        "category": "Kết quả ổn định",
                        "description": "Bạn có kết quả học tập ổn định và đều đặn",
                        "level": "good"
                    })
        
        return strengths
    
    def _identify_weaknesses(
        self, 
        quiz_results: List[QuizResult],
        enrollments: List[Enrollment]
    ) -> List[Dict]:
        """Xác định điểm yếu của sinh viên"""
        weaknesses = []
        
        # Low quiz scores
        low_score_quizzes = [
            q for q in quiz_results if q.score < 50
        ]
        if len(low_score_quizzes) >= 2:
            low_score_quizzes = sorted(low_score_quizzes, key=lambda item: (item.score, item.completed_at or datetime.min))
            weaknesses.append({
                "category": "Điểm quiz thấp",
                "description": f"Bạn có {len(low_score_quizzes)} bài quiz dưới 50%",
                "severity": "high",
                "action": "Cần ôn tập lại các bài học cơ bản",
                "items": [self._serialize_quiz_result_detail(result) for result in low_score_quizzes[:5]]
            })
        
        # Incomplete courses
        stalled_courses = [
            e for e in enrollments 
            if e.progress < 30 and e.progress > 0
        ]
        if len(stalled_courses) >= 2:
            weaknesses.append({
                "category": "Khóa học chưa hoàn thành",
                "description": f"Bạn có {len(stalled_courses)} khóa học bị dừng lại",
                "severity": "medium",
                "action": "Hãy tập trung hoàn thành từng khóa học một",
                "items": [self._serialize_enrollment_detail(enrollment) for enrollment in stalled_courses[:5]]
            })
        
        # Inconsistent study pattern - fixed to use completed_at
        recent_results = sorted(
            quiz_results, 
            key=lambda x: x.completed_at,  # QuizResult has completed_at, not created_at
            reverse=True
        )[:5]
        if len(recent_results) >= 3:
            recent_scores = [q.score for q in recent_results]
            if max(recent_scores) - min(recent_scores) > 40:
                weaknesses.append({
                    "category": "Kết quả không ổn định",
                    "description": "Điểm số của bạn biến động nhiều",
                    "severity": "medium",
                    "action": "Cần học đều đặn hơn"
                })
        
        return weaknesses
    
    def _generate_recommendations(
        self,
        strengths: List[Dict],
        weaknesses: List[Dict],
        enrollments: List[Enrollment],
        profile: Optional[StudentProfile]
    ) -> List[Dict]:
        """Tạo gợi ý cá nhân hóa"""
        recommendations = []
        
        # Based on weaknesses
        if any(w["category"] == "Điểm quiz thấp" for w in weaknesses):
            recommendations.append({
                "priority": "high",
                "title": "Ôn tập kiến thức cơ bản",
                "description": "Bạn nên dành thời gian ôn lại các bài học đã học và làm lại các quiz",
                "actions": [
                    "Xem lại video bài giảng",
                    "Ghi chú lại những phần khó hiểu",
                    "Làm lại các quiz đã fail để củng cố kiến thức"
                ]
            })
        
        if any(w["category"] == "Khóa học chưa hoàn thành" for w in weaknesses):
            recommendations.append({
                "priority": "high",
                "title": "Hoàn thành khóa học đang dở",
                "description": "Tập trung vào việc hoàn thành các khóa học đang học",
                "actions": [
                    "Lập kế hoạch học hàng ngày",
                    "Dành ít nhất 30 phút/ngày cho mỗi khóa học",
                    "Đặt deadline cho bản thân"
                ]
            })
        
        # Based on strengths
        if strengths and not weaknesses:
            recommendations.append({
                "priority": "medium",
                "title": "Thử thách bản thân",
                "description": "Bạn đang học rất tốt! Hãy thử các khóa học nâng cao",
                "actions": [
                    "Đăng ký thêm khóa học chuyên sâu",
                    "Tham gia các dự án thực tế",
                    "Chia sẻ kiến thức với bạn bè"
                ]
            })
        
        # General recommendations
        if len(enrollments) == 0:
            recommendations.append({
                "priority": "high",
                "title": "Bắt đầu học ngay",
                "description": "Bạn chưa đăng ký khóa học nào",
                "actions": [
                    "Vào trang 'Duyệt khóa học'",
                    "Chọn khóa học phù hợp với chuyên ngành",
                    "Bắt đầu học ngay hôm nay"
                ]
            })
        elif len(enrollments) < 3:
            recommendations.append({
                "priority": "medium",
                "title": "Mở rộng kiến thức",
                "description": "Hãy đăng ký thêm các khóa học khác",
                "actions": [
                    "Tìm hiểu các khóa học liên quan đến chuyên ngành",
                    "Đa dạng hóa kỹ năng của bạn"
                ]
            })
        
        return recommendations
    
    def _calculate_overall_score(
        self,
        quiz_results: List[QuizResult],
        enrollments: List[Enrollment]
    ) -> Dict:
        """Tính điểm tổng thể"""
        # Quiz performance (40%)
        quiz_score = 0
        if quiz_results:
            avg_quiz = sum(q.score for q in quiz_results) / len(quiz_results)
            quiz_score = (avg_quiz / 100) * 40
        
        # Course completion (40%)
        completion_score = 0
        if enrollments:
            avg_progress = sum(e.progress for e in enrollments) / len(enrollments)
            completion_score = (avg_progress / 100) * 40
        
        # Consistency (20%)
        consistency_score = 20
        if len(quiz_results) >= 5:
            scores = [q.score for q in quiz_results]
            variance = sum((x - sum(scores)/len(scores))**2 for x in scores) / len(scores)
            # Lower variance = higher consistency score
            consistency_score = max(0, 20 - (variance / 50))
        
        overall = quiz_score + completion_score + consistency_score
        
        # Grade
        if overall >= 85:
            grade = "Xuất sắc"
            color = "green"
        elif overall >= 70:
            grade = "Khá"
            color = "blue"
        elif overall >= 50:
            grade = "Trung bình"
            color = "orange"
        else:
            grade = "Cần cải thiện"
            color = "red"
        
        return {
            "overall_score": round(overall, 2),
            "quiz_component": round(quiz_score, 2),
            "completion_component": round(completion_score, 2),
            "consistency_component": round(consistency_score, 2),
            "grade": grade,
            "color": color
        }

    def _serialize_quiz_result_detail(self, quiz_result: QuizResult) -> Dict:
        lesson = self.db.query(Lesson).filter(Lesson.id == quiz_result.lesson_id).first()
        course = self.db.query(Course).filter(Course.id == lesson.course_id).first() if lesson else None

        return {
            "quiz_result_id": quiz_result.id,
            "lesson_id": quiz_result.lesson_id,
            "lesson_title": lesson.title if lesson else "Bài học không xác định",
            "course_id": course.id if course else None,
            "course_name": course.course_name if course else "Khóa học không xác định",
            "score": round(quiz_result.score or 0, 2),
            "correct_answers": quiz_result.correct_answers,
            "total_questions": quiz_result.total_questions,
            "completed_at": quiz_result.completed_at.isoformat() if quiz_result.completed_at else None
        }

    def _serialize_enrollment_detail(self, enrollment: Enrollment) -> Dict:
        course = self.db.query(Course).filter(Course.id == enrollment.course_id).first()
        return {
            "course_id": enrollment.course_id,
            "course_name": course.course_name if course else "Khóa học không xác định",
            "progress": round(enrollment.progress or 0, 2),
            "completed_lessons": enrollment.completed_lessons or 0,
            "status": enrollment.status.value if enrollment.status else None
        }

    def _build_dashboard_summary(
        self,
        performance: Dict,
        strengths: List[Dict],
        weaknesses: List[Dict],
        recommendations: List[Dict]
    ) -> Dict:
        total_courses = performance.get("total_courses", 0)
        completed_courses = performance.get("completed_courses", 0)
        average_quiz_score = performance.get("average_quiz_score", 0)
        passed_quizzes = performance.get("passed_quizzes", 0)
        total_quizzes = performance.get("total_quizzes", 0)

        if total_courses == 0:
            headline = "Bạn chưa có dữ liệu học tập để AI phân tích sâu."
            summary = "Hãy bắt đầu ít nhất một khóa học và hoàn thành vài quiz để hệ thống chỉ ra điểm mạnh, điểm yếu cụ thể."
        else:
            headline = f"Bạn đã học {total_courses} môn, hoàn thành {completed_courses} môn và đạt trung bình {average_quiz_score:.1f}% ở các bài quiz."
            if weaknesses:
                summary = f"AI thấy bạn đang cần ưu tiên cải thiện: {weaknesses[0]['category'].lower()}."
            elif strengths:
                summary = f"AI đánh giá nổi bật nhất của bạn hiện tại là: {strengths[0]['category'].lower()}."
            else:
                summary = "Dữ liệu hiện tại ở mức trung tính, chưa có điểm mạnh hoặc điểm yếu quá rõ rệt."

        next_step = recommendations[0]["title"] if recommendations else "Tiếp tục duy trì nhịp học hiện tại"

        return {
            "headline": headline,
            "summary": summary,
            "next_step": next_step,
            "total_courses": total_courses,
            "completed_courses": completed_courses,
            "average_quiz_score": average_quiz_score,
            "passed_quizzes": passed_quizzes,
            "total_quizzes": total_quizzes
        }

    def _build_student_snapshot(self, analysis: Dict) -> Dict:
        performance = analysis.get("performance_summary", {})
        score_info = analysis.get("overall_score", {})
        recommendations = analysis.get("recommendations", [])
        strengths = analysis.get("strengths", [])
        weaknesses = analysis.get("weaknesses", [])

        return {
            "name": analysis.get("student_info", {}).get("name") or "bạn",
            "grade": score_info.get("grade", "Chưa đánh giá"),
            "overall_score": score_info.get("overall_score", 0),
            "average_quiz_score": performance.get("average_quiz_score", 0),
            "completed_courses": performance.get("completed_courses", 0),
            "in_progress_courses": performance.get("in_progress_courses", 0),
            "total_study_hours": performance.get("total_study_hours", 0),
            "strengths": strengths,
            "weaknesses": weaknesses,
            "top_recommendation": recommendations[0] if recommendations else None,
        }

    def _question_type(self, question: Optional[str]) -> str:
        normalized = (question or "").strip().lower()
        if not normalized:
            return "general"

        if any(keyword in normalized for keyword in ["tuần", "học hiệu quả", "kế hoạch học", "study plan", "lịch học"]):
            return "weekly_plan"
        if any(keyword in normalized for keyword in ["ôn tập", "ôn thi", "review", "quiz", "củng cố"]):
            return "review_plan"
        if any(keyword in normalized for keyword in ["ưu tiên", "môn nào", "học gì trước", "nên học gì trước", "thứ tự", "khóa nào", "học thêm", "nên học", "đăng ký thêm"]):
            return "priority"
        if any(keyword in normalized for keyword in ["động lực", "mất động lực", "chán", "nản"]):
            return "motivation"
        return "general"

    def _general_response(self, snapshot: Dict) -> str:
        top_recommendation = snapshot.get("top_recommendation")
        opening = (
            f"Hiện tại {snapshot['name']} đang có kết quả học tập ở mức {snapshot['grade'].lower()} "
            f"với điểm tổng thể khoảng {snapshot['overall_score']}/100. "
            f"Điểm quiz trung bình là {snapshot['average_quiz_score']} và bạn đã hoàn thành {snapshot['completed_courses']} khóa học."
        )

        if top_recommendation:
            return (
                f"{opening} Gợi ý phù hợp nhất lúc này là {top_recommendation['title'].lower()}. "
                f"Bạn nên bắt đầu từ việc {top_recommendation['actions'][0].lower()}."
            )

        return f"{opening} Nếu muốn, tôi có thể tiếp tục gợi ý theo từng mục cụ thể như kế hoạch tuần, ôn tập ngắn hoặc thứ tự ưu tiên môn học."

    def _weekly_plan_response(self, snapshot: Dict) -> str:
        focus = "duy trì nhịp học ổn định" if not snapshot.get("weaknesses") else "củng cố phần còn yếu trước khi học thêm nội dung mới"
        return (
            f"Tuần này bạn nên tập trung vào {focus}. Tôi gợi ý một kế hoạch ngắn như sau. "
            f"Đầu tuần, dành một buổi để xem lại các bài đã học và ghi ra 2 đến 3 ý quan trọng của mỗi bài. "
            f"Giữa tuần, làm lại quiz hoặc bài luyện tập trong khoảng 45 đến 60 phút để kiểm tra mức nhớ bài. "
            f"Cuối tuần, chọn một nội dung khó nhất trong tuần để ôn lại thật kỹ và tự tóm tắt bằng lời của mình. "
            f"Với kết quả hiện tại của bạn, chỉ cần giữ đều 30 đến 60 phút mỗi ngày là đã hiệu quả hơn việc học dồn vào một buổi dài."
        )

    def _review_plan_response(self, snapshot: Dict) -> str:
        weak_area = snapshot["weaknesses"][0]["action"].lower() if snapshot.get("weaknesses") else "ưu tiên phần bài nào bạn thấy nhớ chưa chắc"
        return (
            f"Nếu bạn muốn ôn tập ngắn mà vẫn hiệu quả, hãy chia thành ba bước. "
            f"Bước đầu, xem lại nhanh lý thuyết trong 15 đến 20 phút và chỉ giữ lại các khái niệm chính. "
            f"Bước hai, làm lại một số câu quiz hoặc bài tập ngắn để kiểm tra phần nhớ bài. "
            f"Bước ba, ghi lại những câu sai hoặc phần còn lúng túng để ôn lại ngay trong ngày. "
            f"Trong trường hợp của bạn, nên {weak_area}."
        )

    def _priority_response(self, snapshot: Dict) -> str:
        if snapshot.get("weaknesses"):
            weak_area = snapshot["weaknesses"][0]["description"].lower()
            return (
                f"Thứ tự ưu tiên hợp lý lúc này là học trước phần đang ảnh hưởng trực tiếp đến kết quả của bạn. "
                f"Hiện tại điểm cần chú ý nhất là {weak_area}. Vì vậy bạn nên ưu tiên các môn hoặc nội dung đang còn dở, hoặc những phần có quiz chưa thật chắc. "
                f"Sau khi ổn định phần này, bạn mới nên mở rộng sang nội dung nâng cao."
            )

        return (
            f"Với kết quả hiện tại đang khá tốt, bạn nên ưu tiên theo thứ tự sau: hoàn thành những nội dung đang học dở trước, sau đó củng cố quiz để giữ mức điểm ổn định, rồi mới mở rộng sang khóa học nâng cao. "
            f"Cách này sẽ giúp tiến độ học không bị phân tán."
        )

    def _motivation_response(self, snapshot: Dict) -> str:
        return (
            f"Khi thấy mất động lực, bạn đừng cố ép mình học thật nhiều trong một lúc. Với kết quả hiện tại, điều quan trọng hơn là giữ nhịp đều. "
            f"Bạn có thể đặt mục tiêu rất nhỏ cho mỗi ngày, ví dụ hoàn thành một phần bài học hoặc một lượt quiz ngắn. "
            f"Sau mỗi buổi học, hãy tự ghi lại một việc bạn đã làm xong để thấy mình vẫn đang tiến lên. "
            f"Nếu cần, tôi có thể giúp bạn chia tiếp thành kế hoạch 3 ngày hoặc 7 ngày ngắn gọn hơn."
        )
    
    def get_ai_advice(self, user_id: int, question: str = None) -> str:
        """
        Tạo lời khuyên AI dựa trên hồ sơ sinh viên
        """
        analysis = self.analyze_student_profile(user_id)

        if analysis.get("error"):
            return "Hiện tại tôi chưa đọc được dữ liệu học tập của bạn. Bạn thử lại sau một lúc nữa."

        snapshot = self._build_student_snapshot(analysis)
        question_type = self._question_type(question)

        if question_type == "weekly_plan":
            return self._weekly_plan_response(snapshot)
        if question_type == "review_plan":
            return self._review_plan_response(snapshot)
        if question_type == "priority":
            return self._priority_response(snapshot)
        if question_type == "motivation":
            return self._motivation_response(snapshot)

        return self._general_response(snapshot)
