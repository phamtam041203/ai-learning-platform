from pydantic import BaseModel

class CourseOut(BaseModel):
    course_code: str
    course_name: str
    credit_hours: int | None = None
    level: str | None = None

    class Config:
        from_attributes = True
