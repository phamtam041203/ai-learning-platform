import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  BookOpen, Users, FileText, CheckCircle, Clock, TrendingUp,
  Award, BarChart3, MessageCircle, Plus, Eye, Edit, Home, Settings, LogOut,
  Bell, Search, Menu, X, ArrowLeft, AlertCircle
} from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import './DashboardPage.css';

const DashboardPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [dashboardData, setDashboardData] = useState(null);
  const [courses, setCourses] = useState([]);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      setLoading(true);
      const [dashboard, coursesData] = await Promise.all([
        teacherAPI.getDashboard(),
        teacherAPI.getCourses()
      ]);
      setDashboardData(dashboard);
      setCourses(coursesData);
    } catch (err) {
      setError(err.message || 'Không thể tải dữ liệu');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('access_token');
    navigate('/login');
  };

  if (loading) {
    return (
      <div className="teacher-dashboard-layout">
        <div className="loading-container">
          <div className="loading-content">
            <div className="loading-spinner-modern">
              <div className="spinner-ring"></div>
              <div className="spinner-ring"></div>
              <div className="spinner-ring"></div>
              <BookOpen className="spinner-icon" size={32} />
            </div>
            <h3 className="loading-title">Đang tải Dashboard</h3>
            <p className="loading-text">Vui lòng đợi trong giây lát...</p>
            <div className="loading-dots">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="teacher-dashboard-layout">
        <div className="error-message">
          <AlertCircle size={48} />
          <p>{error}</p>
          <button onClick={fetchDashboard} className="btn-retry">Thử lại</button>
        </div>
      </div>
    );
  }

  const stats = dashboardData?.stats || {};

  return (
    <div className="teacher-dashboard-layout">
      {/* Sidebar */}
      <aside className={`dashboard-sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          <div className="logo">
            <BookOpen size={32} />
            <span>AI Learning</span>
          </div>
        </div>

        <nav className="sidebar-nav">
          <a href="/teacher/dashboard" className="nav-item active">
            <Home size={20} />
            <span>Dashboard</span>
          </a>
          <a href="/teacher/content" className="nav-item">
            <BookOpen size={20} />
            <span>Khóa học</span>
          </a>
          <a href="/teacher/students" className="nav-item">
            <Users size={20} />
            <span>Học sinh</span>
          </a>
          <a href="/teacher/student-advisor" className="nav-item">
            <MessageCircle size={20} />
            <span>AI Cố vấn SV</span>
          </a>
          <a href="/teacher/essays" className="nav-item">
            <FileText size={20} />
            <span>Chấm bài</span>
          </a>
          <a href="/teacher/analytics" className="nav-item">
            <BarChart3 size={20} />
            <span>Thống kê</span>
          </a>
          <a href="/teacher/dashboard" className="nav-item">
            <ArrowLeft size={20} />
            <span>Trang chủ</span>
          </a>
        </nav>

        <div className="sidebar-footer">
          <button className="nav-item" onClick={handleLogout}>
            <LogOut size={20} />
            <span>Đăng xuất</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <div className="dashboard-main">
        {/* Top Bar */}
        <header className="dashboard-topbar">
          <button className="menu-toggle" onClick={() => setSidebarOpen(!sidebarOpen)}>
            {sidebarOpen ? <X size={24} /> : <Menu size={24} />}
          </button>

          <div className="topbar-search">
            <Search size={20} />
            <input type="text" placeholder="Tìm kiếm khóa học, học sinh..." />
          </div>

          <div className="topbar-actions">
            <button className="icon-btn">
              <Bell size={20} />
              <span className="badge">3</span>
            </button>
            <div className="user-menu">
              <div className="user-avatar">
                {dashboardData?.teacher?.name?.charAt(0) || 'G'}
              </div>
              <div className="user-info">
                <span className="user-name">{dashboardData?.teacher?.name || 'Giảng viên'}</span>
                <span className="user-role">Giảng viên</span>
              </div>
            </div>
          </div>
        </header>

        {/* Dashboard Content */}
        <div className="dashboard-content">
          {/* Welcome Section */}
          <div className="welcome-section">
            <div className="welcome-text">
              <h1>Chào mừng trở lại, {dashboardData?.teacher?.name?.split(' ').pop() || 'Giảng viên'}! 👋</h1>
              <p>Đây là tổng quan về hoạt động giảng dạy của bạn</p>
            </div>
            <button 
              className="btn-create-course"
              onClick={() => navigate('/teacher/content')}
            >
              <Plus size={20} />
              Tạo khóa học mới
            </button>
          </div>

          {/* Stats Cards */}
          <div className="stats-grid">
            <div className="stat-card blue">
              <div className="stat-icon">
                <BookOpen size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Khóa học</p>
                <p className="stat-value">{stats.total_courses || 0}</p>
              </div>
            </div>

            <div className="stat-card green">
              <div className="stat-icon">
                <Users size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Học sinh</p>
                <p className="stat-value">{stats.total_students || 0}</p>
              </div>
            </div>

            <div className="stat-card purple">
              <div className="stat-icon">
                <FileText size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Bài học</p>
                <p className="stat-value">{stats.total_lessons || 0}</p>
              </div>
            </div>

            <div className="stat-card orange">
              <div className="stat-icon">
                <Clock size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Chờ duyệt</p>
                <p className="stat-value">{stats.pending_approvals || 0}</p>
              </div>
            </div>

            <div className="stat-card indigo">
              <div className="stat-icon">
                <CheckCircle size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Quiz</p>
                <p className="stat-value">{stats.total_quizzes || 0}</p>
              </div>
            </div>

            <div className="stat-card pink">
              <div className="stat-icon">
                <Award size={24} />
              </div>
              <div className="stat-content">
                <p className="stat-label">Đánh giá TB</p>
                <p className="stat-value">{stats.average_rating?.toFixed(1) || '0.0'}</p>
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="quick-actions">
            <div className="section-header">
              <h2>Thao tác nhanh</h2>
            </div>
            <div className="actions-grid">
              <div 
                className="action-card blue"
                onClick={() => navigate('/teacher/essays')}
              >
                <div className="action-icon">
                  <Edit size={24} />
                </div>
                <div className="action-title">Chấm bài</div>
                <div className="action-description">Chấm điểm bài tập và essay</div>
              </div>

              <div 
                className="action-card green"
                onClick={() => navigate('/teacher/students')}
              >
                <div className="action-icon">
                  <Users size={24} />
                </div>
                <div className="action-title">Học sinh</div>
                <div className="action-description">Quản lý danh sách học sinh</div>
              </div>

              <div 
                className="action-card purple"
                onClick={() => navigate('/teacher/content')}
              >
                <div className="action-icon">
                  <BookOpen size={24} />
                </div>
                <div className="action-title">Nội dung</div>
                <div className="action-description">Quản lý khóa học và bài giảng</div>
              </div>

              <div 
                className="action-card orange"
                onClick={() => navigate('/teacher/analytics')}
              >
                <div className="action-icon">
                  <BarChart3 size={24} />
                </div>
                <div className="action-title">Thống kê</div>
                <div className="action-description">Xem báo cáo và phân tích</div>
              </div>
            </div>
          </div>

          {/* Recent Courses */}
          <div className="recent-courses">
            <div className="section-header">
              <h2>Khóa học của bạn</h2>
              <button 
                className="btn-view-all"
                onClick={() => navigate('/teacher/content')}
              >
                Xem tất cả →
              </button>
            </div>

            {courses.length === 0 ? (
              <div className="empty-state">
                <div className="empty-icon">
                  <BookOpen size={40} />
                </div>
                <h3>Chưa có khóa học nào</h3>
                <p>Hãy tạo khóa học đầu tiên để bắt đầu giảng dạy</p>
                <button 
                  className="btn-primary"
                  onClick={() => navigate('/teacher/content')}
                >
                  <Plus size={20} />
                  Tạo khóa học đầu tiên
                </button>
              </div>
            ) : (
              <div className="courses-grid">
                {courses.slice(0, 6).map(course => (
                  <div key={course.id} className="course-card">
                    <div className="course-image">
                      <BookOpen size={48} />
                    </div>
                    <div className="course-content">
                      <h3 className="course-title">{course.title}</h3>
                      <p className="course-description">
                        {course.description?.substring(0, 80) || 'Chưa có mô tả'}...
                      </p>
                      
                      <div className="course-stats">
                        <div className="course-stat">
                          <Users size={16} />
                          <span>{course.enrolled_count || 0} học sinh</span>
                        </div>
                        <div className="course-stat">
                          <FileText size={16} />
                          <span>{course.lesson_count || 0} bài học</span>
                        </div>
                      </div>

                      <div className="course-actions">
                        <button
                          className="btn-icon"
                          onClick={() => navigate(`/teacher/courses/${course.id}`)}
                        >
                          <Eye size={18} />
                          Xem
                        </button>
                        <button
                          className="btn-icon"
                          onClick={() => navigate(`/teacher/content`)}
                        >
                          <Edit size={18} />
                          Sửa
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
