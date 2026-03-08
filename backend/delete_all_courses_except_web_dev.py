"""Delete all courses except Web Development (CNPM101)"""
from app.database import SessionLocal
from app.models import Course, Enrollment, Lesson, Assessment, Material, LessonProgress

db = SessionLocal()

try:
    # Get Web Dev course
    web_dev = db.query(Course).filter(Course.course_code == 'CNPM101').first()
    
    if not web_dev:
        print("❌ Web Development course (CNPM101) not found!")
        exit(1)
    
    print(f"✅ Found Web Dev course: {web_dev.course_name}")
    
    # Delete all OTHER courses
    other_courses = db.query(Course).filter(Course.course_code != 'CNPM101').all()
    print(f"\n🗑️  Deleting {len(other_courses)} other courses...")
    
    for course in other_courses:
        print(f"   Deleting: {course.course_code} - {course.course_name}")
        
        # Cascades should handle this, but let's be explicit
        # Delete lesson progress
        lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
        for lesson in lessons:
            db.query(LessonProgress).filter(LessonProgress.lesson_id == lesson.id).delete()
        
        # Delete materials
        db.query(Material).filter(Material.course_id == course.id).delete()
        
        # Delete assessments
        db.query(Assessment).filter(Assessment.course_id == course.id).delete()
        
        # Delete lessons
        db.query(Lesson).filter(Lesson.course_id == course.id).delete()
        
        # Delete enrollments
        db.query(Enrollment).filter(Enrollment.course_id == course.id).delete()
        
        # Delete course
        db.delete(course)
    
    db.commit()
    
    # Verify
    remaining = db.query(Course).all()
    print(f"\n✅ Remaining courses: {len(remaining)}")
    for c in remaining:
        print(f"   - {c.course_code}: {c.course_name}")
    
    if len(remaining) == 1 and remaining[0].course_code == 'CNPM101':
        print("\n✅ SUCCESS! Only Web Development course remains!")
    else:
        print("\n⚠️  WARNING: More than Web Dev course remains!")
    
except Exception as e:
    print(f"❌ Error: {e}")
    db.rollback()
    import traceback
    traceback.print_exc()
finally:
    db.close()
