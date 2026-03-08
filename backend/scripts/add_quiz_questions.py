"""Add sample questions to existing quizzes"""
from __future__ import annotations

from pathlib import Path
import sys

# Add backend to path
BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE_DIR))

from app.database import SessionLocal
from app.models.assessment import Assessment, Question, AssessmentType

db = SessionLocal()

# Get all quizzes without questions
quizzes = db.query(Assessment).filter(
    Assessment.assessment_type == AssessmentType.QUIZ
).all()

print(f"Found {len(quizzes)} quizzes")

for quiz in quizzes:
    # Check if quiz already has questions
    existing_questions = db.query(Question).filter(
        Question.assessment_id == quiz.id
    ).count()
    
    if existing_questions > 0:
        print(f"  Quiz {quiz.id} already has {existing_questions} questions, skipping")
        continue
    
    print(f"  Adding sample questions to Quiz {quiz.id}: {quiz.title[:40]}...")
    
    # Add 5 sample questions for each quiz
    sample_questions = [
        {
            "question_text": f"Câu hỏi 1: Nội dung chính của bài {quiz.title[:30]} là gì?",
            "option_a": "Đáp án A - Khái niệm cơ bản",
            "option_b": "Đáp án B - Ứng dụng thực tế",
            "option_c": "Đáp án C - Phương pháp giải quyết",
            "option_d": "Đáp án D - Tất cả các đáp án trên",
            "correct_answer": "d",
            "points": 2.0
        },
        {
            "question_text": f"Câu hỏi 2: Phương pháp nào được sử dụng trong bài học này?",
            "option_a": "Phương pháp phân tích",
            "option_b": "Phương pháp tổng hợp",
            "option_c": "Phương pháp so sánh",
            "option_d": "Phương pháp thực nghiệm",
            "correct_answer": "a",
            "points": 2.0
        },
        {
            "question_text": f"Câu hỏi 3: Kết quả mong đợi sau khi hoàn thành bài học là gì?",
            "option_a": "Hiểu được lý thuyết cơ bản",
            "option_b": "Áp dụng được vào thực tế",
            "option_c": "Phân tích được vấn đề",
            "option_d": "Cả A, B và C đều đúng",
            "correct_answer": "d",
            "points": 2.0
        },
        {
            "question_text": f"Câu hỏi 4: Điểm quan trọng nhất cần ghi nhớ là gì?",
            "option_a": "Định nghĩa và khái niệm",
            "option_b": "Công thức và quy tắc",
            "option_c": "Ví dụ minh họa",
            "option_d": "Bài tập thực hành",
            "correct_answer": "b",
            "points": 2.0
        },
        {
            "question_text": f"Câu hỏi 5: Bài học này liên quan đến chủ đề nào?",
            "option_a": "Chủ đề lý thuyết",
            "option_b": "Chủ đề thực hành",
            "option_c": "Chủ đề ứng dụng",
            "option_d": "Chủ đề nghiên cứu",
            "correct_answer": "c",
            "points": 2.0
        }
    ]
    
    for idx, q_data in enumerate(sample_questions, start=1):
        question = Question(
            assessment_id=quiz.id,
            question_text=q_data["question_text"],
            question_type="multiple_choice",
            option_a=q_data["option_a"],
            option_b=q_data["option_b"],
            option_c=q_data["option_c"],
            option_d=q_data["option_d"],
            correct_answer=q_data["correct_answer"],
            points=q_data["points"],
            order=idx
        )
        db.add(question)

db.commit()
print("✅ Sample questions added to all quizzes!")

# Verify
total_questions = db.query(Question).count()
print(f"Total questions in database: {total_questions}")

db.close()
