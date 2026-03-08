"""AI recommendation models"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Float
from sqlalchemy.sql import func
from app.database import Base


class Recommendation(Base):
    __tablename__ = "recommendations"
    
    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("users.id"))
    recommendation_type = Column(String(50))  # course, material, study_time
    item_id = Column(Integer)
    item_type = Column(String(50))
    confidence_score = Column(Float)
    reason = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    is_viewed = Column(String(20), default=False)
    is_accepted = Column(String(20))