#!/usr/bin/env python
"""Create a test student without specialization"""
from app.database import SessionLocal
from app.models import User, StudentProfile
from app.utils.security import get_password_hash
from app.api.auth import generate_student_id

db = SessionLocal()

try:
    # Check if user already exists
    user = db.query(User).filter(User.email == 'test.nospec@vanlanguni.vn').first()
    
    if user:
        print(f"❌ User already exists: test.nospec@vanlanguni.vn")
        db.close()
        exit(1)
    
    # Create new user
    user = User(
        email='test.nospec@vanlanguni.vn',
        hashed_password=get_password_hash('123456'),
        full_name='Sinh Viên Test Không Chuyên Ngành',
        role='student',
        is_active=True
    )
    db.add(user)
    db.flush()
    
    # Generate student ID
    student_id = generate_student_id(db, 25)
    
    # Create profile WITHOUT specialization (set to None or empty)
    profile = StudentProfile(
        user_id=user.id,
        student_id=student_id,
        major='Công nghệ thông tin',
        specialization=None,  # ⭐ NO SPECIALIZATION - This will trigger modal on login
        class_name='CNTT-K25',
        intake_year=25,
        phone=None
    )
    db.add(profile)
    db.commit()
    
    print("✅ Created test student without specialization:")
    print(f"   Email: test.nospec@vanlanguni.vn")
    print(f"   Password: 123456")
    print(f"   Student ID: {student_id}")
    print(f"   Specialization: {profile.specialization} (None - will show modal on login)")
    
except Exception as e:
    print(f"❌ Error: {e}")
    db.rollback()
finally:
    db.close()
