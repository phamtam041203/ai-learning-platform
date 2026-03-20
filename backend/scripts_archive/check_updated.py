#!/usr/bin/env python
"""Check updated lessons"""

from app.database import SessionLocal
from app.models import Lesson, Question, Course

db = SessionLocal()

# Check updated courses
courses_to_check = ["Nhập môn lập trình", "Cấu trúc dữ liệu và giải thuật", "Web Development với React"]

for course_name in courses_to_check:
    course = db.query(Course).filter(Course.course_name == course_name).first()
    
    if not course:
        print(f"❌ Course not found: {course_name}")
        continue
    
    lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
    
    print(f"\n{'=' * 70}")
    print(f"📚 {course_name}")
    print(f"{'=' * 70}")
    
    if lessons:
        for lesson in lessons[:2]:  # Show first 2 lessons
            print(f"\nLesson: {lesson.title}")
            print(f"Content length: {len(lesson.content) if lesson.content else 0} chars")
            if lesson.content and len(lesson.content) > 0:
                print(f"Preview: {lesson.content[:150]}...")
    else:
        print("No lessons found!")

db.close()
