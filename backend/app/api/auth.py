from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.responses import RedirectResponse
from authlib.integrations.starlette_client import OAuth
from typing import Optional
import base64
from urllib.parse import quote
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import func
from jose import JWTError, jwt

from app.database import get_db
from app.models.user import User, StudentProfile, TeacherProfile, UserRole
from app.models.course import Course, Enrollment, EnrollmentStatus
from app.schemas.auth import *
from app.utils.security import (
    verify_password,
    get_password_hash,
    create_access_token
)
from app.core.config import settings

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")
# Optional OAuth2 - doesn't raise error if no token
oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)

CNPM_SPECIALIZATION_CODE = "CNPM"
CNPM_MAJOR_NAME = "Công nghệ thông tin"


def _build_cnpm_class_name(intake_year: Optional[int]) -> Optional[str]:
    if intake_year is None:
        return None
    return f"CNPM-K{intake_year}"

# Microsoft OAuth (Teams via Azure AD)
oauth = OAuth()
if settings.AZURE_AD_CLIENT_ID and settings.AZURE_AD_CLIENT_SECRET:
    tenant_id = settings.AZURE_AD_TENANT_ID or "common"
    oauth.register(
        name="microsoft",
        client_id=settings.AZURE_AD_CLIENT_ID,
        client_secret=settings.AZURE_AD_CLIENT_SECRET,
        server_metadata_url=f"https://login.microsoftonline.com/{tenant_id}/v2.0/.well-known/openid-configuration",
        client_kwargs={"scope": "openid email profile User.Read"},
    )


def _decode_frontend_redirect(state: str) -> str:
    default_redirect = f"{settings.FRONTEND_BASE_URL}/auth/teams/callback"
    if not state:
        return default_redirect
    try:
        decoded = base64.urlsafe_b64decode(state.encode()).decode()
        return decoded or default_redirect
    except Exception:
        return default_redirect


def _is_vlu_email(email: str) -> bool:
    return email.lower().endswith("@vlu.edu.vn")


@router.get("/teams/login")
async def teams_login(request: Request, redirect: Optional[str] = None):
    """Start Microsoft Teams (Azure AD) OAuth login flow."""
    if not settings.AZURE_AD_CLIENT_ID or not settings.AZURE_AD_CLIENT_SECRET:
        raise HTTPException(500, "Azure AD client is not configured")

    frontend_redirect = redirect or f"{settings.FRONTEND_BASE_URL}/auth/teams/callback"
    state = base64.urlsafe_b64encode(frontend_redirect.encode()).decode()
    redirect_uri = request.url_for("teams_callback")
    return await oauth.microsoft.authorize_redirect(request, redirect_uri, state=state)


@router.get("/teams/callback", name="teams_callback")
async def teams_callback(request: Request, db: Session = Depends(get_db)):
    """Handle Microsoft Teams OAuth callback and redirect to frontend."""
    frontend_redirect = _decode_frontend_redirect(request.query_params.get("state"))

    try:
        token = await oauth.microsoft.authorize_access_token(request)
        userinfo = token.get("userinfo")
        if not userinfo:
            try:
                userinfo = await oauth.microsoft.parse_id_token(request, token)
            except Exception:
                userinfo = None

        email = None
        full_name = None
        if userinfo:
            email = userinfo.get("email") or userinfo.get("preferred_username")
            full_name = userinfo.get("name")

        if not email:
            return RedirectResponse(
                f"{frontend_redirect}?error=no_email&error_description={quote('Không lấy được email từ Teams')}")

        if not _is_vlu_email(email):
            return RedirectResponse(
                f"{frontend_redirect}?error=invalid_domain&error_description={quote('Chỉ hỗ trợ sinh viên VLU')}")

        user = db.query(User).filter(User.email == email).first()
        if not user:
            # Auto-create student account for VLU email
            user = User(
                email=email,
                hashed_password=get_password_hash(email),
                full_name=full_name or email.split("@")[0],
                role=UserRole.STUDENT,
                is_active=True,
                is_verified=True
            )
            db.add(user)
            db.commit()
            db.refresh(user)

        if not user.is_active:
            return RedirectResponse(
                f"{frontend_redirect}?error=account_disabled&error_description={quote('Tài khoản đã bị khóa')}")

        # Update full name if missing
        if full_name and user.full_name != full_name:
            user.full_name = full_name
            db.commit()

        access_token = create_access_token({
            "sub": user.email,
            "role": user.role.value,
            "user_id": user.id
        })

        return RedirectResponse(f"{frontend_redirect}?access_token={quote(access_token)}")

    except Exception as e:
        return RedirectResponse(
            f"{frontend_redirect}?error=oauth_error&error_description={quote(str(e))}")



# ⭐ HELPER: Auto-generate MSSV (OPTIMIZED)
def generate_student_id(db: Session, intake_year: int) -> str:
    """
    Generate unique student ID: 2174802XXXXKXX
    Example: 21748020001K27
    OPTIMIZED: Query by intake_year instead of LIKE
    """
    # Validate intake_year
    if intake_year < 20 or intake_year > 99:
        raise HTTPException(400, "Invalid intake year. Must be between 20 and 99.")
    
    # Format: 2174802 + 4 digits + K + year
    prefix = "2174802"
    suffix = f"K{intake_year}"
    
    # ⭐ OPTIMIZED: Count students with this intake_year (fast!)
    try:
        count = db.query(StudentProfile).filter(
            StudentProfile.intake_year == intake_year
        ).count()
        
        new_number = count + 1
        student_id = f"{prefix}{new_number:04d}{suffix}"
        
        return student_id
    except Exception as e:
        # Fallback: use random
        import random
        random_num = random.randint(1, 9999)
        return f"{prefix}{random_num:04d}{suffix}"

# ⭐ PREVIEW MSSV endpoint
@router.get("/preview-mssv/{intake_year}")
async def preview_mssv(intake_year: int, db: Session = Depends(get_db)):
    """Preview what MSSV will be generated for given intake year"""
    try:
        preview_id = generate_student_id(db, intake_year)
        
        # Calculate graduation year (4 years program)
        admission_year = 2000 + intake_year
        graduation_year = admission_year + 4
        
        return {
            "preview_mssv": preview_id,
            "intake_info": {
                "khoa": intake_year,
                "nam_nhap_hoc": admission_year,
                "nam_tot_nghiep_du_kien": graduation_year
            }
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(500, f"Error generating preview: {str(e)}")


# ⭐ DEBUG: Check user in database
@router.get("/debug/check-user/{email}")
async def debug_check_user(email: str, db: Session = Depends(get_db)):
    """DEBUG: Check if user exists and password hash"""
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return {"exists": False, "message": f"User {email} not found"}

    # Get student profile
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()

    # Check enrollments - FIXED: Use profile.id
    enrollments = []
    if profile:
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == profile.id
        ).all()
    
    enrolled_courses = []
    for e in enrollments:
        course = db.query(Course).filter(Course.id == e.course_id).first()
        if course:
            enrolled_courses.append({
                "course_code": course.course_code,
                "course_name": course.course_name
            })

    return {
        "exists": True,
        "user_id": user.id,
        "profile_id": profile.id if profile else None,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role.value,
        "is_active": user.is_active,
        "hashed_password_preview": user.hashed_password[:30] + "..." if user.hashed_password else None,
        "has_password": user.hashed_password is not None,
        "enrolled_courses_count": len(enrolled_courses),
        "enrolled_courses": enrolled_courses
    }


#  DEBUG: Check database status
@router.get("/debug/db-status")
async def debug_db_status(db: Session = Depends(get_db)):
    """DEBUG: Check database tables and counts"""
    try:
        users_count = db.query(User).count()
        courses_count = db.query(Course).count()
        enrollments_count = db.query(Enrollment).count()

        # Get sample courses
        sample_courses = db.query(Course).limit(5).all()

        return {
            "status": "connected",
            "counts": {
                "users": users_count,
                "courses": courses_count,
                "enrollments": enrollments_count
            },
            "sample_courses": [
                {"id": c.id, "code": c.course_code, "name": c.course_name, "major": c.major}
                for c in sample_courses
            ]
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}


# ⭐ DEBUG: Manually enroll user in courses - FIXED
@router.get("/debug/enroll-user/{email}")
async def debug_enroll_user(email: str, db: Session = Depends(get_db)):
    """DEBUG: Manually enroll a user in courses based on their major - FIXED"""
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            return {"success": False, "message": f"User {email} not found"}

        profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
        if not profile:
            return {"success": False, "message": "No student profile found"}

        print(f"[ENROLL] User ID: {user.id}, Profile ID: {profile.id}")

        # Map Vietnamese major names to codes
        major_mapping = {
            "Công nghệ Thông tin": "CNTT",
            "Công nghệ thông tin": "CNTT",
            "Khoa học Máy tính": "KHMT",
            "Hệ thống Thông tin": "HTTT",
            "An toàn Thông tin": "ATTT",
            "Kỹ thuật phần mềm": "KTPM",
            "Mạng máy tính": "MMT",
            "Trí tuệ nhân tạo": "TTNT",
            # Also add English/code versions
            "CNTT": "CNTT",
            "KTPM": "KTPM",
            "HTTT": "HTTT",
            "MMT": "MMT",
            "KHMT": "KHMT",
            "ATTT": "ATTT",
            "TTNT": "TTNT",
        }

        major_code = major_mapping.get(profile.major, "CNTT")
        print(f"[ENROLL] User major: {profile.major} -> Code: {major_code}")

        # Get courses for this major
        courses = db.query(Course).filter(
            Course.major == major_code,
            Course.is_active == True
        ).limit(5).all()

        # If no courses for major, get CNTT courses
        if not courses:
            print(f"[ENROLL] No courses for {major_code}, trying CNTT...")
            courses = db.query(Course).filter(
                Course.major == "CNTT",
                Course.is_active == True
            ).limit(5).all()

        # If still no courses, get any courses
        if not courses:
            print(f"[ENROLL] No CNTT courses, getting any courses...")
            courses = db.query(Course).filter(Course.is_active == True).limit(5).all()

        enrolled_courses = []
        for course in courses:
            # Check if already enrolled - FIXED: Use profile.id
            existing = db.query(Enrollment).filter(
                Enrollment.student_id == profile.id,
                Enrollment.course_id == course.id
            ).first()

            if existing:
                print(f"[ENROLL] Already enrolled in {course.course_code}")
                continue

            # FIXED: Use profile.id instead of user.id
            enrollment = Enrollment(
                student_id=profile.id,
                course_id=course.id,
                status=EnrollmentStatus.ACTIVE,
                progress=0,
                completed_lessons=0
            )
            db.add(enrollment)
            enrolled_courses.append({
                "course_code": course.course_code,
                "course_name": course.course_name
            })
            print(f"[ENROLL] Created enrollment: student_id={profile.id}, course_id={course.id}")

        db.commit()

        return {
            "success": True,
            "user_email": email,
            "user_id": user.id,
            "profile_id": profile.id,
            "user_major": profile.major,
            "major_code": major_code,
            "enrolled_count": len(enrolled_courses),
            "enrolled_courses": enrolled_courses
        }
    except Exception as e:
        db.rollback()
        return {"success": False, "message": str(e)}


# ⭐ REGISTER STUDENT (with auto MSSV + auto enroll courses) - FIXED
@router.post("/register/student")
async def register_student(data: StudentRegister, db: Session = Depends(get_db)):
    """
    Register student with auto-generated MSSV
    Auto-enrolls student in courses based on selected major - FIXED
    """
    # Check existing email
    existing_user = db.query(User).filter(User.email == data.email).first()
    if existing_user:
        raise HTTPException(400, "Email đã được sử dụng")

    # Auto-generate student_id
    generated_student_id = generate_student_id(db, data.intake_year)

    # Hash password
    hashed_pw = get_password_hash(data.password)

    # Create user
    user = User(
        email=data.email,
        hashed_password=hashed_pw,
        full_name=data.full_name,
        role=UserRole.STUDENT,
        is_active=True
    )
    db.add(user)
    db.flush()

    specialization_code = CNPM_SPECIALIZATION_CODE
    major_name = CNPM_MAJOR_NAME
    class_name = _build_cnpm_class_name(data.intake_year) or data.class_name

    # Create student profile with fixed CNPM specialization for the current phase
    profile = StudentProfile(
        user_id=user.id,
        student_id=generated_student_id,
        major=major_name,
        specialization=specialization_code,
        class_name=class_name,
        intake_year=data.intake_year,
        phone=data.phone,
        education_type=data.education_type or "0"
    )
    db.add(profile)
    db.flush()

    print(f"[REGISTER] Created user ID: {user.id}, profile ID: {profile.id}")

    # ⚠️ AUTO-ENROLLMENT DISABLED
    # Students must manually browse and enroll in courses
    # from the "Browse Courses" page
    
    # Commit everything
    db.commit()

    return {
        "message": "Đăng ký thành công",
        "generated_student_id": generated_student_id,
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role.value,
            "is_active": user.is_active
        },
        "student_profile": {
            "student_id": profile.student_id,
            "major": profile.major,
            "specialization": profile.specialization,
            "class_name": profile.class_name,
            "intake_year": profile.intake_year
        }
    }

@router.post("/register/teacher")
async def register_teacher(data: TeacherRegister, db: Session = Depends(get_db)):
    """Public teacher self-registration is disabled. Teachers must be created by admins."""
    raise HTTPException(
        status_code=403,
        detail="Đăng ký giảng viên đã bị tắt. Chỉ admin mới có quyền tạo và cấp tài khoản giảng viên."
    )

@router.post("/login")
async def login(data: dict, db: Session = Depends(get_db)):
    """Login and return token with profile"""
    try:
        email = data.get("email") or data.get("username")
        password = data.get("password")

        if not email or not password:
            raise HTTPException(422, "Email/username và mật khẩu là bắt buộc")

        # Find user
        user = db.query(User).filter(User.email == email).first()

        # Debug logging
        print(f"[LOGIN] Email: {email}")
        print(f"[LOGIN] User found: {user is not None}")

        if not user:
            print(f"[LOGIN] No user with email: {email}")
            raise HTTPException(401, "Email hoặc mật khẩu không đúng")

        print(f"[LOGIN] User ID: {user.id}, Hash: {user.hashed_password[:20]}...")

        # Verify password
        password_valid = verify_password(password, user.hashed_password)
        print(f"[LOGIN] Password valid: {password_valid}")

        if not password_valid:
            raise HTTPException(401, "Email hoặc mật khẩu không đúng")
        
        if not user.is_active:
            raise HTTPException(403, "Tài khoản đã bị khóa")
        
        # Create token
        token = create_access_token({
            "sub": user.email,
            "role": user.role.value,
            "user_id": user.id
        })
        
        # Get profile based on role
        profile_data = None
        if user.role == UserRole.STUDENT:
            profile = db.query(StudentProfile).filter(
                StudentProfile.user_id == user.id
            ).first()
            if profile:
                profile_data = {
                    "student_id": profile.student_id,
                    "major": profile.major,
                    "specialization": profile.specialization,
                    "class_name": profile.class_name,
                    "intake_year": profile.intake_year
                }
        elif user.role == UserRole.TEACHER:
            profile = db.query(TeacherProfile).filter(
                TeacherProfile.user_id == user.id
            ).first()
            if profile:
                profile_data = {
                    "teacher_id": profile.teacher_id,
                    "department": profile.department,
                    "position": profile.position
                }
        
        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "email": user.email,
                "full_name": user.full_name,
                "role": user.role.value,
                "is_active": user.is_active
            },
            "profile": profile_data
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(500, f"Login error: {str(e)}")


@router.post("/login-basic")
async def login_basic(request: Request, db: Session = Depends(get_db)):
    """Login without schema validation (supports JSON or form)"""
    try:
        try:
            payload = await request.json()
        except Exception:
            form = await request.form()
            payload = dict(form)

        email = payload.get("email") or payload.get("username")
        password = payload.get("password")

        if not email or not password:
            raise HTTPException(422, "Email/username và mật khẩu là bắt buộc")

        user = db.query(User).filter(User.email == email).first()

        print(f"[LOGIN_BASIC] Email: {email}")
        print(f"[LOGIN_BASIC] User found: {user is not None}")

        if not user:
            print(f"[LOGIN_BASIC] No user with email: {email}")
            raise HTTPException(401, "Email hoặc mật khẩu không đúng")

        password_valid = verify_password(password, user.hashed_password)
        print(f"[LOGIN_BASIC] Password valid: {password_valid}")

        if not password_valid:
            raise HTTPException(401, "Email hoặc mật khẩu không đúng")

        if not user.is_active:
            raise HTTPException(403, "Tài khoản đã bị khóa")

        token = create_access_token({
            "sub": user.email,
            "role": user.role.value,
            "user_id": user.id
        })

        profile_data = None
        if user.role == UserRole.STUDENT:
            profile = db.query(StudentProfile).filter(
                StudentProfile.user_id == user.id
            ).first()
            if profile:
                profile_data = {
                    "student_id": profile.student_id,
                    "major": profile.major,
                    "specialization": profile.specialization,
                    "class_name": profile.class_name,
                    "intake_year": profile.intake_year
                }
        elif user.role == UserRole.TEACHER:
            profile = db.query(TeacherProfile).filter(
                TeacherProfile.user_id == user.id
            ).first()
            if profile:
                profile_data = {
                    "teacher_id": profile.teacher_id,
                    "department": profile.department,
                    "position": profile.position
                }

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "email": user.email,
                "full_name": user.full_name,
                "role": user.role.value,
                "is_active": user.is_active
            },
            "profile": profile_data
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(500, f"Login error: {str(e)}")


# ⭐ HELPER: Get current user from token
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """Get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user"
        )

    return user


async def get_current_user_optional(
    token: str = Depends(oauth2_scheme_optional),
    db: Session = Depends(get_db)
) -> User | None:
    """Get current user if token provided, otherwise return None"""
    if not token:
        return None
    
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            return None
    except JWTError:
        return None

    user = db.query(User).filter(User.email == email).first()
    if user is None or not user.is_active:
        return None

    return user


@router.post("/teams/complete-profile")
async def complete_teams_profile(
    payload: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Complete student profile after Teams login (collect MSSV)."""
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(403, "Chỉ hỗ trợ sinh viên")

    if not _is_vlu_email(current_user.email):
        raise HTTPException(403, "Chỉ hỗ trợ sinh viên VLU")

    student_id = (payload.get("student_id") or "").strip()
    if not student_id:
        raise HTTPException(422, "MSSV là bắt buộc")

    existing_profile = db.query(StudentProfile).filter(
        StudentProfile.student_id == student_id
    ).first()
    if existing_profile and existing_profile.user_id != current_user.id:
        raise HTTPException(409, "MSSV đã tồn tại")

    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()

    if not profile:
        profile = StudentProfile(
            user_id=current_user.id,
            student_id=student_id
        )
        db.add(profile)
    else:
        current_student_id = (profile.student_id or "").strip()
        if current_student_id and current_student_id != student_id:
            raise HTTPException(400, "Không được phép thay đổi MSSV")
        profile.student_id = student_id

    db.commit()

    return {
        "success": True,
        "student_id": student_id
    }


# ⭐ CHANGE PASSWORD
@router.post("/change-password")
async def change_password(
    data: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Change password for authenticated user
    Requires: current_password, new_password
    """
    try:
        # Verify current password
        if not verify_password(data.current_password, current_user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mật khẩu hiện tại không đúng"
            )

        # Check if new password is same as current
        if data.current_password == data.new_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mật khẩu mới không được trùng với mật khẩu hiện tại"
            )

        # Validate new password strength
        if len(data.new_password) < 8:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Mật khẩu mới phải có ít nhất 8 ký tự"
            )

        # Update password
        current_user.hashed_password = get_password_hash(data.new_password)
        db.commit()

        return {
            "message": "Đổi mật khẩu thành công",
            "success": True
        }

    except HTTPException as e:
        raise e
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi khi đổi mật khẩu: {str(e)}"
        )


# ⭐ GET CURRENT USER INFO
@router.get("/me")
async def get_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current user info"""
    try:
        profile_data = None

        if current_user.role == UserRole.STUDENT:
            profile = db.query(StudentProfile).filter(
                StudentProfile.user_id == current_user.id
            ).first()
            if profile:
                profile_data = {
                    "student_id": profile.student_id,
                    "major": profile.major,
                    "specialization": profile.specialization,
                    "class_name": profile.class_name,
                    "intake_year": profile.intake_year,
                    "phone": profile.phone,
                    "address": profile.address,
                    "date_of_birth": profile.date_of_birth.isoformat() if profile.date_of_birth else None,
                    "gpa": profile.gpa,
                    "learning_style": profile.learning_style,
                    "preferred_difficulty": profile.preferred_difficulty,
                    "avatar": profile.avatar
                }
        elif current_user.role == UserRole.TEACHER:
            profile = db.query(TeacherProfile).filter(
                TeacherProfile.user_id == current_user.id
            ).first()
            if profile:
                profile_data = {
                    "teacher_id": profile.teacher_id,
                    "department": profile.department,
                    "position": profile.position,
                    "phone": profile.phone
                }

        return {
            "user": {
                "id": current_user.id,
                "email": current_user.email,
                "full_name": current_user.full_name,
                "role": current_user.role.value,
                "is_active": current_user.is_active,
                "created_at": current_user.created_at.isoformat() if current_user.created_at else None,
                "updated_at": current_user.updated_at.isoformat() if current_user.updated_at else None,
            },
            "profile": profile_data
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error getting user info: {str(e)}"
        )