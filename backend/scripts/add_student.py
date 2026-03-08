"""
Script thêm sinh viên mới và đăng ký khóa học
Usage: python scripts/add_student.py
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.database import SessionLocal, engine, Base
from app.models import *
from app.utils.security import get_password_hash
from datetime import datetime, timedelta
import random


def calculate_grade_letter(score: float) -> str:
    if score >= 9.0: return "A+"
    elif score >= 8.5: return "A"
    elif score >= 8.0: return "B+"
    elif score >= 7.0: return "B"
    elif score >= 6.5: return "C+"
    elif score >= 5.5: return "C"
    elif score >= 5.0: return "D+"
    elif score >= 4.0: return "D"
    else: return "F"


def add_student(db: Session, email: str, password: str, full_name: str, major_code: str, intake_year: int = 27):
    """Thêm sinh viên mới"""

    # Check if exists
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        print(f"❌ Email {email} đã tồn tại!")
        return None

    # Create user
    user = User(
        email=email,
        hashed_password=get_password_hash(password),
        full_name=full_name,
        role=UserRole.STUDENT,
        is_active=True
    )
    db.add(user)
    db.flush()

    # Generate student ID
    count = db.query(StudentProfile).filter(StudentProfile.intake_year == intake_year).count()
    student_id = f"2174802{count + 1:04d}K{intake_year}"

    # Create profile
    profile = StudentProfile(
        user_id=user.id,
        student_id=student_id,
        major=major_code,
        class_name=f"{major_code}-K{intake_year}",
        intake_year=intake_year
    )
    db.add(profile)
    db.commit()

    print(f"✅ Tạo sinh viên thành công!")
    print(f"   📧 Email: {email}")
    print(f"   🔑 Password: {password}")
    print(f"   🎓 MSSV: {student_id}")
    print(f"   📚 Ngành: {major_code}")

    return user


def enroll_student_in_courses(db: Session, email: str, num_courses: int = 5):
    """Đăng ký khóa học cho sinh viên"""

    user = db.query(User).filter(User.email == email).first()
    if not user:
        print(f"❌ Không tìm thấy user: {email}")
        return

    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if not profile:
        print(f"❌ Không có profile cho: {email}")
        return

    # Get courses for major
    courses = db.query(Course).filter(Course.major == profile.major).all()

    if not courses:
        # Fallback to CNTT
        courses = db.query(Course).filter(Course.major == "CNTT").all()

    enrolled = 0
    for course in courses[:num_courses]:
        existing = db.query(Enrollment).filter(
            Enrollment.student_id == user.id,
            Enrollment.course_id == course.id
        ).first()

        if existing:
            continue

        # Random grades
        midterm = round(random.uniform(6.0, 10.0), 1)
        final = round(random.uniform(6.0, 10.0), 1)
        assignment = round(random.uniform(7.0, 10.0), 1)
        total = round(midterm * 0.3 + final * 0.5 + assignment * 0.2, 1)

        progress = random.randint(40, 100)
        status = EnrollmentStatus.COMPLETED if progress == 100 else EnrollmentStatus.ACTIVE

        enrollment = Enrollment(
            student_id=user.id,
            course_id=course.id,
            status=status,
            progress=progress,
            completed_lessons=random.randint(3, 11),
            total_time_spent=random.randint(300, 2000),
            midterm_score=midterm,
            final_score=final,
            assignment_score=assignment,
            total_score=total,
            grade_letter=calculate_grade_letter(total),
            last_accessed=datetime.now() - timedelta(days=random.randint(0, 3))
        )
        db.add(enrollment)
        enrolled += 1
        print(f"   📖 Đăng ký: {course.course_code} - {course.course_name}")

    db.commit()
    print(f"\n✅ Đã đăng ký {enrolled} khóa học!")


def main():
    print("=" * 50)
    print("THÊM SINH VIÊN MỚI")
    print("=" * 50)

    # Danh sách ngành
    majors = {
        "1": ("CNTT", "Công nghệ thông tin"),
        "2": ("KTPM", "Kỹ thuật phần mềm"),
        "3": ("HTTT", "Hệ thống thông tin"),
        "4": ("MMT", "Mạng máy tính"),
        "5": ("KHMT", "Khoa học máy tính"),
        "6": ("ATTT", "An toàn thông tin"),
        "7": ("TTNT", "Trí tuệ nhân tạo"),
    }

    # Input
    print("\nNhập thông tin sinh viên:")
    email = input("📧 Email (@vanlanguni.vn): ").strip()
    if not email:
        email = "newstudent@vanlanguni.vn"

    password = input("🔑 Mật khẩu (mặc định: Student123): ").strip()
    if not password:
        password = "Student123"

    full_name = input("👤 Họ tên: ").strip()
    if not full_name:
        full_name = "Sinh Viên Mới"

    print("\nChọn ngành:")
    for key, (code, name) in majors.items():
        print(f"  {key}. {code} - {name}")

    major_choice = input("Nhập số (1-7, mặc định 1): ").strip()
    if major_choice not in majors:
        major_choice = "1"

    major_code = majors[major_choice][0]

    intake_year = input("🎓 Khóa (mặc định 27): ").strip()
    if not intake_year:
        intake_year = 27
    else:
        intake_year = int(intake_year)

    # Create
    db = SessionLocal()
    try:
        user = add_student(db, email, password, full_name, major_code, intake_year)

        if user:
            enroll = input("\n📚 Đăng ký khóa học ngay? (y/n, mặc định y): ").strip().lower()
            if enroll != 'n':
                num = input("Số khóa học (mặc định 5): ").strip()
                num = int(num) if num else 5
                enroll_student_in_courses(db, email, num)

        print("\n" + "=" * 50)
        print("HOÀN TẤT!")
        print("=" * 50)

    except Exception as e:
        print(f"❌ Lỗi: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()
