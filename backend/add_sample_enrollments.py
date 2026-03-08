from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.models import User, StudentProfile, Course, Enrollment, EnrollmentStatus

engine = create_engine(settings.DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

try:
    # Get login user
    user = session.query(User).filter(User.email == 'tam.2174802010372@vanlanguni.vn').first()
    if user:
        print('User ID:', user.id, ', Email:', user.email)
        profile = session.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
        if profile:
            print('Profile ID:', profile.id, ', Specialization:', profile.specialization)
            
            # Get CNPM courses (first 5)
            courses = session.query(Course).filter(
                Course.specialization == 'CNPM'
            ).limit(5).all()
            
            print('Found', len(courses), 'CNPM courses')
            
            # Check existing enrollments
            existing = session.query(Enrollment).filter(Enrollment.student_id == profile.id).all()
            print('Existing enrollments:', len(existing))
            
            # Add enrollments for first 3 courses if not already enrolled
            for course in courses[:3]:
                existing_enrollment = session.query(Enrollment).filter(
                    Enrollment.student_id == profile.id,
                    Enrollment.course_id == course.id
                ).first()
                
                if not existing_enrollment:
                    enrollment = Enrollment(
                        student_id=profile.id,
                        course_id=course.id,
                        status=EnrollmentStatus.ACTIVE
                    )
                    session.add(enrollment)
                    print('Added enrollment for:', course.course_name)
                else:
                    print('Already enrolled in:', course.course_name)
            
            session.commit()
            print('Done!')
        else:
            print('Profile not found')
    else:
        print('User not found')

except Exception as e:
    print('Error:', str(e))
    session.rollback()
finally:
    session.close()
