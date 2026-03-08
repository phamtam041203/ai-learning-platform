"""Remove CNPM curriculum courses and related data."""
from pathlib import Path
import json

from app.database import SessionLocal
from app.models import (
    Course,
    Enrollment,
    Lesson,
    LessonProgress,
    Material,
    Assessment,
    Submission,
    Question
)
from app.models.assessment import QuizResult

DATA_PATH = Path(__file__).resolve().parents[1] / "app" / "data" / "curriculum_cnpm.json"


def main() -> None:
    curriculum = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    codes = [
        c["code"]
        for phase in curriculum.get("phases", [])
        for c in phase.get("courses", [])
    ]

    db = SessionLocal()
    try:
        courses = db.query(Course).filter(Course.course_code.in_(codes)).all()
        course_ids = [c.id for c in courses]

        if course_ids:
            db.query(Enrollment).filter(Enrollment.course_id.in_(course_ids)).delete(synchronize_session=False)
            db.query(LessonProgress).filter(
                LessonProgress.lesson_id.in_(
                    db.query(Lesson.id).filter(Lesson.course_id.in_(course_ids))
                )
            ).delete(synchronize_session=False)
            db.query(Submission).filter(
                Submission.assessment_id.in_(
                    db.query(Assessment.id).filter(Assessment.course_id.in_(course_ids))
                )
            ).delete(synchronize_session=False)
            db.query(QuizResult).filter(
                QuizResult.assessment_id.in_(
                    db.query(Assessment.id).filter(Assessment.course_id.in_(course_ids))
                )
            ).delete(synchronize_session=False)
            db.query(Question).filter(
                Question.assessment_id.in_(
                    db.query(Assessment.id).filter(Assessment.course_id.in_(course_ids))
                )
            ).delete(synchronize_session=False)
            db.query(Assessment).filter(Assessment.course_id.in_(course_ids)).delete(synchronize_session=False)
            db.query(Material).filter(Material.course_id.in_(course_ids)).delete(synchronize_session=False)
            db.query(Lesson).filter(Lesson.course_id.in_(course_ids)).delete(synchronize_session=False)
            db.query(Course).filter(Course.id.in_(course_ids)).delete(synchronize_session=False)

        db.commit()
        print(f"Deleted courses: {len(course_ids)}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
