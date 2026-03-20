from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.models import User, StudentProfile, Course, Enrollment

engine = create_engine(settings.DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

try:
    # Check users
    print('=== USERS ===')
    users = session.query(User).all()
    for u in users[:5]:
        print(f'ID: {u.id}, Email: {u.email}, Role: {u.role}')

    # Check student profiles
    print('\n=== STUDENT PROFILES ===')
    profiles = session.query(StudentProfile).all()
    for p in profiles[:5]:
        user = session.query(User).filter(User.id == p.user_id).first()
        print(f'User: {user.email}, Specialization: {p.specialization}')

    # Check courses
    print('\n=== COURSES ===')
    courses = session.query(Course).all()
    print(f'Total courses: {len(courses)}')
    for c in courses[:3]:
        print(f'  - {c.id}: {c.course_name} ({c.specialization})')

    # Check enrollments
    print('\n=== ENROLLMENTS ===')
    enrollments = session.query(Enrollment).all()
    print(f'Total enrollments: {len(enrollments)}')
    for e in enrollments[:10]:
        student = session.query(StudentProfile).filter(StudentProfile.id == e.student_id).first()
        course = session.query(Course).filter(Course.id == e.course_id).first()
        user = session.query(User).filter(User.id == student.user_id).first() if student else None
        print(f'  - User: {user.email if user else "N/A"}, Course: {course.course_name if course else "N/A"}')

finally:
    session.close()
