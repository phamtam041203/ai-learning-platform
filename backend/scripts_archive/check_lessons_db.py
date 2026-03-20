"""Check lessons in database"""
from app.db.database import SessionLocal
from app.models.course import Course, Lesson, Assessment

db = SessionLocal()

print("=== Sample Lessons ===")
lessons = db.query(Lesson).limit(10).all()
for l in lessons:
    print(f"ID: {l.id}, Course: {l.course_id}, Title: {l.title[:40]}, PDF: {l.pdf_file}")

print("\n=== Sample Assessments ===")
assessments = db.query(Assessment).limit(5).all()
for a in assessments:
    print(f"ID: {a.id}, Course: {a.course_id}, Title: {a.title}")
    # Check all attributes
    for attr in ['file_path', 'pdf_file', 'quiz_file']:
        if hasattr(a, attr):
            print(f"  {attr}: {getattr(a, attr)}")

print("\n=== Courses with lessons count ===")
courses = db.query(Course).all()
for c in courses[:10]:
    lesson_count = db.query(Lesson).filter(Lesson.course_id == c.id).count()
    quiz_count = db.query(Assessment).filter(Assessment.course_id == c.id).count()
    print(f"{c.code} (ID: {c.id}): {lesson_count} lessons, {quiz_count} quizzes")

db.close()
