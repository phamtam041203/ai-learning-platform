from sqlalchemy import Column, Integer, String, JSON, DateTime
from datetime import datetime
from app.database import Base

class LearningActivity(Base):
    __tablename__ = "learning_activities"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    activity_type = Column(String(50), nullable=False)

    activity_metadata = Column(JSON)   # ✅ ĐỔI TÊN
    created_at = Column(DateTime, default=datetime.utcnow)
