
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.database import SessionLocal, engine, Base
from app.models import *
from app.utils.security import get_password_hash
from datetime import datetime, timedelta
import random



# Ngành học
MAJORS = {
    "CNTT": "Công nghệ thông tin",
    "KTPM": "Kỹ thuật phần mềm",
    "HTTT": "Hệ thống thông tin",
    "MMT": "Mạng máy tính",
    "KHMT": "Khoa học máy tính",
    "ATTT": "An toàn thông tin",
    "TTNT": "Trí tuệ nhân tạo"
}

# Khóa học theo ngành
COURSES_BY_MAJOR = {
    "CNTT": [
        {"code": "CS101", "name": "Nhập môn lập trình", "credits": 3, "level": "beginner", "description": "Giới thiệu về lập trình cơ bản với Python"},
        {"code": "CS102", "name": "Cấu trúc dữ liệu và giải thuật", "credits": 4, "level": "intermediate", "description": "Các cấu trúc dữ liệu và thuật toán cơ bản"},
        {"code": "CS103", "name": "Cơ sở dữ liệu", "credits": 3, "level": "intermediate", "description": "Thiết kế và quản lý cơ sở dữ liệu quan hệ"},
        {"code": "CS104", "name": "Hệ điều hành", "credits": 3, "level": "intermediate", "description": "Nguyên lý hoạt động của hệ điều hành"},
        {"code": "CS105", "name": "Mạng máy tính cơ bản", "credits": 3, "level": "intermediate", "description": "Kiến thức nền tảng về mạng máy tính"},
        {"code": "CS201", "name": "Lập trình hướng đối tượng", "credits": 4, "level": "intermediate", "description": "OOP với Java/C++"},
        {"code": "CS202", "name": "Phát triển ứng dụng Web", "credits": 4, "level": "intermediate", "description": "HTML, CSS, JavaScript và Framework"},
        {"code": "CS301", "name": "Công nghệ phần mềm", "credits": 3, "level": "advanced", "description": "Quy trình phát triển phần mềm"},
        {"code": "CS302", "name": "Trí tuệ nhân tạo cơ bản", "credits": 3, "level": "advanced", "description": "Giới thiệu về AI và Machine Learning"},
    ],
    "KTPM": [
        {"code": "SE101", "name": "Nhập môn kỹ thuật phần mềm", "credits": 3, "level": "beginner", "description": "Tổng quan về kỹ thuật phần mềm"},
        {"code": "SE102", "name": "Phân tích và thiết kế hệ thống", "credits": 4, "level": "intermediate", "description": "UML và các phương pháp phân tích"},
        {"code": "SE103", "name": "Kiểm thử phần mềm", "credits": 3, "level": "intermediate", "description": "Các kỹ thuật kiểm thử và QA"},
        {"code": "SE201", "name": "Quản lý dự án phần mềm", "credits": 3, "level": "intermediate", "description": "Agile, Scrum và quản lý dự án"},
        {"code": "SE202", "name": "Kiến trúc phần mềm", "credits": 4, "level": "advanced", "description": "Design patterns và kiến trúc hệ thống"},
        {"code": "SE203", "name": "DevOps và CI/CD", "credits": 3, "level": "advanced", "description": "Triển khai và tự động hóa"},
        {"code": "SE301", "name": "Phát triển ứng dụng di động", "credits": 4, "level": "intermediate", "description": "React Native/Flutter"},
        {"code": "SE302", "name": "Microservices Architecture", "credits": 3, "level": "advanced", "description": "Xây dựng hệ thống microservices"},
    ],
    "HTTT": [
        {"code": "IS101", "name": "Nhập môn hệ thống thông tin", "credits": 3, "level": "beginner", "description": "Tổng quan về HTTT trong doanh nghiệp"},
        {"code": "IS102", "name": "Hệ thống quản lý CSDL", "credits": 4, "level": "intermediate", "description": "SQL Server, Oracle, MySQL"},
        {"code": "IS103", "name": "Phân tích dữ liệu kinh doanh", "credits": 3, "level": "intermediate", "description": "Business Intelligence và Analytics"},
        {"code": "IS201", "name": "Hệ thống ERP", "credits": 4, "level": "advanced", "description": "SAP, Oracle ERP"},
        {"code": "IS202", "name": "Data Warehouse", "credits": 3, "level": "advanced", "description": "Xây dựng kho dữ liệu"},
        {"code": "IS203", "name": "Big Data Analytics", "credits": 4, "level": "advanced", "description": "Hadoop, Spark, xử lý dữ liệu lớn"},
        {"code": "IS301", "name": "E-Commerce Systems", "credits": 3, "level": "intermediate", "description": "Hệ thống thương mại điện tử"},
    ],
    "MMT": [
        {"code": "NT101", "name": "Mạng máy tính", "credits": 4, "level": "beginner", "description": "Kiến thức nền tảng về mạng"},
        {"code": "NT102", "name": "Quản trị mạng", "credits": 3, "level": "intermediate", "description": "Quản trị hệ thống mạng doanh nghiệp"},
        {"code": "NT103", "name": "An ninh mạng", "credits": 4, "level": "intermediate", "description": "Bảo mật hệ thống mạng"},
        {"code": "NT201", "name": "Điện toán đám mây", "credits": 4, "level": "advanced", "description": "AWS, Azure, GCP"},
        {"code": "NT202", "name": "Mạng không dây", "credits": 3, "level": "intermediate", "description": "WiFi, 4G/5G"},
        {"code": "NT203", "name": "IoT và hệ thống nhúng", "credits": 3, "level": "advanced", "description": "Internet of Things"},
    ],
    "KHMT": [
        {"code": "CS401", "name": "Thuật toán nâng cao", "credits": 4, "level": "advanced", "description": "Thuật toán và độ phức tạp"},
        {"code": "CS402", "name": "Lý thuyết đồ thị", "credits": 3, "level": "intermediate", "description": "Graph theory và ứng dụng"},
        {"code": "CS403", "name": "Machine Learning", "credits": 4, "level": "advanced", "description": "Học máy và ứng dụng"},
        {"code": "CS404", "name": "Deep Learning", "credits": 4, "level": "advanced", "description": "Neural Networks và Deep Learning"},
        {"code": "CS405", "name": "Computer Vision", "credits": 3, "level": "advanced", "description": "Xử lý ảnh và thị giác máy tính"},
        {"code": "CS406", "name": "Natural Language Processing", "credits": 3, "level": "advanced", "description": "Xử lý ngôn ngữ tự nhiên"},
    ],
    "ATTT": [
        {"code": "SEC101", "name": "An toàn thông tin cơ bản", "credits": 3, "level": "beginner", "description": "Nền tảng về bảo mật thông tin"},
        {"code": "SEC102", "name": "Mật mã học", "credits": 4, "level": "intermediate", "description": "Cryptography"},
        {"code": "SEC103", "name": "Bảo mật ứng dụng Web", "credits": 3, "level": "intermediate", "description": "OWASP và bảo mật web"},
        {"code": "SEC201", "name": "Ethical Hacking", "credits": 4, "level": "advanced", "description": "Penetration Testing"},
        {"code": "SEC202", "name": "Forensics", "credits": 3, "level": "advanced", "description": "Điều tra số"},
        {"code": "SEC203", "name": "Security Operations", "credits": 3, "level": "advanced", "description": "SOC và incident response"},
    ],
    "TTNT": [
        {"code": "AI101", "name": "Trí tuệ nhân tạo", "credits": 4, "level": "intermediate", "description": "Nền tảng AI"},
        {"code": "AI102", "name": "Machine Learning cơ bản", "credits": 4, "level": "intermediate", "description": "Supervised/Unsupervised Learning"},
        {"code": "AI103", "name": "Deep Learning", "credits": 4, "level": "advanced", "description": "CNN, RNN, Transformers"},
        {"code": "AI201", "name": "Reinforcement Learning", "credits": 3, "level": "advanced", "description": "Học tăng cường"},
        {"code": "AI202", "name": "Generative AI", "credits": 3, "level": "advanced", "description": "GANs, VAEs, LLMs"},
        {"code": "AI203", "name": "AI for Robotics", "credits": 4, "level": "advanced", "description": "AI trong robot"},
        {"code": "AI204", "name": "MLOps", "credits": 3, "level": "advanced", "description": "Triển khai ML production"},
    ]
}

# Mẫu bài học cho mỗi khóa học
LESSON_TEMPLATES = [
    {"title": "Giới thiệu môn học", "duration": 45},
    {"title": "Kiến thức nền tảng", "duration": 60},
    {"title": "Các khái niệm cơ bản", "duration": 90},
    {"title": "Thực hành 1", "duration": 120},
    {"title": "Nội dung nâng cao", "duration": 90},
    {"title": "Case Study", "duration": 60},
    {"title": "Thực hành 2", "duration": 120},
    {"title": "Ôn tập giữa kỳ", "duration": 60},
    {"title": "Chủ đề chuyên sâu", "duration": 90},
    {"title": "Project thực tế", "duration": 180},
    {"title": "Tổng kết và ôn tập", "duration": 60},
]


def create_tables():
    """Create all tables"""
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created!")


def seed_courses(db: Session):
    """Seed courses by major"""
    print("\nSeeding courses...")

    courses_created = 0
    for major_code, courses in COURSES_BY_MAJOR.items():
        for course_data in courses:
            # Check if course already exists
            existing = db.query(Course).filter(Course.course_code == course_data["code"]).first()
            if existing:
                print(f"  Course {course_data['code']} already exists, skipping...")
                continue

            # Create course
            course = Course(
                course_code=course_data["code"],
                course_name=course_data["name"],
                description=course_data["description"],
                major=major_code,
                credit_hours=course_data["credits"],
                level=CourseLevel(course_data["level"]),
                semester="HK2-2024",
                academic_year="2024-2025",
                duration_weeks=15,
                max_students=50,
                is_active=True,
                is_featured=random.random() > 0.7
            )
            db.add(course)
            db.flush()

            # Create lessons for this course
            for i, lesson_template in enumerate(LESSON_TEMPLATES):
                lesson = Lesson(
                    course_id=course.id,
                    title=f"{lesson_template['title']} - {course_data['name']}",
                    description=f"Bài học {i + 1}: {lesson_template['title']}",
                    duration_minutes=lesson_template["duration"],
                    order=i,
                    is_published=True,
                    is_free_preview=(i == 0)
                )
                db.add(lesson)

            # tao danh gia
            assessments_data = [
                {"title": f"Quiz 1 - {course_data['name']}", "type": AssessmentType.QUIZ, "weight": 0.1, "max": 10},
                {"title": f"Bài tập 1 - {course_data['name']}", "type": AssessmentType.ASSIGNMENT, "weight": 0.1, "max": 10},
                {"title": f"Giữa kỳ - {course_data['name']}", "type": AssessmentType.MIDTERM, "weight": 0.3, "max": 10},
                {"title": f"Bài tập 2 - {course_data['name']}", "type": AssessmentType.ASSIGNMENT, "weight": 0.1, "max": 10},
                {"title": f"Cuối kỳ - {course_data['name']}", "type": AssessmentType.FINAL, "weight": 0.4, "max": 10},
            ]

            for assess_data in assessments_data:
                assessment = Assessment(
                    course_id=course.id,
                    title=assess_data["title"],
                    assessment_type=assess_data["type"],
                    max_score=assess_data["max"],
                    weight=assess_data["weight"],
                    passing_score=5.0,
                    is_published=True,
                    due_date=datetime.now() + timedelta(days=random.randint(7, 90))
                )
                db.add(assessment)

            courses_created += 1
            print(f"  Created: {course_data['code']} - {course_data['name']} ({major_code})")

    db.commit()
    print(f"\nTotal courses created: {courses_created}")


def seed_sample_teacher(db: Session):
    """Create sample teacher"""
    print("\nCreating sample teacher...")

    existing = db.query(User).filter(User.email == "teacher@test.com").first()
    if existing:
        print("  Teacher already exists, skipping...")
        return existing

    teacher = User(
        email="teacher@test.com",
        hashed_password=get_password_hash("teacher123"),
        full_name="Nguyễn Văn Giảng",
        role=UserRole.TEACHER,
        is_active=True
    )
    db.add(teacher)
    db.flush()

    profile = TeacherProfile(
        user_id=teacher.id,
        teacher_id="GV001",
        department="Công nghệ thông tin",
        position="Giảng viên"
    )
    db.add(profile)
    db.commit()

    print(f"  Created teacher: {teacher.email}")
    return teacher


def seed_sample_students(db: Session, count: int = 5):
    """Create sample students"""
    print(f"\nCreating {count} sample students...")

    students = []
    majors = list(MAJORS.keys())

    for i in range(count):
        email = f"student{i + 1}@vanlanguni.vn"
        existing = db.query(User).filter(User.email == email).first()
        if existing:
            print(f"  Student {email} already exists, skipping...")
            students.append(existing)
            continue

        user = User(
            email=email,
            hashed_password=get_password_hash("student123"),
            full_name=f"Sinh viên Test {i + 1}",
            role=UserRole.STUDENT,
            is_active=True
        )
        db.add(user)
        db.flush()

        major = majors[i % len(majors)]
        profile = StudentProfile(
            user_id=user.id,
            student_id=f"2174802{i + 1:04d}K27",
            major=major,
            class_name=f"{major}-K27",
            intake_year=27
        )
        db.add(profile)

        students.append(user)
        print(f"  Created student: {email} - Major: {major}")

    db.commit()
    return students


def seed_enrollments(db: Session, students: list):
    """Enroll students in courses and generate grades"""
    print("\nEnrolling students in courses...")

    for student in students:
        # Get student's major
        profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
        if not profile:
            continue

        # Get courses for this major
        courses = db.query(Course).filter(Course.major == profile.major).all()

        for course in courses:
            # Check if already enrolled
            existing = db.query(Enrollment).filter(
                Enrollment.student_id == student.id,
                Enrollment.course_id == course.id
            ).first()

            if existing:
                continue

            # Create enrollment with random grades
            midterm = round(random.uniform(5.0, 10.0), 1)
            final = round(random.uniform(5.0, 10.0), 1)
            assignment = round(random.uniform(6.0, 10.0), 1)
            total = round(midterm * 0.3 + final * 0.5 + assignment * 0.2, 1)

            # Calculate grade letter
            grade_letter = calculate_grade_letter(total)

            # Random progress
            progress = random.randint(30, 100)
            status = EnrollmentStatus.COMPLETED if progress == 100 else EnrollmentStatus.ACTIVE

            enrollment = Enrollment(
                student_id=student.id,
                course_id=course.id,
                status=status,
                progress=progress,
                completed_lessons=int(len(LESSON_TEMPLATES) * progress / 100),
                total_time_spent=random.randint(300, 2000),
                midterm_score=midterm,
                final_score=final,
                assignment_score=assignment,
                total_score=total,
                grade_letter=grade_letter,
                last_accessed=datetime.now() - timedelta(days=random.randint(0, 7))
            )
            db.add(enrollment)

    db.commit()
    print("  Enrollments created with grades!")


def calculate_grade_letter(score: float) -> str:
    """Calculate grade letter from score (10-point scale)"""
    if score >= 9.0:
        return "A+"
    elif score >= 8.5:
        return "A"
    elif score >= 8.0:
        return "B+"
    elif score >= 7.0:
        return "B"
    elif score >= 6.5:
        return "C+"
    elif score >= 5.5:
        return "C"
    elif score >= 5.0:
        return "D+"
    elif score >= 4.0:
        return "D"
    else:
        return "F"


def enroll_existing_user(db: Session, email: str):
    """Enroll an existing user in courses based on their major"""
    print(f"\nEnrolling existing user: {email}...")

    user = db.query(User).filter(User.email == email).first()
    if not user:
        print(f"  User {email} not found, skipping...")
        return

    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if not profile:
        print(f"  No student profile for {email}, skipping...")
        return

    # Map Vietnamese major names to codes
    major_mapping = {
        "Công nghệ Thông tin": "CNTT",
        "Công nghệ thông tin": "CNTT",
        "Khoa học Máy tính": "KHMT",
        "Hệ thống Thông tin": "HTTT",
        "An toàn Thông tin": "ATTT",
        "Kỹ thuật phần mềm": "KTPM",
        "Mạng máy tính": "MMT",
        "Trí tuệ nhân tạo": "TTNT",
    }

    major_code = major_mapping.get(profile.major, "CNTT")
    print(f"  Student major: {profile.major} -> Code: {major_code}")

    # Get courses for this major
    courses = db.query(Course).filter(Course.major == major_code).all()

    if not courses:
        # If no courses for major, get CNTT courses
        print(f"  No courses for {major_code}, using CNTT courses...")
        courses = db.query(Course).filter(Course.major == "CNTT").all()

    enrolled_count = 0
    for course in courses[:5]:  # Enroll in up to 5 courses
        existing = db.query(Enrollment).filter(
            Enrollment.student_id == user.id,
            Enrollment.course_id == course.id
        ).first()

        if existing:
            continue

        # Generate random grades
        midterm = round(random.uniform(6.0, 10.0), 1)
        final = round(random.uniform(6.0, 10.0), 1)
        assignment = round(random.uniform(7.0, 10.0), 1)
        total = round(midterm * 0.3 + final * 0.5 + assignment * 0.2, 1)
        grade_letter = calculate_grade_letter(total)

        progress = random.randint(40, 100)
        status = EnrollmentStatus.COMPLETED if progress == 100 else EnrollmentStatus.ACTIVE

        enrollment = Enrollment(
            student_id=user.id,
            course_id=course.id,
            status=status,
            progress=progress,
            completed_lessons=int(len(LESSON_TEMPLATES) * progress / 100),
            total_time_spent=random.randint(300, 2000),
            midterm_score=midterm,
            final_score=final,
            assignment_score=assignment,
            total_score=total,
            grade_letter=grade_letter,
            last_accessed=datetime.now() - timedelta(days=random.randint(0, 3))
        )
        db.add(enrollment)
        enrolled_count += 1
        print(f"    Enrolled in: {course.course_code} - {course.course_name}")

    db.commit()
    print(f"  Total enrolled: {enrolled_count} courses")


def main():
    """Main seed function"""
    print("=" * 50)
    print("SEEDING DATABASE")
    print("=" * 50)

    # Create tables
    create_tables()

    # Create session
    db = SessionLocal()

    try:
        # Seed courses
        seed_courses(db)

        # Seed teacher
        seed_sample_teacher(db)

        # Seed students
        students = seed_sample_students(db, count=5)

        # Seed enrollments with grades
        seed_enrollments(db, students)

        # ⭐ IMPORTANT: Enroll existing users (from setup_db.py)
        enroll_existing_user(db, "student@vanlanguni.vn")

        print("\n" + "=" * 50)
        print("SEEDING COMPLETED!")
        print("=" * 50)

        # Print summary
        print("\nSummary:")
        print(f"  - Courses: {db.query(Course).count()}")
        print(f"  - Lessons: {db.query(Lesson).count()}")
        print(f"  - Assessments: {db.query(Assessment).count()}")
        print(f"  - Users: {db.query(User).count()}")
        print(f"  - Enrollments: {db.query(Enrollment).count()}")

        print("\nTest accounts:")
        print("  Main student: student@vanlanguni.vn / Student123")
        print("  Teacher: teacher@test.com / teacher123")
        print("  Student: student1@test.com / student123")



    except Exception as e:
        print(f"\nError: {e}")
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
