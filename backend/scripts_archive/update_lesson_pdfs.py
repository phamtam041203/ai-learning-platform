"""
Update lessons with PDF file names
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models import Lesson, Course

def update_lessons_with_pdf_files():
    db = SessionLocal()
    try:
        # Find Web Development course
        course = db.query(Course).filter(Course.course_name.ilike("%web%")).first()
        
        if not course:
            print("❌ Web Development course not found")
            return
        
        print(f"✅ Found course: {course.course_name}")
        
        # PDF file mapping
        pdf_files = [
            "Lecture 00 - Course Introduction.pdf",
            "Lecture 01 - HTMLJavaScript.pdf",
            "Lecture 02 - Getting Started with React.pdf",
            "Lecture 03 - React Components.pdf",
            "Lecture 04 - Handling Interactions.pdf",
            "Lecture 05 - Building React Applications.pdf",
            "Lecture 06 - Redux Fundamentals.pdf",
            "Lecture 07 - Angular Basics.pdf"
        ]
        
        # Get all lessons for this course, ordered by order field
        lessons = db.query(Lesson).filter(
            Lesson.course_id == course.id
        ).order_by(Lesson.order).all()
        
        print(f"\n📚 Found {len(lessons)} lessons")
        
        if len(lessons) != len(pdf_files):
            print(f"⚠️  Warning: Number of lessons ({len(lessons)}) doesn't match PDF files ({len(pdf_files)})")
        
        # Update each lesson with corresponding PDF file
        for i, lesson in enumerate(lessons):
            if i < len(pdf_files):
                lesson.pdf_file_name = pdf_files[i]
                print(f"  {i+1}. {lesson.title} -> {pdf_files[i]}")
            else:
                print(f"  {i+1}. {lesson.title} -> No PDF assigned")
        
        db.commit()
        print("\n✅ Successfully updated lessons with PDF file names!")
        
        # Verify
        print("\n🔍 Verification:")
        for lesson in lessons:
            print(f"  {lesson.title}: {lesson.pdf_file_name or 'No PDF'}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    update_lessons_with_pdf_files()
