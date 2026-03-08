#!/usr/bin/env python
"""Check what lesson content is in the database and API should return"""

from app.database import SessionLocal
from app.models import Course, Lesson

db = SessionLocal()

course = db.query(Course).filter(Course.course_name == "Nhập môn lập trình").first()

if course:
    lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
    
    print("=" * 70)
    print(f"📚 {course.course_name}")
    print("=" * 70)
    print(f"Total lessons: {len(lessons)}\n")
    
    for i, lesson in enumerate(lessons, 1):
        print(f"{i}. {lesson.title}")
        print(f"   Content length: {len(lesson.content) if lesson.content else 0}")
        if lesson.content:
            print(f"   Preview: {lesson.content[:80]}...")
        print()
else:
    print("Course not found")

db.close()
