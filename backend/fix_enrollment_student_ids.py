"""
Fix enrollment student_id references
Change from profile.id to user.id
"""
from app.database import SessionLocal
from app.models import Enrollment, User, StudentProfile

db = SessionLocal()

try:
    print("🔧 Fixing enrollment student_id references...\n")
    
    # Get all enrollments
    enrollments = db.query(Enrollment).all()
    print(f"📊 Found {len(enrollments)} enrollments")
    
    fixed_count = 0
    deleted_count = 0
    
    for enrollment in enrollments:
        # Check if student_id is actually a profile.id
        profile = db.query(StudentProfile).filter(StudentProfile.id == enrollment.student_id).first()
        
        if profile:
            # This enrollment has student_id = profile.id (WRONG)
            # Need to change to user.id
            user = db.query(User).filter(User.id == profile.user_id).first()
            
            if user:
                print(f"  ⚠️  Enrollment #{enrollment.id}: student_id={enrollment.student_id} (profile) → {user.id} (user)")
                
                # Check if there's already an enrollment with correct user.id
                existing = db.query(Enrollment).filter(
                    Enrollment.student_id == user.id,
                    Enrollment.course_id == enrollment.course_id,
                    Enrollment.id != enrollment.id
                ).first()
                
                if existing:
                    print(f"      ❌ Duplicate exists, deleting old enrollment")
                    db.delete(enrollment)
                    deleted_count += 1
                else:
                    print(f"      ✅ Updating to user.id")
                    enrollment.student_id = user.id
                    fixed_count += 1
    
    db.commit()
    
    print(f"\n✅ Fixed {fixed_count} enrollments")
    print(f"🗑️  Deleted {deleted_count} duplicates")
    print("\n🎉 Database fixed!")

except Exception as e:
    print(f"\n❌ Error: {e}")
    db.rollback()
finally:
    db.close()
