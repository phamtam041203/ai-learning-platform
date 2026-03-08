from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.models import Course

engine = create_engine(settings.DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

try:
    print('=== CHECKING COURSES ===')
    
    # Get CNPM courses
    cnpm_courses = session.query(Course).filter(Course.specialization == 'CNPM').all()
    print(f'Total CNPM courses: {len(cnpm_courses)}')
    
    # Check is_active status
    for course in cnpm_courses[:5]:
        print(f'  - {course.course_name}: is_active={course.is_active}')
    
    # Count active courses
    active_courses = session.query(Course).filter(
        Course.specialization == 'CNPM',
        Course.is_active == True
    ).all()
    print(f'\nActive CNPM courses: {len(active_courses)}')

finally:
    session.close()
