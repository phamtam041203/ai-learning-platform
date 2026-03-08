"""
Setup Database Script
- Tạo tất cả bảng
- Tạo user mẫu để test
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# Load .env
load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:admin@localhost:5432/ai_learning_db"
)

print(f"🔗 Connecting to: {DATABASE_URL}")

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Import Base và tất cả models
from app.database import Base
from app.models import (
    User, StudentProfile, TeacherProfile, UserRole,
    Course, Enrollment, Lesson, LessonProgress,
    Assessment, Submission, Question
)
from app.utils.security import get_password_hash


def create_tables():
    """Tạo tất cả bảng trong database"""
    print("📦 Creating all tables...")
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created successfully!")


def create_test_users():
    """Tạo user mẫu để test"""
    db = SessionLocal()

    try:
        # Check if test student exists
        existing_student = db.query(User).filter(User.email == "student@vanlanguni.vn").first()
        if not existing_student:
            print("👨‍🎓 Creating test student...")
            student = User(
                email="student@vanlanguni.vn",
                hashed_password=get_password_hash("Student123"),
                full_name="Nguyễn Văn Sinh Viên",
                role=UserRole.STUDENT,
                is_active=True
            )
            db.add(student)
            db.flush()

            # Create student profile
            student_profile = StudentProfile(
                user_id=student.id,
                student_id="2174802010001K27",
                major="Công nghệ Thông tin",
                class_name="CNTT-K27",
                intake_year=27,
                phone="0901234567"
            )
            db.add(student_profile)
            print("✅ Test student created!")
            print("   📧 Email: student@vanlanguni.vn")
            print("   🔑 Password: Student123")
        else:
            print("ℹ️ Test student already exists")

        # Check if test teacher exists
        existing_teacher = db.query(User).filter(User.email == "teacher@vanlanguni.vn").first()
        if not existing_teacher:
            print("👨‍🏫 Creating test teacher...")
            teacher = User(
                email="teacher@vanlanguni.vn",
                hashed_password=get_password_hash("Teacher123"),
                full_name="TS. Nguyễn Văn Giảng Viên",
                role=UserRole.TEACHER,
                is_active=True
            )
            db.add(teacher)
            db.flush()

            # Create teacher profile
            teacher_profile = TeacherProfile(
                user_id=teacher.id,
                teacher_id="GV001",
                department="Khoa CNTT",
                position="Giảng viên",
                phone="0909876543"
            )
            db.add(teacher_profile)
            print("✅ Test teacher created!")
            print("   📧 Email: teacher@vanlanguni.vn")
            print("   🔑 Password: Teacher123")
        else:
            print("ℹ️ Test teacher already exists")

        db.commit()
        print("\n🎉 Database setup completed!")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        db.close()


def main():
    print("=" * 50)
    print("🚀 AI Learning Platform - Database Setup")
    print("=" * 50)

    try:
        # 1. Create tables
        create_tables()

        # 2. Create test users
        create_test_users()

        print("\n" + "=" * 50)
        print("📝 Test Accounts:")
        print("=" * 50)
        print("\n👨‍🎓 STUDENT:")
        print("   Email: student@vanlanguni.vn")
        print("   Password: Student123")
        print("\n👨‍🏫 TEACHER:")
        print("   Email: teacher@vanlanguni.vn")
        print("   Password: Teacher123")
        print("=" * 50)

    except Exception as e:
        print(f"\n❌ Setup failed: {e}")
        print("\n💡 Make sure:")
        print("   1. PostgreSQL is running")
        print("   2. Database 'ai_learning_db' exists")
        print("   3. Check DATABASE_URL in .env file")


if __name__ == "__main__":
    main()
