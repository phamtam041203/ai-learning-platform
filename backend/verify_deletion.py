#!/usr/bin/env python
"""Verify that only Web Development course remains in the database."""

import sys
sys.stdout.reconfigure(encoding='utf-8')

from app.database import SessionLocal
from app.models import Course, Lesson, Enrollment

db = SessionLocal()

try:
    # Get all courses
    courses = db.query(Course).all()
    print(f"\n{'='*60}")
    print(f"📊 DATABASE VERIFICATION - AFTER COURSE DELETION")
    print(f"{'='*60}\n")
    
    print(f"✅ Total Courses: {len(courses)}\n")
    
    if len(courses) == 0:
        print("❌ ERROR: No courses found in database!")
    else:
        for course in courses:
            lessons = db.query(Lesson).filter(Lesson.course_id == course.id).all()
            enrollments = db.query(Enrollment).filter(Enrollment.course_id == course.id).all()
            
            print(f"📚 Course Details:")
            print(f"   ID: {course.id}")
            print(f"   Name: {course.course_name}")
            print(f"   Code: {course.course_code}")
            print(f"   Specialization: {course.specialization}")
            print(f"   Lessons: {len(lessons)}")
            print(f"   Enrollments: {len(enrollments)}")
            print()
    
    if len(courses) == 1:
        course = courses[0]
        if "Web" in course.course_name or "web" in course.course_code.lower():
            print(f"✅ SUCCESS! Only Web Development course remains!")
            print(f"   Course: {course.course_code} - {course.course_name}")
        else:
            print(f"⚠️  WARNING: Only one course remains but it's not Web Development")
            print(f"   Found: {course.course_code} - {course.course_name}")
    elif len(courses) > 1:
        print(f"❌ ERROR: Multiple courses still in database ({len(courses)})")
        print(f"   The deletion script may not have worked properly")
    
    print(f"\n{'='*60}\n")
    
finally:
    db.close()
