"""
Create test user for quiz testing
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models import User, StudentProfile, Enrollment, Course
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

db = SessionLocal()
try:
    # Check if test user exists
    test_user = db.query(User).filter(User.email == "quiztest@vanlanguni.vn").first()
    
    if test_user:
        print("✅ Test user already exists")
    else:
        # Create test user
        hashed_password = pwd_context.hash("123456")
        test_user = User(
            email="quiztest@vanlanguni.vn",
            hashed_password=hashed_password,
            full_name="Quiz Test User",
            role="student"
        )
        db.add(test_user)
        db.flush()
        
        # Create student profile
        student_profile = StudentProfile(
            user_id=test_user.id,
            student_id="2174802099999",
            major="CNTT",
            intake_year=2021
        )
        db.add(student_profile)
        db.flush()
        
        print("✅ Created test user")
    
    # Enroll in Web Development course
    course = db.query(Course).filter(Course.course_name.ilike("%web%")).first()
    if course:
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == test_user.id,
            Enrollment.course_id == course.id
        ).first()
        
        if not enrollment:
            enrollment = Enrollment(
                student_id=test_user.id,
                course_id=course.id,
                status="active",
                progress=0
            )
            db.add(enrollment)
            print(f"✅ Enrolled in course: {course.course_name}")
        else:
            print(f"✅ Already enrolled in: {course.course_name}")
    
    db.commit()
    
    print(f"\n📋 Test User Info:")
    print(f"   Email: quiztest@vanlanguni.vn")
    print(f"   Password: 123456")
    print(f"   User ID: {test_user.id}")
    
except Exception as e:
    print(f"❌ Error: {e}")
    db.rollback()
finally:
    db.close()
