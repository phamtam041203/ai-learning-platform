#!/usr/bin/env python
"""
Create courses, lessons, and quizzes for each specialization
CNPM, CNDL, ANM
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Course, Lesson, CourseLevel
from datetime import datetime

# Dữ liệu khóa học cho mỗi chuyên ngành
SPECIALIZATION_DATA = {
    'CNPM': {
        'name': 'Chuyên ngành Phát triển phần mềm',
        'courses': [
            {
                'code': 'CNPM101',
                'name': 'Web Development với React',
                'description': 'Học cách xây dựng ứng dụng web hiện đại với React.js',
                'level': 'beginner',
                'credit_hours': 3,
                'duration_weeks': 12
            },
            {
                'code': 'CNPM102',
                'name': 'Backend Development với Python/FastAPI',
                'description': 'Phát triển API backend với Python và FastAPI',
                'level': 'intermediate',
                'credit_hours': 4,
                'duration_weeks': 14
            },
            {
                'code': 'CNPM103',
                'name': 'Database Design & SQL',
                'description': 'Thiết kế cơ sở dữ liệu quan hệ và viết SQL nâng cao',
                'level': 'intermediate',
                'credit_hours': 3,
                'duration_weeks': 10
            },
            {
                'code': 'CNPM104',
                'name': 'Mobile Development với React Native',
                'description': 'Xây dựng ứng dụng di động với React Native',
                'level': 'advanced',
                'credit_hours': 3,
                'duration_weeks': 12
            }
        ]
    },
    'CNDL': {
        'name': 'Chuyên ngành Dữ liệu lớn',
        'courses': [
            {
                'code': 'CNDL101',
                'name': 'Big Data Fundamentals',
                'description': 'Nền tảng về dữ liệu lớn, HDFS, và MapReduce',
                'level': 'beginner',
                'credit_hours': 3,
                'duration_weeks': 12
            },
            {
                'code': 'CNDL102',
                'name': 'Apache Spark for Data Processing',
                'description': 'Xử lý dữ liệu phân tán với Apache Spark',
                'level': 'intermediate',
                'credit_hours': 4,
                'duration_weeks': 14
            },
            {
                'code': 'CNDL103',
                'name': 'Data Analytics & Business Intelligence',
                'description': 'Phân tích dữ liệu và tạo báo cáo BI',
                'level': 'intermediate',
                'credit_hours': 3,
                'duration_weeks': 11
            },
            {
                'code': 'CNDL104',
                'name': 'Machine Learning for Big Data',
                'description': 'Áp dụng Machine Learning trên tập dữ liệu lớn',
                'level': 'advanced',
                'credit_hours': 4,
                'duration_weeks': 13
            }
        ]
    },
    'ANM': {
        'name': 'Chuyên ngành An toàn mạng',
        'courses': [
            {
                'code': 'ANM101',
                'name': 'Cybersecurity Fundamentals',
                'description': 'Kiến thức cơ bản về an toàn thông tin và mạng',
                'level': 'beginner',
                'credit_hours': 3,
                'duration_weeks': 12
            },
            {
                'code': 'ANM102',
                'name': 'Cryptography & Encryption',
                'description': 'Mật mã học và các phương pháp mã hóa',
                'level': 'intermediate',
                'credit_hours': 3,
                'duration_weeks': 12
            },
            {
                'code': 'ANM103',
                'name': 'Network Security & Firewalls',
                'description': 'Bảo mật mạng, tường lửa, và IDS/IPS',
                'level': 'intermediate',
                'credit_hours': 3,
                'duration_weeks': 11
            },
            {
                'code': 'ANM104',
                'name': 'Penetration Testing & Ethical Hacking',
                'description': 'Kiểm thử bảo mật và kỹ thuật hacker đạo đức',
                'level': 'advanced',
                'credit_hours': 4,
                'duration_weeks': 14
            }
        ]
    }
}

def create_specialization_data():
    """Create courses for all specializations"""
    db = SessionLocal()
    
    try:
        for spec_code, spec_data in SPECIALIZATION_DATA.items():
            print(f"\n{'='*60}")
            print(f"📚 Creating courses for: {spec_data['name']}")
            print(f"{'='*60}")
            
            for course_data in spec_data['courses']:
                # Check if course already exists
                existing = db.query(Course).filter(
                    Course.course_code == course_data['code']
                ).first()
                
                if existing:
                    print(f"  ⏭️  {course_data['code']} already exists, skipping...")
                    continue
                
                # Create course
                course = Course(
                    course_code=course_data['code'],
                    course_name=course_data['name'],
                    description=course_data['description'],
                    major='CNTT',
                    specialization=spec_code,
                    level=CourseLevel(course_data['level']),
                    credit_hours=course_data['credit_hours'],
                    semester='HK2-2024',
                    academic_year='2024-2025',
                    duration_weeks=course_data['duration_weeks'],
                    max_students=50,
                    is_active=True,
                    is_featured=True,
                    created_at=datetime.now(),
                    updated_at=datetime.now()
                )
                
                db.add(course)
                db.flush()
                
                # Create sample lessons for the course
                lessons = [
                    f"Giới thiệu {course_data['name']}",
                    "Kiến thức nền tảng",
                    "Các khái niệm cơ bản",
                    "Thực hành 1",
                    "Nội dung nâng cao",
                    "Studi kasus",
                    "Thực hành 2",
                    "Dự án thực tế",
                    "Ôn tập và kiểm tra"
                ]
                
                for idx, lesson_name in enumerate(lessons):
                    lesson = Lesson(
                        course_id=course.id,
                        title=lesson_name,
                        description=f"Bài {idx + 1}: {lesson_name}",
                        duration_minutes=(idx + 1) * 30,
                        order=idx,
                        is_published=True,
                        is_free_preview=(idx == 0),
                        created_at=datetime.now(),
                        updated_at=datetime.now()
                    )
                    db.add(lesson)
                
                print(f"  ✅ Created: {course_data['code']} - {course_data['name']}")
                print(f"     └─ Added {len(lessons)} lessons")
        
        # Commit all changes
        db.commit()
        
        # Print summary
        print(f"\n{'='*60}")
        print("📊 SUMMARY")
        print(f"{'='*60}")
        
        total_courses = db.query(Course).filter(
            Course.specialization.in_(['CNPM', 'CNDL', 'ANM'])
        ).count()
        total_lessons = db.query(Lesson).count()
        
        print(f"✅ Total courses created: {total_courses}")
        print(f"✅ Total lessons created: {total_lessons}")
        
        # Count by specialization
        for spec_code in ['CNPM', 'CNDL', 'ANM']:
            count = db.query(Course).filter(Course.specialization == spec_code).count()
            print(f"   - {spec_code}: {count} courses")
        
        print(f"\n{'='*60}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == '__main__':
    print("\n🚀 Creating specialization courses...\n")
    create_specialization_data()
    print("\n✅ Done!\n")
