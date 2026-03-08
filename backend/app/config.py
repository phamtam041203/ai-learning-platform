# backend/app/config.py
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "AI Learning Platform"
    DEBUG: bool = True
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:admin@localhost:5432/learning_db"
    MONGODB_URL: str = "mongodb://localhost:27017"
    REDIS_URL: str = "redis://localhost:6379"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
    ]
    
    # AI Models
    BERT_MODEL_NAME: str = "vinai/phobert-base"  # Vietnamese BERT
    GPT_MODEL_NAME: str = "gpt-3.5-turbo"
    OPENAI_API_KEY: str = ""
    
    # ML Settings
    MIN_INTERACTIONS_FOR_RECOMMENDATION: int = 5
    RECOMMENDATION_TOP_K: int = 10
    MODEL_UPDATE_INTERVAL_HOURS: int = 24
    
    # File Upload
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10MB
    ALLOWED_EXTENSIONS: List[str] = [".pdf", ".docx", ".pptx", ".txt"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()