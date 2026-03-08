from app.database import SessionLocal
from app.models import Enrollment, Course, StudentProfile, User

db = SessionLocal()

# Lấy student test
user = db.query(User).filter(User.email == 'tam.2174802010372@vanlanguni.vn').first()
if user:
    student = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if student:
        print(f"👤 Student: {user.full_name} ({user.email})")
        print(f"   Specialization: {student.specialization}\n")
        
        # Lấy enrollments của student
        enrollments = db.query(Enrollment).filter(Enrollment.student_id == user.id).all()
        print(f"📚 Enrolled courses ({len(enrollments)}):")
        for e in enrollments:
            course = db.query(Course).filter(Course.id == e.course_id).first()
            print(f"  - {course.course_code}: {course.course_name}")
        
        # Lấy tất cả courses theo specialization
        print(f"\n🎯 All courses with specialization {student.specialization}:")
        all_courses = db.query(Course).filter(Course.specialization == student.specialization).all()
        for c in all_courses:
            enrolled = any(e.course_id == c.id for e in enrollments)
            status = "✓ ENROLLED" if enrolled else "○ AVAILABLE"
            print(f"  {status} - {c.course_code}: {c.course_name}")
    else:
        print("No student profile found")
else:
    print("No user found with email tam.2174802010372@vanlanguni.vn")

db.close()
