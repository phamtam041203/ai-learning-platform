"""Create missing courses from curriculum"""
from app.database import SessionLocal
from app.models.course import Course, CourseLevel
import json
from pathlib import Path

def main():
    db = SessionLocal()
    
    # Load curriculum
    curriculum_path = Path(__file__).parent / "app" / "data" / "curriculum_cnpm.json"
    curriculum = json.loads(curriculum_path.read_text(encoding="utf-8"))
    
    created = []
    skipped = []
    
    # Get all course codes from curriculum
    all_course_codes = set()
    for phase in curriculum.get("phases", []):
        all_course_codes.update(phase.get("required_courses", []))
        all_course_codes.update(phase.get("elective_courses", []))
    
    print(f"Found {len(all_course_codes)} course codes in curriculum")
    print(f"Codes: {sorted(all_course_codes)}\n")
    
    # Create missing courses
    for course_code in sorted(all_course_codes):
        existing = db.query(Course).filter(Course.course_code == course_code).first()
        if existing:
            skipped.append(course_code)
            continue
        
        # Get details from curriculum
        details = curriculum.get("course_details", {}).get(course_code, {})
        course_name = details.get("name", course_code)
        credit_hours = details.get("credit_hours", 3)
        
        # Create course
        new_course = Course(
            course_code=course_code,
            course_name=course_name,
            description=f"Course {course_code} - {course_name}",
            major="CNTT",
            specialization="CNPM",
            credit_hours=credit_hours,
            level=CourseLevel.BEGINNER,
            is_active=True
        )
        db.add(new_course)
        created.append(course_code)
        print(f"✓ Created: {course_code} - {course_name}")
    
    db.commit()
    
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Created: {len(created)} courses")
    print(f"  Skipped: {len(skipped)} courses (already exist)")
    print(f"  Total: {len(all_course_codes)} courses")
    print(f"{'='*60}")
    
    if created:
        print(f"\nCreated courses: {', '.join(created)}")
    if skipped:
        print(f"Skipped courses: {', '.join(skipped)}")
    
    db.close()

if __name__ == "__main__":
    main()
