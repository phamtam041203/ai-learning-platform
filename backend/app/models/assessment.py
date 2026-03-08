"""Assessment, Submission, and Grade models"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Float, Boolean, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.database import Base


class AssessmentType(str, enum.Enum):
    """Assessment type"""
    QUIZ = "quiz"
    ASSIGNMENT = "assignment"
    MIDTERM = "midterm"
    FINAL = "final"
    PROJECT = "project"
    LAB = "lab"


class Assessment(Base):
    """Assessment/Exam model"""
    __tablename__ = "assessments"

    id = Column(Integer, primary_key=True)
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"))

    title = Column(String(255), nullable=False)
    description = Column(Text)
    instructions = Column(Text)

    assessment_type = Column(Enum(AssessmentType), default=AssessmentType.ASSIGNMENT)

    # Scoring
    max_score = Column(Float, default=10.0)
    weight = Column(Float, default=1.0)  # Weight in final grade (e.g., 0.3 for 30%)
    passing_score = Column(Float, default=5.0)

    # Time settings
    due_date = Column(DateTime(timezone=True))
    start_date = Column(DateTime(timezone=True))
    duration_minutes = Column(Integer)  # For timed assessments

    # Settings
    is_published = Column(Boolean, default=False)
    allow_late_submission = Column(Boolean, default=True)
    late_penalty_percent = Column(Float, default=10.0)  # % penalty per day
    max_attempts = Column(Integer, default=1)

    # Attachment
    attachment_url = Column(String(500))
    attachment_name = Column(String(255))

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    course = relationship("Course", back_populates="assessments")
    submissions = relationship("Submission", back_populates="assessment", cascade="all, delete-orphan")
    questions = relationship("Question", back_populates="assessment", cascade="all, delete-orphan")


class Question(Base):
    """Quiz/Exam question"""
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True)
    assessment_id = Column(Integer, ForeignKey("assessments.id", ondelete="CASCADE"))

    question_text = Column(Text, nullable=False)
    question_type = Column(String(50), default="multiple_choice")  # multiple_choice, true_false, essay, fill_blank

    # For multiple choice
    option_a = Column(Text)
    option_b = Column(Text)
    option_c = Column(Text)
    option_d = Column(Text)
    correct_answer = Column(String(10))  # a, b, c, d or true/false
    explanation = Column(Text)

    points = Column(Float, default=1.0)
    order = Column(Integer, default=0)

    # Relationships
    assessment = relationship("Assessment", back_populates="questions")


class Submission(Base):
    """Student submission for assessment"""
    __tablename__ = "submissions"

    id = Column(Integer, primary_key=True)
    assessment_id = Column(Integer, ForeignKey("assessments.id", ondelete="CASCADE"))
    student_id = Column(Integer, ForeignKey("users.id"))

    # Submission content
    content = Column(Text)  # For essay/text answers
    file_url = Column(String(500))  # For file uploads
    answers_json = Column(Text)  # JSON string for quiz answers

    # Scoring
    score = Column(Float)
    max_score = Column(Float)
    percentage = Column(Float)

    # Status
    status = Column(String(50), default="submitted")  # submitted, graded, returned
    attempt_number = Column(Integer, default=1)

    # Feedback
    feedback = Column(Text)
    graded_by = Column(Integer, ForeignKey("users.id"))

    # Timestamps
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())
    graded_at = Column(DateTime(timezone=True))
    is_late = Column(Boolean, default=False)

    # Relationships
    assessment = relationship("Assessment", back_populates="submissions")


class QuizResult(Base):
    """Quiz results for lessons"""
    __tablename__ = "quiz_results"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))
    
    score = Column(Float, nullable=False)  # Percentage score
    total_questions = Column(Integer, nullable=False)
    correct_answers = Column(Integer, nullable=False)
    
    completed_at = Column(DateTime(timezone=True), server_default=func.now())


class EssaySubmission(Base):
    """Essay/Assignment submission for lessons (tự luận)"""
    __tablename__ = "essay_submissions"

    id = Column(Integer, primary_key=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"))
    student_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"))

    # Submission content - student can either write text or upload file
    text_content = Column(Text)  # For text answers written in textbox
    file_url = Column(String(500))  # For file uploads
    file_name = Column(String(255))  # Original filename
    file_type = Column(String(100))  # MIME type of uploaded file
    file_size = Column(Integer)  # File size in bytes

    # Status
    status = Column(String(50), default="submitted")  # submitted, reviewed, graded, returned
    
    # Grading (by teacher)
    score = Column(Float)  # Score given by teacher
    max_score = Column(Float, default=10.0)
    feedback = Column(Text)  # Teacher feedback
    graded_by = Column(Integer, ForeignKey("users.id"))
    
    # Timestamps
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    graded_at = Column(DateTime(timezone=True))
    
    # Relationships
    lesson = relationship("Lesson", backref="essay_submissions")
    student = relationship("User", foreign_keys=[student_id], backref="essay_submissions")
    grader = relationship("User", foreign_keys=[graded_by])


class GradeHistory(Base):
    """Track grade changes for auditing"""
    __tablename__ = "grade_history"

    id = Column(Integer, primary_key=True)
    enrollment_id = Column(Integer, ForeignKey("enrollments.id"))
    student_id = Column(Integer, ForeignKey("users.id"))
    course_id = Column(Integer, ForeignKey("courses.id"))

    grade_type = Column(String(50))  # midterm, final, assignment, total
    old_score = Column(Float)
    new_score = Column(Float)
    changed_by = Column(Integer, ForeignKey("users.id"))
    reason = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())


class StudentSkillProfile(Base):
    """Per-skill confidence tracking per student (updated after each quiz)"""
    __tablename__ = "student_skill_profiles"

    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    skill_id = Column(String(100), nullable=False)   # e.g., "programming_foundations"
    confidence = Column(Float, default=0.5)          # 0.0 – 1.0
    attempts = Column(Integer, default=0)
    correct = Column(Integer, default=0)
    last_updated = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
