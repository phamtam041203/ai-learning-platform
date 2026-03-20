"""Curriculum rules and stage gating utilities."""
from __future__ import annotations

from functools import lru_cache
from pathlib import Path
import json
from typing import Any

from sqlalchemy.orm import Session

from app.models import Course, Enrollment, EnrollmentStatus

DATA_PATH = Path(__file__).resolve().parents[1] / "data" / "curriculum_cnpm.json"


@lru_cache(maxsize=1)
def load_cnpm_curriculum() -> dict:
    if not DATA_PATH.exists():
        return {}
    return json.loads(DATA_PATH.read_text(encoding="utf-8"))


def build_curriculum_index(curriculum: dict) -> dict[str, Any]:
    phases = curriculum.get("phases", [])
    course_details = curriculum.get("course_details", {})
    course_by_code: dict[str, dict] = {}
    phase_by_code: dict[str, dict] = {}
    phase_index_by_code: dict[str, int] = {}
    all_elective_codes: set[str] = set()

    for idx, phase in enumerate(phases):
        # Get all courses for this phase (both new and old structure)
        required_courses = phase.get("required_courses", [])
        elective_courses = phase.get("elective_courses", [])
        old_courses = phase.get("courses", [])
        
        all_phase_courses = required_courses + elective_courses + old_courses
        
        for course in all_phase_courses:
            # Handle both string and dict formats
            if isinstance(course, str):
                code = course
                course_info = course_details.get(code, {"name": code, "credit_hours": 3})
                course_info["code"] = code
            else:
                code = course.get("code", course)
                course_info = course
            
            course_by_code[code] = course_info
            phase_by_code[code] = phase
            phase_index_by_code[code] = idx
        
        # Track elective codes from each phase
        for ec in elective_courses:
            all_elective_codes.add(_get_course_code(ec))

    return {
        "phases": phases,
        "course_by_code": course_by_code,
        "phase_by_code": phase_by_code,
        "phase_index_by_code": phase_index_by_code,
        "all_elective_codes": all_elective_codes
    }


def _get_course_code(course) -> str:
    """Get course code from either string or dict format"""
    if isinstance(course, str):
        return course
    return course.get("code", course)


def get_curriculum_codes(curriculum: dict) -> list[str]:
    """Get all course codes from curriculum (both required and elective)"""
    codes = []
    for phase in curriculum.get("phases", []):
        # Support new structure with required_courses and elective_courses
        required = phase.get("required_courses", [])
        elective = phase.get("elective_courses", [])
        # Also support old structure with courses
        old_courses = phase.get("courses", [])
        
        for c in required + elective + old_courses:
            codes.append(_get_course_code(c))
    return codes


def _phase_completed(
    phase: dict,
    completed_codes: set[str],
    phase_elective_completed: set[str]
) -> bool:
    """Check if a phase is completed (all required + min electives)"""
    # Get required courses for this phase
    required = [_get_course_code(c) for c in phase.get("required_courses", [])]
    # Fallback to old structure
    if not required:
        required = [_get_course_code(c) for c in phase.get("courses", [])]
    
    # Check all required courses are completed
    if required and not all(code in completed_codes for code in required):
        return False
    
    # Check elective requirement for this phase
    elective = phase.get("elective_courses", [])
    min_select = phase.get("elective_min_select", 0)
    
    if elective and min_select > 0:
        elective_codes = {_get_course_code(c) for c in elective}
        completed_electives_in_phase = completed_codes & elective_codes
        if len(completed_electives_in_phase) < min_select:
            return False
    
    return True


def get_active_phase_index(
    curriculum: dict,
    completed_codes: set[str],
    completed_electives: set[str]
) -> int:
    phases = curriculum.get("phases", [])
    for idx, phase in enumerate(phases):
        if not _phase_completed(phase, completed_codes, completed_electives):
            return idx
    return len(phases)


def get_current_phase_index(
    curriculum: dict,
    active_phase_index: int,
    enrolled_codes: set[str],
    completed_codes: set[str],
    phase_index_by_code: dict[str, int],
) -> int:
    """Return the phase that best reflects the student's actual current level."""
    phases = curriculum.get("phases", [])
    if not phases:
        return 0

    highest_engaged_phase = max(
        (phase_index_by_code[code] for code in (enrolled_codes | completed_codes) if code in phase_index_by_code),
        default=None,
    )
    clamped_active_phase = min(active_phase_index, len(phases) - 1)

    if highest_engaged_phase is None:
        return clamped_active_phase

    return min(max(clamped_active_phase, highest_engaged_phase), len(phases) - 1)


def get_user_curriculum_state(
    db: Session,
    user_id: int,
    curriculum: dict
) -> dict[str, Any]:
    index = build_curriculum_index(curriculum)
    curriculum_codes = get_curriculum_codes(curriculum)
    if not curriculum_codes:
        return {
            "completed_codes": set(),
            "enrolled_codes": set(),
            "selected_electives": set(),
            "completed_electives": set(),
            "active_phase_index": 0,
            **index
        }

    courses = db.query(Course).filter(Course.course_code.in_(curriculum_codes)).all()
    course_code_by_id = {c.id: c.course_code for c in courses}
    course_ids = list(course_code_by_id.keys())

    enrolled_codes: set[str] = set()
    completed_codes: set[str] = set()

    if course_ids:
        enrollments = db.query(Enrollment).filter(
            Enrollment.student_id == user_id,
            Enrollment.course_id.in_(course_ids)
        ).all()

        for e in enrollments:
            code = course_code_by_id.get(e.course_id)
            if not code:
                continue
            enrolled_codes.add(code)
            if e.status == EnrollmentStatus.COMPLETED or (e.progress or 0) >= 100:
                completed_codes.add(code)

    all_elective_codes = index.get("all_elective_codes", set())
    selected_electives = enrolled_codes & all_elective_codes
    completed_electives = completed_codes & all_elective_codes

    active_phase_index = get_active_phase_index(curriculum, completed_codes, completed_electives)
    current_phase_index = get_current_phase_index(
        curriculum,
        active_phase_index,
        enrolled_codes,
        completed_codes,
        index.get("phase_index_by_code", {}),
    )

    return {
        "completed_codes": completed_codes,
        "enrolled_codes": enrolled_codes,
        "selected_electives": selected_electives,
        "completed_electives": completed_electives,
        "active_phase_index": active_phase_index,
        "current_phase_index": current_phase_index,
        **index
    }


def get_allowed_course_codes(
    curriculum: dict,
    completed_codes: set[str],
    enrolled_codes: set[str]
) -> set[str]:
    """Get courses that can be enrolled in based on current progress"""
    allowed_codes: set[str] = set()
    phases = curriculum.get("phases", [])

    for phase in phases:
        # Get required and elective courses for this phase
        required_courses = [_get_course_code(c) for c in phase.get("required_courses", [])]
        elective_courses = [_get_course_code(c) for c in phase.get("elective_courses", [])]
        
        # Fallback to old structure
        if not required_courses and not elective_courses:
            required_courses = [_get_course_code(c) for c in phase.get("courses", [])]
        
        min_elective = phase.get("elective_min_select", 0)
        
        # Check if phase is completed
        required_completed = all(code in completed_codes for code in required_courses)
        elective_completed_count = sum(1 for code in elective_courses if code in completed_codes)
        elective_completed = elective_completed_count >= min_elective
        
        if required_completed and elective_completed:
            continue  # Phase completed, check next
        
        # This phase is active - add available courses
        # Add uncompleted required courses
        for code in required_courses:
            if code not in completed_codes:
                allowed_codes.add(code)
        
        # Add elective courses if not enough selected yet
        if elective_courses:
            enrolled_electives = set(elective_courses) & enrolled_codes
            if len(enrolled_electives) < min_elective:
                allowed_codes.update(elective_courses)
            else:
                allowed_codes.update(enrolled_electives)
        
        break  # Only allow courses from the active phase

    return allowed_codes


def get_course_lock_status(
    course_code: str,
    curriculum_state: dict[str, Any]
) -> dict[str, Any]:
    if course_code in curriculum_state.get("enrolled_codes", set()):
        return {"is_locked": False, "lock_reason": None}

    phase_index_by_code = curriculum_state.get("phase_index_by_code", {})
    phase_by_code = curriculum_state.get("phase_by_code", {})
    course_by_code = curriculum_state.get("course_by_code", {})

    phase_index = phase_index_by_code.get(course_code)
    if phase_index is None:
        return {"is_locked": False, "lock_reason": None}

    active_phase_index = curriculum_state.get("active_phase_index", 0)
    if phase_index > active_phase_index:
        return {"is_locked": True, "lock_reason": "stage_locked"}

    # Check if this is an elective course in its phase
    phase = phase_by_code.get(course_code, {})
    elective_courses = [_get_course_code(c) for c in phase.get("elective_courses", [])]
    
    if course_code in elective_courses:
        min_select = phase.get("elective_min_select", 0)
        enrolled_codes = curriculum_state.get("enrolled_codes", set())
        enrolled_electives = set(elective_courses) & enrolled_codes
        
        if len(enrolled_electives) >= min_select and course_code not in enrolled_electives:
            return {"is_locked": True, "lock_reason": "elective_limit"}

    prereqs = course_by_code.get(course_code, {}).get("prerequisites", [])
    completed_codes = curriculum_state.get("completed_codes", set())
    if prereqs and not all(code in completed_codes for code in prereqs):
        return {"is_locked": True, "lock_reason": "prerequisites"}

    return {"is_locked": False, "lock_reason": None}


def validate_enrollment(
    course_code: str,
    curriculum_state: dict[str, Any]
) -> tuple[bool, str | None]:
    lock = get_course_lock_status(course_code, curriculum_state)
    if lock["is_locked"]:
        return False, lock["lock_reason"]

    phase_by_code = curriculum_state.get("phase_by_code", {})
    phase = phase_by_code.get(course_code, {})
    elective_courses = [_get_course_code(c) for c in phase.get("elective_courses", [])]
    
    if course_code in elective_courses:
        min_select = phase.get("elective_min_select", 0)
        enrolled_codes = curriculum_state.get("enrolled_codes", set())
        enrolled_electives = set(elective_courses) & enrolled_codes
        
        if course_code not in enrolled_electives and len(enrolled_electives) >= min_select:
            return False, "elective_limit"

    return True, None
