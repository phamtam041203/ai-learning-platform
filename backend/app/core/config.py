import json

from pydantic_settings import BaseSettings
from pydantic import Field, field_validator
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
    ALLOWED_ORIGINS: list[str] = Field(
        default_factory=lambda: [
            "http://localhost:3000",
            "http://localhost:3001",
            "http://localhost:3002",
            "http://localhost:5173",
        ]
    )

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

    class Config:
        env_file = str(BACKEND_DIR / ".env")
        env_file_encoding = 'utf-8'


settings = Settings()
