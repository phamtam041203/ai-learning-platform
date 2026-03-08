"""Check quiz data matches courses"""
import sys
sys.path.insert(0, '.')

from app.database import SessionLocal
from app.models import Course, Lesson
from app.models.assessment import Assessment, Question

db = SessionLocal()

print("=" * 60)
print("CHECKING QUIZ DATA")
print("=" * 60)

# Get all quizzes
quizzes = db.query(Assessment).filter(Assessment.assessment_type == 'quiz').all()
print(f"\nTotal quizzes: {len(quizzes)}")

# Group by course
courses_with_quizzes = {}
for quiz in quizzes:
    course = db.query(Course).filter(Course.id == quiz.course_id).first()
    if course:
        if course.course_code not in courses_with_quizzes:
            courses_with_quizzes[course.course_code] = {
                'course_name': course.course_name,
                'quizzes': []
            }
        courses_with_quizzes[course.course_code]['quizzes'].append(quiz)

print(f"\nCourses with quizzes: {len(courses_with_quizzes)}")

# Check each course
for code, data in courses_with_quizzes.items():
    print(f"\n{'='*50}")
    print(f"Course: {code} - {data['course_name']}")
    print(f"Number of quizzes: {len(data['quizzes'])}")
    
    for quiz in data['quizzes'][:3]:  # Show first 3 quizzes per course
        questions = db.query(Question).filter(Question.assessment_id == quiz.id).limit(2).all()
        print(f"\n  Quiz: {quiz.title}")
        print(f"  Questions: {db.query(Question).filter(Question.assessment_id == quiz.id).count()}")
        for q in questions:
            print(f"    - {q.question_text[:70]}...")

# Check lessons and their quizzes
print("\n" + "=" * 60)
print("CHECKING LESSONS WITH QUIZZES")
print("=" * 60)

lessons = db.query(Lesson).all()
print(f"\nTotal lessons: {len(lessons)}")

for lesson in lessons[:10]:
    course = db.query(Course).filter(Course.id == lesson.course_id).first()
    # Find quiz by matching lesson order with quiz title
    quiz = db.query(Assessment).filter(
        Assessment.course_id == lesson.course_id,
        Assessment.assessment_type == 'quiz',
        Assessment.title.contains(f"Bài {lesson.order}")
    ).first()
    
    if quiz:
        q_count = db.query(Question).filter(Question.assessment_id == quiz.id).count()
        print(f"\nLesson {lesson.order}: {lesson.title[:40]}...")
        print(f"  Course: {course.course_code if course else 'N/A'}")
        print(f"  Quiz: {quiz.title} ({q_count} questions)")

db.close()
print("\n✅ Check complete!")
