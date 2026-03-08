import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  BarChart3, BookOpen, Award, TrendingUp, 
  Clock, CheckCircle, Target, Activity 
} from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { studentAPI, courseAPI } from '../../services/api';
import './StudentDashboard.css';

const DashboardPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [dashboardData, setDashboardData] = useState(null);
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

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
    fetchDashboardData();
    
    // Refresh data when user comes back to this tab
    const handleFocus = () => {
      fetchDashboardData();
    };
    
    window.addEventListener('focus', handleFocus);
    
    return () => {
      window.removeEventListener('focus', handleFocus);
    };
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Fetch dashboard stats and courses
      const [statsResponse, coursesResponse] = await Promise.all([
        studentAPI.getDashboard(),
        courseAPI.getMyCourses()
      ]);
      
      setDashboardData(statsResponse);
      
      // Transform enrollment data to course format
      const transformedCourses = (coursesResponse || []).map(enrollment => {
        console.log('Dashboard - Enrollment:', enrollment);
        const course = {
          id: enrollment.course?.id,
          title: enrollment.course?.course_name || 'Unknown Course',
          course_code: enrollment.course?.course_code,
          progress: enrollment.progress || 0,
          completed_lessons: enrollment.completed_lessons || 0,
          total_lessons: enrollment.total_lessons || 9,
          total_score: enrollment.grades?.total || 0,
          enrollment_id: enrollment.enrollment_id
        };
        console.log('Dashboard - Transformed course:', course);
        return course;
      });
      
      setCourses(transformedCourses);
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError('Không thể tải dữ liệu. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  const getProgressColor = (percentage) => {
    if (percentage === 100) return '#10b981';
    if (percentage >= 75) return '#3b82f6';
    if (percentage >= 50) return '#f59e0b';
    return '#ef4444';
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: 'var(--bg-primary)' }}>
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div style={{ flex: 1, marginLeft: '280px', width: 'calc(100% - 280px)' }}>
        {/* Header */}
        <div style={{
          background: 'var(--bg-secondary)',
          padding: '2rem',
          borderBottom: '1px solid var(--border-color)'
        }}>
          <div style={{ maxWidth: '1400px', margin: '0 auto' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
              <BarChart3 size={32} style={{ color: 'var(--primary)' }} />
              <h1 style={{
                fontSize: '2rem',
                fontWeight: 'bold',
                color: 'var(--text-primary)',
                margin: 0
              }}>
                Tổng Quan
              </h1>
            </div>
            <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
              Xem tổng quan về quá trình học tập của bạn
            </p>
          </div>
        </div>

        {/* Content */}
        <div style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto' }}>
          {loading ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: 'var(--text-secondary)' }}>Đang tải dữ liệu...</p>
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: '#ef4444' }}>{error}</p>
              <button
                onClick={fetchDashboardData}
                style={{
                  marginTop: '1rem',
                  padding: '0.75rem 1.5rem',
                  background: 'var(--primary)',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  cursor: 'pointer'
                }}
              >
                Thử lại
              </button>
            </div>
          ) : (
            <>
              {/* Stats Cards */}
              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
                gap: '1.5rem',
                marginBottom: '2rem'
              }}>
                {/* Total Courses */}
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '12px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)',
                  boxShadow: 'var(--shadow-sm)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div style={{
                      width: '48px',
                      height: '48px',
                      borderRadius: '12px',
                      background: 'rgba(59, 130, 246, 0.1)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <BookOpen size={24} style={{ color: '#3b82f6' }} />
                    </div>
                    <div>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', margin: 0 }}>
                        Tổng Khóa Học
                      </p>
                      <h3 style={{ 
                        fontSize: '1.75rem', 
                        fontWeight: 'bold', 
                        color: 'var(--text-primary)', 
                        margin: 0 
                      }}>
                        {courses.length}
                      </h3>
                    </div>
                  </div>
                </div>

                {/* Average Progress */}
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '12px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)',
                  boxShadow: 'var(--shadow-sm)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div style={{
                      width: '48px',
                      height: '48px',
                      borderRadius: '12px',
                      background: 'rgba(16, 185, 129, 0.1)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <TrendingUp size={24} style={{ color: '#10b981' }} />
                    </div>
                    <div>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', margin: 0 }}>
                        Tiến Độ Trung Bình
                      </p>
                      <h3 style={{ 
                        fontSize: '1.75rem', 
                        fontWeight: 'bold', 
                        color: 'var(--text-primary)', 
                        margin: 0 
                      }}>
                        {courses.length > 0 
                          ? Math.round(courses.reduce((sum, c) => sum + (c.progress || 0), 0) / courses.length)
                          : 0}%
                      </h3>
                    </div>
                  </div>
                </div>

                {/* Completed Lessons */}
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '12px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)',
                  boxShadow: 'var(--shadow-sm)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div style={{
                      width: '48px',
                      height: '48px',
                      borderRadius: '12px',
                      background: 'rgba(245, 158, 11, 0.1)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <CheckCircle size={24} style={{ color: '#f59e0b' }} />
                    </div>
                    <div>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', margin: 0 }}>
                        Bài Học Hoàn Thành
                      </p>
                      <h3 style={{ 
                        fontSize: '1.75rem', 
                        fontWeight: 'bold', 
                        color: 'var(--text-primary)', 
                        margin: 0 
                      }}>
                        {courses.reduce((sum, c) => sum + (c.completed_lessons || 0), 0)}
                      </h3>
                    </div>
                  </div>
                </div>

                {/* Average Grade */}
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '12px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)',
                  boxShadow: 'var(--shadow-sm)'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div style={{
                      width: '48px',
                      height: '48px',
                      borderRadius: '12px',
                      background: 'rgba(168, 85, 247, 0.1)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <Award size={24} style={{ color: '#a855f7' }} />
                    </div>
                    <div>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', margin: 0 }}>
                        Điểm Trung Bình
                      </p>
                      <h3 style={{ 
                        fontSize: '1.75rem', 
                        fontWeight: 'bold', 
                        color: 'var(--text-primary)', 
                        margin: 0 
                      }}>
                        {courses.length > 0
                          ? (courses.reduce((sum, c) => sum + (c.total_score || 0), 0) / courses.length).toFixed(1)
                          : 0}
                      </h3>
                    </div>
                  </div>
                </div>
              </div>

              {/* Recent Courses */}
              <div>
                <div style={{ 
                  display: 'flex', 
                  justifyContent: 'space-between', 
                  alignItems: 'center',
                  marginBottom: '1.5rem'
                }}>
                  <h2 style={{
                    fontSize: '1.5rem',
                    fontWeight: 'bold',
                    color: 'var(--text-primary)',
                    margin: 0
                  }}>
                    Khóa Học Đang Học
                  </h2>
                  <button
                    onClick={() => navigate('/student/courses')}
                    style={{
                      padding: '0.5rem 1rem',
                      background: 'transparent',
                      color: 'var(--primary)',
                      border: '1px solid var(--primary)',
                      borderRadius: '8px',
                      cursor: 'pointer',
                      fontSize: '0.875rem',
                      fontWeight: '500'
                    }}
                  >
                    Xem Tất Cả
                  </button>
                </div>

                {courses.length === 0 ? (
                  <div style={{
                    background: 'var(--bg-secondary)',
                    borderRadius: '12px',
                    padding: '3rem',
                    textAlign: 'center',
                    border: '1px solid var(--border-color)'
                  }}>
                    <BookOpen size={48} style={{ color: 'var(--text-secondary)', margin: '0 auto 1rem' }} />
                    <p style={{ color: 'var(--text-secondary)' }}>
                      Bạn chưa đăng ký khóa học nào
                    </p>
                    <button
                      onClick={() => navigate('/student/browse-courses')}
                      style={{
                        marginTop: '1rem',
                        padding: '0.75rem 1.5rem',
                        background: 'var(--primary)',
                        color: 'white',
                        border: 'none',
                        borderRadius: '8px',
                        cursor: 'pointer',
                        fontWeight: '500'
                      }}
                    >
                      Duyệt Khóa Học
                    </button>
                  </div>
                ) : (
                  <div style={{
                    display: 'grid',
                    gap: '1.5rem'
                  }}>
                    {courses.slice(0, 3).map((course) => (
                      <div
                        key={course.id}
                        style={{
                          background: 'var(--bg-secondary)',
                          borderRadius: '12px',
                          padding: '1.5rem',
                          border: '1px solid var(--border-color)',
                          boxShadow: 'var(--shadow-sm)',
                          cursor: 'pointer',
                          transition: 'all 0.3s ease'
                        }}
                        onClick={() => navigate(`/student/course/${course.id}`)}
                        onMouseEnter={(e) => {
                          e.currentTarget.style.transform = 'translateY(-2px)';
                          e.currentTarget.style.boxShadow = 'var(--shadow-md)';
                        }}
                        onMouseLeave={(e) => {
                          e.currentTarget.style.transform = 'translateY(0)';
                          e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
                        }}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                          <h3 style={{
                            fontSize: '1.125rem',
                            fontWeight: 'bold',
                            color: 'var(--text-primary)',
                            margin: 0
                          }}>
                            {course.title}
                          </h3>
                          <span style={{
                            padding: '0.25rem 0.75rem',
                            borderRadius: '999px',
                            fontSize: '0.75rem',
                            fontWeight: '600',
                            background: `${getProgressColor(course.progress || 0)}20`,
                            color: getProgressColor(course.progress || 0)
                          }}>
                            {course.progress || 0}%
                          </span>
                        </div>

                        {/* Progress Bar */}
                        <div style={{
                          width: '100%',
                          height: '8px',
                          background: 'var(--border-color)',
                          borderRadius: '999px',
                          overflow: 'hidden'
                        }}>
                          <div style={{
                            width: `${course.progress || 0}%`,
                            height: '100%',
                            background: getProgressColor(course.progress || 0),
                            transition: 'width 0.3s ease'
                          }} />
                        </div>

                        {/* Stats */}
                        <div style={{
                          display: 'flex',
                          gap: '2rem',
                          marginTop: '1rem',
                          fontSize: '0.875rem',
                          color: 'var(--text-secondary)'
                        }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            <CheckCircle size={16} />
                            <span>{course.completed_lessons || 0}/{course.total_lessons || 9} bài</span>
                          </div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            <Award size={16} />
                            <span>Điểm: {course.total_score?.toFixed(1) || 0}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
