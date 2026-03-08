from pydantic import BaseModel
from app.schemas.course import CourseOut


class EnrollmentOut(BaseModel):
    enrollment_id: int
    progress: int
    status: str
    course: CourseOut

    class Config:
        from_attributes = True
