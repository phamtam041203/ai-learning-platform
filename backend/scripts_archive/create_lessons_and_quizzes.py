#!/usr/bin/env python
"""
Create sample lessons and quizzes for specialization courses
"""
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base, SessionLocal
from app.core.config import settings
from app.models.course import Course, Lesson
from app.models.assessment import Assessment, Question, AssessmentType
from datetime import datetime, timedelta

# Create database engine
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True
)

def create_lessons_and_quizzes():
    """Create sample lessons and quizzes"""
    db = SessionLocal()
    
    try:
        # Get all active courses
        courses = db.query(Course).filter(Course.is_active == True).all()
        
        if not courses:
            print("❌ No courses found!")
            return
        
        print(f"📚 Found {len(courses)} courses")
        
        for course in courses:
            print(f"\n📖 Creating lessons for: {course.course_name}")
            
            # Create 5 lessons per course
            lessons_data = [
                {
                    "title": "Giới thiệu và Khái niệm cơ bản",
                    "description": "Tìm hiểu những khái niệm nền tảng về môn học",
                    "content": "Bài học này giới thiệu các khái niệm cơ bản mà bạn cần nắm vững để tiến tới các phần nâng cao hơn.",
                    "order": 1
                },
                {
                    "title": "Các nguyên tắc và lý thuyết",
                    "description": "Khám phá các nguyên tắc chính và lý thuyết đằng sau",
                    "content": "Tìm hiểu sâu hơn về các nguyên tắc khoa học và lý thuyết hỗ trợ cho lĩnh vực này.",
                    "order": 2
                },
                {
                    "title": "Ứng dụng thực tế",
                    "description": "Áp dụng kiến thức vào các tình huống thực tế",
                    "content": "Học cách áp dụng những gì bạn đã học vào các tình huống thực tế và dự án thực.",
                    "order": 3
                },
                {
                    "title": "Công cụ và Kỹ thuật",
                    "description": "Thành thạo các công cụ và kỹ thuật chuyên môn",
                    "content": "Làm quen với các công cụ chuyên dụng và kỹ thuật được sử dụng trong ngành.",
                    "order": 4
                },
                {
                    "title": "Dự án cuối khoá",
                    "description": "Tổng hợp kiến thức qua dự án toàn diện",
                    "content": "Hoàn thành một dự án lớn kết hợp tất cả những gì bạn đã học từ đầu khoá.",
                    "order": 5
                }
            ]
            
            for lesson_data in lessons_data:
                # Check if lesson already exists
                existing = db.query(Lesson).filter(
                    Lesson.course_id == course.id,
                    Lesson.title == lesson_data["title"]
                ).first()
                
                if existing:
                    print(f"  ✓ Lesson '{lesson_data['title']}' already exists")
                    continue
                
                lesson = Lesson(
                    course_id=course.id,
                    title=lesson_data["title"],
                    description=lesson_data["description"],
                    content=lesson_data["content"],
                    order=lesson_data["order"],
                    is_published=True
                )
                db.add(lesson)
                db.flush()
                print(f"  ✓ Created lesson: {lesson_data['title']}")
                
                # Create quiz for this lesson
                quiz_title = f"Quiz: {lesson_data['title']}"
                existing_quiz = db.query(Assessment).filter(
                    Assessment.course_id == course.id,
                    Assessment.title == quiz_title
                ).first()
                
                if existing_quiz:
                    print(f"    ✓ Quiz already exists")
                    continue
                
                assessment = Assessment(
                    course_id=course.id,
                    title=quiz_title,
                    description=f"Kiểm tra kiến thức về: {lesson_data['title']}",
                    instructions="Trả lời tất cả các câu hỏi dưới đây. Bạn có 15 phút để hoàn thành bài quiz này.",
                    assessment_type=AssessmentType.QUIZ,
                    max_score=10.0,
                    passing_score=7.0,
                    duration_minutes=15,
                    is_published=True,
                    due_date=datetime.utcnow() + timedelta(days=30)
                )
                db.add(assessment)
                db.flush()
                print(f"    ✓ Created assessment: {quiz_title}")
                
                # Create 5 questions for each quiz
                questions_data = [
                    {
                        "text": f"Câu 1: Khái niệm chính của '{lesson_data['title']}' là gì?",
                        "options": {
                            "a": "Đáp án A: Định nghĩa đúng",
                            "b": "Đáp án B: Định nghĩa sai",
                            "c": "Đáp án C: Định nghĩa sai",
                            "d": "Đáp án D: Định nghĩa sai"
                        },
                        "correct": "a",
                        "explanation": "Đây là khái niệm đúng dựa trên nội dung bài học."
                    },
                    {
                        "text": f"Câu 2: Ứng dụng nào là ví dụ thực tế của '{lesson_data['title']}'?",
                        "options": {
                            "a": "Ứng dụng A không phù hợp",
                            "b": "Ứng dụng B là chính xác",
                            "c": "Ứng dụng C không phù hợp",
                            "d": "Ứng dụng D không phù hợp"
                        },
                        "correct": "b",
                        "explanation": "Ứng dụng B là ví dụ đúng được đề cập trong bài học."
                    },
                    {
                        "text": f"Câu 3: Bước đầu tiên trong '{lesson_data['title']}' là gì?",
                        "options": {
                            "a": "Bước A là đúng",
                            "b": "Bước B không đúng",
                            "c": "Bước C không đúng",
                            "d": "Bước D không đúng"
                        },
                        "correct": "a",
                        "explanation": "Bước A là bước khởi đầu được giải thích chi tiết trong bài học."
                    },
                    {
                        "text": f"Câu 4: Lợi ích chính của '{lesson_data['title']}' là gì?",
                        "options": {
                            "a": "Lợi ích A là đúng",
                            "b": "Lợi ích B không phù hợp",
                            "c": "Lợi ích C không phù hợp",
                            "d": "Lợi ích D không phù hợp"
                        },
                        "correct": "a",
                        "explanation": "Lợi ích A được nhấn mạnh trong bài học này."
                    },
                    {
                        "text": f"Câu 5: Thách thức khi áp dụng '{lesson_data['title']}' là gì?",
                        "options": {
                            "a": "Thách thức A không phải là vấn đề",
                            "b": "Thách thức B là vấn đề chính",
                            "c": "Thách thức C không phải là vấn đề",
                            "d": "Thách thức D không phải là vấn đề"
                        },
                        "correct": "b",
                        "explanation": "Thách thức B là vấn đề chính được thảo luận trong bài học."
                    }
                ]
                
                for idx, q_data in enumerate(questions_data, 1):
                    question = Question(
                        assessment_id=assessment.id,
                        question_text=q_data["text"],
                        question_type="multiple_choice",
                        option_a=q_data["options"]["a"],
                        option_b=q_data["options"]["b"],
                        option_c=q_data["options"]["c"],
                        option_d=q_data["options"]["d"],
                        correct_answer=q_data["correct"],
                        explanation=q_data["explanation"],
                        points=2.0,
                        order=idx
                    )
                    db.add(question)
                
                print(f"    ✓ Created 5 questions for quiz")
        
        # Commit all changes
        db.commit()
        print("\n✅ Successfully created lessons and quizzes!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    create_lessons_and_quizzes()
