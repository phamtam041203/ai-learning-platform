import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Award, TrendingUp, BookOpen, Target } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { courseAPI } from '../../services/api';
import { buildGradesSnapshotFromEnrollments } from '../../utils/studentDataTransforms';
import './StudentDashboard.css';

const GradesPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [grades, setGrades] = useState([]);
  const [gradesSummary, setGradesSummary] = useState(null);
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
    fetchGrades();
    
    // Refresh data when user comes back to this tab
    const handleFocus = () => {
      fetchGrades();
    };
    
    window.addEventListener('focus', handleFocus);
    
    return () => {
      window.removeEventListener('focus', handleFocus);
    };
  }, []);

  const fetchGrades = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await courseAPI.getMyCourses();
      const snapshot = buildGradesSnapshotFromEnrollments(response || []);

      setGrades(snapshot.grades.map((grade) => ({
        id: grade.id,
        course: grade.course_name,
        quizzes: grade.scores.assignment ?? 0,
        assignments: grade.scores.assignment ?? 0,
        midterm: grade.scores.midterm ?? 0,
        final: grade.scores.final ?? 0,
        average: grade.scores.total ?? 0,
        progress: grade.progress || 0
      })));
      setGradesSummary(snapshot.summary);
    } catch (err) {
      console.error('Error fetching grades:', err);
      setError('Không thể tải điểm số. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  const getGradeColor = (grade) => {
    if (grade >= 9) return '#10b981';
    if (grade >= 8) return '#3b82f6';
    if (grade >= 7) return '#f59e0b';
    return '#ef4444';
  };

  return (
    <div className="student-page-shell">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="student-page-main">
        {/* Header */}
        <div className="student-page-header">
          <div className="student-page-header-inner">
            <div className="student-page-title-row">
              <Award size={32} style={{ color: 'var(--primary)' }} />
              <h1 style={{
                fontSize: '2rem',
                fontWeight: 'bold',
                color: 'var(--text-primary)',
                margin: 0
              }}>
                Điểm Số
              </h1>
            </div>
            <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
              Xem điểm số chi tiết từ các khóa học của bạn
            </p>
          </div>
        </div>

        {/* Content */}
        <div className="student-page-body">
          {loading ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: 'var(--text-secondary)' }}>Đang tải điểm số...</p>
            </div>
          ) : (
            <div style={{
              display: 'grid',
              gap: '2rem'
            }}>
              {grades.map((grade) => (
                <div
                  key={grade.id}
                  style={{
                    background: 'var(--bg-secondary)',
                    borderRadius: '12px',
                    padding: '2rem',
                    border: '1px solid var(--border-color)',
                    boxShadow: 'var(--shadow-sm)'
                  }}
                >
                  {/* Course Name and Average */}
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '2rem',
                    paddingBottom: '1rem',
                    borderBottom: '1px solid var(--border-color)'
                  }}>
                    <h3 style={{
                      fontSize: '1.25rem',
                      fontWeight: 'bold',
                      color: 'var(--text-primary)',
                      margin: 0
                    }}>
                      {grade.course}
                    </h3>
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '1rem'
                    }}>
                      <div style={{
                        width: '80px',
                        height: '80px',
                        borderRadius: '50%',
                        background: `${getGradeColor(grade.average)}20`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flexDirection: 'column'
                      }}>
                        <span style={{
                          fontSize: '1.8rem',
                          fontWeight: 'bold',
                          color: getGradeColor(grade.average)
                        }}>
                          {grade.average}
                        </span>
                        <span style={{
                          fontSize: '0.75rem',
                          color: 'var(--text-secondary)'
                        }}>
                          TB
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Grades Grid */}
                  <div style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                    gap: '1rem'
                  }}>
                    {[
                      { label: 'Bài kiểm tra', value: grade.quizzes },
                      { label: 'Bài tập', value: grade.assignments },
                      { label: 'Thi giữa kỳ', value: grade.midterm },
                      { label: 'Thi cuối kỳ', value: grade.final }
                    ].map((item, idx) => (
                      <div
                        key={idx}
                        style={{
                          padding: '1rem',
                          background: 'var(--bg-primary)',
                          borderRadius: '8px',
                          border: '1px solid var(--border-color)',
                          textAlign: 'center'
                        }}
                      >
                        <p style={{
                          fontSize: '0.85rem',
                          color: 'var(--text-secondary)',
                          margin: '0 0 0.5rem 0'
                        }}>
                          {item.label}
                        </p>
                        <p style={{
                          fontSize: '1.5rem',
                          fontWeight: 'bold',
                          color: getGradeColor(item.value),
                          margin: 0
                        }}>
                          {item.value}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Summary Stats */}
          <div style={{
            marginTop: '3rem',
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
            gap: '2rem'
          }}>
            <div style={{
              padding: '2rem',
              background: 'linear-gradient(135deg, #10b98120, #10b98120)',
              borderRadius: '12px',
              border: '1px solid var(--border-color)',
              textAlign: 'center'
            }}>
              <TrendingUp size={32} style={{ color: '#10b981', marginBottom: '1rem' }} />
              <h4 style={{ color: 'var(--text-primary)', margin: 0, marginBottom: '0.5rem' }}>
                Điểm TB cao nhất
              </h4>
              <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{gradesSummary?.highest_score || 0}/10</p>
            </div>

            <div style={{
              padding: '2rem',
              background: 'linear-gradient(135deg, #3b82f620, #3b82f620)',
              borderRadius: '12px',
              border: '1px solid var(--border-color)',
              textAlign: 'center'
            }}>
              <Target size={32} style={{ color: '#3b82f6', marginBottom: '1rem' }} />
              <h4 style={{ color: 'var(--text-primary)', margin: 0, marginBottom: '0.5rem' }}>
                Điểm TB tổng
              </h4>
              <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{gradesSummary?.average_10 || '0.00'}/10</p>
            </div>

            <div style={{
              padding: '2rem',
              background: 'linear-gradient(135deg, #8b5cf620, #8b5cf620)',
              borderRadius: '12px',
              border: '1px solid var(--border-color)',
              textAlign: 'center'
            }}>
              <BookOpen size={32} style={{ color: '#8b5cf6', marginBottom: '1rem' }} />
              <h4 style={{ color: 'var(--text-primary)', margin: 0, marginBottom: '0.5rem' }}>
                Khóa học hoàn thành
              </h4>
              <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{gradesSummary?.completed_courses || 0}/{gradesSummary?.total_courses || 0} khóa học</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default GradesPage;
