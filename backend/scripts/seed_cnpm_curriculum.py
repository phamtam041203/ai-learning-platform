import os
import sys
import json
from pathlib import Path

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.database import SessionLocal
from app.models.course import Course, CourseLevel

DATA_PATH = Path(__file__).resolve().parents[1] / "app" / "data" / "curriculum_cnpm.json"


def main() -> None:
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Curriculum not found: {DATA_PATH}")

    curriculum = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    db = SessionLocal()

    created = []
    skipped = []

    try:
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
    finally:
        db.close()

    print("CREATED", len(created), created)
    print("SKIPPED", len(skipped), skipped)


if __name__ == "__main__":
    main()
