"""
Generate project data diagrams from Python code.

Outputs:
- docs/diagrams/so_do_luong_du_lieu.png
- docs/diagrams/so_do_lien_ket_du_lieu.png
- docs/diagrams/so_do_quan_he_du_lieu.png
- docs/diagrams/so_do_ho_so_sinh_vien.png
- docs/diagrams/so_do_phan_cap_chuc_nang.png
- docs/diagrams/so_do_xu_ly_du_lieu_hoc_tap.png
- docs/diagrams/so_do_goi_y_noi_dung_hoc_tap.png

Requirements:
1) pip install graphviz
2) Graphviz binary installed and available in PATH (dot command)
"""

from pathlib import Path

from graphviz import Digraph, Graph
from graphviz.backend.execute import ExecutableNotFound


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "diagrams"


def build_dfd() -> Digraph:
    g = Digraph("dfd_system", format="png")
    g.attr(rankdir="LR", fontsize="11")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("student", "Student")
    g.node("teacher", "Teacher")
    g.node("admin", "Admin")

    g.node("fe", "Frontend\nReact + Vite", fillcolor="#e0f2fe")
    g.node("api", "FastAPI Backend", fillcolor="#dbeafe")

    g.node("auth", "Auth API")
    g.node("student_api", "Student API")
    g.node("courses", "Courses API")
    g.node("teacher_api", "Teacher API")
    g.node("admin_api", "Admin API")
    g.node("chatbot", "Chatbot API")

    g.node("pg", "PostgreSQL", shape="cylinder", fillcolor="#fef3c7")
    g.node("redis", "Redis", shape="cylinder", fillcolor="#fee2e2")
    g.node("mongo", "MongoDB", shape="cylinder", fillcolor="#dcfce7")
    g.node("gemini", "Gemini AI", shape="component", fillcolor="#ede9fe")
    g.node("uploads", "Uploads", shape="folder", fillcolor="#f1f5f9")

    g.edge("student", "fe", "login/learn/quiz")
    g.edge("teacher", "fe", "manage content")
    g.edge("admin", "fe", "manage system")
    g.edge("fe", "api", "REST API")

    for name in ["auth", "student_api", "courses", "teacher_api", "admin_api", "chatbot"]:
        g.edge("api", name)

    for name in ["auth", "student_api", "courses", "teacher_api", "admin_api"]:
        g.edge(name, "pg")

    g.edge("student_api", "redis")
    g.edge("chatbot", "redis")
    g.edge("student_api", "mongo")
    g.edge("chatbot", "mongo")
    g.edge("chatbot", "gemini")

    g.edge("api", "uploads")
    g.edge("uploads", "pg", "file refs")

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "api", style="dashed", arrowhead="none")
    return g


def build_data_link() -> Digraph:
    g = Digraph("data_link", format="png")
    g.attr(rankdir="TB", fontsize="11")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("pages", "Frontend Pages\n(student/teacher/admin)", fillcolor="#e0f2fe")
    g.node("svc", "frontend/src/services/api.js", fillcolor="#dbeafe")
    g.node("cfg", "frontend/src/config/api.js\n(API_URL/buildApiUrl)")
    g.node("routers", "FastAPI Routers", fillcolor="#ede9fe")
    g.node("models", "SQLAlchemy Models", fillcolor="#fce7f3")
    g.node("db", "PostgreSQL", shape="cylinder", fillcolor="#fef3c7")
    g.node("redis", "Redis", shape="cylinder", fillcolor="#fee2e2")
    g.node("mongo", "MongoDB", shape="cylinder", fillcolor="#dcfce7")
    g.node("ai", "Gemini", shape="component", fillcolor="#ede9fe")

    g.edge("pages", "svc")
    g.edge("svc", "cfg", "base URLs")
    g.edge("svc", "routers", "HTTP requests")
    g.edge("routers", "models")
    g.edge("models", "db")
    g.edge("routers", "redis")
    g.edge("routers", "mongo")
    g.edge("routers", "ai")

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "routers", style="dashed", arrowhead="none")
    return g


def build_erd_core() -> Graph:
    g = Graph("erd_core", format="png")
    g.attr(layout="neato", overlap="false", splines="true")
    g.attr("node", shape="record", style="filled", fillcolor="#f8fafc", color="#64748b", fontsize="10")

    def table(name: str, fields: list[str]):
        body = "|".join(fields)
        g.node(name, "{" + name + "|" + body + "}")

    table("USERS", ["id PK", "email", "role", "full_name"])
    table("STUDENT_PROFILES", ["id PK", "user_id FK", "student_id", "major", "specialization"])
    table("TEACHER_PROFILES", ["id PK", "user_id FK", "teacher_id", "department"])
    table("COURSES", ["id PK", "teacher_id FK", "course_code", "course_name"])
    table("LESSONS", ["id PK", "course_id FK", "title", "order"])
    table("ENROLLMENTS", ["id PK", "student_id FK", "course_id FK", "status", "total_score"])
    table("LESSON_PROGRESS", ["id PK", "student_id FK", "lesson_id FK", "is_completed"])
    table("ASSESSMENTS", ["id PK", "course_id FK", "title", "assessment_type"])
    table("QUESTIONS", ["id PK", "assessment_id FK", "question_text"])
    table("SUBMISSIONS", ["id PK", "assessment_id FK", "student_id FK", "score"])
    table("QUIZ_RESULTS", ["id PK", "user_id FK", "lesson_id FK", "score"])
    table("ESSAY_SUBMISSIONS", ["id PK", "lesson_id FK", "student_id FK", "course_id FK", "score"])
    table("RECOMMENDATIONS", ["id PK", "student_id FK", "recommendation_type", "confidence_score"])
    table("STUDENT_SKILL_PROFILES", ["id PK", "student_id FK", "skill_id", "confidence"])

    g.edge("USERS", "STUDENT_PROFILES", label="1-0..1")
    g.edge("USERS", "TEACHER_PROFILES", label="1-0..1")
    g.edge("USERS", "COURSES", label="1-N teaches")
    g.edge("USERS", "ENROLLMENTS", label="1-N student")

    g.edge("COURSES", "LESSONS", label="1-N")
    g.edge("COURSES", "ENROLLMENTS", label="1-N")
    g.edge("COURSES", "ASSESSMENTS", label="1-N")

    g.edge("LESSONS", "LESSON_PROGRESS", label="1-N")
    g.edge("LESSONS", "QUIZ_RESULTS", label="1-N")
    g.edge("LESSONS", "ESSAY_SUBMISSIONS", label="1-N")

    g.edge("ASSESSMENTS", "QUESTIONS", label="1-N")
    g.edge("ASSESSMENTS", "SUBMISSIONS", label="1-N")

    g.edge("USERS", "SUBMISSIONS", label="1-N student")
    g.edge("USERS", "QUIZ_RESULTS", label="1-N")
    g.edge("USERS", "ESSAY_SUBMISSIONS", label="1-N")
    g.edge("USERS", "RECOMMENDATIONS", label="1-N")
    g.edge("USERS", "STUDENT_SKILL_PROFILES", label="1-N")

    g.node("LEGEND", "{GHI_CHÚ|1-1: một-một|1-N: một-nhiều}", shape="record", fillcolor="#fff7ed")
    g.edge("LEGEND", "USERS", style="dashed", arrowhead="none")
    return g


def build_student_profile_flow() -> Digraph:
    g = Digraph("student_profile_flow", format="png")
    g.attr(rankdir="LR", fontsize="11")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("users", "Users")
    g.node("profile", "StudentProfile", fillcolor="#e0f2fe")
    g.node("enrollments", "Enrollments")
    g.node("progress", "LessonProgress")
    g.node("quiz", "QuizResults")
    g.node("essay", "EssaySubmissions")
    g.node("skills", "StudentSkillProfiles", fillcolor="#dcfce7")
    g.node("reco", "Recommendations", fillcolor="#ede9fe")
    g.node("activity", "LearningActivities")

    g.edge("users", "profile", "1-1")
    g.edge("users", "enrollments", "1-N")
    g.edge("users", "progress", "1-N")
    g.edge("users", "quiz", "1-N")
    g.edge("users", "essay", "1-N")
    g.edge("users", "skills", "1-N")
    g.edge("users", "reco", "1-N")
    g.edge("users", "activity", "1-N")

    g.edge("enrollments", "profile", "course status")
    g.edge("progress", "profile", "lesson completion")
    g.edge("quiz", "skills", "performance signals")
    g.edge("essay", "skills", "writing signals")
    g.edge("skills", "reco", "skill-gap input")

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "users", style="dashed", arrowhead="none")
    return g


def build_function_hierarchy() -> Digraph:
    g = Digraph("function_hierarchy", format="png")
    g.attr(rankdir="TB", fontsize="10")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("root", "AI Learning Platform", fillcolor="#dbeafe")

    g.node("u", "1. User Management")
    g.node("l", "2. Teaching & Learning")
    g.node("a", "3. Assessment")
    g.node("p", "4. Progress Tracking")
    g.node("r", "5. AI Assistant & Recommendation")
    g.node("adm", "6. Administration")

    g.edge("root", "u")
    g.edge("root", "l")
    g.edge("root", "a")
    g.edge("root", "p")
    g.edge("root", "r")
    g.edge("root", "adm")

    for parent, children in {
        "u": ["login", "profile", "rbac"],
        "l": ["course_mgmt", "lesson_mgmt", "enrollment"],
        "a": ["quiz", "essay", "grading"],
        "p": ["lesson_prog", "course_comp", "cert"],
        "r": ["chat", "skill_analysis", "content_reco"],
        "adm": ["dashboard", "data_ops", "qa"],
    }.items():
        for child in children:
            labels = {
                "login": "1.1 Login/Register",
                "profile": "1.2 Student/Teacher Profile",
                "rbac": "1.3 Roles & Permissions",
                "course_mgmt": "2.1 Course Management",
                "lesson_mgmt": "2.2 Lesson Management",
                "enrollment": "2.3 Enrollment",
                "quiz": "3.1 Quiz",
                "essay": "3.2 Essay",
                "grading": "3.3 Grading & Feedback",
                "lesson_prog": "4.1 Lesson Progress",
                "course_comp": "4.2 Course Completion",
                "cert": "4.3 Certificate",
                "chat": "5.1 Chatbot",
                "skill_analysis": "5.2 Skill Analysis",
                "content_reco": "5.3 Content Recommendation",
                "dashboard": "6.1 Admin Dashboard",
                "data_ops": "6.2 Data Management",
                "qa": "6.3 Quality Control",
            }
            g.node(child, labels[child], fillcolor="#eef2ff")
            g.edge(parent, child)

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "root", style="dashed", arrowhead="none")

    return g


def build_data_processing_pipeline() -> Digraph:
    g = Digraph("data_processing_pipeline", format="png")
    g.attr(rankdir="LR", fontsize="11")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("event", "Learning Events\n(lesson view, quiz, essay)", fillcolor="#e0f2fe")
    g.node("fe", "Frontend Event Payload")
    g.node("api", "FastAPI Endpoint")
    g.node("val", "Auth + Validation")
    g.node("pg", "PostgreSQL\ntransactional", shape="cylinder", fillcolor="#fef3c7")
    g.node("redis", "Redis\nrealtime state", shape="cylinder", fillcolor="#fee2e2")
    g.node("mongo", "MongoDB\nactivity logs", shape="cylinder", fillcolor="#dcfce7")
    g.node("agg", "Aggregation Job")
    g.node("update", "Update Progress + Scores", fillcolor="#dbeafe")
    g.node("snapshot", "Student Profile Snapshot", fillcolor="#dbeafe")
    g.node("engine", "Recommendation Engine", fillcolor="#ede9fe")
    g.node("table", "Recommendations Table")
    g.node("dash", "Student Dashboard")

    g.edge("event", "fe")
    g.edge("fe", "api")
    g.edge("api", "val")
    g.edge("val", "pg")
    g.edge("val", "redis")
    g.edge("val", "mongo")
    g.edge("pg", "agg")
    g.edge("redis", "agg")
    g.edge("mongo", "agg")
    g.edge("agg", "update")
    g.edge("update", "snapshot")
    g.edge("snapshot", "engine")
    g.edge("engine", "table")
    g.edge("table", "dash")

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "update", style="dashed", arrowhead="none")
    return g


def build_content_recommendation_flow() -> Digraph:
    g = Digraph("content_recommendation_flow", format="png")
    g.attr(rankdir="TB", fontsize="10")
    g.attr("node", shape="box", style="rounded,filled", fillcolor="#f8fafc", color="#475569")

    g.node("i1", "Student Context\n(major, specialization, goals)")
    g.node("i2", "Learning History\n(enrollments, progress, scores)")
    g.node("i3", "Behavior Signals\n(time, frequency, interests)")
    g.node("i4", "Content Metadata\n(topic, difficulty, skill tags)")

    g.node("features", "Feature Builder", fillcolor="#e0f2fe")
    g.node("rule", "Rule-based Filter\n(prerequisite, level)")
    g.node("gap", "Skill-gap Scoring")
    g.node("pop", "Popularity Prior")
    g.node("rank", "Ranking + Merge", fillcolor="#dbeafe")
    g.node("topn", "Top-N Recommendations", fillcolor="#ede9fe")
    g.node("ui", "Student Dashboard")
    g.node("fb", "Feedback\n(click/complete/skip)")
    g.node("loop", "Model Update", fillcolor="#dcfce7")

    for n in ["i1", "i2", "i3", "i4"]:
        g.edge(n, "features")

    g.edge("features", "rule")
    g.edge("features", "gap")
    g.edge("features", "pop")
    g.edge("rule", "rank")
    g.edge("gap", "rank")
    g.edge("pop", "rank")
    g.edge("rank", "topn")
    g.edge("topn", "ui")
    g.edge("ui", "fb")
    g.edge("fb", "loop")
    g.edge("loop", "features")

    g.node("legend", "Ghi chú:\n1-1: một - một\n1-N: một - nhiều", shape="note", fillcolor="#fff7ed")
    g.edge("legend", "features", style="dashed", arrowhead="none")
    return g


def render_all() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    diagrams = {
        "so_do_luong_du_lieu": build_dfd(),
        "so_do_lien_ket_du_lieu": build_data_link(),
        "so_do_quan_he_du_lieu": build_erd_core(),
        "so_do_ho_so_sinh_vien": build_student_profile_flow(),
        "so_do_phan_cap_chuc_nang": build_function_hierarchy(),
        "so_do_xu_ly_du_lieu_hoc_tap": build_data_processing_pipeline(),
        "so_do_goi_y_noi_dung_hoc_tap": build_content_recommendation_flow(),
    }

    try:
        for name, graph in diagrams.items():
            graph.render(str(OUT_DIR / name), cleanup=True)

        print("Generated diagrams:")
        print(f"- {OUT_DIR / 'so_do_luong_du_lieu.png'}")
        print(f"- {OUT_DIR / 'so_do_lien_ket_du_lieu.png'}")
        print(f"- {OUT_DIR / 'so_do_quan_he_du_lieu.png'}")
        print(f"- {OUT_DIR / 'so_do_ho_so_sinh_vien.png'}")
        print(f"- {OUT_DIR / 'so_do_phan_cap_chuc_nang.png'}")
        print(f"- {OUT_DIR / 'so_do_xu_ly_du_lieu_hoc_tap.png'}")
        print(f"- {OUT_DIR / 'so_do_goi_y_noi_dung_hoc_tap.png'}")
    except ExecutableNotFound:
        print("Graphviz binary 'dot' was not found.")
        print("Writing .dot files instead:")

        for name, graph in diagrams.items():
            dot_path = OUT_DIR / f"{name}.dot"
            dot_path.write_text(graph.source, encoding="utf-8")
            print(f"- {dot_path}")

        print("\nInstall Graphviz binary and run this script again to generate PNG files.")


if __name__ == "__main__":
    render_all()
