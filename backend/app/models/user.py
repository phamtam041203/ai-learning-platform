"""
User models: User, StudentProfile, TeacherProfile
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum, ForeignKey, Text, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.database import Base


class UserRole(str, enum.Enum):
    """User role enumeration"""
    STUDENT = "student"
    TEACHER = "teacher"
    ADMIN = "admin"


class User(Base):
    """Base user model"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    student_profile = relationship("StudentProfile", back_populates="user", uselist=False)
    teacher_profile = relationship("TeacherProfile", back_populates="user", uselist=False)


class StudentProfile(Base):
    """Student profile"""
    __tablename__ = "student_profiles"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    student_id = Column(String(50), unique=True, nullable=False, index=True)
    major = Column(String(255))
    specialization = Column(String(255))  # ⭐ Chuyên ngành: CNPM, CNDL, ANM
    class_name = Column(String(100))
    intake_year = Column(Integer)  # ⭐ Đổi từ 'year' thành 'intake_year'
    gpa = Column(String(10))
    phone = Column(String(20))
    address = Column(Text)
    date_of_birth = Column(Date)
    education_type = Column(String(10))  # ⭐ Thêm field này
    learning_style = Column(String(50))  # visual, auditory, kinesthetic, reading
    preferred_difficulty = Column(String(50))  # easy, medium, hard
    avatar = Column(String(500))

    user = relationship("User", back_populates="student_profile")


class TeacherProfile(Base):
    """Teacher profile"""
    __tablename__ = "teacher_profiles"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    teacher_id = Column(String(50), unique=True, nullable=False, index=True)
    department = Column(String(255))
    position = Column(String(100))
    specialization = Column(Text)
    phone = Column(String(20))
    office_location = Column(String(255))
    bio = Column(Text)
    years_of_experience = Column(Integer)
    courses_taught = Column(Text)  # JSON string
    
    user = relationship("User", back_populates="teacher_profile")


class LoginHistory(Base):
    """Login history tracking"""
    __tablename__ = "login_history"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    login_at = Column(DateTime(timezone=True), server_default=func.now())
    ip_address = Column(String(50))
    user_agent = Column(Text)
    success = Column(Boolean, default=True)