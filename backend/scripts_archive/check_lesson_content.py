#!/usr/bin/env python
"""Check if lessons have actual content"""

from app.database import SessionLocal
from app.models import Lesson, Assessment, Question

db = SessionLocal()

# Check lessons
lessons = db.query(Lesson).limit(5).all()
print("=" * 70)
print("CHECKING LESSON CONTENT")
print("=" * 70)

for lesson in lessons:
    print(f"\nLesson: {lesson.title}")
    print(f"Content length: {len(lesson.content) if lesson.content else 0} chars")
    if lesson.content:
        print(f"Preview: {lesson.content[:100]}...")
    else:
        print("⚠️  NO CONTENT!")

# Check questions
print("\n" + "=" * 70)
print("CHECKING QUESTION CONTENT")
print("=" * 70)

questions = db.query(Question).limit(5).all()
for q in questions:
    print(f"\nQuestion: {q.question_text}")
    print(f"Options: A={q.option_a}, B={q.option_b}, C={q.option_c}, D={q.option_d}")
    if not q.question_text or "Khái niệm" in q.question_text:
        print("⚠️  Generic content detected!")

db.close()
