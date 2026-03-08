from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.models import User, StudentProfile, Course, Enrollment

engine = create_engine(settings.DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

try:
    print('=== CURRENT LOGIN USER ===')
    # Email từ login: tam.2174802010372@vanlanguni.vn
    user = session.query(User).filter(User.email == 'tam.2174802010372@vanlanguni.vn').first()
    if user:
        print('User ID:', user.id, ', Email:', user.email)
        profile = session.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
        if profile:
            print('Profile ID:', profile.id, ', Specialization:', profile.specialization)
            
            # Check enrollments for this student
            enrollments = session.query(Enrollment).filter(Enrollment.student_id == profile.id).all()
            print('Total enrollments:', len(enrollments))
            for e in enrollments[:3]:
                course = session.query(Course).filter(Course.id == e.course_id).first()
                print('  - Course:', course.course_name if course else 'Not found')
        else:
            print('Profile not found for user')
    else:
        print('User not found')

finally:
    session.close()
