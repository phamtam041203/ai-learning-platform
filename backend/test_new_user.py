from app.database import SessionLocal
from app.models import User, StudentProfile, Enrollment, Course
from app.utils.security import get_password_hash
from datetime import datetime

db = SessionLocal()

# Tạo tài khoản mới
new_user = User(
    email='testnew123@vanlanguni.vn',
    hashed_password=get_password_hash('Test@123456'),
    full_name='Test New User',
    role='student',
    is_active=True,
    is_verified=True
)
db.add(new_user)
db.flush()

# Tạo profile
new_profile = StudentProfile(
    user_id=new_user.id,
    student_id='STU999999',
    specialization='CNPM',
    phone='0123456789',
    address='Test Address'
)
db.add(new_profile)
db.commit()

print(f"✅ Created new user:")
print(f"   Email: {new_user.email}")
print(f"   ID: {new_user.id}")
print(f"   Profile ID: {new_profile.id}")

# Kiểm tra enrollments của tài khoản mới
enrollments = db.query(Enrollment).filter(Enrollment.student_id == new_user.id).all()
print(f"\n📚 New user enrollments: {len(enrollments)}")
for e in enrollments:
    course = db.query(Course).filter(Course.id == e.course_id).first()
    print(f"   - {course.course_code}: {course.course_name}")

if len(enrollments) > 0:
    print("\n⚠️  ISSUE: New user has automatic enrollments!")
else:
    print("\n✅ New user has NO enrollments (as expected)")

db.close()
