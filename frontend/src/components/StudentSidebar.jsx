import { useNavigate } from 'react-router-dom';
import {
  Brain, BarChart3, BookOpen, Library, Award, TrendingUp,
  MessageSquare, Settings, LogOut, Moon, Sun, Route, ClipboardList
} from 'lucide-react';
import { clearLegacyPersonalizationStorage } from '../utils/personalizationStorage';
import NotificationBell from './NotificationBell';
import '../pages/student/StudentDashboard.css';

const StudentSidebar = ({ darkMode, onToggleDarkMode }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    clearLegacyPersonalizationStorage();
    localStorage.removeItem('token');
    localStorage.removeItem('currentUser');
    navigate('/login');
  };

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="logo">
          <Brain className="w-8 h-8" />
        </div>
        <h2 className="logo-text">AI Learning</h2>
      </div>

      <nav className="sidebar-nav">
        <button
          className="nav-item"
          onClick={() => navigate('/student/dashboard')}
        >
          <BarChart3 className="w-5 h-5" />
          <span>Tổng Quan</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/courses')}
        >
          <BookOpen className="w-5 h-5" />
          <span>Khóa Học Của Tôi</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/browse-courses')}
        >
          <Library className="w-5 h-5" />
          <span>Duyệt Khóa Học</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/recommendations')}
        >
          <Brain className="w-5 h-5" />
          <span>Gợi Ý AI</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/grades')}
        >
          <Award className="w-5 h-5" />
          <span>Điểm Số</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/progress')}
        >
          <TrendingUp className="w-5 h-5" />
          <span>Tiến Độ</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/skill-assessment')}
        >
          <ClipboardList className="w-5 h-5" />
          <span>Test Năng Lực</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/roadmap')}
        >
          <Route className="w-5 h-5" />
          <span>Lộ Trình Học</span>
        </button>
        <button
          className="nav-item"
          onClick={() => navigate('/student/ai-advisor')}
        >
          <MessageSquare className="w-5 h-5" />
          <span>AI Advisor</span>
        </button>
      </nav>

      <div className="sidebar-footer">
        {/* Notification Bell */}
        <div className="nav-item" style={{ cursor: 'default', justifyContent: 'space-between' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <NotificationBell />
            <span>Thông báo</span>
          </span>
        </div>

        {/* Settings */}
        <button className="nav-item" onClick={() => navigate('/student/profile')}>
          <Settings className="w-5 h-5" />
          <span>Cài Đặt</span>
        </button>

        {/* Dark Mode Toggle */}
        <button
          className="nav-item theme-toggle"
          onClick={onToggleDarkMode}
          title={darkMode ? "Chế độ sáng" : "Chế độ tối"}
        >
          {darkMode ? (
            <Sun className="w-5 h-5" />
          ) : (
            <Moon className="w-5 h-5" />
          )}
          <span>{darkMode ? "Chế độ sáng" : "Chế độ tối"}</span>
        </button>

        {/* Logout */}
        <button className="nav-item" onClick={handleLogout}>
          <LogOut className="w-5 h-5" />
          <span>Đăng Xuất</span>
        </button>
      </div>
    </aside>
  );
};

export default StudentSidebar;
