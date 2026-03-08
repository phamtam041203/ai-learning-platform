from app.database import SessionLocal
from app.models import Course

db = SessionLocal()
courses = db.query(Course).all()
for c in courses:
    print(f"{c.course_code}: {c.course_name}")
db.close()
