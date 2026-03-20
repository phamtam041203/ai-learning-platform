import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Brain, BookOpen, TrendingUp, Award, ArrowRight, Sparkles, CheckCircle } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { studentAPI } from '../../services/api';
import { normalizeRecommendations } from '../../utils/studentDataTransforms';
import './StudentDashboard.css';

const RecommendationsPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [recommendations, setRecommendations] = useState([]);
  const [studentInfo, setStudentInfo] = useState(null);
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
    fetchRecommendations();

    const handleFocus = () => {
      fetchRecommendations();
    };

    window.addEventListener('focus', handleFocus);

    return () => {
      window.removeEventListener('focus', handleFocus);
    };
  }, []);

  const fetchRecommendations = async () => {
    try {
      setLoading(true);
      const response = await studentAPI.getRecommendedCourses();
      console.log('API Response:', response);
      
      // Handle different response formats
      const data = response.data || response;
      setRecommendations(normalizeRecommendations(data.recommendations || []));
      setStudentInfo(data.student_info);
      setError(null);
    } catch (err) {
      console.error('Error fetching recommendations:', err);
      setError('Không thể tải gợi ý. Vui lòng thử lại sau.');
    } finally {
      setLoading(false);
    }
  };

  const handleCourseClick = (courseId) => {
    navigate(`/student/courses/${courseId}`);
  };

  return (
    <div className="student-page-shell">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="student-page-main">
        {/* Header */}
        <div className="student-page-header">
          <div className="student-page-header-inner">
            <div className="student-page-title-row">
              <Brain size={32} style={{ color: 'var(--primary)' }} />
              <h1 style={{
                fontSize: '2rem',
                fontWeight: 'bold',
                color: 'var(--text-primary)',
                margin: 0
              }}>
                Gợi Ý AI
              </h1>
            </div>
            <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
              Khám phá các khóa học được AI đề xuất dựa trên hành vi học tập của bạn
            </p>
          </div>
        </div>

        {/* Content */}
        <div className="student-page-body">
          {/* Student Info Cards */}
          {studentInfo && (
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
              gap: '1rem',
              marginBottom: '2rem'
            }}>
              <div style={{
                background: 'var(--bg-secondary)',
                padding: '1rem',
                borderRadius: '8px',
                border: '1px solid var(--border-color)'
              }}>
                <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginBottom: '0.5rem' }}>
                  Chuyên ngành
                </div>
                <div style={{ color: 'var(--text-primary)', fontSize: '1.25rem', fontWeight: 'bold' }}>
                  {studentInfo.specialization || 'Chưa chọn'}
                </div>
              </div>
              <div style={{
                background: 'var(--bg-secondary)',
                padding: '1rem',
                borderRadius: '8px',
                border: '1px solid var(--border-color)'
              }}>
                <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginBottom: '0.5rem' }}>
                  Đã hoàn thành
                </div>
                <div style={{ color: 'var(--text-primary)', fontSize: '1.25rem', fontWeight: 'bold' }}>
                  {studentInfo.completed_courses} môn
                </div>
              </div>
              <div style={{
                background: 'var(--bg-secondary)',
                padding: '1rem',
                borderRadius: '8px',
                border: '1px solid var(--border-color)'
              }}>
                <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginBottom: '0.5rem' }}>
                  Đang học
                </div>
                <div style={{ color: 'var(--text-primary)', fontSize: '1.25rem', fontWeight: 'bold' }}>
                  {studentInfo.active_courses} môn
                </div>
              </div>
            </div>
          )}

          {loading ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <Sparkles size={48} style={{ color: 'var(--primary)', marginBottom: '1rem' }} />
              <p style={{ color: 'var(--text-secondary)' }}>AI đang phân tích và tạo gợi ý cho bạn...</p>
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: '#ef4444' }}>{error}</p>
              <button
                onClick={fetchRecommendations}
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
          ) : recommendations.length === 0 ? (
            <div style={{
              textAlign: 'center',
              padding: '3rem',
              background: 'var(--bg-secondary)',
              borderRadius: '12px',
              border: '1px solid var(--border-color)'
            }}>
              <Brain size={48} style={{ color: 'var(--text-tertiary)', marginBottom: '1rem' }} />
              <h3 style={{ color: 'var(--text-primary)', marginBottom: '0.5rem' }}>Chưa có gợi ý</h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                Hãy hoàn thành một vài khóa học để AI có thể đưa ra gợi ý phù hợp cho bạn
              </p>
            </div>
          ) : (
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
              gap: '2rem'
            }}>
              {recommendations.map((rec) => (
                <div
                  key={rec.id}
                  onClick={() => handleCourseClick(rec.id)}
                  style={{
                    background: 'var(--bg-secondary)',
                    borderRadius: '12px',
                    padding: '1.5rem',
                    border: '1px solid var(--border-color)',
                    cursor: 'pointer',
                    transition: 'all 0.3s ease',
                    boxShadow: 'var(--shadow-sm)',
                    position: 'relative',
                    overflow: 'hidden'
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.transform = 'translateY(-4px)';
                    e.currentTarget.style.boxShadow = 'var(--shadow-md)';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
                  }}
                >
                  {/* Background accent */}
                  <div style={{
                    position: 'absolute',
                    top: 0,
                    right: 0,
                    width: '100px',
                    height: '100px',
                    background: `${rec.color}20`,
                    borderRadius: '50%',
                    transform: 'translate(30%, -30%)',
                    pointerEvents: 'none'
                  }} />

                  {/* Score Badge - Top Right */}
                  <div style={{
                    position: 'absolute',
                    top: '1rem',
                    right: '1rem',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.25rem',
                    padding: '0.35rem 0.75rem',
                    background: `${rec.color}20`,
                    borderRadius: '20px',
                    zIndex: 1
                  }}>
                    <Award size={14} style={{ color: rec.color }} />
                    <span style={{
                      fontWeight: 'bold',
                      color: rec.color,
                      fontSize: '0.9rem'
                    }}>
                      {rec.score}%
                    </span>
                  </div>

                  {/* Icon */}
                  <div style={{
                    fontSize: '2.5rem',
                    marginBottom: '1rem',
                    position: 'relative',
                    zIndex: 1
                  }}>
                    {rec.icon}
                  </div>

                  {/* Title */}
                  <h3 style={{
                    fontSize: '1.25rem',
                    fontWeight: 'bold',
                    color: 'var(--text-primary)',
                    margin: '0 0 0.5rem 0',
                    position: 'relative',
                    zIndex: 1
                  }}>
                    {rec.title}
                  </h3>

                  {/* Major Badge */}
                  <div style={{
                    display: 'inline-block',
                    padding: '0.25rem 0.5rem',
                    background: 'var(--bg-tertiary)',
                    borderRadius: '4px',
                    fontSize: '0.75rem',
                    color: 'var(--text-secondary)',
                    marginBottom: '0.75rem'
                  }}>
                    {rec.major} • {rec.credit_hours} tín chỉ
                  </div>

                  {/* Description */}
                  <p style={{
                    color: 'var(--text-secondary)',
                    fontSize: '0.9rem',
                    marginBottom: '1rem',
                    position: 'relative',
                    zIndex: 1,
                    lineHeight: '1.5'
                  }}>
                    {rec.description}
                  </p>

                  {/* Reasons */}
                  {rec.reasons && rec.reasons.length > 0 && (
                    <div style={{
                      marginTop: '1rem',
                      paddingTop: '1rem',
                      borderTop: '1px solid var(--border-color)'
                    }}>
                      {rec.reasons.slice(0, 2).map((reason, idx) => (
                        <div
                          key={idx}
                          style={{
                            display: 'flex',
                            alignItems: 'start',
                            gap: '0.5rem',
                            marginBottom: '0.5rem'
                          }}
                        >
                          <CheckCircle size={14} style={{ color: rec.color, marginTop: '2px', flexShrink: 0 }} />
                          <span style={{
                            fontSize: '0.85rem',
                            color: 'var(--text-secondary)',
                            lineHeight: '1.4'
                          }}>
                            {reason}
                          </span>
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Arrow */}
                  <div style={{
                    marginTop: '1rem',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'flex-end'
                  }}>
                    <ArrowRight size={18} style={{
                      color: rec.color,
                      transition: 'all 0.3s ease'
                    }} />
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Info Box */}
          <div style={{
            marginTop: '3rem',
            padding: '2rem',
            background: 'linear-gradient(135deg, var(--primary)20, var(--primary-dark)20)',
            borderRadius: '12px',
            border: '1px solid var(--border-color)',
            display: 'flex',
            alignItems: 'center',
            gap: '1.5rem'
          }}>
            <Brain size={32} style={{ color: 'var(--primary)', minWidth: '32px' }} />
            <div>
              <h3 style={{
                color: 'var(--text-primary)',
                margin: '0 0 0.5rem 0',
                fontWeight: 'bold'
              }}>
                Cách AI tạo gợi ý
              </h3>
              <p style={{
                color: 'var(--text-secondary)',
                margin: 0,
                fontSize: '0.9rem'
              }}>
                AI của chúng tôi phân tích tiến độ học tập, điểm số và các mô hình hành vi để đề xuất khóa học phù hợp nhất cho bạn. Càng nhiều bạn học, gợi ý càng chính xác.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RecommendationsPage;
