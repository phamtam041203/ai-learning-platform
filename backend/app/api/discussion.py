"""
Lesson Discussion API
Cho phép sinh viên thảo luận sau mỗi bài học (hỗ trợ reply + like)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_
from typing import List, Optional
from pydantic import BaseModel, validator
from datetime import datetime

from app.database import get_db
from app.models.course import LessonComment, LessonCommentLike, Lesson, Notification
from app.models.user import User
from app.api.auth import get_current_user

router = APIRouter(prefix="/discussion", tags=["discussion"])


# ─────────────────────── Schemas ───────────────────────

class CommentCreate(BaseModel):
    content: str
    parent_id: Optional[int] = None

    @validator("content")
    def content_not_empty(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Nội dung bình luận không được để trống")
        if len(v) > 2000:
            raise ValueError("Nội dung tối đa 2000 ký tự")
        return v


class CommentUpdate(BaseModel):
    content: str

    @validator("content")
    def content_not_empty(cls, v):
        v = v.strip()
        if not v:
            raise ValueError("Nội dung bình luận không được để trống")
        if len(v) > 2000:
            raise ValueError("Nội dung tối đa 2000 ký tự")
        return v


class ReplyOut(BaseModel):
    id: int
    content: str
    likes_count: int
    liked_by_me: bool
    created_at: datetime
    updated_at: Optional[datetime]
    author_id: int
    author_name: str

    class Config:
        from_attributes = True


class CommentOut(BaseModel):
    id: int
    content: str
    likes_count: int
    liked_by_me: bool
    created_at: datetime
    updated_at: Optional[datetime]
    author_id: int
    author_name: str
    replies: List[ReplyOut] = []

    class Config:
        from_attributes = True


# ─────────────────────── Helpers ───────────────────────

def _serialize(comment: LessonComment, current_user_id: int,
               liked_ids: set, replies: list = None) -> dict:
    return {
        "id": comment.id,
        "content": comment.content,
        "likes_count": comment.likes_count,
        "liked_by_me": comment.id in liked_ids,
        "created_at": comment.created_at,
        "updated_at": comment.updated_at,
        "author_id": comment.user_id,
        "author_name": comment.author.full_name if comment.author else "Người dùng",
        "replies": replies or [],
    }


# ─────────────────────── Endpoints ───────────────────────

@router.get("/lesson/{lesson_id}", response_model=List[CommentOut])
def get_comments(lesson_id: int, db: Session = Depends(get_db),
                 current_user: User = Depends(get_current_user)):
    """Lấy toàn bộ bình luận gốc + replies của một bài học"""
    # Verify lesson exists
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Bài học không tồn tại")

    # Top-level comments (parent_id IS NULL, not deleted)
    top_comments = (
        db.query(LessonComment)
        .filter(
            LessonComment.lesson_id == lesson_id,
            LessonComment.parent_id.is_(None),
            LessonComment.is_deleted == False,
        )
        .options(joinedload(LessonComment.author))
        .order_by(LessonComment.created_at.asc())
        .all()
    )

    # All replies for this lesson
    reply_map: dict[int, list] = {}
    all_replies = (
        db.query(LessonComment)
        .filter(
            LessonComment.lesson_id == lesson_id,
            LessonComment.parent_id.isnot(None),
            LessonComment.is_deleted == False,
        )
        .options(joinedload(LessonComment.author))
        .order_by(LessonComment.created_at.asc())
        .all()
    )
    for r in all_replies:
        reply_map.setdefault(r.parent_id, []).append(r)

    # Collect IDs liked by current user for this lesson's comments
    all_ids = [c.id for c in top_comments] + [r.id for r in all_replies]
    liked_ids = set()
    if all_ids:
        liked_rows = db.query(LessonCommentLike.comment_id).filter(
            LessonCommentLike.comment_id.in_(all_ids),
            LessonCommentLike.user_id == current_user.id
        ).all()
        liked_ids = {row[0] for row in liked_rows}

    result = []
    for c in top_comments:
        replies_out = [
            _serialize(r, current_user.id, liked_ids)
            for r in reply_map.get(c.id, [])
        ]
        result.append(_serialize(c, current_user.id, liked_ids, replies_out))

    return result


@router.post("/lesson/{lesson_id}", response_model=CommentOut, status_code=status.HTTP_201_CREATED)
def post_comment(lesson_id: int, body: CommentCreate,
                 db: Session = Depends(get_db),
                 current_user: User = Depends(get_current_user)):
    """Đăng bình luận mới hoặc reply"""
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Bài học không tồn tại")

    if body.parent_id:
        parent = db.query(LessonComment).filter(
            LessonComment.id == body.parent_id,
            LessonComment.lesson_id == lesson_id,
            LessonComment.is_deleted == False,
        ).first()
        if not parent:
            raise HTTPException(status_code=404, detail="Bình luận gốc không tồn tại")

    comment = LessonComment(
        lesson_id=lesson_id,
        user_id=current_user.id,
        parent_id=body.parent_id,
        content=body.content.strip(),
    )
    db.add(comment)
    db.flush()  # get comment.id
    db.refresh(comment, ["author"])

    # Notify original comment author when someone replies (skip self-reply)
    if body.parent_id:
        parent = db.query(LessonComment).filter(
            LessonComment.id == body.parent_id
        ).first()
        if parent and parent.user_id != current_user.id:
            notif = Notification(
                recipient_id=parent.user_id,
                actor_id=current_user.id,
                notif_type="reply",
                message=f"{current_user.full_name} đã trả lời bình luận của bạn: \"{body.content.strip()[:80]}{'...' if len(body.content.strip()) > 80 else ''}\"",
                lesson_id=lesson_id,
                comment_id=comment.id,
            )
            db.add(notif)

    db.commit()

    return _serialize(comment, current_user.id, set())


@router.put("/{comment_id}", response_model=CommentOut)
def update_comment(comment_id: int, body: CommentUpdate,
                   db: Session = Depends(get_db),
                   current_user: User = Depends(get_current_user)):
    """Sửa bình luận (chỉ tác giả)"""
    comment = db.query(LessonComment).filter(
        LessonComment.id == comment_id,
        LessonComment.is_deleted == False,
    ).first()
    if not comment:
        raise HTTPException(status_code=404, detail="Bình luận không tồn tại")
    if comment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bạn không có quyền sửa bình luận này")

    comment.content = body.content.strip()
    db.commit()
    db.refresh(comment, ["author"])

    liked_ids = set()
    row = db.query(LessonCommentLike).filter(
        LessonCommentLike.comment_id == comment_id,
        LessonCommentLike.user_id == current_user.id,
    ).first()
    if row:
        liked_ids.add(comment_id)

    return _serialize(comment, current_user.id, liked_ids)


@router.delete("/{comment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(comment_id: int, db: Session = Depends(get_db),
                   current_user: User = Depends(get_current_user)):
    """Xoá mềm bình luận (tác giả hoặc admin/teacher)"""
    from app.models.user import UserRole
    comment = db.query(LessonComment).filter(
        LessonComment.id == comment_id,
        LessonComment.is_deleted == False,
    ).first()
    if not comment:
        raise HTTPException(status_code=404, detail="Bình luận không tồn tại")

    is_owner = comment.user_id == current_user.id
    is_moderator = current_user.role in (UserRole.ADMIN, UserRole.TEACHER)
    if not (is_owner or is_moderator):
        raise HTTPException(status_code=403, detail="Bạn không có quyền xoá bình luận này")

    comment.is_deleted = True
    db.commit()


@router.post("/{comment_id}/like")
def toggle_like(comment_id: int, db: Session = Depends(get_db),
                current_user: User = Depends(get_current_user)):
    """Toggle like/unlike bình luận"""
    comment = db.query(LessonComment).filter(
        LessonComment.id == comment_id,
        LessonComment.is_deleted == False,
    ).first()
    if not comment:
        raise HTTPException(status_code=404, detail="Bình luận không tồn tại")

    existing = db.query(LessonCommentLike).filter(
        LessonCommentLike.comment_id == comment_id,
        LessonCommentLike.user_id == current_user.id,
    ).first()

    if existing:
        db.delete(existing)
        comment.likes_count = max(0, comment.likes_count - 1)
        liked = False
    else:
        db.add(LessonCommentLike(comment_id=comment_id, user_id=current_user.id))
        comment.likes_count += 1
        liked = True

    db.commit()
    return {"liked": liked, "likes_count": comment.likes_count}
