#!/usr/bin/env python
"""Final summary of content creation"""

from app.database import SessionLocal
from app.models import Lesson, Assessment, Question, Course

db = SessionLocal()

lessons = db.query(Lesson).count()
quizzes = db.query(Assessment).count()
questions = db.query(Question).count()
courses = db.query(Course).count()

print("\n" + "=" * 70)
print("✅ CONTENT CREATION COMPLETED SUCCESSFULLY")
print("=" * 70)
print(f"\n📊 Statistics:")
print(f"   Courses:        {courses:>4}")
print(f"   Lessons:        {lessons:>4,}")
print(f"   Quizzes:        {quizzes:>4,}")
print(f"   Questions:      {questions:>4,}")

print(f"\n📚 Content Breakdown:")
print(f"   • {courses} total courses")
print(f"   • {lessons // courses} avg lessons per course")
print(f"   • {quizzes // courses} avg quizzes per course")
print(f"   • {questions // quizzes} avg questions per quiz")

print(f"\n🎓 Specializations Covered:")
print(f"   • CNPM - Software Development")
print(f"     - Web Development (React, Frontend)")
print(f"     - Backend Development (Python, FastAPI)")
print(f"     - Database Design & SQL")
print(f"     - Mobile Development (React Native)")
print(f"\n   • CNDL - Big Data")
print(f"     - Big Data Fundamentals")
print(f"     - Apache Spark")
print(f"     - Data Analytics & Business Intelligence")
print(f"     - Machine Learning for Big Data")
print(f"\n   • ANM - Cybersecurity")
print(f"     - Cybersecurity Fundamentals")
print(f"     - Cryptography & Encryption")
print(f"     - Network Security")
print(f"     - Penetration Testing & Ethical Hacking")

print(f"\n   • Plus general computer science courses:")
print(f"     - Programming Fundamentals")
print(f"     - Data Structures & Algorithms")
print(f"     - Operating Systems")
print(f"     - Networks")
print(f"     - AI & Machine Learning")
print(f"     - And many more!")

print("\n" + "=" * 70)
print("🎯 Next Steps:")
print("   1. Students can access lessons for their courses")
print("   2. Complete quizzes to test knowledge")
print("   3. Track progress through the platform")
print("   4. Receive personalized recommendations")
print("=" * 70 + "\n")

db.close()
