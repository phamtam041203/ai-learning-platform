from pydantic_settings import BaseSettings
from pydantic import Field
from pathlib import Path

# Get backend directory path
BACKEND_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    DATABASE_URL: str = Field(
        default="postgresql://postgres:admin@localhost:5432/ai_learning_db"
    )
    SECRET_KEY: str = "super-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    
    # Google Gemini API Key for AI Chat integration
    GEMINI_API_KEY: str = Field(default="")

    # Microsoft Teams (Azure AD) OAuth
    AZURE_AD_CLIENT_ID: str = Field(default="")
    AZURE_AD_CLIENT_SECRET: str = Field(default="")
    AZURE_AD_TENANT_ID: str = Field(default="common")
    FRONTEND_BASE_URL: str = Field(default="http://localhost:3000")

    class Config:
        env_file = str(BACKEND_DIR / ".env")
        env_file_encoding = 'utf-8'


settings = Settings()
