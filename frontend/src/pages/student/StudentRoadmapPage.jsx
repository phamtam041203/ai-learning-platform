import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Route, Flag, CheckCircle2, Lock, BookOpen, Sparkles, BookMarked, Bookmark, ChevronDown } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { studentAPI } from '../../services/api';
import './StudentRoadmap.css';

const StudentRoadmapPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [roadmap, setRoadmap] = useState(null);
  const [expandedPhases, setExpandedPhases] = useState({});

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
    const fetchRoadmap = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await studentAPI.getCurriculumStatus();
        setRoadmap(data);
      } catch (err) {
        console.error('Roadmap error:', err);
        setError('Không thể tải lộ trình học. Vui lòng thử lại.');
      } finally {
        setLoading(false);
      }
    };

    fetchRoadmap();
  }, []);

  const activePhase = useMemo(() => {
    return roadmap?.phases?.find(phase => phase.is_active) || null;
  }, [roadmap]);

  const togglePhase = (phaseId) => {
    setExpandedPhases(prev => ({
      ...prev,
      [phaseId]: !prev[phaseId]
    }));
  };

  const getCourseStatus = (course) => {
    if (course.is_completed) return { label: 'Hoàn thành', tone: 'completed', icon: CheckCircle2 };
    if (course.is_enrolled) return { label: 'Đang học', tone: 'active', icon: BookOpen };
    if (course.is_locked) {
      if (course.lock_reason === 'elective_limit') {
        return { label: 'Đã khóa (đủ 2 môn)', tone: 'locked', icon: Lock };
      }
      return { label: 'Chưa mở', tone: 'locked', icon: Lock };
    }
    return { label: 'Có thể học', tone: 'available', icon: Flag };
  };

  const getPhaseProgress = (phase) => {
    const requiredDone = phase.required_completed || 0;
    const requiredTotal = phase.required_total || 0;
    const electiveDone = phase.elective_completed || 0;
    const electiveMin = phase.elective_min_select || 0;
    
    return {
      required: `${requiredDone}/${requiredTotal}`,
      elective: `${electiveDone}/${electiveMin}`
    };
  };

  const renderCourseCard = (course) => {
    const status = getCourseStatus(course);
    const StatusIcon = status.icon;

    return (
      <div className={`course-item ${status.tone}`} key={course.code}>
        <div className="course-main">
          <div className="course-info">
            <h4 className="course-name">{course.name}</h4>
            <div className="course-details">
              <span className="course-code">{course.code}</span>
              <span className="course-credits">{course.credit_hours} tín chỉ</span>
              {course.type === 'elective' && <span className="elective-tag">Tự chọn</span>}
            </div>
          </div>
          <span className={`course-badge ${status.tone}`}>
            <StatusIcon size={14} />
            {status.label}
          </span>
        </div>

        <div className="course-progress">
          <div className="progress-bar">
            <span style={{ width: `${course.progress || 0}%` }} />
          </div>
          <span className="progress-text">{course.progress || 0}%</span>
        </div>
      </div>
    );
  };

  return (
    <div className="roadmap-layout">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="roadmap-content">
        <div className="roadmap-header">
          <div className="roadmap-title">
            <Route className="title-icon" />
            <div>
              <h1>Lộ trình học</h1>
              <p>Theo dõi tiến trình và điều kiện mở khóa các giai đoạn</p>
            </div>
          </div>
        </div>

        <div className="roadmap-body">
          {loading ? (
            <div className="roadmap-empty">Đang tải dữ liệu...</div>
          ) : error ? (
            <div className="roadmap-empty error">{error}</div>
          ) : (
            <>
              <div className="roadmap-intake-callout">
                <div>
                  <span className="roadmap-intake-kicker">AI Personalization</span>
                  <h3>Bài test năng lực đã có trang riêng</h3>
                  <p>
                    Vào mục Test Năng Lực để làm bài đánh giá đầu vào, sau đó Gemini sẽ phân tích năng lực hiện tại và mở khóa các khu vực phù hợp trên bản đồ 3D.
                  </p>
                </div>
                <button className="roadmap-intake-button" onClick={() => navigate('/student/skill-assessment')}>
                  Mở test năng lực
                </button>
              </div>

              <div className="roadmap-summary">
                <div className="summary-card">
                  <div className="summary-label">Chương trình</div>
                  <div className="summary-value">{roadmap?.program || 'CNPM'}</div>
                </div>
                <div className="summary-card">
                  <div className="summary-label">Giai đoạn hiện tại</div>
                  <div className="summary-value">{activePhase?.name || 'Đang cập nhật'}</div>
                </div>
                <div className="summary-card">
                  <div className="summary-label">Bắt buộc</div>
                  <div className="summary-value">
                    {activePhase ? getPhaseProgress(activePhase).required : '0/0'}
                  </div>
                </div>
                {activePhase && activePhase.elective_courses && activePhase.elective_courses.length > 0 && (
                  <div className="summary-card">
                    <div className="summary-label">Tự chọn</div>
                    <div className="summary-value">
                      {getPhaseProgress(activePhase).elective}
                    </div>
                  </div>
                )}
              </div>

              {activePhase && (
                <div className="roadmap-active">
                  <h3>Việc cần hoàn thành để mở khóa giai đoạn tiếp theo</h3>
                  <div className="active-requirements">
                    <div className="requirement-section">
                      <h4><BookMarked size={16} /> Môn bắt buộc</h4>
                      <ul>
                        {(activePhase.required_courses || [])
                          .filter(course => !course.is_completed)
                          .map(course => (
                            <li key={course.code}>
                              {course.name} ({course.code})
                            </li>
                          ))}
                        {(activePhase.required_courses || []).every(c => c.is_completed) && (
                          <li className="all-done">✓ Đã hoàn thành tất cả</li>
                        )}
                      </ul>
                    </div>
                    {activePhase.elective_courses && activePhase.elective_courses.length > 0 && (
                      <div className="requirement-section">
                        <h4><Bookmark size={16} /> Môn tự chọn (cần {activePhase.elective_min_select || 0} môn)</h4>
                        <ul>
                          {activePhase.elective_completed < activePhase.elective_min_select ? (
                            <li>
                              Chọn và hoàn thành {(activePhase.elective_min_select || 0) - (activePhase.elective_completed || 0)} môn nữa
                            </li>
                          ) : (
                            <li className="all-done">✓ Đã hoàn thành đủ số môn tự chọn</li>
                          )}
                        </ul>
                      </div>
                    )}
                  </div>
                </div>
              )}

              <div className="roadmap-phases">
                {roadmap?.phases?.map(phase => {
                  const progress = getPhaseProgress(phase);
                  const hasRequiredCourses = phase.required_courses && phase.required_courses.length > 0;
                  const hasElectiveCourses = phase.elective_courses && phase.elective_courses.length > 0;
                  const isExpanded = expandedPhases[phase.id];
                  
                  return (
                    <div className={`phase-card ${phase.is_active ? 'active' : ''} ${isExpanded ? 'expanded' : ''}`} key={phase.id}>
                      <div className="phase-header" onClick={() => togglePhase(phase.id)}>
                        <div className="phase-header-content">
                          <div>
                            <h3>{phase.name}</h3>
                            <p>{phase.description}</p>
                          </div>
                          <span className={`phase-status ${phase.is_completed ? 'completed' : phase.is_active ? 'active' : 'locked'}`}>
                            {phase.is_completed ? 'Đã hoàn thành' : phase.is_active ? 'Đang học' : 'Chưa mở'}
                          </span>
                        </div>
                        <ChevronDown className={`collapse-icon ${isExpanded ? 'expanded' : ''}`} size={20} />
                      </div>

                      {isExpanded && (
                        <div className="phase-content">
                          {/* Progress info - only show if there are electives */}
                          {hasElectiveCourses && (
                            <div className="phase-progress-info">
                              <span className="progress-item required">
                                <BookMarked size={14} />
                                Bắt buộc: {progress.required}
                              </span>
                              <span className="progress-item elective">
                                <Bookmark size={14} />
                                Tự chọn: {progress.elective} (chọn {phase.elective_min_select || 0})
                              </span>
                            </div>
                          )}

                          {/* Required Courses Section */}
                          {hasRequiredCourses && (
                            <div className="course-section">
                              <div className="section-header required">
                                <BookMarked size={16} />
                                <span>Môn bắt buộc ({phase.required_courses.length} môn)</span>
                              </div>
                              <div className="course-grid">
                                {phase.required_courses.map(course => renderCourseCard(course))}
                              </div>
                            </div>
                          )}

                          {/* Elective Courses Section - only show if there are electives */}
                          {hasElectiveCourses && (
                            <div className="course-section">
                              <div className="section-header elective">
                                <Bookmark size={16} />
                                <span>Môn tự chọn ({phase.elective_courses.length} môn - chọn ít nhất {phase.elective_min_select || 0})</span>
                              </div>
                              <div className="course-grid">
                                {phase.elective_courses.map(course => renderCourseCard(course))}
                              </div>
                            </div>
                          )}

                          {/* Fallback for old structure */}
                          {!hasRequiredCourses && !hasElectiveCourses && phase.courses && (
                            <div className="course-grid">
                              {phase.courses.map(course => renderCourseCard(course))}
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default StudentRoadmapPage;
