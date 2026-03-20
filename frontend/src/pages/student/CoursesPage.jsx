import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Search, Filter, Grid, List, BookOpen, Clock,
  Users, Star, Play, CheckCircle, Award, TrendingUp,
  Home, GraduationCap, ChevronDown, X, Loader2, Lock, ChevronRight
} from 'lucide-react';
import { authAPI } from '../../services/api';
import StudentSidebar from '../../components/StudentSidebar';
import { buildApiUrl } from '../../config/api';
import './CoursesPage.css';

// Phase configurations with icons and colors
const PHASE_CONFIG = {
  1: { icon: '📚', name: 'Giai đoạn 1: Cơ sở ngành', color: '#3b82f6' },
  2: { icon: '📖', name: 'Giai đoạn 2: Môn bắt buộc', color: '#8b5cf6' },
  3: { icon: '🎯', name: 'Giai đoạn 3: Môn tự chọn', color: '#10b981' },
  4: { icon: '💻', name: 'Giai đoạn 4: Chuyên ngành CNPM', color: '#f59e0b' },
  5: { icon: '🎓', name: 'Giai đoạn 5: Tốt nghiệp', color: '#ef4444' },
  other: { icon: '📋', name: 'Khóa học khác', color: '#6b7280' }
};

const CoursesPage = () => {
  const navigate = useNavigate();
  const [viewMode, setViewMode] = useState('grid');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    const storedDarkMode = localStorage.getItem('darkMode') === 'true';
    setDarkMode(storedDarkMode);
    if (storedDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  const toggleDarkMode = () => {
    const newDarkMode = !darkMode;
    setDarkMode(newDarkMode);
    localStorage.setItem('darkMode', newDarkMode);
    if (newDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  };

  useEffect(() => {
    const storedUser = JSON.parse(localStorage.getItem('currentUser'));
    
    // Only fetch if user has changed
    if (!currentUser || currentUser.id !== storedUser?.id) {
      setCurrentUser(storedUser);
      fetchCoursesData();
    }
  }, [currentUser?.id]);

  const fetchCoursesData = async () => {
    try {
      setLoading(true);
      setError(null);

      console.log('🔍 [CoursesPage] Starting fetch...');
      const token = localStorage.getItem('token');
      console.log('🔑 [CoursesPage] Token from localStorage:', token ? `${token.substring(0, 30)}...` : 'NULL');

      const response = await authAPI.getCurrentUser();
      const userData = { ...response.user, ...response.profile };
      setUserProfile(userData);
      console.log('👤 [CoursesPage] User profile loaded:', userData.email);

      console.log('📡 [CoursesPage] Fetching specialization courses...');
      const coursesResponse = await fetch(buildApiUrl('/student/specialization-courses'), {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('📡 [CoursesPage] Response status:', coursesResponse.status);

      if (!coursesResponse.ok) {
        const errorData = await coursesResponse.json().catch(() => ({}));
        console.error('❌ [CoursesPage] Error response:', errorData);
        throw new Error(errorData.detail || 'Failed to fetch courses');
      }

      const coursesData = await coursesResponse.json();
      console.log('✅ [CoursesPage] Courses loaded:', coursesData.length);
      console.log('📋 [CoursesPage] All courses:', coursesData);
      
      // Chỉ hiển thị khóa học ĐÃ đăng ký
      const enrolledCourses = coursesData.filter(c => c.is_enrolled);
      console.log('📚 [CoursesPage] Enrolled courses:', enrolledCourses.length, enrolledCourses);
      
      // Add default progress if not present
      const coursesWithProgress = enrolledCourses.map(c => ({
        ...c,
        progress: c.progress || 0
      }));
      
      setCourses(coursesWithProgress);

    } catch (err) {
      console.error('Error fetching courses:', err);
      setError(err.message || 'Không thể tải danh sách khóa học');
    } finally {
      setLoading(false);
    }
  };

  const getLevelBadge = (level) => {
    const badges = {
      beginner: { text: 'Cơ bản', class: 'level-beginner' },
      intermediate: { text: 'Trung cấp', class: 'level-intermediate' },
      advanced: { text: 'Nâng cao', class: 'level-advanced' }
    };
    return badges[level] || badges.beginner;
  };

  const getSpecializationName = (spec) => {
    const names = {
      'CNPM': 'Công nghệ phần mềm',
      'CNDL': 'Công nghệ dữ liệu',
      'ANM': 'An ninh mạng'
    };
    return names[spec] || spec;
  };

  if (loading) {
    return (
      <div className="courses-page">
        <div className="loading-container">
          <div className="loading-spinner-wrapper">
            <div className="loading-spinner-circle"></div>
          </div>
          <p>Đang tải danh sách khóa học...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="courses-page">
        <div className="error-container">
          <X className="error-icon" size={48} />
          <h2>Không thể tải khóa học</h2>
          <p>{error}</p>
          <button onClick={fetchCoursesData} className="btn-retry">
            <RefreshCw size={18} />
            Thử lại
          </button>
        </div>
      </div>
    );
  }

  const filteredCourses = courses.filter(course => {
    const matchesSearch = course.course_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         course.course_code?.toLowerCase().includes(searchQuery.toLowerCase());
    
    if (selectedFilter === 'all') return matchesSearch;
    if (selectedFilter === 'in-progress') return matchesSearch && course.progress > 0 && course.progress < 100;
    if (selectedFilter === 'completed') return matchesSearch && course.progress === 100;
    if (selectedFilter === 'not-started') return matchesSearch && (!course.progress || course.progress === 0);
    if (selectedFilter === 'beginner') return matchesSearch && course.level === 'beginner';
    if (selectedFilter === 'intermediate') return matchesSearch && course.level === 'intermediate';
    if (selectedFilter === 'advanced') return matchesSearch && course.level === 'advanced';
    
    return matchesSearch;
  });

  // Group courses by phase (1-5), courses without valid phase go to "other"
  const coursesByPhase = filteredCourses.reduce((acc, course) => {
    const phaseId = course.phase_id;
    // Valid phases are 1-5, anything else goes to "other"
    const groupKey = (phaseId >= 1 && phaseId <= 5) ? phaseId : 'other';
    if (!acc[groupKey]) {
      acc[groupKey] = [];
    }
    acc[groupKey].push(course);
    return acc;
  }, {});

  // Sort phases: 1, 2, 3, 4, 5, then 'other' at the end
  const sortedPhaseIds = Object.keys(coursesByPhase)
    .sort((a, b) => {
      if (a === 'other') return 1;
      if (b === 'other') return -1;
      return Number(a) - Number(b);
    });

  const stats = [
    {
      label: 'Tổng khóa học',
      value: courses.length,
      icon: <BookOpen className="w-5 h-5" />,
      color: 'blue'
    },
    {
      label: 'Đang học',
      value: courses.filter(c => (c.progress || 0) > 0 && (c.progress || 0) < 100).length,
      icon: <Play className="w-5 h-5" />,
      color: 'purple'
    },
    {
      label: 'Hoàn thành',
      value: courses.filter(c => (c.progress || 0) === 100).length,
      icon: <CheckCircle className="w-5 h-5" />,
      color: 'green'
    },
    {
      label: 'Tiến độ TB',
      value: courses.length > 0 ? Math.round(courses.reduce((acc, c) => acc + (c.progress || 0), 0) / courses.length) + '%' : '0%',
      icon: <TrendingUp className="w-5 h-5" />,
      color: 'orange'
    }
  ];

  return (
    <div className="student-page-shell courses-page">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="student-page-main courses-main-wrapper">
        {/* Header */}
        <div className="courses-header">
          <div className="header-content">
            <div className="header-left">
              <h1 className="page-title">
                <BookOpen size={32} />
                Khóa học của tôi
              </h1>
              {userProfile?.specialization && (
                <p className="specialization-badge">
                  <GraduationCap size={18} />
                  Chuyên ngành: {getSpecializationName(userProfile.specialization)}
                </p>
              )}
            </div>
            <div className="header-actions">
              <button 
                onClick={() => navigate('/student/browse-courses')}
                className="btn-primary"
              >
                <BookOpen size={18} />
                Duyệt khóa học
              </button>
              <button 
                onClick={() => navigate('/student/dashboard')}
                className="btn-outline"
              >
                <Home size={18} />
                Dashboard
              </button>
            </div>
          </div>
        </div>

      {/* Stats Bar */}
      <div className="stats-bar">
        {stats.map((stat, index) => (
          <div key={index} className="stat-item">
            <div className={`stat-icon stat-${stat.color}`}>
              {stat.icon}
            </div>
            <div className="stat-content">
              <span className="stat-value">{stat.value}</span>
              <span className="stat-label">{stat.label}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Toolbar */}
      <div className="courses-toolbar">
        <div className="search-box">
          <Search size={20} />
          <input
            type="text"
            placeholder="Tìm kiếm khóa học theo tên hoặc mã..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery('')} className="clear-search">
              <X size={16} />
            </button>
          )}
        </div>

        <div className="toolbar-right">
          <div className="filter-dropdown">
            <Filter size={18} />
            <select 
              value={selectedFilter} 
              onChange={(e) => setSelectedFilter(e.target.value)}
            >
              <option value="all">Tất cả</option>
              <option value="in-progress">Đang học</option>
              <option value="completed">Hoàn thành</option>
              <option value="not-started">Chưa bắt đầu</option>
              <option value="beginner">Cơ bản</option>
              <option value="intermediate">Trung cấp</option>
              <option value="advanced">Nâng cao</option>
            </select>
            <ChevronDown size={16} />
          </div>

          <div className="view-mode">
            <button
              className={`view-btn ${viewMode === 'grid' ? 'active' : ''}`}
              onClick={() => setViewMode('grid')}
              title="Xem dạng lưới"
            >
              <Grid size={18} />
            </button>
            <button
              className={`view-btn ${viewMode === 'list' ? 'active' : ''}`}
              onClick={() => setViewMode('list')}
              title="Xem dạng danh sách"
            >
              <List size={18} />
            </button>
          </div>
        </div>
      </div>

      {/* Results Info */}
      <div className="results-info">
        <p>
          Hiển thị <strong>{filteredCourses.length}</strong> khóa học trong <strong>{sortedPhaseIds.length}</strong> giai đoạn
          {searchQuery && ` cho "${searchQuery}"`}
        </p>
      </div>

      {/* Courses Content - Grouped by Phase */}
      {filteredCourses.length === 0 ? (
        <div className="empty-state">
          <BookOpen size={64} />
          <h3>Chưa có khóa học nào</h3>
          <p>Bạn chưa đăng ký khóa học nào. Hãy duyệt và đăng ký khóa học mới!</p>
          <button onClick={() => navigate('/student/browse-courses')} className="btn-primary">
            <BookOpen size={18} />
            Duyệt khóa học
          </button>
        </div>
      ) : (
        <div className="phases-container">
          {sortedPhaseIds.map((phaseId) => {
            const phaseConfig = PHASE_CONFIG[phaseId] || { 
              icon: '📋', 
              name: `Giai đoạn ${phaseId}`, 
              color: '#6b7280' 
            };
            const phaseCourses = coursesByPhase[phaseId];
            // Only count enrolled courses for progress calculation
            const enrolledCourses = phaseCourses.filter(c => c.is_enrolled);
            const completedCount = enrolledCourses.filter(c => (c.progress || 0) === 100).length;
            const phaseProgress = enrolledCourses.length > 0 
              ? Math.round(enrolledCourses.reduce((acc, c) => acc + (c.progress || 0), 0) / enrolledCourses.length)
              : 0;

            return (
              <div key={phaseId} className="phase-section">
                <div className="phase-header" style={{ borderLeftColor: phaseConfig.color }}>
                  <div className="phase-title-group">
                    <span className="phase-icon">{phaseConfig.icon}</span>
                    <div className="phase-info">
                      <h2 className="phase-title">{phaseConfig.name}</h2>
                      <p className="phase-stats">
                        {completedCount}/{enrolledCourses.length} môn hoàn thành • Tiến độ: {phaseProgress}%
                      </p>
                    </div>
                  </div>
                  <div className="phase-progress-ring">
                    <svg width="50" height="50" viewBox="0 0 50 50">
                      <circle cx="25" cy="25" r="20" fill="none" stroke="#e5e7eb" strokeWidth="4"/>
                      <circle 
                        cx="25" cy="25" r="20" 
                        fill="none" 
                        stroke={phaseConfig.color} 
                        strokeWidth="4"
                        strokeDasharray={`${2 * Math.PI * 20 * phaseProgress / 100} ${2 * Math.PI * 20}`}
                        strokeLinecap="round"
                        transform="rotate(-90 25 25)"
                      />
                    </svg>
                    <span className="progress-text">{phaseProgress}%</span>
                  </div>
                </div>

                <div className={`courses-container ${viewMode}`}>
                  {phaseCourses.map((course) => {
                    const levelBadge = getLevelBadge(course.level);
                    
                    return (
                      <div key={course.id} className={`course-card ${course.is_locked ? 'locked' : ''}`}>
                        {course.is_locked && (
                          <div className="course-locked-overlay">
                            <Lock size={24} />
                            <span>Khóa</span>
                          </div>
                        )}
                        <div className="course-header">
                          <div className="course-emoji">
                            {course.progress === 100 ? '✅' : phaseConfig.icon}
                          </div>
                          <div className="course-badges">
                            <span className={`badge ${levelBadge.class}`}>
                              {levelBadge.text}
                            </span>
                            {course.progress === 100 && (
                              <span className="badge badge-completed">
                                <CheckCircle size={12} />
                                Hoàn thành
                              </span>
                            )}
                          </div>
                        </div>

                        <div className="course-body">
                          <div className="course-code">{course.course_code}</div>
                          <h3 className="course-title">{course.course_name}</h3>
                          <p className="course-description">
                            {course.description || 'Khóa học chuyên sâu với nội dung cập nhật'}
                          </p>

                          <div className="course-meta">
                            <div className="meta-item">
                              <Clock size={16} />
                              <span>{course.duration_weeks || 8} tuần</span>
                            </div>
                            <div className="meta-item">
                              <BookOpen size={16} />
                              <span>{course.credit_hours || 3} tín chỉ</span>
                            </div>
                            <div className="meta-item">
                              <Users size={16} />
                              <span>{course.enrolled_count || 0} học viên</span>
                            </div>
                          </div>

                          {course.is_enrolled && (
                            <div className="course-progress">
                              <div className="progress-header">
                                <span className="progress-label">Tiến độ</span>
                                <span className="progress-value">{course.progress || 0}%</span>
                              </div>
                              <div className="progress-bar">
                                <div 
                                  className="progress-fill" 
                                  style={{ 
                                    width: `${course.progress || 0}%`,
                                    backgroundColor: phaseConfig.color
                                  }}
                                />
                              </div>
                            </div>
                          )}
                        </div>

                        <div className="course-footer">
                          {course.is_enrolled ? (
                            <button 
                              onClick={() => navigate(`/student/courses/${course.id}/lessons`)}
                              className="btn btn-primary"
                              disabled={course.is_locked}
                            >
                              <Play size={18} />
                              {course.progress === 100 ? 'Xem lại' : 'Tiếp tục học'}
                            </button>
                          ) : (
                            <button 
                              onClick={() => navigate(`/student/course/${course.id}`)}
                              className="btn btn-outline"
                              disabled={course.is_locked}
                            >
                              <BookOpen size={18} />
                              Xem chi tiết
                            </button>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      )}
      </div>
    </div>
  );
};

export default CoursesPage;