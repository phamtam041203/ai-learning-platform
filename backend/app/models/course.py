"""
Course, Enrollment, Material, Lesson models
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Float, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.database import Base


class CourseLevel(str, enum.Enum):
    """Course difficulty level"""
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class EnrollmentStatus(str, enum.Enum):
    """Enrollment status"""
    ACTIVE = "active"
    COMPLETED = "completed"
    DROPPED = "dropped"
    PENDING = "pending"


class Course(Base):
    """Course model with major support"""
    __tablename__ = "courses"

    id = Column(Integer, primary_key=True)
    course_code = Column(String(50), unique=True, nullable=False, index=True)
    course_name = Column(String(255), nullable=False)
    description = Column(Text)

    # Teacher info
    teacher_id = Column(Integer, ForeignKey("users.id"))

    # Course details
    major = Column(String(100), index=True)  # Ngành học: CNTT, KTPM, HTTT, MMT, KHMT
    specialization = Column(String(100), index=True)  # Chuyên ngành: CNPM, CNDL, ANM
    credit_hours = Column(Integer, default=3)
    semester = Column(String(50))  # HK1-2024, HK2-2024
    academic_year = Column(String(20))  # 2024-2025

    # Course metadata
    level = Column(Enum(CourseLevel), default=CourseLevel.BEGINNER)
    thumbnail = Column(String(500))
    duration_weeks = Column(Integer, default=15)
    max_students = Column(Integer, default=50)

    # Status
    is_active = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    lessons = relationship("Lesson", back_populates="course", cascade="all, delete-orphan")
    enrollments = relationship("Enrollment", back_populates="course", cascade="all, delete-orphan")
    materials = relationship("Material", back_populates="course", cascade="all, delete-orphan")
    assessments = relationship("Assessment", back_populates="course", cascade="all, delete-orphan")


class Lesson(Base):
    """Course lesson/chapter"""
    __tablename__ = "lessons"

    id = Column(Integer, primary_key=True)
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"))

    title = Column(String(255), nullable=False)
    description = Column(Text)
    content = Column(Text)  # HTML/Markdown content
    video_url = Column(String(500))
    pdf_file_name = Column(String(500))  # PDF file name for lesson content
    duration_minutes = Column(Integer, default=0)

    order = Column(Integer, default=0)
    is_published = Column(Boolean, default=True)
    is_free_preview = Column(Boolean, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    course = relationship("Course", back_populates="lessons")
    progress = relationship("LessonProgress", back_populates="lesson", cascade="all, delete-orphan")


class Enrollment(Base):
    """Student course enrollment with grades"""
    __tablename__ = "enrollments"

    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("users.id"))
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"))

    enrolled_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True))

    status = Column(Enum(EnrollmentStatus), default=EnrollmentStatus.ACTIVE)

    # Progress tracking
    progress = Column(Integer, default=0)  # 0-100%
    completed_lessons = Column(Integer, default=0)
    total_time_spent = Column(Integer, default=0)  # minutes
    last_accessed = Column(DateTime(timezone=True))

    # Grades
    midterm_score = Column(Float)  # Điểm giữa kỳ (30%)
    final_score = Column(Float)    # Điểm cuối kỳ (50%)
    assignment_score = Column(Float)  # Điểm bài tập (20%)
    total_score = Column(Float)    # Điểm tổng kết
    grade_letter = Column(String(5))  # A, B+, B, C+, C, D+, D, F

    # Relationships
    course = relationship("Course", back_populates="enrollments")


class LessonProgress(Base):
    """Track student progress per lesson"""
    __tablename__ = "lesson_progress"

    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("users.id"))
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))

    is_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime(timezone=True))
    time_spent = Column(Integer, default=0)  # minutes
    last_position = Column(Integer, default=0)  # video position in seconds

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    lesson = relationship("Lesson", back_populates="progress")


class Material(Base):
    """Course material/resources"""
    __tablename__ = "materials"

    id = Column(Integer, primary_key=True)
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"))
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="SET NULL"), nullable=True)

    title = Column(String(255), nullable=False)
    description = Column(Text)
    file_url = Column(String(500))
    file_size = Column(Integer)  # bytes
    material_type = Column(String(50))  # pdf, video, document, link, slide

    order = Column(Integer, default=0)
    download_count = Column(Integer, default=0)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    course = relationship("Course", back_populates="materials")


class LessonComment(Base):
    """Student discussion comment on a lesson (supports threaded replies)"""
    __tablename__ = "lesson_comments"

    id = Column(Integer, primary_key=True, index=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    parent_id = Column(Integer, ForeignKey("lesson_comments.id", ondelete="CASCADE"), nullable=True)

    content = Column(Text, nullable=False)
    likes_count = Column(Integer, default=0)
    is_deleted = Column(Boolean, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    author = relationship("User", foreign_keys=[user_id])
    lesson = relationship("Lesson", foreign_keys=[lesson_id])
    replies = relationship(
        "LessonComment",
        foreign_keys="[LessonComment.parent_id]",
        primaryjoin="LessonComment.parent_id == LessonComment.id",
        cascade="all, delete-orphan",
    )


class LessonCommentLike(Base):
    """Tracks which users liked which comments (prevents duplicate likes)"""
    __tablename__ = "lesson_comment_likes"

    id = Column(Integer, primary_key=True)
    comment_id = Column(Integer, ForeignKey("lesson_comments.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class Notification(Base):
    """In-app notification for students (e.g. someone replied to their comment)"""
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    recipient_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    actor_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    notif_type = Column(String(50), nullable=False)   # "reply", "like"
    # Human-readable message stored at creation time
    message = Column(Text, nullable=False)
    # Optional deep-link data
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="SET NULL"), nullable=True)
    comment_id = Column(Integer, ForeignKey("lesson_comments.id", ondelete="SET NULL"), nullable=True)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    recipient = relationship("User", foreign_keys=[recipient_id])
    actor = relationship("User", foreign_keys=[actor_id])
