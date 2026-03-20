import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TrendingUp, CheckCircle, Clock } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import ProgressJourney3D from '../../components/student/ProgressJourney3D';
import Loading from '../../components/common/Loading';
import { studentAPI } from '../../services/api';
import './StudentDashboard.css';

const ProgressPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [roadmap, setRoadmap] = useState(null);
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
    fetchProgress();
    
    // Refresh data when user comes back to this tab
    const handleFocus = () => {
      fetchProgress();
    };
    
    window.addEventListener('focus', handleFocus);
    
    return () => {
      window.removeEventListener('focus', handleFocus);
    };
  }, []);

  const fetchProgress = async () => {
    try {
      setLoading(true);
      setError(null);
      const roadmapResponse = await studentAPI.getCurriculumStatus();
      setRoadmap(roadmapResponse);
    } catch (err) {
      console.error('Error fetching progress:', err);
      setError('Không thể tải tiến độ. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  const phases = roadmap?.phases || [];
  const currentPhase = roadmap?.current_phase || roadmap?.active_phase || null;
  const totalMilestones = phases.reduce((sum, phase) => sum + (phase.required_total || 0) + (phase.elective_min_select || 0), 0);
  const completedMilestones = phases.reduce((sum, phase) => sum + (phase.required_completed || 0) + Math.min(phase.elective_completed || 0, phase.elective_min_select || 0), 0);
  const overallPercentage = totalMilestones > 0 ? Math.round((completedMilestones / totalMilestones) * 100) : 0;
  const completedStages = phases.filter((phase) => phase.is_completed).length;

  const getPhaseProgress = (phase) => {
    const total = (phase.required_total || 0) + (phase.elective_min_select || 0);
    const done = (phase.required_completed || 0) + Math.min(phase.elective_completed || 0, phase.elective_min_select || 0);

    return total > 0 ? Math.round((done / total) * 100) : 0;
  };

  const getNextCourses = (phase) => {
    const pendingRequired = (phase.required_courses || []).filter((course) => !course.is_completed);
    const neededElectives = Math.max(0, (phase.elective_min_select || 0) - (phase.elective_completed || 0));
    const pendingElectives = (phase.elective_courses || []).filter((course) => !course.is_completed).slice(0, neededElectives || 2);
    return [...pendingRequired, ...pendingElectives].slice(0, 3);
  };

  const handleOpenCourseFromMap = (course) => {
    if (!course?.courseId) {
      return;
    }

    navigate(`/student/courses/${course.courseId}/lessons`);
  };

  if (loading) {
    return (
      <div className="student-page-shell">
        <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

        <div className="student-page-main">
          <div className="student-page-header">
            <div className="student-page-header-inner">
              <div className="student-page-title-row">
                <TrendingUp size={32} style={{ color: 'var(--primary)' }} />
                <h1 style={{
                  fontSize: '2rem',
                  fontWeight: 'bold',
                  color: 'var(--text-primary)',
                  margin: 0
                }}>
                  Tiến Độ Học Tập
                </h1>
              </div>
              <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
                Theo dõi tiến độ hoàn thành khóa học của bạn
              </p>
            </div>
          </div>

          <div className="student-page-body">
            <Loading
              title="Dang tai tien do hoc tap"
              subtitle="Dang cap nhat roadmap va cac cot moc hoan thanh."
            />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="student-page-shell">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="student-page-main">
        {/* Header */}
        <div className="student-page-header">
          <div className="student-page-header-inner">
            <div className="student-page-title-row">
              <TrendingUp size={32} style={{ color: 'var(--primary)' }} />
              <h1 style={{
                fontSize: '2rem',
                fontWeight: 'bold',
                color: 'var(--text-primary)',
                margin: 0
              }}>
                Tiến Độ Học Tập
              </h1>
            </div>
            <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
              Theo dõi tiến độ hoàn thành khóa học của bạn
            </p>
          </div>
        </div>

        {/* Content */}
        <div className="student-page-body">
          <ProgressJourney3D
            roadmap={roadmap}
            onCourseSelect={handleOpenCourseFromMap}
            personalization={null}
          />

          {error ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: 'var(--text-secondary)' }}>{error}</p>
            </div>
          ) : (
            <div style={{
              display: 'grid',
              gap: '2rem'
            }}>
              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
                gap: '1rem'
              }}>
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '16px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)'
                }}>
                  <p style={{ margin: '0 0 0.5rem', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Tiến độ toàn chặng</p>
                  <h3 style={{ margin: 0, fontSize: '2rem', color: 'var(--text-primary)' }}>{overallPercentage}%</h3>
                </div>
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '16px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)'
                }}>
                  <p style={{ margin: '0 0 0.5rem', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Giai đoạn đã vượt qua</p>
                  <h3 style={{ margin: 0, fontSize: '2rem', color: 'var(--text-primary)' }}>{completedStages}/{phases.length || 5}</h3>
                </div>
                <div style={{
                  background: 'var(--bg-secondary)',
                  borderRadius: '16px',
                  padding: '1.5rem',
                  border: '1px solid var(--border-color)'
                }}>
                  <p style={{ margin: '0 0 0.5rem', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Giai đoạn hiện tại</p>
                  <h3 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--text-primary)' }}>{currentPhase?.name || 'Đang cập nhật'}</h3>
                </div>
              </div>

              {phases.map((phase) => (
                <div
                  key={phase.id}
                  style={{
                    background: 'var(--bg-secondary)',
                    borderRadius: '12px',
                    padding: '2rem',
                    border: '1px solid var(--border-color)',
                    boxShadow: 'var(--shadow-sm)',
                    cursor: 'pointer',
                    transition: 'all 0.3s ease'
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.transform = 'translateY(-2px)';
                    e.currentTarget.style.boxShadow = 'var(--shadow-md)';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
                  }}
                >
                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'flex-start',
                    marginBottom: '1.5rem'
                  }}>
                    <div>
                      <h3 style={{
                        fontSize: '1.25rem',
                        fontWeight: 'bold',
                        color: 'var(--text-primary)',
                        margin: 0,
                        marginBottom: '0.5rem'
                      }}>
                        {phase.name}
                      </h3>
                      <p style={{
                        fontSize: '0.9rem',
                        color: 'var(--text-secondary)',
                        margin: 0
                      }}>
                        {phase.description}
                      </p>
                    </div>
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '1rem'
                    }}>
                      <div style={{
                        textAlign: 'right'
                      }}>
                        <div style={{
                          fontSize: '2rem',
                          fontWeight: 'bold',
                          color: phase.is_completed ? '#10b981' : phase.is_active ? '#f59e0b' : '#64748b'
                        }}>
                          {getPhaseProgress(phase)}%
                        </div>
                        <p style={{
                          fontSize: '0.75rem',
                          color: 'var(--text-secondary)',
                          margin: 0
                        }}>
                          {phase.is_completed ? 'Đã xong' : phase.is_active ? 'Đang học' : 'Sẽ mở khóa'}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div style={{
                    marginBottom: '1.5rem'
                  }}>
                    <div style={{
                      width: '100%',
                      height: '12px',
                      background: 'var(--bg-primary)',
                      borderRadius: '6px',
                      overflow: 'hidden',
                      border: '1px solid var(--border-color)'
                    }}>
                      <div
                        style={{
                          width: `${getPhaseProgress(phase)}%`,
                          height: '100%',
                          background: `linear-gradient(90deg, ${phase.is_completed ? '#10b981' : phase.is_active ? '#f59e0b' : '#94a3b8'}, ${phase.is_completed ? '#34d399' : phase.is_active ? '#fbbf24' : '#cbd5e1'})`,
                          transition: 'width 0.3s ease'
                        }}
                      />
                    </div>
                  </div>

                  <div style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                    gap: '1rem'
                  }}>
                    <div style={{
                      padding: '1rem',
                      background: 'var(--bg-primary)',
                      borderRadius: '8px',
                      border: '1px solid var(--border-color)'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '0.5rem',
                        marginBottom: '0.5rem'
                      }}>
                        <Clock size={16} style={{ color: 'var(--primary)' }} />
                        <p style={{
                          fontSize: '0.85rem',
                          color: 'var(--text-secondary)',
                          margin: 0
                        }}>
                          Mốc bắt buộc
                        </p>
                      </div>
                      <p style={{
                        fontWeight: 'bold',
                        color: 'var(--text-primary)',
                        margin: 0
                      }}>
                        {phase.required_completed || 0}/{phase.required_total || 0}
                      </p>
                    </div>

                    <div style={{
                      padding: '1rem',
                      background: 'var(--bg-primary)',
                      borderRadius: '8px',
                      border: '1px solid var(--border-color)'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '0.5rem',
                        marginBottom: '0.5rem'
                      }}>
                        <CheckCircle size={16} style={{ color: phase.is_completed ? '#10b981' : '#f59e0b' }} />
                        <p style={{
                          fontSize: '0.85rem',
                          color: 'var(--text-secondary)',
                          margin: 0
                        }}>
                          Môn tự chọn
                        </p>
                      </div>
                      <p style={{
                        fontWeight: 'bold',
                        color: 'var(--text-primary)',
                        margin: 0
                      }}>
                        {Math.min(phase.elective_completed || 0, phase.elective_min_select || 0)}/{phase.elective_min_select || 0}
                      </p>
                    </div>

                    <div style={{
                      padding: '1rem',
                      background: 'var(--bg-primary)',
                      borderRadius: '8px',
                      border: '1px solid var(--border-color)'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '0.5rem',
                        marginBottom: '0.5rem'
                      }}>
                        <TrendingUp size={16} style={{ color: 'var(--primary)' }} />
                        <p style={{
                          fontSize: '0.85rem',
                          color: 'var(--text-secondary)',
                          margin: 0
                        }}>
                          Sap toi can hoc
                        </p>
                      </div>
                      <p style={{
                        fontWeight: 'bold',
                        color: 'var(--text-primary)',
                        margin: 0,
                        lineHeight: 1.5
                      }}>
                        {getNextCourses(phase).length ? getNextCourses(phase).map((course) => course.name).join(', ') : 'Không còn yêu cầu trong chặng này'}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Overall Stats */}
          {(() => {
            const estimatedMinutes = completedMilestones * 45;
            const hours = Math.floor(estimatedMinutes / 60);
            const minutes = estimatedMinutes % 60;
            const studyTimeDisplay = hours > 0
              ? `${hours}h ${minutes}m`
              : `${minutes}m`;

            return (
              <div style={{
                marginTop: '3rem',
                padding: '2rem',
                background: 'linear-gradient(135deg, var(--primary)20, var(--primary-dark)20)',
                borderRadius: '12px',
                border: '1px solid var(--border-color)',
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                gap: '2rem'
              }}>
                <div>
                  <p style={{
                    fontSize: '0.9rem',
                    color: 'var(--text-secondary)',
                    margin: 0,
                    marginBottom: '0.5rem'
                  }}>
                    Tổng tiến độ
                  </p>
                  <p style={{
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--primary)',
                    margin: 0
                  }}>
                    {overallPercentage}%
                  </p>
                </div>
                <div>
                  <p style={{
                    fontSize: '0.9rem',
                    color: 'var(--text-secondary)',
                    margin: 0,
                    marginBottom: '0.5rem'
                  }}>
                    Cột mốc hoàn thành
                  </p>
                  <p style={{
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--primary)',
                    margin: 0
                  }}>
                    {completedMilestones}/{totalMilestones}
                  </p>
                </div>
                <div>
                  <p style={{
                    fontSize: '0.9rem',
                    color: 'var(--text-secondary)',
                    margin: 0,
                    marginBottom: '0.5rem'
                  }}>
                    Thời gian học
                  </p>
                  <p style={{
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--primary)',
                    margin: 0
                  }}>
                    {studyTimeDisplay}
                  </p>
                </div>
                <div>
                  <p style={{
                    fontSize: '0.9rem',
                    color: 'var(--text-secondary)',
                    margin: 0,
                    marginBottom: '0.5rem'
                  }}>
                    Giai đoạn đã vượt
                  </p>
                  <p style={{
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--primary)',
                    margin: 0
                  }}>
                    {completedStages}/{phases.length || 5}
                  </p>
                </div>
              </div>
            );
          })()}
        </div>
      </div>
    </div>
  );
};

export default ProgressPage;
