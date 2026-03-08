"""Helper functions"""
from typing import Optional
import re

def validate_student_id(student_id: str) -> bool:
    """Validate MSSV format"""
    pattern = r'^\d{10,13}$'
    return bool(re.match(pattern, student_id))

def calculate_gpa(grades: list) -> float:
    """Calculate GPA from grades"""
    grade_points = {
        'A': 4.0, 'A-': 3.7,
        'B+': 3.3, 'B': 3.0, 'B-': 2.7,
        'C+': 2.3, 'C': 2.0, 'C-': 1.7,
        'D': 1.0, 'F': 0.0
    }
    if not grades:
        return 0.0
    total = sum(grade_points.get(g, 0) for g in grades)
    return round(total / len(grades), 2)