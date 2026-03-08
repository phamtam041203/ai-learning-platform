#!/usr/bin/env python
"""Populate sample courses for testing"""
from app.database import SessionLocal
from app.models import Course, CourseLevel

db = SessionLocal()

try:
    # Check if courses already exist
    existing_count = db.query(Course).count()
    print(f'📚 Found {existing_count} existing courses')
    
    if existing_count > 0:
        print('✅ Courses already exist, skipping sample data creation')
    else:
        print('📝 Creating sample courses...\n')
        
        # Sample courses for CNPM specialization
        courses_data = [
            # CNPM (Chuyên ngành Phát triển phần mềm)
            {
                'course_code': 'CNPM001',
                'course_name': 'Web Development with React',
                'major': 'CNTT',
                'specialization': 'CNPM',
                'level': CourseLevel.BEGINNER,
                'credit_hours': 3,
                'duration_weeks': 12,
                'description': 'Learn modern web development with React and JavaScript'
            },
            {
                'course_code': 'CNPM002',
                'course_name': 'Backend Development with Python',
                'major': 'CNTT',
                'specialization': 'CNPM',
                'level': CourseLevel.INTERMEDIATE,
                'credit_hours': 3,
                'duration_weeks': 14,
                'description': 'Master backend development using Python and FastAPI'
            },
            {
                'course_code': 'CNPM003',
                'course_name': 'Database Design & SQL',
                'major': 'CNTT',
                'specialization': 'CNPM',
                'level': CourseLevel.BEGINNER,
                'credit_hours': 2,
                'duration_weeks': 10,
                'description': 'Learn database design principles and SQL queries'
            },
            # CNDL (Chuyên ngành Dữ liệu lớn)
            {
                'course_code': 'CNDL001',
                'course_name': 'Big Data Fundamentals',
                'major': 'CNTT',
                'specialization': 'CNDL',
                'level': CourseLevel.INTERMEDIATE,
                'credit_hours': 3,
                'duration_weeks': 12,
                'description': 'Introduction to big data technologies and concepts'
            },
            {
                'course_code': 'CNDL002',
                'course_name': 'Apache Spark for Data Processing',
                'major': 'CNTT',
                'specialization': 'CNDL',
                'level': CourseLevel.ADVANCED,
                'credit_hours': 3,
                'duration_weeks': 14,
                'description': 'Learn distributed data processing with Apache Spark'
            },
            # ANM (Chuyên ngành An toàn mạng)
            {
                'course_code': 'ANM001',
                'course_name': 'Cybersecurity Fundamentals',
                'major': 'CNTT',
                'specialization': 'ANM',
                'level': CourseLevel.BEGINNER,
                'credit_hours': 3,
                'duration_weeks': 12,
                'description': 'Learn the basics of cybersecurity and network protection'
            },
            {
                'course_code': 'ANM002',
                'course_name': 'Cryptography & Encryption',
                'major': 'CNTT',
                'specialization': 'ANM',
                'level': CourseLevel.INTERMEDIATE,
                'credit_hours': 3,
                'duration_weeks': 13,
                'description': 'Master cryptographic techniques and encryption methods'
            },
        ]
        
        courses = [Course(**data) for data in courses_data]
        db.add_all(courses)
        db.commit()
        
        print(f'✅ Created {len(courses)} sample courses')
        for course in courses:
            print(f'  - {course.course_code}: {course.course_name} ({course.specialization})')
            
except Exception as e:
    db.rollback()
    print(f'❌ Error: {e}')
    import traceback
    traceback.print_exc()
finally:
    db.close()
