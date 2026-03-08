import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

import {
  BookOpen, TrendingUp, Clock, Award, Brain,
  MessageSquare, Target, BarChart3, ChevronRight,
  Play, CheckCircle, AlertCircle, Star, Zap,
  Calendar, User, Settings, LogOut, Bell,
  Search, Filter, ArrowUp, Download, Moon, Sun,
  Loader2, RefreshCw, PlusCircle, Library
} from 'lucide-react';
import './StudentDashboard.css';
import { studentAPI, courseAPI } from '../../services/api';
import { buildGradesSnapshotFromEnrollments, convertScore10ToGpa4, normalizeRecommendations } from '../../utils/studentDataTransforms';

const StudentDashboard = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('overview');
  const [showNotifications, setShowNotifications] = useState(false);
  const [darkMode, setDarkMode] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);

  // Data states
  const [studentData, setStudentData] = useState({
    name: '',
    studentId: '',
    major: '',
    className: '',
    avatar: ''
  });

  const [dashboardData, setDashboardData] = useState(null);
  const [myCourses, setMyCourses] = useState([]);
  const [recommendedCourses, setRecommendedCourses] = useState([]);

  // Load dark mode preference from localStorage
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
      setDarkMode(true);
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  // Check auth and fetch data
  useEffect(() => {
    const storedUser = JSON.parse(localStorage.getItem('currentUser'));
    const token = localStorage.getItem('token');

    if (!storedUser || !token) {
      navigate('/login');
      return;
    }

    // Only fetch if currentUser has changed (avoid redundant fetches)
    if (!currentUser || currentUser.id !== storedUser.id) {
      setCurrentUser(storedUser);

      setStudentData({
        name: storedUser.name || '',
        studentId: storedUser.studentId || '',
        major: storedUser.major || '',
        className: storedUser.className || '',
        avatar: ''
      });

      fetchDashboardData();
    }
  }, [currentUser?.id, navigate]);

  // Fetch all dashboard data
  const fetchDashboardData = async () => {
    setLoading(true);
    setError(null);

    try {
      // Fetch dashboard and specialization courses in parallel
      const [dashboardRes, coursesRes, recommendationsRes] = await Promise.all([
        studentAPI.getDashboard().catch(() => null),
        courseAPI.getMyCourses().catch(() => []),
        studentAPI.getRecommendedCourses().catch(() => ({ recommendations: [] }))
      ]);

      if (dashboardRes) {
        setDashboardData(dashboardRes);
        // Update student data from dashboard
        if (dashboardRes.student) {
          setStudentData(prev => ({
            ...prev,
            name: dashboardRes.student.name || prev.name,
            studentId: dashboardRes.student.student_id || prev.studentId,
            major: dashboardRes.student.major || prev.major,
            className: dashboardRes.student.class_name || prev.className
          }));
        }
      }

      const normalizedCourses = (coursesRes || []).filter((enrollment) => enrollment.course);
      setMyCourses(normalizedCourses);
      setRecommendedCourses(normalizeRecommendations(recommendationsRes?.recommendations || []));

    } catch (err) {
      console.error('Failed to fetch dashboard data:', err);
      setError('Không thể tải dữ liệu. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'recommendations') {
      void fetchDashboardData();
    }
  }, [activeTab]);

  // Toggle dark mode
  const toggleDarkMode = () => {
    const newMode = !darkMode;
    setDarkMode(newMode);

    if (newMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
      localStorage.setItem('theme', 'light');
    }
  };

  const handleLogout = () => {
    localStorage.clear();
    sessionStorage.clear();
    navigate('/login');
  };

  const gradedCourses = myCourses.filter((enrollment) => typeof enrollment.grades?.total === 'number');
  const averageScore = gradedCourses.length
    ? gradedCourses.reduce((sum, enrollment) => sum + enrollment.grades.total, 0) / gradedCourses.length
    : 0;
  const averageGpa = gradedCourses.length
    ? gradedCourses.reduce((sum, enrollment) => sum + convertScore10ToGpa4(enrollment.grades.total), 0) / gradedCourses.length
    : 0;
  const totalCredits = myCourses.reduce((sum, enrollment) => sum + (enrollment.course?.credit_hours || 0), 0);
  const averageProgress = dashboardData?.stats?.average_progress
    ?? dashboardData?.stats?.avg_progress
    ?? (myCourses.length
      ? Math.round(myCourses.reduce((sum, enrollment) => sum + (enrollment.progress || 0), 0) / myCourses.length)
      : 0);
  const totalHours = dashboardData?.stats?.total_hours ?? dashboardData?.stats?.hours_spent ?? 0;

  // Get stats from dashboard data
  const learningStats = dashboardData ? [
    {
      label: 'Tổng khóa học',
      value: dashboardData.stats?.total_courses || myCourses.length || 0,
      change: `${dashboardData.stats?.completed_courses || myCourses.filter((enrollment) => (enrollment.progress || 0) >= 100).length} hoàn thành`,
      trend: 'up',
      icon: <BookOpen className="w-5 h-5" />,
      color: 'blue'
    },
    {
      label: 'GPA',
      value: averageGpa.toFixed(2),
      change: `${averageScore.toFixed(2)}/10`,
      trend: 'up',
      icon: <Star className="w-5 h-5" />,
      color: 'yellow'
    },
    {
      label: 'Tiến độ trung bình',
      value: `${averageProgress}%`,
      change: `${dashboardData.stats?.in_progress || 0} đang học`,
      trend: 'up',
      icon: <TrendingUp className="w-5 h-5" />,
      color: 'green'
    },
    {
      label: 'Thời gian học',
      value: `${totalHours}h`,
      change: `${totalCredits} tín chỉ`,
      trend: 'up',
      icon: <Clock className="w-5 h-5" />,
      color: 'orange'
    }
  ] : [];
  // Recent activity (mock for now)
  const recentActivity = [
    {
      id: 1,
      type: 'completed',
      title: 'Hoàn thành bài học mới',
      time: 'Gần đây',
      icon: <CheckCircle className="w-5 h-5 text-green-500" />
    },
    {
      id: 2,
      type: 'achievement',
      title: 'Đạt thành tựu học tập',
      time: 'Hôm nay',
      icon: <Award className="w-5 h-5 text-yellow-500" />
    },
    {
      id: 3,
      type: 'study',
      title: 'Tiếp tục khóa học',
      time: '1 ngày trước',
      icon: <BookOpen className="w-5 h-5 text-blue-500" />
    }
  ];

  // Weekly progress (mock for now)
  const weeklyProgress = [
    { day: 'T2', hours: 3.5 },
    { day: 'T3', hours: 4.2 },
    { day: 'T4', hours: 2.8 },
    { day: 'T5', hours: 5.1 },
    { day: 'T6', hours: 3.9 },
    { day: 'T7', hours: 2.5 },
    { day: 'CN', hours: 2.5 }
  ];

  // Loading state
  if (loading) {
    return (
      <div className="student-dashboard loading-screen">
        <div className="loading-content">
          <Loader2 className="w-12 h-12 animate-spin text-blue-600" />
          <p>Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="student-dashboard">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <div className="logo">
            <Brain className="w-8 h-8" />
          </div>
          <h2 className="logo-text">AI Learning</h2>
        </div>

        <nav className="sidebar-nav">
          <button
            className={`nav-item ${activeTab === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveTab('overview')}
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
            className={`nav-item ${activeTab === 'recommendations' ? 'active' : ''}`}
            onClick={() => setActiveTab('recommendations')}
          >
            <Brain className="w-5 h-5" />
            <span>Gợi Ý AI</span>
            {recommendedCourses.length > 0 && (
              <span className="badge">{recommendedCourses.length}</span>
            )}
          </button>
          <button
            className={`nav-item ${activeTab === 'grades' ? 'active' : ''}`}
            onClick={() => setActiveTab('grades')}
          >
            <Award className="w-5 h-5" />
            <span>Điểm Số</span>
          </button>
          <button
            className={`nav-item ${activeTab === 'progress' ? 'active' : ''}`}
            onClick={() => setActiveTab('progress')}
          >
            <TrendingUp className="w-5 h-5" />
            <span>Tiến Độ</span>
          </button>
        </nav>

        <div className="sidebar-footer">
          {/* Settings */}
          <button className="nav-item" onClick={() => navigate('/student/profile')}>
            <Settings className="w-5 h-5" />
            <span>Cài Đặt</span>
          </button>

          {/* Dark Mode Toggle */}
          <button
            className="nav-item theme-toggle"
            onClick={toggleDarkMode}
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

      {/* Main Content */}
      <main className="main-content">
        {/* Header */}
        <header className="dashboard-header">
          <div className="header-left">
            <h1 className="page-title">
              {activeTab === 'overview' && 'Tổng Quan'}
              {activeTab === 'courses' && 'Khóa Học Của Tôi'}
              {activeTab === 'browse' && 'Duyệt Khóa Học'}
              {activeTab === 'recommendations' && 'Gợi Ý AI'}
              {activeTab === 'grades' && 'Bảng Điểm'}
              {activeTab === 'progress' && 'Tiến Độ Học Tập'}
              {activeTab === 'chatbot' && 'AI Chatbot'}
            </h1>
            <p className="page-subtitle">
              Xin chào, {studentData.name}
            </p>
          </div>
          <div className="header-right">
            <button className="icon-button" onClick={fetchDashboardData} title="Làm mới">
              <RefreshCw className="w-5 h-5" />
            </button>
            <button className="icon-button">
              <Search className="w-5 h-5" />
            </button>
            <button
              className="icon-button notification-button"
              onClick={() => setShowNotifications(!showNotifications)}
            >
              <Bell className="w-5 h-5" />
              {dashboardData?.upcoming_deadlines?.length > 0 && (
                <span className="notification-dot"></span>
              )}
            </button>
            <div className="user-menu" onClick={() => navigate('/student/profile')}>
              <div className="user-avatar">
                {studentData.name ? studentData.name.charAt(0).toUpperCase() : '?'}
              </div>
              <div className="user-info">
                <div className="user-name">{studentData.name}</div>
                <div className="user-id">{studentData.studentId}</div>
              </div>
            </div>
          </div>
        </header>

        {/* Error Message */}
        {error && (
          <div className="error-banner">
            <AlertCircle className="w-5 h-5" />
            <span>{error}</span>
            <button onClick={fetchDashboardData}>Thử lại</button>
          </div>
        )}

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="dashboard-content">
            {/* Stats Cards */}
            <div className="stats-grid">
              {learningStats.map((stat, index) => (
                <div key={index} className={`stat-card ${stat.color}`}>
                  <div className="stat-header">
                    <div className="stat-icon">{stat.icon}</div>
                    <span className={`stat-change ${stat.trend}`}>
                      <ArrowUp className="w-4 h-4" />
                      {stat.change}
                    </span>
                  </div>
                  <div className="stat-value">{stat.value}</div>
                  <div className="stat-label">{stat.label}</div>
                </div>
              ))}
            </div>

            {/* Main Grid */}
            <div className="content-grid">
              {/* Current Courses */}
              <div className="content-card courses-card">
                <div className="card-header">
                  <h3 className="card-title">Khóa Học Đang Học</h3>
                  <button className="text-button" onClick={() => setActiveTab('courses')}>
                    Xem tất cả
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
                <div className="courses-list">
                  {dashboardData?.recent_courses?.length > 0 ? (
                    dashboardData.recent_courses.map((course) => (
                      <div key={course.id} className="course-item">
                        <div className="course-thumbnail">
                          {course.course_code?.charAt(0) || '📚'}
                        </div>
                        <div className="course-info">
                          <div className="course-header">
                            <h4 className="course-title">{course.course_name}</h4>
                            <span className="course-code">{course.course_code}</span>
                          </div>
                          <p className="course-next">
                            Tiến độ: {course.progress || 0}%
                          </p>
                          <div className="course-footer">
                            <div className="progress-bar">
                              <div
                                className="progress-fill"
                                style={{ width: `${course.progress || 0}%` }}
                              ></div>
                            </div>
                            <span className="progress-text">{course.progress || 0}%</span>
                          </div>
                        </div>
                        <button className="continue-button">
                          <Play className="w-5 h-5" />
                        </button>
                      </div>
                    ))
                  ) : (
                    <div className="empty-state">
                      <BookOpen className="w-12 h-12 text-gray-300" />
                      <p>Chưa có khóa học nào</p>
                      <button className="btn-enroll" onClick={() => setActiveTab('recommendations')}>
                        Đăng ký khóa học
                      </button>
                    </div>
                  )}
                </div>
              </div>

              {/* AI Recommendations Preview */}
              <div className="content-card">
                <div className="card-header">
                  <div className="card-title-with-icon">
                    <Brain className="w-5 h-5 text-purple-600" />
                    <h3 className="card-title">Gợi Ý AI Cho Bạn</h3>
                  </div>
                  <button className="text-button" onClick={() => setActiveTab('recommendations')}>
                    Xem tất cả
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
                <div className="recommendations-preview">
                  {recommendedCourses.slice(0, 3).map((rec) => (
                    <div key={rec.id} className="recommendation-item">
                      <div className="rec-icon">{rec.icon || '📚'}</div>
                      <div className="rec-info">
                        <h4 className="rec-title">{rec.course_name}</h4>
                        <p className="rec-description">{rec.reason}</p>
                        <div className="rec-footer">
                          <span className="rec-category">{rec.credit_hours} tín chỉ</span>
                          <span className="rec-relevance">{rec.score ? `${rec.score}% phù hợp` : rec.level}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                  {recommendedCourses.length === 0 && (
                    <div className="empty-state small">
                      <p>Không có gợi ý nào</p>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Bottom Grid */}
            <div className="bottom-grid">
              {/* Weekly Progress Chart */}
              <div className="content-card">
                <div className="card-header">
                  <h3 className="card-title">Hoạt Động Tuần Này</h3>
                  <button className="icon-button small">
                    <Download className="w-4 h-4" />
                  </button>
                </div>
                <div className="chart-container">
                  {weeklyProgress.map((day, index) => (
                    <div key={index} className="chart-bar-container">
                      <div className="chart-bar">
                        <div
                          className="chart-bar-fill"
                          style={{ height: `${(day.hours / 6) * 100}%` }}
                        >
                          <span className="chart-value">{day.hours}h</span>
                        </div>
                      </div>
                      <span className="chart-label">{day.day}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Upcoming Deadlines */}
              <div className="content-card">
                <div className="card-header">
                  <h3 className="card-title">Deadline Sắp Tới</h3>
                  <button className="text-button">
                    <Calendar className="w-4 h-4" />
                  </button>
                </div>
                <div className="deadlines-list">
                  {dashboardData?.upcoming_deadlines?.length > 0 ? (
                    dashboardData.upcoming_deadlines.map((deadline) => (
                      <div key={deadline.id} className="deadline-item">
                        <div className={`deadline-priority ${deadline.days_left <= 3 ? 'high' : 'medium'}`}></div>
                        <div className="deadline-info">
                          <h4 className="deadline-title">{deadline.title}</h4>
                          <p className="deadline-course">{deadline.course_name}</p>
                        </div>
                        <div className="deadline-time">
                          <span className="days-left">{deadline.days_left} ngày</span>
                          <span className="due-date">{deadline.type}</span>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="empty-state small">
                      <Calendar className="w-8 h-8 text-gray-300" />
                      <p>Không có deadline sắp tới</p>
                    </div>
                  )}
                </div>
              </div>

              {/* Recent Activity */}
              <div className="content-card">
                <div className="card-header">
                  <h3 className="card-title">Hoạt Động Gần Đây</h3>
                </div>
                <div className="activity-list">
                  {recentActivity.map((activity) => (
                    <div key={activity.id} className="activity-item">
                      <div className="activity-icon">{activity.icon}</div>
                      <div className="activity-info">
                        <p className="activity-title">{activity.title}</p>
                        <span className="activity-time">{activity.time}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Courses Tab */}
        {activeTab === 'courses' && (
          <div className="dashboard-content">
            <div className="courses-header">
              <div className="search-filter">
                <div className="search-box">
                  <Search className="w-5 h-5" />
                  <input type="text" placeholder="Tìm kiếm khóa học..." />
                </div>
                <button className="filter-button">
                  <Filter className="w-5 h-5" />
                  Lọc
                </button>
              </div>
            </div>

            <div className="courses-grid">
              {myCourses.length > 0 ? (
                myCourses.map((enrollment) => (
                  <div 
                    key={enrollment.enrollment_id} 
                    className="course-card"
                    onClick={() => navigate(`/student/course/${enrollment.course.id}`, { state: { enrollment } })}
                    style={{ cursor: 'pointer' }}
                  >
                    <div className="course-card-header">
                      <div className="course-thumbnail-large">
                        {enrollment.course.course_code?.charAt(0) || '📚'}
                      </div>
                      <span className="course-progress-badge">{enrollment.progress || 0}%</span>
                    </div>
                    <div className="course-card-body">
                      <span className="course-code-badge">{enrollment.course.course_code}</span>
                      <h3 className="course-card-title">{enrollment.course.course_name}</h3>
                      <p className="course-instructor">
                        <BookOpen className="w-4 h-4" />
                        {enrollment.course.credit_hours} tín chỉ - {enrollment.course.level}
                      </p>
                      <div className="course-progress-bar">
                        <div
                          className="course-progress-fill"
                          style={{ width: `${enrollment.progress || 0}%` }}
                        ></div>
                      </div>
                      <div className="course-card-footer">
                        <span className="next-lesson">
                          {enrollment.completed_lessons || 0}/{enrollment.total_lessons || 0} bài học
                        </span>
                        <button 
                          className="btn-continue"
                          onClick={(e) => {
                            e.stopPropagation();
                            navigate(`/student/course/${enrollment.course.id}`, { state: { enrollment } });
                          }}
                        >
                          Tiếp tục
                          <ChevronRight className="w-4 h-4" />
                        </button>
                      </div>
                      {enrollment.grades?.total && (
                        <div className="course-grade">
                          <span>Điểm: {enrollment.grades.total}/10</span>
                          <span className="grade-letter">{enrollment.grades.letter}</span>
                        </div>
                      )}
                    </div>
                  </div>
                ))
              ) : (
                <div className="empty-state-large">
                  <BookOpen className="w-16 h-16 text-gray-300" />
                  <h3>Chưa có khóa học nào</h3>
                  <p>Hãy đăng ký khóa học để bắt đầu học</p>
                  <button className="btn-primary" onClick={() => setActiveTab('recommendations')}>
                    Xem gợi ý khóa học
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      
        {/* Browse Courses Tab */}
        {activeTab === 'browse' && (
          <BrowseCoursesTab onEnrollSuccess={fetchDashboardData} />
        )}

        {/* Recommendations Tab */}
        {activeTab === 'recommendations' && (
          <RecommendationsTab
            recommendations={recommendedCourses}
            onEnrollSuccess={fetchDashboardData}
          />
        )}

        {/* Grades Tab */}
        {activeTab === 'grades' && (
          <GradesTab />
        )}

        {/* Progress Tab */}
        {activeTab === 'progress' && (
          <ProgressTab />
        )}
      </main>
    </div>
  );
};

// Grades Tab Component
const GradesTab = () => {
  const [gradesData, setGradesData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchGrades = async () => {
      try {
        const enrollments = await courseAPI.getMyCourses();
        setGradesData(buildGradesSnapshotFromEnrollments(enrollments));
      } catch (err) {
        console.error('Failed to fetch grades:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchGrades();
  }, []);

  if (loading) {
    return (
      <div className="dashboard-content loading-tab">
        <Loader2 className="w-8 h-8 animate-spin" />
        <p>Đang tải bảng điểm...</p>
      </div>
    );
  }

  return (
    <div className="dashboard-content">
      {/* Summary Cards */}
      {gradesData?.summary && (
        <div className="grades-summary">
          <div className="summary-card gpa">
            <h3>GPA</h3>
            <div className="value">{gradesData.summary.gpa_4}</div>
            <span className="scale">/4.0</span>
          </div>
          <div className="summary-card avg">
            <h3>Điểm TB</h3>
            <div className="value">{gradesData.summary.average_10}</div>
            <span className="scale">/10</span>
          </div>
          <div className="summary-card credits">
            <h3>Tín chỉ</h3>
            <div className="value">{gradesData.summary.total_credits}</div>
          </div>
          <div className="summary-card passed">
            <h3>Đạt</h3>
            <div className="value">{gradesData.summary.passed}</div>
            <span className="label">môn</span>
          </div>
        </div>
      )}

      {/* Grades Table */}
      <div className="content-card grades-table-card">
        <div className="card-header">
          <h3 className="card-title">Bảng Điểm Chi Tiết</h3>
        </div>
        {gradesData?.grades?.length > 0 ? (
          <table className="grades-table">
            <thead>
              <tr>
                <th>Mã MH</th>
                <th>Tên môn học</th>
                <th>Tín chỉ</th>
                <th>Giữa kỳ</th>
                <th>Cuối kỳ</th>
                <th>Tổng kết</th>
                <th>Điểm chữ</th>
              </tr>
            </thead>
            <tbody>
              {gradesData.grades.map((grade, index) => (
                <tr key={index} className={grade.scores?.total < 5 ? 'failed' : ''}>
                  <td>{grade.course_code}</td>
                  <td>{grade.course_name}</td>
                  <td>{grade.credits}</td>
                  <td>{grade.scores?.midterm ?? '-'}</td>
                  <td>{grade.scores?.final ?? '-'}</td>
                  <td className="total-score">{grade.scores?.total ?? '-'}</td>
                  <td className={`grade-letter ${grade.grade_letter}`}>
                    {grade.grade_letter || '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty-state">
            <Award className="w-12 h-12 text-gray-300" />
            <p>Chưa có điểm nào</p>
          </div>
        )}
      </div>
    </div>
  );
};

// Progress Tab Component
const ProgressTab = () => {
  const [statsData, setStatsData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await studentAPI.getStatistics();
        setStatsData(data);
      } catch (err) {
        console.error('Failed to fetch statistics:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="dashboard-content loading-tab">
        <Loader2 className="w-8 h-8 animate-spin" />
        <p>Đang tải thống kê...</p>
      </div>
    );
  }

  return (
    <div className="dashboard-content">
      {statsData && (
        <>
          {/* Overview Stats */}
          <div className="stats-section">
            <h3>Tổng quan</h3>
            <div className="stats-grid small">
              <div className="stat-item">
                <BookOpen className="w-6 h-6" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.overview?.total_courses || 0}</span>
                  <span className="stat-label">Khóa học</span>
                </div>
              </div>
              <div className="stat-item">
                <CheckCircle className="w-6 h-6 text-green-500" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.overview?.completed_courses || 0}</span>
                  <span className="stat-label">Hoàn thành</span>
                </div>
              </div>
              <div className="stat-item">
                <TrendingUp className="w-6 h-6 text-blue-500" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.overview?.completion_rate || 0}%</span>
                  <span className="stat-label">Tỷ lệ hoàn thành</span>
                </div>
              </div>
            </div>
          </div>

          {/* Time Stats */}
          <div className="stats-section">
            <h3>Thời gian học</h3>
            <div className="stats-grid small">
              <div className="stat-item">
                <Clock className="w-6 h-6" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.time?.total_hours || 0}h</span>
                  <span className="stat-label">Tổng thời gian</span>
                </div>
              </div>
              <div className="stat-item">
                <Target className="w-6 h-6" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.time?.avg_hours_per_course || 0}h</span>
                  <span className="stat-label">TB/khóa học</span>
                </div>
              </div>
            </div>
          </div>

          {/* Lessons Stats */}
          <div className="stats-section">
            <h3>Bài học</h3>
            <div className="progress-stat">
              <div className="progress-info">
                <span>{statsData.lessons?.completed || 0} / {statsData.lessons?.total || 0} bài học</span>
                <span>{statsData.lessons?.completion_rate || 0}%</span>
              </div>
              <div className="progress-bar large">
                <div
                  className="progress-fill"
                  style={{ width: `${statsData.lessons?.completion_rate || 0}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* Grade Distribution */}
          <div className="stats-section">
            <h3>Phân bố điểm</h3>
            <div className="grade-distribution">
              {Object.entries(statsData.grades?.distribution || {}).map(([grade, count]) => (
                <div key={grade} className={`grade-bar ${grade}`}>
                  <span className="grade-label">{grade}</span>
                  <div className="bar-container">
                    <div
                      className="bar-fill"
                      style={{ width: `${count * 20}%` }}
                    ></div>
                  </div>
                  <span className="grade-count">{count}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Submission Stats */}
          <div className="stats-section">
            <h3>Bài nộp</h3>
            <div className="stats-grid small">
              <div className="stat-item">
                <CheckCircle className="w-6 h-6 text-green-500" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.submissions?.on_time || 0}</span>
                  <span className="stat-label">Đúng hạn</span>
                </div>
              </div>
              <div className="stat-item">
                <AlertCircle className="w-6 h-6 text-red-500" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.submissions?.late || 0}</span>
                  <span className="stat-label">Trễ hạn</span>
                </div>
              </div>
              <div className="stat-item">
                <Target className="w-6 h-6" />
                <div className="stat-content">
                  <span className="stat-value">{statsData.submissions?.on_time_rate || 0}%</span>
                  <span className="stat-label">Tỷ lệ đúng hạn</span>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

// Recommendations Tab Component
const RecommendationsTab = ({ recommendations, onEnrollSuccess }) => {
  const [enrolling, setEnrolling] = useState(null);
  const [message, setMessage] = useState(null);

  const handleEnroll = async (courseId) => {
    setEnrolling(courseId);
    setMessage(null);
    try {
      await courseAPI.enrollCourse(courseId);
      setMessage({ type: 'success', text: 'Đăng ký khóa học thành công!' });
      if (onEnrollSuccess) onEnrollSuccess();
    } catch (err) {
      setMessage({ type: 'error', text: err.message || 'Không thể đăng ký khóa học' });
    } finally {
      setEnrolling(null);
    }
  };

  return (
    <div className="dashboard-content">
      <div className="recommendations-header">
        <h2>Khóa Học Gợi Ý Dành Cho Bạn</h2>
        <p>Dựa trên ngành học và tiến độ của bạn</p>
      </div>

      {message && (
        <div className={`message-banner ${message.type}`}>
          {message.type === 'success' ? <CheckCircle className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
          <span>{message.text}</span>
        </div>
      )}

      <div className="recommendations-grid">
        {recommendations.length > 0 ? (
          recommendations.map((rec) => (
            <div key={rec.id} className="recommendation-card">
              <div className="rec-card-header">
                <span className="rec-code">{rec.course_code}</span>
                <span className="rec-level">{rec.score ? `${rec.score}%` : rec.level}</span>
              </div>
              <h3 className="rec-card-title">{rec.course_name}</h3>
              <p className="rec-reason">{rec.reason}</p>
              <div className="rec-card-footer">
                <span className="rec-credits">{rec.credit_hours} tín chỉ</span>
                <button
                  className="btn-enroll-course"
                  onClick={() => handleEnroll(rec.id)}
                  disabled={enrolling === rec.id}
                >
                  {enrolling === rec.id ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Đang đăng ký...
                    </>
                  ) : (
                    <>
                      <PlusCircle className="w-4 h-4" />
                      Đăng ký
                    </>
                  )}
                </button>
              </div>
            </div>
          ))
        ) : (
          <div className="empty-state-large">
            <Brain className="w-16 h-16 text-gray-300" />
            <h3>Không có gợi ý nào</h3>
            <p>Bạn đã đăng ký tất cả các khóa học phù hợp</p>
          </div>
        )}
      </div>
    </div>
  );
};

// Browse Courses Tab Component
const BrowseCoursesTab = ({ onEnrollSuccess }) => {
  const [courses, setCourses] = useState([]);
  const [majors, setMajors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedMajor, setSelectedMajor] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [enrolling, setEnrolling] = useState(null);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    fetchData();
  }, [selectedMajor, searchTerm]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [coursesRes, majorsRes] = await Promise.all([
        courseAPI.getCourses({ major: selectedMajor, search: searchTerm }),
        courseAPI.getMajors()
      ]);
      setCourses(coursesRes.courses || []);
      setMajors(majorsRes || []);
    } catch (err) {
      console.error('Failed to fetch courses:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleEnroll = async (courseId) => {
    setEnrolling(courseId);
    setMessage(null);
    try {
      await courseAPI.enrollCourse(courseId);
      setMessage({ type: 'success', text: 'Đăng ký khóa học thành công!' });
      if (onEnrollSuccess) onEnrollSuccess();
      fetchData();
    } catch (err) {
      setMessage({ type: 'error', text: err.message || 'Không thể đăng ký khóa học' });
    } finally {
      setEnrolling(null);
    }
  };

  return (
    <div className="dashboard-content">
      <div className="browse-header">
        <div className="search-filter">
          <div className="search-box">
            <Search className="w-5 h-5" />
            <input
              type="text"
              placeholder="Tìm kiếm khóa học..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <select
            className="major-select"
            value={selectedMajor}
            onChange={(e) => setSelectedMajor(e.target.value)}
          >
            <option value="">Tất cả ngành</option>
            {majors.map((major) => (
              <option key={major.code} value={major.code}>
                {major.name} ({major.course_count})
              </option>
            ))}
          </select>
        </div>
      </div>

      {message && (
        <div className={`message-banner ${message.type}`}>
          {message.type === 'success' ? <CheckCircle className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
          <span>{message.text}</span>
        </div>
      )}

      {loading ? (
        <div className="loading-tab">
          <Loader2 className="w-8 h-8 animate-spin" />
          <p>Đang tải khóa học...</p>
        </div>
      ) : (
        <div className="browse-courses-grid">
          {courses.length > 0 ? (
            courses.map((course) => (
              <div key={course.id} className="browse-course-card">
                <div className="browse-card-header">
                  <span className="course-code-badge">{course.course_code}</span>
                  <span className="course-major">{course.major}</span>
                </div>
                <h3 className="browse-card-title">{course.course_name}</h3>
                <p className="browse-card-desc">{course.description}</p>
                <div className="browse-card-meta">
                  <span>{course.credit_hours} tín chỉ</span>
                  <span>{course.level}</span>
                  <span>{course.enrolled_count} học viên</span>
                </div>
                <button
                  className="btn-enroll-course"
                  onClick={() => handleEnroll(course.id)}
                  disabled={enrolling === course.id}
                >
                  {enrolling === course.id ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Đang đăng ký...
                    </>
                  ) : (
                    <>
                      <PlusCircle className="w-4 h-4" />
                      Đăng ký
                    </>
                  )}
                </button>
              </div>
            ))
          ) : (
            <div className="empty-state-large">
              <BookOpen className="w-16 h-16 text-gray-300" />
              <h3>Không tìm thấy khóa học</h3>
              <p>Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default StudentDashboard;
