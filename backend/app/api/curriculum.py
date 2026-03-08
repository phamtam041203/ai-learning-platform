"""Curriculum endpoints"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pathlib import Path
import json

from app.database import get_db
from app.dependencies import get_current_admin
from app.models.course import Course, CourseLevel
from app.models.user import User

router = APIRouter(prefix="/curriculum", tags=["Curriculum"])

DATA_PATH = Path(__file__).resolve().parents[1] / "data" / "curriculum_cnpm.json"


def load_curriculum() -> dict:
    if not DATA_PATH.exists():
        raise HTTPException(404, "Curriculum data not found")
    return json.loads(DATA_PATH.read_text(encoding="utf-8"))


@router.get("/cnpm")
async def get_cnpm_curriculum():
    return load_curriculum()


@router.post("/cnpm/seed")
async def seed_cnpm_courses(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    curriculum = load_curriculum()

    created = []
    skipped = []

    for phase in curriculum.get("phases", []):
        for course in phase.get("courses", []):
            course_code = course["code"]
            existing = db.query(Course).filter(Course.course_code == course_code).first()
            if existing:
                skipped.append(course_code)
                continue

            specialization = curriculum.get("specialization_code")
            description = (
                f"Giai đoạn: {phase['name']}\n"
                f"Loại: {course['type']}\n"
                f"Tiên quyết: {', '.join(course.get('prerequisites', [])) or 'Không'}"
            )

            new_course = Course(
                course_code=course_code,
                course_name=course["name"],
                description=description,
                major="CNTT",
                specialization=specialization,
                credit_hours=course.get("credit_hours", 3),
                level=CourseLevel.BEGINNER,
                is_active=True
            )
            db.add(new_course)
            created.append(course_code)

    db.commit()

    return {
        "created": created,
        "skipped": skipped,
        "total_created": len(created),
        "total_skipped": len(skipped)
    }
