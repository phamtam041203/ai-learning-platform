"""Import course files from /Courses into DB and uploads."""
from __future__ import annotations

from pathlib import Path
import shutil

from app.database import SessionLocal
from app.models import Course, Lesson
from app.models.assessment import Assessment, AssessmentType

BASE_DIR = Path(__file__).resolve().parents[1]
COURSES_DIR = BASE_DIR / ".." / "Courses"
UPLOAD_LESSONS_DIR = BASE_DIR / "uploads" / "lessons"
UPLOAD_ASSESSMENTS_DIR = BASE_DIR / "uploads" / "assessments"

COURSE_FOLDER_MAP = {
    "CoSoNganh/NhapMonCNTT": "IT101",
    "CoSoNganh/CoSoLapTrinh": "PR101",
    "CoSoNganh/KyThuatLapTrinh": "PR102",
    "CoSoNganh/NhapMonMangMayTinhVaDienToanDamMay": "NET101",
    "CoSoNganh/CauTrucDuLieuVaGiaiThuat": "DSA101",

    "MonBatBuoc/CoSoDuLieu": "DB101",
    "MonBatBuoc/Laptrinhungdungweb": "WEB101",
    "CNPM/LapTrinhHuongDoiTuong": "OOP101",

    "MonBatBuoc/HeQuanTriCSDL": "EL201",
    "MonBatBuoc/LapTrinhgUngDungJava": "EL202",
    "MonBatBuoc/AnNinhMangMT": "EL203",
    "MonBatBuoc/QuanLyDuAnCNTT": "EL204",
    "MonBatBuoc/ThietKeGiaoDienNguoiDung": "EL205",
    "MonBatBuoc/LapTrinhungdungdidong": "EL206",
    "MonBatBuoc/QuanLyVaPhatTrienCacHeThongThongTin": "EL207",

    "CNPM/NhapMonCongNghePhanMeM": "SE101",
    "CNPM/KythuatLayYeuCau": "RE101",
    "CNPM/KiemThuPhanMem": "TEST101",
    "CNPM/PhanTichVaThietKeHeThongTheoHuongDoiTuong": "SAD101",
    "CNPM/LapTrinhWebNangCao": "WEB201",
    "CNPM/QuanLyDuAnPhanMem": "SEPM101",

    "TotNghiep/DoAnThucTap": "INTERN401",
    "TotNghiep/KhoaLuanTotNghiep": "GRAD401"
}


def _normalize_title(file_name: str) -> str:
    name = file_name.rsplit(".", 1)[0]
    name = name.replace("_", " ").replace("-", " ").strip()
    return " ".join(name.split())


def _ensure_dirs() -> None:
    UPLOAD_LESSONS_DIR.mkdir(parents=True, exist_ok=True)
    UPLOAD_ASSESSMENTS_DIR.mkdir(parents=True, exist_ok=True)


def import_for_course(db, course: Course, course_dir: Path) -> None:
    theory_dir = course_dir / "LyThuyet"
    quiz_dir = course_dir / "BaiTap"

    if theory_dir.exists():
        files = sorted([p for p in theory_dir.iterdir() if p.is_file()])
        for idx, file_path in enumerate(files, start=1):
            prefixed_name = f"{course.course_code}__{file_path.name}"
            dest_path = UPLOAD_LESSONS_DIR / prefixed_name

            existing = db.query(Lesson).filter(
                Lesson.course_id == course.id,
                Lesson.pdf_file_name == prefixed_name
            ).first()
            if not existing:
                shutil.copy2(file_path, dest_path)
                lesson = Lesson(
                    course_id=course.id,
                    title=_normalize_title(file_path.name),
                    description=f"Tài liệu: {file_path.name}",
                    order=idx,
                    is_published=True,
                    pdf_file_name=prefixed_name
                )
                db.add(lesson)
            else:
                if not dest_path.exists():
                    shutil.copy2(file_path, dest_path)

    if quiz_dir.exists():
        files = sorted([p for p in quiz_dir.iterdir() if p.is_file()])
        for idx, file_path in enumerate(files, start=1):
            dest_name = f"{course.course_code}__{file_path.name}"
            dest_path = UPLOAD_ASSESSMENTS_DIR / dest_name

            title = _normalize_title(file_path.name)
            existing = db.query(Assessment).filter(
                Assessment.course_id == course.id,
                Assessment.title == title
            ).first()

            if not existing:
                shutil.copy2(file_path, dest_path)
                assessment = Assessment(
                    course_id=course.id,
                    title=title,
                    description=f"Quiz từ file: {file_path.name}",
                    assessment_type=AssessmentType.QUIZ,
                    max_score=10.0,
                    weight=1.0,
                    passing_score=5.0,
                    is_published=True,
                    attachment_url=str(dest_path),
                    attachment_name=file_path.name
                )
                db.add(assessment)
            else:
                if not dest_path.exists():
                    shutil.copy2(file_path, dest_path)


def main() -> None:
    _ensure_dirs()

    db = SessionLocal()
    try:
        for folder, course_code in COURSE_FOLDER_MAP.items():
            course_dir = (COURSES_DIR / folder).resolve()
            if not course_dir.exists():
                print(f"⚠️  Missing folder: {course_dir}")
                continue

            course = db.query(Course).filter(Course.course_code == course_code).first()
            if not course:
                print(f"⚠️  Missing course in DB: {course_code}")
                continue

            print(f"📚 Importing {course_code} from {course_dir}")
            import_for_course(db, course, course_dir)

        db.commit()
        print("✅ Import completed")
    finally:
        db.close()


if __name__ == "__main__":
    main()
