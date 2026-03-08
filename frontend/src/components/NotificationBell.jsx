import { useState, useEffect, useRef, useCallback } from 'react';
import { Bell, CheckCheck, MessageSquare, Reply } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { notificationAPI } from '../services/api';
import './NotificationBell.css';

const POLL_INTERVAL = 30_000; // 30 seconds

function timeAgo(dateStr) {
  const diff = (Date.now() - new Date(dateStr)) / 1000;
  if (diff < 60) return 'vừa xong';
  if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`;
  if (diff < 604800) return `${Math.floor(diff / 86400)} ngày trước`;
  return new Date(dateStr).toLocaleDateString('vi-VN');
}

const TYPE_ICON = {
  reply: <Reply size={14} />,
  like: <MessageSquare size={14} />,
};

export default function NotificationBell() {
  const [open, setOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [unread, setUnread] = useState(0);
  const [loading, setLoading] = useState(false);
  const panelRef = useRef(null);
  const navigate = useNavigate();

  // ── fetch helpers ──
  const fetchCount = useCallback(async () => {
    try {
      const data = await notificationAPI.unreadCount();
      setUnread(data.count);
    } catch (_) {}
  }, []);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    try {
      const data = await notificationAPI.list();
      setNotifications(data);
      setUnread(data.filter(n => !n.is_read).length);
    } catch (_) {}
    finally { setLoading(false); }
  }, []);

  // ── initial load + polling ──
  useEffect(() => {
    fetchCount();
    const id = setInterval(fetchCount, POLL_INTERVAL);
    return () => clearInterval(id);
  }, [fetchCount]);

  // ── open panel ──
  const handleOpen = () => {
    if (!open) {
      setOpen(true);
      fetchAll();
    } else {
      setOpen(false);
    }
  };

  // ── close on outside click ──
  useEffect(() => {
    const handler = (e) => {
      if (panelRef.current && !panelRef.current.contains(e.target)) {
        setOpen(false);
      }
    };
    if (open) document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [open]);

  // ── click a notification ──
  const handleClick = async (notif) => {
    if (!notif.is_read) {
      await notificationAPI.markRead(notif.id);
      setNotifications(prev =>
        prev.map(n => n.id === notif.id ? { ...n, is_read: true } : n)
      );
      setUnread(prev => Math.max(0, prev - 1));
    }
    setOpen(false);
    if (notif.course_id && notif.lesson_id) {
      navigate(`/student/courses/${notif.course_id}/lessons/${notif.lesson_id}`);
    } else if (notif.lesson_id) {
      // fallback: try without course context
      navigate(`/student/courses/0/lessons/${notif.lesson_id}`);
    }
  };

  const handleMarkAll = async () => {
    await notificationAPI.markAllRead();
    setNotifications(prev => prev.map(n => ({ ...n, is_read: true })));
    setUnread(0);
  };

  return (
    <div className="nb-root" ref={panelRef}>
      <button className="nb-bell-btn" onClick={handleOpen} title="Thông báo">
        <Bell size={20} />
        {unread > 0 && (
          <span className="nb-badge">{unread > 99 ? '99+' : unread}</span>
        )}
      </button>

      {open && (
        <div className="nb-panel">
          <div className="nb-panel-header">
            <span className="nb-panel-title">Thông báo</span>
            {unread > 0 && (
              <button className="nb-mark-all" onClick={handleMarkAll}>
                <CheckCheck size={14} /> Đánh dấu tất cả đã đọc
              </button>
            )}
          </div>

          <div className="nb-list">
            {loading ? (
              <div className="nb-empty">Đang tải...</div>
            ) : notifications.length === 0 ? (
              <div className="nb-empty">
                <Bell size={32} />
                <p>Chưa có thông báo nào</p>
              </div>
            ) : (
              notifications.map(n => (
                <button
                  key={n.id}
                  className={`nb-item ${!n.is_read ? 'nb-item--unread' : ''}`}
                  onClick={() => handleClick(n)}
                >
                  <span className="nb-item-icon">{TYPE_ICON[n.notif_type] ?? <Bell size={14} />}</span>
                  <div className="nb-item-body">
                    <p className="nb-item-msg">{n.message}</p>
                    <span className="nb-item-time">{timeAgo(n.created_at)}</span>
                  </div>
                  {!n.is_read && <span className="nb-dot" />}
                </button>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
}
