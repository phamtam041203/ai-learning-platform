# backend/app/config.py
import json

from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "AI Learning Platform"
    DEBUG: bool = True
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@db:5432/ai_learning_db"
    MONGODB_URL: str = "mongodb://mongo:27017"
    REDIS_URL: str = "redis://redis:6379/0"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:3002",
        "http://localhost:5173",
    ]

    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def parse_allowed_origins(cls, value):
        if value is None or value == "":
            return [
                "http://localhost:3000",
                "http://localhost:3001",
                "http://localhost:3002",
                "http://localhost:5173",
            ]

        if isinstance(value, str):
            stripped_value = value.strip()

            if stripped_value.startswith("["):
                parsed_value = json.loads(stripped_value)
                return [origin.strip() for origin in parsed_value if isinstance(origin, str) and origin.strip()]

            return [origin.strip() for origin in value.split(",") if origin.strip()]

        return value
    
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