import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Brain, BarChart3, BookOpen, Library, Award, TrendingUp,
  MessageSquare, Settings, LogOut, Moon, Sun, Route, Menu, X
} from 'lucide-react';
import { clearLegacyPersonalizationStorage } from '../utils/personalizationStorage';
import NotificationBell from './NotificationBell';
import { studentAPI } from '../services/api';
import '../pages/student/StudentDashboard.css';

const StudentSidebar = ({ darkMode, onToggleDarkMode }) => {
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [hasCompletionCertificate, setHasCompletionCertificate] = useState(false);

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 768) {
        setIsMobileMenuOpen(false);
      }
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  useEffect(() => {
    document.body.classList.toggle('student-menu-open', isMobileMenuOpen);
    return () => document.body.classList.remove('student-menu-open');
  }, [isMobileMenuOpen]);

  useEffect(() => {
    let isMounted = true;

    const loadCompletionCertificate = async () => {
      try {
        const roadmap = await studentAPI.getCurriculumStatus();

        const phases = roadmap?.phases || [];
        const requiredStageIds = [1, 2, 3, 4, 5];
        const completedRequiredStages = requiredStageIds.every((stageId) => {
          const stage = phases.find((phase) => phase.id === stageId);
          return Boolean(stage?.is_completed);
        });

        if (isMounted) {
          setHasCompletionCertificate(completedRequiredStages);
        }
      } catch (error) {
        console.error('Certificate load error:', error);
        if (isMounted) {
          setHasCompletionCertificate(false);
        }
      }
    };

    loadCompletionCertificate();

    return () => {
      isMounted = false;
    };
  }, []);

  const closeMobileMenu = () => setIsMobileMenuOpen(false);

  const handleNavigate = (path) => {
    navigate(path);
    closeMobileMenu();
  };

  const handleLogout = () => {
    clearLegacyPersonalizationStorage();
    localStorage.removeItem('token');
    localStorage.removeItem('currentUser');
    navigate('/login');
    closeMobileMenu();
  };

  return (
    <>
      <button
        type="button"
        className={`mobile-sidebar-toggle ${isMobileMenuOpen ? 'is-open' : ''}`}
        onClick={() => setIsMobileMenuOpen((current) => !current)}
        aria-label={isMobileMenuOpen ? 'Đóng menu điều hướng' : 'Mở menu điều hướng'}
        aria-expanded={isMobileMenuOpen}
      >
        {isMobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
      </button>

      {isMobileMenuOpen ? (
        <button
          type="button"
          className="sidebar-backdrop"
          aria-label="Đóng menu"
          onClick={closeMobileMenu}
        />
      ) : null}

      <aside className={`sidebar ${isMobileMenuOpen ? 'mobile-open' : ''}`}>
      <div className="sidebar-header">
        <div className="logo">
          <Brain className="w-8 h-8" />
        </div>
        <h2 className="logo-text">VLU AI Learning</h2>
      </div>

      <nav className="sidebar-nav">
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/dashboard')}
        >
          <BarChart3 className="w-5 h-5" />
          <span>Tổng Quan</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/courses')}
        >
          <BookOpen className="w-5 h-5" />
          <span>Khóa Học Của Tôi</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/browse-courses')}
        >
          <Library className="w-5 h-5" />
          <span>Duyệt Khóa Học</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/recommendations')}
        >
          <Brain className="w-5 h-5" />
          <span>Gợi Ý AI</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/grades')}
        >
          <Award className="w-5 h-5" />
          <span>Điểm Số</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/progress')}
        >
          <TrendingUp className="w-5 h-5" />
          <span>Tiến Độ</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/roadmap')}
        >
          <Route className="w-5 h-5" />
          <span>Lộ Trình Học</span>
        </button>
        <button
          className="nav-item"
          onClick={() => handleNavigate('/student/ai-advisor')}
        >
          <MessageSquare className="w-5 h-5" />
          <span>AI Advisor</span>
        </button>

        {hasCompletionCertificate ? (
          <button
            className="nav-item"
            onClick={() => handleNavigate('/student/certificate')}
          >
            <Award className="w-5 h-5" />
            <span>Chứng Chỉ Hoàn Thành</span>
          </button>
        ) : null}
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
        <button className="nav-item" onClick={() => handleNavigate('/student/profile')}>
          <Settings className="w-5 h-5" />
          <span>Cài Đặt</span>
        </button>

        {/* Dark Mode Toggle */}
        <button
          className="nav-item theme-toggle"
          onClick={() => {
            onToggleDarkMode();
            closeMobileMenu();
          }}
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
    </>
  );
};

export default StudentSidebar;
