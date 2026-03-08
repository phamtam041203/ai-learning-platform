import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Search, Filter, Grid, List, BookOpen, Clock, Users, Star,
  CheckCircle, Award, TrendingUp, Home, GraduationCap,
  ChevronDown, X, RefreshCw, BookPlus
} from 'lucide-react';
import { authAPI } from '../../services/api';
import StudentSidebar from '../../components/StudentSidebar';
import './CoursesPage.css';
import './PhaseGroups.css';

const BrowseCoursesPage = () => {
  const navigate = useNavigate();
  const [viewMode, setViewMode] = useState('grid');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [enrollingCourseId, setEnrollingCourseId] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);
  const [darkMode, setDarkMode] = useState(false);
  const [curriculum, setCurriculum] = useState(null);
  const [groupByPhase, setGroupByPhase] = useState(true);

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
      fetchCoursesData(storedUser);
    }
  }, [currentUser?.id]);

  const fetchCoursesData = async (userFromStorage = currentUser) => {
    try {
      setLoading(true);
      setError(null);

      const token = localStorage.getItem('access_token') || localStorage.getItem('token');
      const role = userFromStorage?.role;

      if (role && role !== 'student') {
        setError('Chức năng này chỉ dành cho sinh viên.');
        setLoading(false);
        return;
      }

      console.log('🔍 [BrowseCoursesPage] Fetching user profile...');
      console.log('🔑 [BrowseCoursesPage] Token:', token ? 'Found' : 'Not found');

      const response = await authAPI.getCurrentUser();
      const userData = { ...response.user, ...response.profile };
      setUserProfile(userData);
      console.log('👤 [BrowseCoursesPage] User specialization:', userData.specialization);

      // Fetch curriculum data
      console.log('📚 [BrowseCoursesPage] Fetching curriculum...');
      const curriculumResponse = await fetch('http://localhost:8000/api/curriculum/cnpm', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (curriculumResponse.ok) {
        const curriculumData = await curriculumResponse.json();
        setCurriculum(curriculumData);
        console.log('✅ [BrowseCoursesPage] Curriculum loaded:', curriculumData.program);
      }

      console.log('📡 [BrowseCoursesPage] Fetching specialization courses...');
      const coursesResponse = await fetch('http://localhost:8000/api/student/specialization-courses', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!coursesResponse.ok) {
        const errorData = await coursesResponse.json().catch(() => ({}));
        throw new Error(errorData.detail || 'Failed to fetch courses');
      }

      const coursesData = await coursesResponse.json();
      console.log('✅ [BrowseCoursesPage] Courses loaded:', coursesData.length);
      
      // Chỉ hiển thị khóa học CHƯA đăng ký
      const availableCourses = coursesData.filter(c => !c.is_enrolled);
      console.log('📚 Available courses to enroll:', availableCourses.length);
      setCourses(availableCourses);

    } catch (err) {
      console.error('Error fetching courses:', err);
      setError(err.message || 'Không thể tải danh sách khóa học');
    } finally {
      setLoading(false);
    }
  };

  const handleEnrollCourse = async (courseId) => {
    try {
      setEnrollingCourseId(courseId);
      const token = localStorage.getItem('token');

      console.log(`📝 [BrowseCoursesPage] Enrolling course ${courseId}...`);
      const response = await fetch(`http://localhost:8000/api/courses/${courseId}/enroll`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        const errorMsg = errorData.detail || 'Không thể đăng ký khóa học';
        
        // Nếu đã đăng ký rồi, chỉ cần refresh danh sách
        if (errorMsg.includes('Already enrolled') || errorMsg.includes('đã đăng ký')) {
          console.log('⚠️ Already enrolled, refreshing list...');
          await fetchCoursesData();
          return; // Không hiện alert lỗi
        }
        
        throw new Error(errorMsg);
      }

      const result = await response.json();
      console.log('✅ Enrolled successfully:', result);

      // Refresh danh sách khóa học
      await fetchCoursesData();
      
      alert('Đăng ký khóa học thành công! ✅');
      
      // Navigate to CoursesPage to show enrolled course
      setTimeout(() => {
        navigate('/student/courses');
      }, 500);

    } catch (err) {
      console.error('Error enrolling course:', err);
      alert(`Lỗi: ${err.message}`);
    } finally {
      setEnrollingCourseId(null);
    }
  };

  const filteredCourses = courses.filter(course => {
    const matchesSearch = course.course_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         course.course_code?.toLowerCase().includes(searchQuery.toLowerCase());
    
    if (selectedFilter === 'all') return matchesSearch;
    if (selectedFilter === 'beginner') return matchesSearch && course.level === 'beginner';
    if (selectedFilter === 'intermediate') return matchesSearch && course.level === 'intermediate';
    if (selectedFilter === 'advanced') return matchesSearch && course.level === 'advanced';
    
    return matchesSearch;
  });

  // Group courses by phase and type (required/elective)
  const getGroupedCourses = () => {
    if (!curriculum || !groupByPhase) {
      return { ungrouped: filteredCourses };
    }

    const grouped = {};
    
    curriculum.phases.forEach(phase => {
      const phaseRequired = [];
      const phaseElective = [];
      
      filteredCourses.forEach(course => {
        if (phase.required_courses.includes(course.course_code)) {
          phaseRequired.push(course);
        } else if (phase.elective_courses.includes(course.course_code)) {
          phaseElective.push(course);
        }
      });

      if (phaseRequired.length > 0 || phaseElective.length > 0) {
        grouped[phase.id] = {
          phase: phase,
          required: phaseRequired,
          elective: phaseElective
        };
      }
    });

    return grouped;
  };

  const groupedCourses = getGroupedCourses();

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

  const stats = [
    { label: 'Khóa học khả dụng', value: courses.length, icon: <BookOpen className="w-5 h-5" />, color: 'blue' },
    { label: 'Chưa đăng ký', value: courses.length, icon: <BookPlus className="w-5 h-5" />, color: 'orange' }
  ];

  return (
    <div className="courses-page">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="courses-main-wrapper">
        {/* Header */}
        <div className="courses-header">
          <div className="header-content">
            <div className="header-left">
              <h1 className="page-title">
                <BookOpen size={32} />
                Duyệt khóa học
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
                onClick={() => navigate('/student/courses')}
                className="btn-outline"
              >
                <CheckCircle size={18} />
                Khóa học của tôi
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

          {curriculum && (
            <button
              className={`view-btn ${groupByPhase ? 'active' : ''}`}
              onClick={() => setGroupByPhase(!groupByPhase)}
              title={groupByPhase ? "Hiển thị tất cả" : "Nhóm theo giai đoạn"}
              style={{ marginLeft: '10px', padding: '8px 16px', fontSize: '14px' }}
            >
              {groupByPhase ? '📚 Theo giai đoạn' : '📋 Tất cả'}
            </button>
          )}
        </div>
      </div>

      {/* Results Info */}
      <div className="results-info">
        <p>
          Hiển thị <strong>{filteredCourses.length}</strong> khóa học có thể đăng ký
          {searchQuery && ` cho "${searchQuery}"`}
          {groupByPhase && curriculum && ' (Nhóm theo giai đoạn và loại môn học)'}
        </p>
      </div>

      {/* Courses Grid/List */}
      {filteredCourses.length === 0 ? (
        <div className="empty-state">
          <BookOpen size={64} />
          <h3>Không tìm thấy khóa học</h3>
          <p>Tất cả khóa học của chuyên ngành này đã được đăng ký hoặc không có khóa học khả dụng</p>
          <button onClick={() => navigate('/student/courses')} className="btn-primary">
            Xem khóa học của tôi
          </button>
        </div>
      ) : groupByPhase && curriculum ? (
        // Grouped by phase view
        <div className="phases-container">
          {Object.keys(groupedCourses).map(phaseId => {
            const { phase, required, elective } = groupedCourses[phaseId];
            
            return (
              <div key={phaseId} className="phase-group">
                <div className="phase-header">
                  <h2 className="phase-title">
                    <Award size={24} />
                    {phase.name}
                  </h2>
                  <p className="phase-description">{phase.description}</p>
                </div>

                {/* Required Courses Section */}
                {required.length > 0 && (
                  <div className="course-type-section">
                    <div className="section-header required">
                      <div className="section-title">
                        <CheckCircle size={20} />
                        <h3>Môn bắt buộc ({required.length} môn)</h3>
                      </div>
                      <span className="requirement-badge required">Phải hoàn thành tất cả</span>
                    </div>
                    
                    <div className={`courses-container ${viewMode}`}>
                      {required.map((course) => renderCourseCard(course))}
                    </div>
                  </div>
                )}

                {/* Elective Courses Section */}
                {elective.length > 0 && (
                  <div className="course-type-section">
                    <div className="section-header elective">
                      <div className="section-title">
                        <Star size={20} />
                        <h3>Môn tự chọn ({elective.length} môn)</h3>
                      </div>
                      <span className="requirement-badge elective">
                        Chọn tối thiểu {phase.elective_min_select} môn
                      </span>
                    </div>
                    
                    <div className={`courses-container ${viewMode}`}>
                      {elective.map((course) => renderCourseCard(course))}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      ) : (
        // Original flat list view
        <div className={`courses-container ${viewMode}`}>
          {filteredCourses.map((course) => renderCourseCard(course))}
        </div>
      )}
      </div>
    </div>
  );

  // Helper function to render course card
  function renderCourseCard(course) {
    const levelBadge = getLevelBadge(course.level);
    const isEnrolling = enrollingCourseId === course.id;
    
    return (
      <div key={course.id} className="course-card">
                <div className="course-header">
                  <div className="course-emoji">
                    {course.specialization === 'CNPM' && '💻'}
                    {course.specialization === 'CNDL' && '📊'}
                    {course.specialization === 'ANM' && '🔒'}
                  </div>
                  <div className="course-badges">
                    <span className={`badge ${levelBadge.class}`}>
                      {levelBadge.text}
                    </span>
                    <span className="badge badge-available">
                      Có thể đăng ký
                    </span>
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
                      <span>{course.duration_weeks} tuần</span>
                    </div>
                    <div className="meta-item">
                      <BookOpen size={16} />
                      <span>{course.credit_hours} tín chỉ</span>
                    </div>
                    <div className="meta-item">
                      <Users size={16} />
                      <span>{course.enrolled_count || 0} học viên</span>
                    </div>
                  </div>
                </div>

                <div className="course-footer">
                  <button 
                    onClick={() => handleEnrollCourse(course.id)}
                    className="btn btn-primary"
                    disabled={isEnrolling}
                  >
                    {isEnrolling ? (
                      <>
                        <RefreshCw size={18} className="spinning" />
                        Đang đăng ký...
                      </>
                    ) : (
                      <>
                        <BookPlus size={18} />
                        Đăng ký khóa học
                      </>
                    )}
                  </button>
                </div>
              </div>
    );
  }
};

export default BrowseCoursesPage;
