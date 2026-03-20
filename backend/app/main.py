"""
FastAPI Main Application
Đồ án tốt nghiệp - Phạm Thành Tâm
"""
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import inspect, text
from starlette.middleware.sessions import SessionMiddleware
from contextlib import asynccontextmanager
import threading

# Import routers - FIXED
from app.api.auth import router as auth_router
from app.api.courses import router as courses_router
from app.api.student import router as student_router
from app.api.lessons import router as lessons_router
from app.api.quizzes import router as quizzes_router
from app.api.chatbot import router as chatbot_router
from app.api.admin import router as admin_router
from app.api.curriculum import router as curriculum_router
from app.api.essay import router as essay_router
from app.api.teacher import router as teacher_router
from app.api.discussion import router as discussion_router
from app.api.notifications import router as notifications_router

from app.database import engine, Base, SessionLocal
# Import all models so Base.metadata knows about them
from app.models import (
    User, StudentProfile, TeacherProfile, LoginHistory,
    Course, Enrollment, Lesson, LessonProgress, Material, LessonComment, LessonCommentLike, Notification,
    Assessment, Submission, Question, GradeHistory, QuizResult,
    LearningActivity, Recommendation, StudentSkillProfile
)
from app.models.user import UserRole
from app.utils.security import get_password_hash
from app.core.config import settings


# Startup event - create tables (DISABLED - causing shutdown issues)
# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     # Startup: Create tables in thread pool
#     print("🚀 Starting up - Creating database tables...")
#     def create_tables():
#         Base.metadata.create_all(bind=engine)
#         print("✅ Database tables ready!")
#     
#     # Run in separate thread to avoid blocking
#     thread = threading.Thread(target=create_tables)
#     thread.start()
#     thread.join()
#     
#     yield
#     # Shutdown
#     print("👋 Shutting down...")


# Create app
app = FastAPI(
    title="AI Learning Platform API",
    description="Hệ thống cá nhân hóa học tập - Đại học Văn Lang",
    version="1.0.0"
    # lifespan=lifespan  # Disabled due to shutdown issues
)

uploads_dir = Path(__file__).resolve().parents[1] / "uploads"
uploads_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=uploads_dir), name="uploads")


def ensure_runtime_columns() -> None:
    """Add required columns for deployments that rely on create_all instead of migrations."""
    inspector = inspect(engine)
    student_profile_columns = {column["name"] for column in inspector.get_columns("student_profiles")}

    if "avatar" not in student_profile_columns:
        with engine.begin() as connection:
            connection.execute(text("ALTER TABLE student_profiles ADD COLUMN avatar VARCHAR(500)"))
        print("✅ Added student_profiles.avatar column")

# Session middleware for OAuth state handling
app.add_middleware(
    SessionMiddleware,
    secret_key=settings.SECRET_KEY,
)

# Startup event for creating tables
@app.on_event("startup")
async def startup_event():
    print("🚀 Starting up - Creating database tables...")
    Base.metadata.create_all(bind=engine)
    ensure_runtime_columns()
    # Ensure default admin account
    db = SessionLocal()
    try:
        admin_user = db.query(User).filter(User.email == "admin").first()
        if not admin_user:
            admin_user = User(
                email="admin",
                hashed_password=get_password_hash("admin"),
                full_name="Administrator",
                role=UserRole.ADMIN,
                is_active=True
            )
            db.add(admin_user)
            db.commit()
            print("✅ Default admin account created")
        else:
            print("ℹ️ Default admin account exists")
    finally:
        db.close()
    print("✅ Database tables ready!")

# CORS - Cho phép Frontend (MOVED BEFORE ROUTERS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Include routers - FIXED: Removed duplicate prefix
app.include_router(auth_router, prefix="/api", tags=["Authentication"])
app.include_router(courses_router, prefix="/api", tags=["Courses"])
app.include_router(student_router, prefix="/api", tags=["Student"])
app.include_router(lessons_router, prefix="/api", tags=["Lessons"])
app.include_router(quizzes_router, prefix="/api", tags=["Quizzes"])
app.include_router(essay_router, prefix="/api", tags=["Essays"])
app.include_router(chatbot_router, prefix="/api/chatbot", tags=["Chatbot"])
app.include_router(admin_router, prefix="/api", tags=["Admin"])
app.include_router(curriculum_router, prefix="/api", tags=["Curriculum"])
app.include_router(teacher_router, prefix="/api/teacher", tags=["Teacher"])
app.include_router(discussion_router, prefix="/api", tags=["Discussion"])
app.include_router(notifications_router, prefix="/api", tags=["Notifications"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "🎓 AI Learning Platform API",
        "project": "Phát triển ứng dụng AI trong Cá nhân hóa học tập",
        "student": "Phạm Thành Tâm - 2174802010372",
        "university": "Đại học Văn Lang",
        "status": "running",
        "version": "1.0.0"
    }

# Health check
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "database": "connected",
        "message": "System is running"
    }

# Test endpoint
@app.get("/api/test")
async def test():
    return {
        "message": "API hoạt động bình thường!",
        "timestamp": "2025-01-16"
    }

# Debug: Print all registered routes on startup
@app.on_event("startup")
async def print_routes():
    print("\n📋 Registered Routes:")
    for route in app.routes:
        if hasattr(route, 'methods'):
            methods = ', '.join(route.methods)
            print(f"  {methods:8} {route.path}")
    print()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)