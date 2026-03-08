#!/usr/bin/env python
"""Summary of lessons and quizzes created"""

from app.database import SessionLocal
from app.models import Course, Lesson, Assessment, Question

db = SessionLocal()

courses = db.query(Course).all()
total_lessons = db.query(Lesson).count()
total_assessments = db.query(Assessment).count()
total_questions = db.query(Question).count()

print("=" * 70)
print("📊 LESSON & QUIZ SUMMARY")
print("=" * 70)
print(f"\nTotal Courses: {len(courses)}")
print(f"Total Lessons: {total_lessons}")
print(f"Total Quizzes: {total_assessments}")
print(f"Total Questions: {total_questions}")

print("\n" + "=" * 70)
print("COURSES WITH CONTENT:")
print("=" * 70)

for c in courses:
    lessons = db.query(Lesson).filter(Lesson.course_id == c.id).count()
    quizzes = db.query(Assessment).filter(Assessment.course_id == c.id).count()
    if lessons > 0:
        questions = db.query(Question).join(
            Assessment, Assessment.id == Question.assessment_id
        ).filter(Assessment.course_id == c.id).count()
        print(f"\n{c.course_code}: {c.course_name}")
        print(f"  Lessons: {lessons}")
        print(f"  Quizzes: {quizzes}")
        if quizzes > 0:
            print(f"  Questions: {questions}")

db.close()
