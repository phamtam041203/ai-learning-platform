"""Check database status - courses and enrollments"""
from app.database import SessionLocal
from app.models.course import Course, Enrollment
from app.models.user import User, StudentProfile

db = SessionLocal()

try:
    # Check courses
    courses = db.query(Course).all()
    print(f'\n📚 COURSES: {len(courses)} total')
    if courses:
        print('   First 5 courses:')
        for c in courses[:5]:
            print(f'     - {c.course_code}: {c.course_name} (Specialization: {c.specialization})')
    
    # Check students
    students = db.query(StudentProfile).all()
    print(f'\n👥 STUDENTS: {len(students)} total')
    if students:
        print('   First 5 students:')
        for s in students[:5]:
            user = db.query(User).filter(User.id == s.user_id).first()
            enrollments = db.query(Enrollment).filter(Enrollment.student_id == s.id).count()
            print(f'     - {user.email} (Specialization: {s.specialization}, Enrollments: {enrollments})')
    
    # Check enrollments
    enrollments = db.query(Enrollment).all()
    print(f'\n📝 ENROLLMENTS: {len(enrollments)} total')
    if enrollments:
        print('   First 10 enrollments:')
        for e in enrollments[:10]:
            student = db.query(StudentProfile).filter(StudentProfile.id == e.student_id).first()
            course = db.query(Course).filter(Course.id == e.course_id).first()
            user = db.query(User).filter(User.id == student.user_id).first()
            print(f'     - {user.email} → {course.course_code} ({course.specialization})')
    
finally:
    db.close()
