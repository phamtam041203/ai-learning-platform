"""
Test script to verify lesson progress updates after quiz submission
"""
import sys
from pathlib import Path

# Add backend directory to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import User, Course, Lesson, LessonProgress, Enrollment

def test_progress():
    db = SessionLocal()
    try:
        # Get a student
        student = db.query(User).filter(User.role == 'student').first()
        if not student:
            print("❌ No student found")
            return
        
        print(f"✅ Student: {student.email} (ID: {student.id})")
        
        # Get enrolled courses
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == student.id
        ).all()
        
        if not enrollments:
            print("❌ Student has no enrollments")
            return
        
        print(f"📚 Enrollments: {len(enrollments)}")
        
        for enrollment in enrollments:
            course = db.query(Course).filter(Course.id == enrollment.course_id).first()
            if not course:
                continue
            
            course_name = getattr(course, 'title', None) or getattr(course, 'name', f'Course {course.id}')
            print(f"\n📖 Course: {course_name}")
            
            # Get total lessons
            total_lessons = db.query(Lesson).filter(Lesson.course_id == course.id).count()
            print(f"  Total lessons: {total_lessons}")
            
            # Get lesson progress records
            progress_records = db.query(LessonProgress).filter(
                LessonProgress.student_id == student.id,
                LessonProgress.lesson_id.in_(
                    db.query(Lesson.id).filter(Lesson.course_id == course.id)
                )
            ).all()
            
            print(f"  Lesson progress records: {len(progress_records)}")
            
            # Count completed lessons
            completed = sum(1 for p in progress_records if p.is_completed)
            print(f"  Completed: {completed}/{total_lessons}")
            
            # Calculate progress
            progress = int((completed / total_lessons) * 100) if total_lessons > 0 else 0
            print(f"  📊 Progress: {progress}%")
            
            # Show details of each progress record
            if progress_records:
                print("\n  Progress details:")
                for p in progress_records:
                    lesson = db.query(Lesson).filter(Lesson.id == p.lesson_id).first()
                    status = "✅ Completed" if p.is_completed else "⏳ In Progress"
                    completed_at = p.completed_at.strftime("%Y-%m-%d %H:%M") if p.completed_at else "N/A"
                    print(f"    - {lesson.title if lesson else 'Unknown'}: {status} (at {completed_at})")
        
        print("\n" + "="*50)
        print("✅ Test completed successfully!")
        print("\n📝 Next steps:")
        print("1. Go to http://localhost:3000/student/courses")
        print("2. Complete a quiz (score >= 70%)")
        print("3. Run this script again to see progress updated")
        print("4. Refresh the courses page to see the progress bar update")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    test_progress()
