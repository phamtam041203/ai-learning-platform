import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TrendingUp, CheckCircle, Clock } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import ProgressJourney3D from '../../components/student/ProgressJourney3D';
import { studentAPI } from '../../services/api';
import {
  clearStoredPersonalization,
  getStoredPersonalization,
} from '../../utils/personalizationStorage';
import './StudentDashboard.css';

const ProgressPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [roadmap, setRoadmap] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [intakeTemplate, setIntakeTemplate] = useState([]);
  const [personalization, setPersonalization] = useState(() => getStoredPersonalization());

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
      setPersonalization(getStoredPersonalization());
      const [roadmapResponse, intakeResponse] = await Promise.all([
        studentAPI.getCurriculumStatus(),
        studentAPI.getIntakeAssessmentTemplate().catch(() => ({ questions: [] }))
      ]);

      setRoadmap(roadmapResponse);
      setIntakeTemplate(intakeResponse?.questions || []);
    } catch (err) {
      console.error('Error fetching progress:', err);
      setError('Không thể tải tiến độ. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  const phases = roadmap?.phases || [];
  const totalMilestones = phases.reduce((sum, phase) => sum + (phase.required_total || 0) + (phase.elective_min_select || 0), 0);
  const completedMilestones = phases.reduce((sum, phase) => sum + (phase.required_completed || 0) + Math.min(phase.elective_completed || 0, phase.elective_min_select || 0), 0);
  const overallPercentage = totalMilestones > 0 ? Math.round((completedMilestones / totalMilestones) * 100) : 0;
  const completedStages = phases.filter((phase) => phase.is_completed).length;
  const personalizationAnalysis = personalization?.analysis || personalization || null;
  const intakeUnavailable = !loading && !personalizationAnalysis && intakeTemplate.length === 0;

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

  const handleResetAssessment = () => {
    clearStoredPersonalization();
    setPersonalization(null);
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
        <div style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto' }}>
          <div style={{
            marginBottom: '1.5rem',
            background: 'var(--bg-secondary)',
            border: '1px solid var(--border-color)',
            borderRadius: '24px',
            padding: '1.5rem',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'grid', gap: '0.75rem', marginBottom: '1rem' }}>
              <div style={{
                display: 'inline-flex',
                width: 'fit-content',
                padding: '0.35rem 0.75rem',
                borderRadius: '999px',
                background: 'rgba(185, 28, 28, 0.08)',
                color: '#991b1b',
                fontSize: '0.78rem',
                fontWeight: 700,
                letterSpacing: '0.06em',
                textTransform: 'uppercase'
              }}>
                AI Personalization
              </div>
              <div>
                <h2 style={{ margin: 0, color: 'var(--text-primary)' }}>Bài test đầu vào để mở khóa bản đồ 3D</h2>
                <p style={{ margin: '0.4rem 0 0', color: 'var(--text-secondary)', lineHeight: 1.6 }}>
                  Hoàn thành bài test đầu vào để Gemini phân tích nền tảng hiện tại, đề xuất độ khó phù hợp và mở trước các khu vực nên ưu tiên trên hành trình học tập.
                </p>
              </div>
            </div>

            {personalizationAnalysis ? (
              <div style={{ display: 'grid', gap: '1rem' }}>
                <div style={{
                  padding: '1rem 1.1rem',
                  borderRadius: '18px',
                  background: 'linear-gradient(135deg, rgba(185, 28, 28, 0.08), rgba(245, 158, 11, 0.12))',
                  border: '1px solid rgba(185, 28, 28, 0.14)'
                }}>
                  <p style={{ margin: 0, color: 'var(--text-primary)', lineHeight: 1.7 }}>
                    {personalizationAnalysis.ai_summary}
                  </p>
                </div>

                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                  gap: '0.9rem'
                }}>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Điểm đầu vào</div>
                    <strong style={{ fontSize: '1.8rem', color: 'var(--text-primary)' }}>{personalizationAnalysis.assessment_score}%</strong>
                  </div>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Phong cách học</div>
                    <strong style={{ fontSize: '1.1rem', color: 'var(--text-primary)', textTransform: 'capitalize' }}>{personalizationAnalysis.learning_style}</strong>
                  </div>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Độ khó khởi đầu</div>
                    <strong style={{ fontSize: '1.1rem', color: 'var(--text-primary)', textTransform: 'capitalize' }}>{personalizationAnalysis.recommended_difficulty}</strong>
                  </div>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Chặng được AI mở khóa</div>
                    <strong style={{ fontSize: '1.1rem', color: 'var(--text-primary)' }}>{(personalizationAnalysis.unlocked_phase_ids || []).join(', ')}</strong>
                  </div>
                </div>

                <div style={{ display: 'grid', gap: '0.7rem' }}>
                  <strong style={{ color: 'var(--text-primary)' }}>Hành động đề xuất</strong>
                  <div style={{ display: 'grid', gap: '0.6rem' }}>
                    {(personalizationAnalysis.next_actions || []).map((action, index) => (
                      <div
                        key={`action-${index}`}
                        style={{
                          padding: '0.85rem 1rem',
                          borderRadius: '14px',
                          background: 'var(--bg-primary)',
                          border: '1px solid var(--border-color)',
                          color: 'var(--text-primary)'
                        }}
                      >
                        {action}
                      </div>
                    ))}
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
                  <button className="btn-outline" onClick={() => navigate('/student/skill-assessment')}>
                    Xem bài test năng lực
                  </button>
                  <button className="btn-outline" onClick={handleResetAssessment}>
                    Làm lại bài test đầu vào
                  </button>
                </div>
              </div>
            ) : (
              <div style={{ display: 'grid', gap: '1rem' }}>
                {intakeUnavailable ? (
                  <div style={{
                    padding: '1rem 1.1rem',
                    borderRadius: '18px',
                    background: 'rgba(245, 158, 11, 0.12)',
                    border: '1px solid rgba(245, 158, 11, 0.24)',
                    color: 'var(--text-primary)',
                    lineHeight: 1.6
                  }}>
                    Hiện chưa tải được bộ câu hỏi bài test đầu vào từ backend. Nếu bạn vừa cập nhật code, hãy khởi động lại backend rồi mở lại trang này.
                  </div>
                ) : null}

                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                  gap: '0.9rem'
                }}>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Số câu hỏi đánh giá</div>
                    <strong style={{ fontSize: '1.8rem', color: 'var(--text-primary)' }}>{intakeTemplate.length || '--'}</strong>
                  </div>
                  <div style={{ background: 'var(--bg-primary)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>Đầu ra</div>
                    <strong style={{ fontSize: '1.1rem', color: 'var(--text-primary)' }}>Roadmap 3D + Adaptive Learning</strong>
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
                  <button className="btn-outline" onClick={() => navigate('/student/skill-assessment')}>
                    Xem trang test năng lực
                  </button>
                  <button
                    className="btn-primary"
                    disabled={intakeUnavailable}
                    onClick={() => navigate('/student/skill-assessment')}
                  >
                    Bắt đầu bài test đầu vào
                  </button>
                </div>
              </div>
            )}
          </div>

          <ProgressJourney3D
            roadmap={roadmap}
            onCourseSelect={handleOpenCourseFromMap}
            personalization={personalizationAnalysis}
          />

          {loading ? (
            <div style={{ textAlign: 'center', padding: '3rem' }}>
              <p style={{ color: 'var(--text-secondary)' }}>Đang tải tiến độ...</p>
            </div>
          ) : error ? (
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
                  <h3 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--text-primary)' }}>{roadmap?.active_phase?.name || 'Đang cập nhật'}</h3>
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
