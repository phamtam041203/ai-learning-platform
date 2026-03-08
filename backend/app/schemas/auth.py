from pydantic import BaseModel, EmailStr, Field
from typing import Optional

# ============================================
# REQUEST SCHEMAS
# ============================================

class StudentRegister(BaseModel):
    """Student registration - intake_year instead of student_id"""
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str = Field(min_length=2)
    intake_year: int = Field(ge=20, le=99, description="Khóa học (VD: 25 cho K25)")
    major: str
    specialization: str = Field(description="Chuyên ngành: Công nghệ phần mềm, Công nghệ dữ liệu, An ninh mạng")
    class_name: str
    phone: Optional[str] = None
    education_type: Optional[str] = "0"

class TeacherRegister(BaseModel):
    """Teacher registration - manual teacher_id"""
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str = Field(min_length=2)
    teacher_id: str = Field(min_length=3, description="Mã giảng viên (VD: GV001)")
    department: str
    position: Optional[str] = None
    phone: Optional[str] = None

class LoginRequest(BaseModel):
    email: str
    password: str

# ============================================
# RESPONSE SCHEMAS
# ============================================

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True


class ChangePasswordRequest(BaseModel):
    """Change password request"""
    current_password: str = Field(min_length=1, description="Mật khẩu hiện tại")
    new_password: str = Field(min_length=8, description="Mật khẩu mới (ít nhất 8 ký tự)")


class SetSpecializationRequest(BaseModel):
    """Set student specialization"""
    specialization: str = Field(..., description="Chuyên ngành: CNPM, CNDL, hoặc ANM")
    
    class Config:
        from_attributes = True
