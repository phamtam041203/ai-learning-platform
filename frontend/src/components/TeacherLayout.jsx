import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Home, BookOpen, Users, FileText, BarChart3, 
  LogOut, Menu, X
} from 'lucide-react';
import './TeacherLayout.css';

const TeacherLayout = ({ children }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  const navItems = [
    { path: '/teacher/dashboard', icon: Home, label: 'Dashboard' },
    { path: '/teacher/content', icon: BookOpen, label: 'Khóa học' },
    { path: '/teacher/students', icon: Users, label: 'Học sinh' },
    { path: '/teacher/essays', icon: FileText, label: 'Chấm bài' },
    { path: '/teacher/analytics', icon: BarChart3, label: 'Thống kê' },
  ];

  return (
    <div className="teacher-layout">
      {/* Sidebar */}
      <aside className={`teacher-sidebar ${sidebarOpen ? '' : 'collapsed'}`}>
        <div className="sidebar-header">
          <div className="logo">
            <BookOpen size={28} />
            <span>AI Learning</span>
          </div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <a
                key={item.path}
                href={item.path}
                className={`nav-item ${isActive ? 'active' : ''}`}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </a>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <button className="nav-item" onClick={handleLogout}>
            <LogOut size={20} />
            <span>Đăng xuất</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="teacher-main">
        <button 
          className="sidebar-toggle"
          onClick={() => setSidebarOpen(!sidebarOpen)}
        >
          {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
        {children}
      </main>
    </div>
  );
};

export default TeacherLayout;
