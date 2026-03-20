"""Add sample enrollments for test students"""
from app.database import SessionLocal
from app.models.course import Course, Enrollment
from app.models.user import User, StudentProfile
from datetime import datetime

db = SessionLocal()

try:
    # Get test student
    user = db.query(User).filter(User.email == 'tam.2174802010372@vanlanguni.vn').first()
    if not user:
        print('❌ Student not found')
        exit(1)
    
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if not profile:
        print('❌ Student profile not found')
        exit(1)
    
    print(f'👤 Student: {user.email} (ID: {profile.id}, Spec: {profile.specialization})')
    
    # Get courses matching student's specialization
    spec = profile.specialization  # CNPM
    courses = db.query(Course).filter(Course.specialization == spec).all()
    print(f'📚 Found {len(courses)} courses for {spec}')
    
    # Enroll in first 2 courses
    enrolled = 0
    for course in courses[:2]:
        # Check if already enrolled
        existing = db.query(Enrollment).filter(
            Enrollment.student_id == profile.id,
            Enrollment.course_id == course.id
        ).first()
        
        if existing:
            print(f'   ℹ️  Already enrolled in {course.course_code}')
            continue
        
        # Create enrollment
        enrollment = Enrollment(
            student_id=profile.id,
            course_id=course.id,
            status='active'
        )
        db.add(enrollment)
        enrolled += 1
        print(f'   ✅ Enrolled in {course.course_code}: {course.course_name}')
    
    db.commit()
    print(f'\n✅ Total enrolled: {enrolled} courses')
    
finally:
    db.close()
