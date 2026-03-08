import { useState, useEffect, useCallback } from 'react';
import { MessageSquare, ThumbsUp, Reply, Trash2, Edit2, Send, ChevronDown, ChevronUp, X, Check } from 'lucide-react';
import { discussionAPI } from '../services/api';
import './DiscussionBoard.css';

/** Format relative time (Vietnamese) */
function timeAgo(dateStr) {
  const diff = (Date.now() - new Date(dateStr)) / 1000;
  if (diff < 60) return 'vừa xong';
  if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`;
  if (diff < 604800) return `${Math.floor(diff / 86400)} ngày trước`;
  return new Date(dateStr).toLocaleDateString('vi-VN');
}

/** Avatar initials */
function Avatar({ name }) {
  const initials = name
    ? name.split(' ').slice(-2).map(w => w[0]).join('').toUpperCase()
    : '?';
  const colors = ['#7c3aed', '#2563eb', '#16a34a', '#dc2626', '#ea580c', '#0891b2'];
  const color = colors[name?.charCodeAt(0) % colors.length] ?? '#6b7280';
  return (
    <div className="disc-avatar" style={{ background: color }}>
      {initials}
    </div>
  );
}

/** Single comment row (supports editing + reply inline) */
function CommentItem({ comment, currentUserId, onDelete, onLike, onReply, onUpdate, depth = 0 }) {
  const [editing, setEditing] = useState(false);
  const [editText, setEditText] = useState(comment.content);
  const [replyOpen, setReplyOpen] = useState(false);
  const [replyText, setReplyText] = useState('');
  const [showReplies, setShowReplies] = useState(true);
  const [saving, setSaving] = useState(false);

  const isOwner = comment.author_id === currentUserId;

  const handleSaveEdit = async () => {
    if (!editText.trim() || editText.trim() === comment.content) {
      setEditing(false);
      return;
    }
    setSaving(true);
    await onUpdate(comment.id, editText.trim());
    setSaving(false);
    setEditing(false);
  };

  const handleReplySubmit = async () => {
    if (!replyText.trim()) return;
    await onReply(replyText.trim(), comment.id);
    setReplyText('');
    setReplyOpen(false);
  };

  return (
    <div className={`disc-comment ${depth > 0 ? 'disc-comment--reply' : ''}`}>
      <Avatar name={comment.author_name} />

      <div className="disc-comment-body">
        <div className="disc-comment-meta">
          <span className="disc-author">{comment.author_name}</span>
          <span className="disc-time">{timeAgo(comment.created_at)}</span>
          {comment.updated_at && comment.updated_at !== comment.created_at && (
            <span className="disc-edited">(đã sửa)</span>
          )}
        </div>

        {editing ? (
          <div className="disc-edit-area">
            <textarea
              className="disc-textarea disc-textarea--edit"
              value={editText}
              onChange={e => setEditText(e.target.value)}
              rows={3}
              maxLength={2000}
            />
            <div className="disc-edit-actions">
              <button className="disc-btn disc-btn--save" onClick={handleSaveEdit} disabled={saving}>
                <Check size={14} /> Lưu
              </button>
              <button className="disc-btn disc-btn--cancel" onClick={() => { setEditing(false); setEditText(comment.content); }}>
                <X size={14} /> Huỷ
              </button>
            </div>
          </div>
        ) : (
          <p className="disc-content">{comment.content}</p>
        )}

        <div className="disc-actions">
          <button
            className={`disc-action-btn ${comment.liked_by_me ? 'disc-action-btn--liked' : ''}`}
            onClick={() => onLike(comment.id)}
          >
            <ThumbsUp size={14} />
            <span>{comment.likes_count > 0 ? comment.likes_count : ''}</span>
            Thích
          </button>

          {depth === 0 && (
            <button className="disc-action-btn" onClick={() => setReplyOpen(v => !v)}>
              <Reply size={14} /> Trả lời
            </button>
          )}

          {isOwner && !editing && (
            <button className="disc-action-btn" onClick={() => setEditing(true)}>
              <Edit2 size={14} /> Sửa
            </button>
          )}

          {isOwner && (
            <button className="disc-action-btn disc-action-btn--danger" onClick={() => onDelete(comment.id)}>
              <Trash2 size={14} /> Xoá
            </button>
          )}
        </div>

        {/* Reply input */}
        {replyOpen && (
          <div className="disc-reply-box">
            <textarea
              className="disc-textarea disc-textarea--reply"
              placeholder="Viết phản hồi..."
              value={replyText}
              onChange={e => setReplyText(e.target.value)}
              rows={2}
              maxLength={2000}
            />
            <div className="disc-reply-actions">
              <button className="disc-btn disc-btn--send" onClick={handleReplySubmit} disabled={!replyText.trim()}>
                <Send size={14} /> Gửi
              </button>
              <button className="disc-btn disc-btn--cancel" onClick={() => setReplyOpen(false)}>
                Huỷ
              </button>
            </div>
          </div>
        )}

        {/* Replies */}
        {comment.replies && comment.replies.length > 0 && (
          <div className="disc-replies">
            <button className="disc-toggle-replies" onClick={() => setShowReplies(v => !v)}>
              {showReplies ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
              {comment.replies.length} phản hồi
            </button>
            {showReplies && comment.replies.map(r => (
              <CommentItem
                key={r.id}
                comment={r}
                currentUserId={currentUserId}
                onDelete={onDelete}
                onLike={onLike}
                onReply={onReply}
                onUpdate={onUpdate}
                depth={depth + 1}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

/** Main Discussion Board */
export default function DiscussionBoard({ lessonId }) {
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [text, setText] = useState('');
  const [error, setError] = useState('');

  const currentUserId = (() => {
    try {
      const u = JSON.parse(localStorage.getItem('user') || '{}');
      return u.id ?? null;
    } catch {
      return null;
    }
  })();

  const fetchComments = useCallback(async () => {
    try {
      setLoading(true);
      const data = await discussionAPI.getComments(lessonId);
      setComments(data);
    } catch (e) {
      console.error('Discussion load error:', e);
    } finally {
      setLoading(false);
    }
  }, [lessonId]);

  useEffect(() => {
    fetchComments();
  }, [fetchComments]);

  const handlepost = async () => {
    if (!text.trim()) return;
    setSubmitting(true);
    setError('');
    try {
      const newComment = await discussionAPI.postComment(lessonId, text.trim());
      setComments(prev => [...prev, { ...newComment, replies: [] }]);
      setText('');
    } catch (e) {
      setError(e.message || 'Không thể gửi bình luận');
    } finally {
      setSubmitting(false);
    }
  };

  const handleReply = async (content, parentId) => {
    try {
      const reply = await discussionAPI.postComment(lessonId, content, parentId);
      setComments(prev => prev.map(c =>
        c.id === parentId ? { ...c, replies: [...(c.replies || []), reply] } : c
      ));
    } catch (e) {
      console.error('Reply error:', e);
    }
  };

  const handleLike = async (commentId) => {
    try {
      const res = await discussionAPI.toggleLike(commentId);
      setComments(prev => prev.map(c => {
        if (c.id === commentId) return { ...c, likes_count: res.likes_count, liked_by_me: res.liked };
        return {
          ...c,
          replies: (c.replies || []).map(r =>
            r.id === commentId ? { ...r, likes_count: res.likes_count, liked_by_me: res.liked } : r
          ),
        };
      }));
    } catch (e) {
      console.error('Like error:', e);
    }
  };

  const handleDelete = async (commentId) => {
    if (!window.confirm('Bạn chắc chắn muốn xoá bình luận này?')) return;
    await discussionAPI.deleteComment(commentId);
    setComments(prev =>
      prev
        .filter(c => c.id !== commentId)
        .map(c => ({ ...c, replies: (c.replies || []).filter(r => r.id !== commentId) }))
    );
  };

  const handleUpdate = async (commentId, content) => {
    try {
      const updated = await discussionAPI.updateComment(commentId, content);
      setComments(prev => prev.map(c => {
        if (c.id === commentId) return { ...c, content: updated.content, updated_at: updated.updated_at };
        return {
          ...c,
          replies: (c.replies || []).map(r =>
            r.id === commentId ? { ...r, content: updated.content, updated_at: updated.updated_at } : r
          ),
        };
      }));
    } catch (e) {
      console.error('Update error:', e);
    }
  };

  const totalCount = comments.reduce((s, c) => s + 1 + (c.replies?.length || 0), 0);

  return (
    <div className="disc-board">
      <div className="disc-board-header">
        <MessageSquare size={22} />
        <h3>Thảo luận bài học</h3>
        {!loading && <span className="disc-count">{totalCount}</span>}
      </div>

      {/* Composer */}
      <div className="disc-composer">
        <Avatar name={currentUserId ? 'Bạn' : '?'} />
        <div className="disc-composer-inner">
          <textarea
            className="disc-textarea"
            placeholder="Đặt câu hỏi hoặc chia sẻ suy nghĩ của bạn về bài học này..."
            value={text}
            onChange={e => setText(e.target.value)}
            rows={3}
            maxLength={2000}
          />
          {error && <p className="disc-error">{error}</p>}
          <div className="disc-composer-footer">
            <span className="disc-char-count">{text.length}/2000</span>
            <button
              className="disc-btn disc-btn--primary"
              onClick={handlepost}
              disabled={!text.trim() || submitting}
            >
              <Send size={16} />
              {submitting ? 'Đang gửi...' : 'Đăng bình luận'}
            </button>
          </div>
        </div>
      </div>

      {/* Comment list */}
      <div className="disc-list">
        {loading ? (
          <div className="disc-loading">Đang tải thảo luận...</div>
        ) : comments.length === 0 ? (
          <div className="disc-empty">
            <MessageSquare size={40} />
            <p>Chưa có bình luận nào. Hãy là người đầu tiên thảo luận!</p>
          </div>
        ) : (
          comments.map(c => (
            <CommentItem
              key={c.id}
              comment={c}
              currentUserId={currentUserId}
              onDelete={handleDelete}
              onLike={handleLike}
              onReply={handleReply}
              onUpdate={handleUpdate}
            />
          ))
        )}
      </div>
    </div>
  );
}
