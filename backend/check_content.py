#!/usr/bin/env python
"""Check which courses need content"""

from app.database import SessionLocal
from app.models import Course, Lesson

db = SessionLocal()

courses = db.query(Course).all()

print("Courses without lessons:")
print("=" * 60)

count = 0
for c in courses:
    lessons = db.query(Lesson).filter(Lesson.course_id == c.id).count()
    if lessons == 0:
        print(f"❌ {c.course_code}: {c.course_name}")
        count += 1

print(f"\nTotal: {count} courses need content")
db.close()
