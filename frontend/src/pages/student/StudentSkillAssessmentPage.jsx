import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Brain, CheckCircle2, ClipboardList, Gauge, Sparkles } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import Loading from '../../components/common/Loading';
import { studentAPI } from '../../services/api';
import {
  clearStoredPersonalization,
  getStoredPersonalization,
  setStoredPersonalization,
} from '../../utils/personalizationStorage';
import './StudentSkillAssessmentPage.css';

const StudentSkillAssessmentPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [personalization, setPersonalization] = useState(() => getStoredPersonalization());

  useEffect(() => {
    const storedDarkMode = localStorage.getItem('darkMode') === 'true';
    setDarkMode(storedDarkMode);
    if (storedDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  useEffect(() => {
    const fetchTemplate = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await studentAPI.getIntakeAssessmentTemplate();
        setQuestions(response?.questions || []);
      } catch (err) {
        console.error('Error loading competency assessment:', err);
        setError(err.message || 'Không thể tải bài test năng lực.');
      } finally {
        setLoading(false);
      }
    };

    fetchTemplate();
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

  const groupedQuestions = useMemo(() => {
    const knowledge = questions.filter((question) => question.type === 'knowledge');
    const preferences = questions.filter((question) => question.type === 'preference');
    return [
      {
        id: 'knowledge',
        title: 'Năng lực nền tảng',
        description: 'Đo mức sẵn sàng về lập trình, database, web, testing và tư duy kỹ thuật.',
        questions: knowledge,
      },
      {
        id: 'preference',
        title: 'Phong cách học tập',
        description: 'Giúp AI điều chỉnh cách hướng dẫn và độ khó khởi đầu phù hợp với bạn.',
        questions: preferences,
      },
    ].filter((group) => group.questions.length > 0);
  }, [questions]);

  const totalQuestions = questions.length;
  const answeredCount = questions.filter((question) => answers[question.id]).length;
  const completionRate = totalQuestions > 0 ? Math.round((answeredCount / totalQuestions) * 100) : 0;
  const allAnswered = totalQuestions > 0 && answeredCount === totalQuestions;
  const analysis = personalization?.analysis || personalization || null;

  const handleAnswerChange = (questionId, value) => {
    setAnswers((current) => ({
      ...current,
      [questionId]: value,
    }));
  };

  const handleSubmit = async () => {
    if (!allAnswered) {
      return;
    }

    try {
      setSubmitting(true);
      setError(null);
      const response = await studentAPI.analyzeIntakeAssessment(answers);
      setPersonalization(response);
      setStoredPersonalization(response);
    } catch (err) {
      console.error('Error analyzing competency assessment:', err);
      setError(err.message || 'Không thể phân tích kết quả bài test năng lực.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleRedo = () => {
    clearStoredPersonalization();
    setPersonalization(null);
    setAnswers({});
  };

  return (
    <div className="skill-assessment-layout">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="skill-assessment-content">
        <div className="skill-assessment-header">
          <div className="skill-assessment-header-inner">
            <button className="assessment-back-button" onClick={() => navigate('/student/progress')}>
              <ArrowLeft size={18} />
              Quay lại trang tiến độ
            </button>

            <div className="skill-assessment-title-row">
              <div className="skill-assessment-icon">
                <ClipboardList size={28} />
              </div>
              <div>
                <h1>Test Năng Lực Sinh Viên</h1>
                <p>Đánh giá năng lực đầu vào để VLU AI mở khóa đúng chặng học, gợi ý cách học và thiết lập độ khó khởi đầu.</p>
              </div>
            </div>
          </div>
        </div>

        <div className="skill-assessment-body">
          <div className="skill-assessment-summary-grid">
            <div className="skill-summary-card">
              <span>Tổng câu hỏi</span>
              <strong>{totalQuestions}</strong>
            </div>
            <div className="skill-summary-card">
              <span>Đã trả lời</span>
              <strong>{answeredCount}</strong>
            </div>
            <div className="skill-summary-card">
              <span>Mức hoàn thành</span>
              <strong>{completionRate}%</strong>
            </div>
            <div className="skill-summary-card">
              <span>Ứng dụng</span>
              <strong>Bản đồ 3D + Adaptive Learning</strong>
            </div>
          </div>

          {error ? <div className="skill-assessment-alert error">{error}</div> : null}

          {analysis ? (
            <div className="skill-assessment-result">
              <div className="skill-result-hero">
                <div>
                  <span className="skill-result-kicker">Phân tích hoàn tất</span>
                  <h2>VLU AI đã tạo hồ sơ năng lực cá nhân cho bạn</h2>
                  <p>{analysis.ai_summary}</p>
                </div>
                <div className="skill-result-score">
                  <span>Điểm đầu vào</span>
                  <strong>{analysis.assessment_score}%</strong>
                </div>
              </div>

              <div className="skill-result-grid">
                <div className="skill-result-card">
                  <div className="result-card-title"><Gauge size={18} /> Độ khó khởi đầu</div>
                  <strong>{analysis.recommended_difficulty}</strong>
                </div>
                <div className="skill-result-card">
                  <div className="result-card-title"><Brain size={18} /> Phong cách học</div>
                  <strong>{analysis.learning_style}</strong>
                </div>
                <div className="skill-result-card">
                  <div className="result-card-title"><Sparkles size={18} /> Chặng mở khóa</div>
                  <strong>{(analysis.unlocked_phase_ids || []).join(', ')}</strong>
                </div>
              </div>

              <div className="skill-result-sections">
                <div className="skill-result-section">
                  <h3>Điểm mạnh</h3>
                  <div className="result-chip-row">
                    {(analysis.strengths || []).map((item, index) => (
                      <span key={`strength-${index}`} className="result-chip good">{item}</span>
                    ))}
                  </div>
                </div>
                <div className="skill-result-section">
                  <h3>Phần cần ưu tiên</h3>
                  <div className="result-chip-row">
                    {(analysis.weaknesses || []).map((item, index) => (
                      <span key={`weakness-${index}`} className="result-chip warn">{item}</span>
                    ))}
                  </div>
                </div>
                <div className="skill-result-section">
                  <h3>Hành động tiếp theo</h3>
                  <div className="result-action-list">
                    {(analysis.next_actions || []).map((item, index) => (
                      <div key={`action-${index}`} className="result-action-item">
                        <CheckCircle2 size={16} />
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="skill-result-actions">
                <button className="assessment-secondary-button" onClick={handleRedo}>
                  Làm lại bài test
                </button>
                <button className="assessment-primary-button" onClick={() => navigate('/student/progress')}>
                  Xem bản đồ cá nhân hóa
                </button>
              </div>
            </div>
          ) : (
            <div className="skill-assessment-form">
              {loading ? (
                <Loading
                  compact
                  title="Dang tai bai test nang luc"
                  subtitle="Dang chuan bi bo cau hoi dau vao de AI phan tich ho so hoc tap cua ban."
                />
              ) : groupedQuestions.length === 0 ? (
                <div className="skill-assessment-alert error">Chưa có dữ liệu câu hỏi từ hệ thống. Hãy thử lại sau khi backend được khởi động lại.</div>
              ) : (
                <>
                  {groupedQuestions.map((group) => (
                    <section key={group.id} className="assessment-group">
                      <div className="assessment-group-header">
                        <h2>{group.title}</h2>
                        <p>{group.description}</p>
                      </div>

                      <div className="assessment-question-list">
                        {group.questions.map((question, index) => {
                          const absoluteIndex = questions.findIndex((item) => item.id === question.id) + 1;

                          return (
                            <article key={question.id} className="assessment-question-card">
                              <div className="assessment-question-title">
                                <span className="question-number">Câu {absoluteIndex}</span>
                                <strong>{question.prompt}</strong>
                              </div>

                              <div className="assessment-options">
                                {(question.options || []).map((option) => (
                                  <label key={`${question.id}-${option.value}`} className="assessment-option">
                                    <input
                                      type="radio"
                                      name={question.id}
                                      value={option.value}
                                      checked={answers[question.id] === option.value}
                                      onChange={(event) => handleAnswerChange(question.id, event.target.value)}
                                    />
                                    <span>
                                      <strong>{option.label}.</strong> {option.text}
                                    </span>
                                  </label>
                                ))}
                              </div>
                            </article>
                          );
                        })}
                      </div>
                    </section>
                  ))}

                  <div className="assessment-submit-bar">
                    <div>
                      <strong>{answeredCount}/{totalQuestions}</strong>
                      <span> câu đã hoàn thành</span>
                    </div>
                    <button className="assessment-primary-button" disabled={!allAnswered || submitting} onClick={handleSubmit}>
                      {submitting ? 'VLU AI đang phân tích...' : 'Nộp bài test năng lực'}
                    </button>
                  </div>
                </>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default StudentSkillAssessmentPage;