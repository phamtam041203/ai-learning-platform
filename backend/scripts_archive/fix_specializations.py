#!/usr/bin/env python
"""Fix specialization - convert Vietnamese text to codes"""
from app.database import SessionLocal
from app.models import StudentProfile

db = SessionLocal()

try:
    # Map Vietnamese text to codes
    conversion_map = {
        "Công nghệ phần mềm": "CNPM",
        "Công nghệ dữ liệu": "CNDL",
        "An ninh mạng": "ANM",
    }
    
    # Find all profiles with Vietnamese specialization
    for vietnamese_text, code in conversion_map.items():
        profiles = db.query(StudentProfile).filter(
            StudentProfile.specialization == vietnamese_text
        ).all()
        
        if profiles:
            print(f"Found {len(profiles)} students with specialization: {vietnamese_text}")
            for profile in profiles:
                profile.specialization = code
                print(f"  ✅ Updated student {profile.student_id}: {vietnamese_text} → {code}")
            db.commit()
    
    # Check for students without specialization
    no_spec = db.query(StudentProfile).filter(
        StudentProfile.specialization.is_(None)
    ).all()
    
    if no_spec:
        print(f"\nFound {len(no_spec)} students without specialization (will need modal on login)")
    else:
        print(f"\n✅ All students have specialization set!")
    
    print("\n✨ Conversion complete!")
    
except Exception as e:
    print(f"❌ Error: {e}")
    db.rollback()
finally:
    db.close()
