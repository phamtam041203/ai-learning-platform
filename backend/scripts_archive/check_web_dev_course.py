from app.database import SessionLocal
from app.models import Course

db = SessionLocal()

# Tìm khóa học "Lập Trình Ứng Dụng Web"
courses = db.query(Course).all()
print(f"\n📚 Tổng số khóa học: {len(courses)}\n")

web_dev_courses = [c for c in courses if 'web' in c.course_name.lower() or (c.description and 'web' in c.description.lower())]
print(f"🔍 Khóa học liên quan 'Web':\n")
for c in web_dev_courses:
    print(f"  ID: {c.id}")
    print(f"  Tên: {c.course_name}")
    print(f"  Mã: {c.course_code}")
    print(f"  Specialization: {c.specialization}")
    print(f"  Level: {c.level}")
    print()

# Nếu không có, liệt kê tất cả khóa học CNPM
print("\n" + "="*60)
print("📋 Tất cả khóa học theo specialization:\n")
cnpm_courses = [c for c in courses if c.specialization == 'CNPM']
cndl_courses = [c for c in courses if c.specialization == 'CNDL']
anm_courses = [c for c in courses if c.specialization == 'ANM']

print(f"🔧 CNPM ({len(cnpm_courses)} khóa):")
for c in cnpm_courses:
    print(f"  - {c.course_name}")

print(f"\n📊 CNDL ({len(cndl_courses)} khóa):")
for c in cndl_courses:
    print(f"  - {c.course_name}")

print(f"\n🔐 ANM ({len(anm_courses)} khóa):")
for c in anm_courses:
    print(f"  - {c.course_name}")

db.close()
