"""
FastAPI application with Celery integration
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import auth, analytics, chatbot, courses, materials, student, teacher
from database import init_db

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    description="Backend API cho hệ thống học tập thông minh với AI - Đại học Văn Lang",
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(analytics.router, prefix="/api/analytics", tags=["Analytics"])
app.include_router(chatbot.router, prefix="/api/chatbot", tags=["Chatbot"])
app.include_router(courses.router, prefix="/api/courses", tags=["Courses"])
app.include_router(materials.router, prefix="/api/materials", tags=["Materials"])
app.include_router(student.router, prefix="/api/student", tags=["Student"])
app.include_router(teacher.router, prefix="/api/teacher", tags=["Teacher"])


@app.get("/")
async def root():
    return {
        "message": "AI Learning Platform API",
        "university": settings.UNIVERSITY_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.on_event("startup")
async def startup_event():
    print("🚀 Starting AI Learning Platform...")
    init_db()
    print("✅ API is ready!")


@app.on_event("shutdown")
async def shutdown_event():
    print("👋 Shutting down...")