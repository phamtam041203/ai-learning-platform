"""Check quizzes in database"""
import os
import sys

# Set working directory
os.chdir('D:/KLTN/ai-learning-platform/backend')
sys.path.insert(0, 'D:/KLTN/ai-learning-platform/backend')

from app.db.database import SessionLocal
from app.models.assessment import Assessment, Question

db = SessionLocal()

print("=" * 50)
print("QUIZ DATABASE CHECK")
print("=" * 50)

total_assessments = db.query(Assessment).count()
total_questions = db.query(Question).count()

print(f"Total assessments: {total_assessments}")
print(f"Total questions: {total_questions}")

print("\n--- Sample Assessments ---")
assessments = db.query(Assessment).limit(10).all()
for a in assessments:
    q_count = db.query(Question).filter(Question.assessment_id == a.id).count()
    print(f"ID:{a.id}, Course:{a.course_id}, Type:{a.assessment_type}, Questions:{q_count}")
    print(f"   Title: {a.title[:60]}...")

db.close()
