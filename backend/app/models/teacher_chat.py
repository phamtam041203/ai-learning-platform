"""Teacher-student advisor chat history models."""

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.sql import func

from app.database import Base


class TeacherStudentChatHistory(Base):
    __tablename__ = "teacher_student_chat_histories"

    id = Column(Integer, primary_key=True)
    teacher_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"), nullable=True, index=True)

    request_type = Column(String(40), nullable=False, default="chat")
    message = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    response_source = Column(String(20), nullable=False, default="local")
    checklist_json = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)
