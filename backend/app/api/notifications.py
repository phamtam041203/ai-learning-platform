"""
Notifications API
Quản lý thông báo trong ứng dụng cho sinh viên
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from datetime import datetime

from app.database import get_db
from app.models.course import Notification, Lesson
from app.models.user import User
from app.api.auth import get_current_user

router = APIRouter(prefix="/notifications", tags=["notifications"])


class NotificationOut(BaseModel):
    id: int
    notif_type: str
    message: str
    lesson_id: int | None
    course_id: int | None
    comment_id: int | None
    is_read: bool
    created_at: datetime
    actor_name: str

    class Config:
        from_attributes = True


@router.get("", response_model=List[NotificationOut])
def list_notifications(
    limit: int = 30,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Lấy danh sách thông báo (mới nhất trước)"""
    rows = (
        db.query(Notification)
        .filter(Notification.recipient_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .limit(limit)
        .all()
    )
    # Batch-fetch course_id for lessons referenced in notifications
    lesson_ids = [n.lesson_id for n in rows if n.lesson_id]
    lesson_course_map: dict[int, int] = {}
    if lesson_ids:
        lessons = db.query(Lesson.id, Lesson.course_id).filter(Lesson.id.in_(lesson_ids)).all()
        lesson_course_map = {l.id: l.course_id for l in lessons}
    return [
        NotificationOut(
            id=n.id,
            notif_type=n.notif_type,
            message=n.message,
            lesson_id=n.lesson_id,
            course_id=lesson_course_map.get(n.lesson_id) if n.lesson_id else None,
            comment_id=n.comment_id,
            is_read=n.is_read,
            created_at=n.created_at,
            actor_name=n.actor.full_name if n.actor else "Ai đó",
        )
        for n in rows
    ]


@router.get("/unread-count")
def unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Đếm số thông báo chưa đọc"""
    count = (
        db.query(Notification)
        .filter(
            Notification.recipient_id == current_user.id,
            Notification.is_read == False,
        )
        .count()
    )
    return {"count": count}


@router.post("/{notif_id}/read")
def mark_read(
    notif_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Đánh dấu một thông báo là đã đọc"""
    notif = db.query(Notification).filter(
        Notification.id == notif_id,
        Notification.recipient_id == current_user.id,
    ).first()
    if notif and not notif.is_read:
        notif.is_read = True
        db.commit()
    return {"ok": True}


@router.post("/read-all")
def mark_all_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Đánh dấu tất cả thông báo là đã đọc"""
    db.query(Notification).filter(
        Notification.recipient_id == current_user.id,
        Notification.is_read == False,
    ).update({"is_read": True})
    db.commit()
    return {"ok": True}
