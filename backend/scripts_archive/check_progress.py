from app.database import SessionLocal
from app.models import LessonProgress, Lesson, User, Enrollment, Course, QuizResult

db = SessionLocal()

# Get user
users = db.query(User).filter(User.role == 'student').all()
print(f"Total students: {len(users)}")
for u in users[:3]:
    print(f"  - {u.email} (ID: {u.id})")

user = users[0] if users else None
if not user:
    print("User not found")
    exit()

print(f"✅ User: {user.email} (ID: {user.id})")

# Get enrollments
enrollments = db.query(Enrollment).filter(Enrollment.student_id == user.id).all()
print(f"\n📚 Enrollments: {len(enrollments)}")
for e in enrollments:
    course = db.query(Course).filter(Course.id == e.course_id).first()
    print(f"  - {course.course_name if course else 'Unknown'}")

# Check lesson progress
for enrollment in enrollments:
    course = db.query(Course).filter(Course.id == enrollment.course_id).first()
    if not course:
        continue
        
    print(f"\n📖 Course: {course.course_name}")
    
    # Total lessons
    total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
    print(f"  Total lessons: {total_lessons}")
    
    # Lesson progress
    lesson_progress = db.query(LessonProgress).filter(
        LessonProgress.student_id == user.id,
        LessonProgress.lesson_id.in_(
            db.query(Lesson.id).filter(Lesson.course_id == course.id)
        )
    ).all()
    print(f"  Lesson progress records: {len(lesson_progress)}")
    
    completed = sum(1 for lp in lesson_progress if lp.is_completed)
    print(f"  Completed: {completed}/{total_lessons}")
    
    if total_lessons > 0:
        progress = int((completed / total_lessons) * 100)
        print(f"  📊 Progress: {progress}%")
    
    # Check quiz results
    quiz_results = db.query(QuizResult).filter(
        QuizResult.student_id == user.id,
        QuizResult.lesson_id.in_(
            db.query(Lesson.id).filter(Lesson.course_id == course.id)
        )
    ).all()
    print(f"  Quiz results: {len(quiz_results)}")
    for qr in quiz_results[:3]:
        lesson = db.query(Lesson).filter(Lesson.id == qr.lesson_id).first()
        print(f"    - {lesson.title if lesson else 'Unknown'}: {qr.score}/{qr.total_questions} ({qr.percentage:.1f}%)")

db.close()
