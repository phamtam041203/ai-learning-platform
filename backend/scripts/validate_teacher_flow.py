from fastapi.testclient import TestClient

from app.database import SessionLocal
from app.main import app
from app.models.user import User, UserRole
from app.utils.security import create_access_token


def main() -> None:
    db = SessionLocal()
    try:
        teacher = db.query(User).filter(User.role == UserRole.TEACHER).first()
        if teacher is None:
            print({"error": "No teacher account found"})
            return

        token = create_access_token(
            {"sub": teacher.email, "role": teacher.role.value, "user_id": teacher.id}
        )
    finally:
        db.close()

    headers = {"Authorization": f"Bearer {token}"}
    results: dict[str, int | str] = {}

    with TestClient(app) as client:
        response = client.get("/api/teacher/dashboard", headers=headers)
        results["dashboard"] = response.status_code

        response = client.post(
            "/api/teacher/courses",
            headers=headers,
            json={
                "title": "Kiem thu giao vien",
                "description": "course test",
                "category": "programming",
            },
        )
        results["create_course"] = response.status_code
        if response.status_code != 200:
            results["create_course_body"] = response.text
            print(results)
            return

        course = response.json()
        course_id = course["id"]

        response = client.put(
            f"/api/teacher/courses/{course_id}",
            headers=headers,
            json={
                "title": "Kiem thu giao vien updated",
                "description": "updated",
                "category": "design",
            },
        )
        results["update_course"] = response.status_code

        response = client.post(
            "/api/teacher/quizzes",
            headers=headers,
            json={
                "course_id": course_id,
                "title": "Quiz test",
                "description": "quiz mo ta",
                "is_published": True,
                "questions": [
                    {
                        "question_text": "1+1=?",
                        "option_a": "1",
                        "option_b": "2",
                        "option_c": "3",
                        "option_d": "4",
                        "correct_answer": "b",
                        "explanation": "2",
                        "points": 1,
                    },
                    {
                        "question_text": "2+2=?",
                        "option_a": "2",
                        "option_b": "3",
                        "option_c": "4",
                        "option_d": "5",
                        "correct_answer": "c",
                        "explanation": "4",
                        "points": 1,
                    },
                ],
            },
        )
        results["create_quiz"] = response.status_code
        if response.status_code != 200:
            results["create_quiz_body"] = response.text
            print(results)
            return

        quiz = response.json()
        quiz_id = quiz["id"]

        response = client.get(f"/api/teacher/courses/{course_id}/quizzes", headers=headers)
        results["list_quizzes"] = response.status_code

        response = client.put(
            f"/api/teacher/quizzes/{quiz_id}",
            headers=headers,
            json={
                "title": "Quiz test updated",
                "description": "quiz update",
                "is_published": False,
                "questions": [
                    {
                        "question_text": "3+3=?",
                        "option_a": "5",
                        "option_b": "6",
                        "option_c": "7",
                        "option_d": "8",
                        "correct_answer": "b",
                        "explanation": "6",
                        "points": 2,
                    }
                ],
            },
        )
        results["update_quiz"] = response.status_code

        response = client.delete(f"/api/teacher/quizzes/{quiz_id}", headers=headers)
        results["delete_quiz"] = response.status_code

        response = client.delete(f"/api/teacher/courses/{course_id}", headers=headers)
        results["delete_course"] = response.status_code

    print(results)


if __name__ == "__main__":
    main()