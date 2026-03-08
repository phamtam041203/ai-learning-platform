import { useState, useEffect, useRef } from 'react';
import {
  Send, Bot, User, TrendingUp, AlertCircle, CheckCircle, Target,
  Sparkles, Moon, Sun, ChevronLeft, ChevronRight,
  Calendar, BellRing, BarChart2, RefreshCw, BookOpen
} from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { chatbotAPI, studentAPI } from '../../services/api';
import './AIAdvisorPage.css';
import './StudentDashboard.css';

const getUserStorageKey = (baseKey) => {
  const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}');
  const userId = currentUser.id || currentUser.studentId || 'guest';
  return `${baseKey}_${userId}`;
};

const STORAGE_KEYS = {
  MESSAGES: 'ai_advisor_messages',
  DARK_MODE: 'ai_advisor_dark_mode',
  SHOW_ANALYSIS: 'ai_advisor_show_analysis',
  STUDY_PLAN: 'ai_advisor_study_plan',
};

const TABS = ['chat', 'plan', 'reminders'];

const AIAdvisorPage = () => {
  const [activeTab, setActiveTab] = useState('chat');
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [studentAnalysis, setStudentAnalysis] = useState(null);
  const [analytics, setAnalytics] = useState(null);
  const [skillProfile, setSkillProfile] = useState(null);
  const [currentUserId, setCurrentUserId] = useState(null);
  const [showAnalysis, setShowAnalysis] = useState(() => {
    const saved = localStorage.getItem(getUserStorageKey(STORAGE_KEYS.SHOW_ANALYSIS));
    return saved !== null ? JSON.parse(saved) : true;
  });
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const globalTheme = localStorage.getItem('theme');
    if (globalTheme) return globalTheme === 'dark';
    const saved = localStorage.getItem(getUserStorageKey(STORAGE_KEYS.DARK_MODE));
    return saved !== null ? JSON.parse(saved) : false;
  });

  // Study-plan state
  const [studyPlan, setStudyPlan] = useState(null);
  const [planGoal, setPlanGoal] = useState('');
  const [isPlanLoading, setIsPlanLoading] = useState(false);
  const [planError, setPlanError] = useState(null);
  const [expandedWeek, setExpandedWeek] = useState(0);

  const messagesEndRef = useRef(null);

  useEffect(() => {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}');
    const userId = currentUser.id || currentUser.studentId || 'guest';
    if (currentUserId !== null && currentUserId !== userId) {
      loadMessagesForUser(userId);
    } else if (currentUserId === null) {
      loadMessagesForUser(userId);
    }
    setCurrentUserId(userId);
    loadStudentAnalysis();
    loadAnalytics();
    loadSkillProfile();

    // Restore cached study plan
    const cachedPlan = localStorage.getItem(getUserStorageKey(STORAGE_KEYS.STUDY_PLAN));
    if (cachedPlan) {
      try { setStudyPlan(JSON.parse(cachedPlan)); } catch (_) {}
    }
  }, []);

  const loadAnalytics = async () => {
    try {
      const data = await studentAPI.getLearningAnalytics();
      setAnalytics(data);
    } catch (_) {}
  };

  const loadSkillProfile = async () => {
    try {
      const data = await studentAPI.getSkillProfile();
      setSkillProfile(data);
    } catch (_) {}
  };

  const loadMessagesForUser = (userId) => {
    const saved = localStorage.getItem(`${STORAGE_KEYS.MESSAGES}_${userId}`);
    if (saved) {
      try {
        setMessages(JSON.parse(saved).map(m => ({ ...m, timestamp: new Date(m.timestamp) })));
      } catch (_) { initializeWelcomeMessage(); }
    } else {
      initializeWelcomeMessage();
    }
  };

  useEffect(() => {
    if (messages.length > 0 && currentUserId) {
      localStorage.setItem(`${STORAGE_KEYS.MESSAGES}_${currentUserId}`, JSON.stringify(messages));
    }
  }, [messages, currentUserId]);

  useEffect(() => {
    if (currentUserId) {
      localStorage.setItem(getUserStorageKey(STORAGE_KEYS.DARK_MODE), JSON.stringify(isDarkMode));
    }
    localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
    if (isDarkMode) document.documentElement.setAttribute('data-theme', 'dark');
    else document.documentElement.removeAttribute('data-theme');
  }, [isDarkMode, currentUserId]);

  useEffect(() => {
    if (currentUserId) {
      localStorage.setItem(getUserStorageKey(STORAGE_KEYS.SHOW_ANALYSIS), JSON.stringify(showAnalysis));
    }
  }, [showAnalysis, currentUserId]);

  useEffect(() => { messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  const initializeWelcomeMessage = () => {
    setMessages([{
      id: Date.now(), type: 'bot', timestamp: new Date(),
      content: 'Xin chào! Tôi là **AI Learning Advisor**.\nDùng tab **Tư vấn AI** để hỏi về học tập, tab **Kế hoạch học** để tạo lịch 4 tuần, tab **Ôn tập** để xem lịch ôn kỹ năng yếu.',
    }]);
  };

  const loadStudentAnalysis = async () => {
    try { setStudentAnalysis(await chatbotAPI.getStudentAnalysis()); } catch (_) {}
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!inputMessage.trim() || isLoading) return;
    const userMessage = { id: Date.now(), type: 'user', content: inputMessage, timestamp: new Date() };
    setMessages(prev => [...prev, userMessage]);
    const currentQuestion = inputMessage;
    setInputMessage('');
    setIsLoading(true);
    try {
      const response = await chatbotAPI.askChatGPT(currentQuestion);
      setMessages(prev => [...prev, {
        id: Date.now() + 1, type: 'bot', timestamp: new Date(),
        content: response.answer || response.advice, source: response.source || 'gemini',
      }]);
    } catch (_) {
      try {
        const response = await chatbotAPI.askAdvisor(currentQuestion);
        setMessages(prev => [...prev, {
          id: Date.now() + 1, type: 'bot', timestamp: new Date(),
          content: response.advice, source: 'local',
        }]);
      } catch (__) {
        setMessages(prev => [...prev, {
          id: Date.now() + 1, type: 'bot', timestamp: new Date(),
          content: 'Xin lỗi, tôi đang gặp sự cố. Vui lòng thử lại sau.', isError: true,
        }]);
      }
    } finally { setIsLoading(false); }
  };

  const handleGeneratePlan = async () => {
    setIsPlanLoading(true);
    setPlanError(null);
    try {
      const data = await studentAPI.generateStudyPlan(planGoal);
      setStudyPlan(data.plan);
      setExpandedWeek(0);
      localStorage.setItem(getUserStorageKey(STORAGE_KEYS.STUDY_PLAN), JSON.stringify(data.plan));
    } catch (err) {
      setPlanError('Không thể tạo kế hoạch lúc này. Vui lòng thử lại.');
    } finally { setIsPlanLoading(false); }
  };

  const clearChatHistory = () => {
    if (window.confirm('Xóa toàn bộ lịch sử chat?')) {
      if (currentUserId) localStorage.removeItem(`${STORAGE_KEYS.MESSAGES}_${currentUserId}`);
      initializeWelcomeMessage();
    }
  };

  const formatContent = (content) => {
    return content.split('\n').map((line, index) => {
      if (line.includes('**')) {
        const parts = line.split('**');
        return <p key={index} className="message-line">{parts.map((p, i) => i % 2 === 1 ? <strong key={i}>{p}</strong> : p)}</p>;
      }
      if (line.startsWith('- ') || line.startsWith('✓ ') || line.startsWith('→ '))
        return <li key={index} className="message-list-item">{line.substring(2)}</li>;
      if (line.match(/^[📊💪⚠️🎯💡]/))
        return <h4 key={index} className="message-header">{line}</h4>;
      if (line.trim() === '') return <br key={index} />;
      return <p key={index} className="message-line">{line}</p>;
    });
  };

  const riskColor = { low: '#22c55e', medium: '#f59e0b', high: '#ef4444' };
  const riskLabel = { low: 'Ổn định', medium: 'Cần chú ý', high: 'Nguy hiểm' };

  return (
    <div className={`ai-advisor-page ${isDarkMode ? 'dark-mode' : ''}`}>
      <StudentSidebar darkMode={isDarkMode} onToggleDarkMode={() => setIsDarkMode(!isDarkMode)} />

      <div className="advisor-content">
        <div className="advisor-container">

          {/* ── Toggle button when panel hidden ── */}
          {!showAnalysis && (
            <button className="floating-toggle-btn" onClick={() => setShowAnalysis(true)} title="Mở phân tích">
              <ChevronRight size={24} />
            </button>
          )}

          {/* ── Analysis Panel ── */}
          {studentAnalysis && (
            <div className={`analysis-panel ${showAnalysis ? 'show' : 'hide'}`}>
              <div className="analysis-header">
                <h3><Sparkles size={20} /> Phân Tích Hồ Sơ</h3>
                <button onClick={() => setShowAnalysis(!showAnalysis)}>
                  {showAnalysis ? <ChevronLeft size={20} /> : <ChevronRight size={20} />}
                </button>
              </div>

              {showAnalysis && (
                <div className="analysis-content">
                  <div className={`score-card score-${studentAnalysis.overall_score.color}`}>
                    <div className="score-value">{studentAnalysis.overall_score.overall_score}</div>
                    <div className="score-label">/ 100</div>
                    <div className="score-grade">{studentAnalysis.overall_score.grade}</div>
                  </div>

                  {/* Early-warning panel */}
                  {analytics && analytics.risk_level !== 'low' && (
                    <div className="early-warning-panel" style={{ borderColor: riskColor[analytics.risk_level] }}>
                      <div className="ew-header">
                        <AlertCircle size={16} color={riskColor[analytics.risk_level]} />
                        <span style={{ color: riskColor[analytics.risk_level], fontWeight: 700 }}>
                          {riskLabel[analytics.risk_level]}
                        </span>
                      </div>
                      {analytics.warning_messages.map((msg, i) => (
                        <p key={i} className="ew-message">{msg}</p>
                      ))}
                      <p className="ew-recommendation">{analytics.recommendation}</p>
                    </div>
                  )}

                  <div className="stats-grid">
                    <div className="stat-item">
                      <span className="stat-icon">📚</span>
                      <span className="stat-value">{studentAnalysis.performance_summary.completed_courses}/{studentAnalysis.performance_summary.total_courses}</span>
                      <span className="stat-label">Khóa học</span>
                    </div>
                    <div className="stat-item">
                      <span className="stat-icon">✅</span>
                      <span className="stat-value">{studentAnalysis.performance_summary.quiz_pass_rate}%</span>
                      <span className="stat-label">Pass quiz</span>
                    </div>
                    <div className="stat-item">
                      <span className="stat-icon">📝</span>
                      <span className="stat-value">{studentAnalysis.performance_summary.average_quiz_score}%</span>
                      <span className="stat-label">Điểm TB</span>
                    </div>
                    <div className="stat-item">
                      <span className="stat-icon">⏱️</span>
                      <span className="stat-value">{studentAnalysis.performance_summary.total_study_hours}h</span>
                      <span className="stat-label">Giờ học</span>
                    </div>
                  </div>

                  {studentAnalysis.strengths.length > 0 && (
                    <div className="insights-section strengths-section">
                      <h4><CheckCircle size={16} /> Điểm Mạnh ({studentAnalysis.strengths.length})</h4>
                      <ul>
                        {studentAnalysis.strengths.slice(0, 3).map((s, i) => (
                          <li key={i}><strong>{s.category}</strong><p>{s.description}</p></li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {studentAnalysis.weaknesses.length > 0 && (
                    <div className="insights-section weaknesses-section">
                      <h4><AlertCircle size={16} /> Cần Cải Thiện ({studentAnalysis.weaknesses.length})</h4>
                      <ul>
                        {studentAnalysis.weaknesses.slice(0, 3).map((w, i) => (
                          <li key={i}><strong>{w.category}</strong><p>{w.description}</p><span className="action">→ {w.action}</span></li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {studentAnalysis.recommendations.length > 0 && (
                    <div className="insights-section recommendation-section">
                      <h4><Target size={16} /> Gợi Ý Ưu Tiên</h4>
                      <div className="recommendation-card">
                        <h5>{studentAnalysis.recommendations[0].title}</h5>
                        <p>{studentAnalysis.recommendations[0].description}</p>
                      </div>
                    </div>
                  )}

                  <button className="refresh-analysis-btn" onClick={loadStudentAnalysis}>
                    <TrendingUp size={16} /> Làm mới phân tích
                  </button>
                </div>
              )}
            </div>
          )}

          {/* ── Main Chat / Plan area ── */}
          <div className="chat-area">
            {/* Header */}
            <div className="chat-header">
              <div className="header-info">
                <Bot size={32} className="bot-icon-header" />
                <div>
                  <h2>AI Learning Advisor</h2>
                  <p>Tư vấn cá nhân hoá · Kế hoạch học · Nhắc ôn tập</p>
                </div>
              </div>
              <div className="header-actions">
                <button className="theme-toggle-btn" onClick={() => setIsDarkMode(!isDarkMode)}
                  title={isDarkMode ? 'Chế độ sáng' : 'Chế độ tối'}>
                  {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
                </button>
                {activeTab === 'chat' && (
                  <button className="clear-history-btn" onClick={clearChatHistory} title="Xóa lịch sử">🗑️</button>
                )}
              </div>
            </div>

            {/* Tab navigation */}
            <div className="advisor-tabs">
              <button className={`advisor-tab ${activeTab === 'chat' ? 'active' : ''}`} onClick={() => setActiveTab('chat')}>
                <Bot size={16} /> Tư vấn AI
              </button>
              <button className={`advisor-tab ${activeTab === 'plan' ? 'active' : ''}`} onClick={() => setActiveTab('plan')}>
                <Calendar size={16} /> Kế hoạch học
              </button>
              <button className={`advisor-tab ${activeTab === 'reminders' ? 'active' : ''}`} onClick={() => setActiveTab('reminders')}>
                <BellRing size={16} /> Ôn tập
              </button>
            </div>

            {/* ── TAB: Chat ── */}
            {activeTab === 'chat' && (
              <>
                <div className="messages-area">
                  {messages.map((message) => (
                    <div key={message.id} className={`message ${message.type}-message`}>
                      <div className="message-avatar">{message.type === 'user' ? <User size={24} /> : <Bot size={24} />}</div>
                      <div className="message-bubble">
                        <div className="message-text">{formatContent(message.content)}</div>
                        <div className="message-time">
                          {message.timestamp.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
                        </div>
                      </div>
                    </div>
                  ))}
                  {isLoading && (
                    <div className="message bot-message">
                      <div className="message-avatar"><Bot size={24} /></div>
                      <div className="message-bubble">
                        <div className="typing-indicator"><span /><span /><span /></div>
                      </div>
                    </div>
                  )}
                  <div ref={messagesEndRef} />
                </div>

                <div className="quick-questions">
                  <button onClick={() => setInputMessage('Tôi đang học tốt như thế nào?')}>Tôi đang học tốt như thế nào?</button>
                  <button onClick={() => setInputMessage('Tôi cần cải thiện gì?')}>Tôi cần cải thiện gì?</button>
                  <button onClick={() => setInputMessage('Gợi ý học tập cho tôi')}>Gợi ý học tập cho tôi</button>
                </div>

                <form className="chat-input-form" onSubmit={handleSendMessage}>
                  <div className="input-wrapper">
                    <input
                      type="text"
                      value={inputMessage}
                      onChange={(e) => setInputMessage(e.target.value)}
                      placeholder="Hỏi AI advisor về việc học của bạn..."
                      disabled={isLoading}
                    />
                    <button type="submit" disabled={!inputMessage.trim() || isLoading}><Send size={20} /></button>
                  </div>
                </form>
              </>
            )}

            {/* ── TAB: Study Plan ── */}
            {activeTab === 'plan' && (
              <div className="plan-tab-content">
                <div className="plan-goal-form">
                  <label className="plan-goal-label">
                    <Target size={16} /> Mục tiêu học tập của bạn
                  </label>
                  <div className="plan-goal-row">
                    <input
                      type="text"
                      className="plan-goal-input"
                      placeholder="VD: Hoàn thành Phase 2 trước tháng 4, đạt điểm B+..."
                      value={planGoal}
                      onChange={(e) => setPlanGoal(e.target.value)}
                      onKeyDown={(e) => e.key === 'Enter' && !isPlanLoading && handleGeneratePlan()}
                    />
                    <button
                      className="plan-generate-btn"
                      onClick={handleGeneratePlan}
                      disabled={isPlanLoading}
                    >
                      {isPlanLoading ? <><RefreshCw size={16} className="spin" /> Đang tạo...</> : <><Sparkles size={16} /> Tạo kế hoạch</>}
                    </button>
                  </div>
                  {planError && <p className="plan-error">{planError}</p>}
                </div>

                {studyPlan ? (
                  <div className="plan-result">
                    <div className="plan-header-info">
                      <h3 className="plan-goal-text"><Target size={18} /> {studyPlan.goal}</h3>
                      <p className="plan-summary">{studyPlan.summary}</p>
                    </div>

                    <div className="plan-weeks">
                      {(studyPlan.weeks || []).map((week, wi) => (
                        <div key={wi} className={`plan-week ${expandedWeek === wi ? 'expanded' : ''}`}>
                          <button
                            className="plan-week-header"
                            onClick={() => setExpandedWeek(expandedWeek === wi ? -1 : wi)}
                          >
                            <span className="week-badge">Tuần {week.week}</span>
                            <span className="week-theme">{week.theme}</span>
                            <span className="week-toggle">{expandedWeek === wi ? '▲' : '▼'}</span>
                          </button>
                          {expandedWeek === wi && (
                            <div className="plan-week-tasks">
                              {(week.daily_tasks || []).map((task, ti) => (
                                <div key={ti} className="plan-task-row">
                                  <span className="task-day">{task.day}</span>
                                  <span className="task-desc">{task.task}</span>
                                  <span className="task-duration">{task.duration}</span>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                ) : (
                  <div className="plan-empty">
                    <Calendar size={48} opacity={0.3} />
                    <p>Nhập mục tiêu và nhấn <strong>Tạo kế hoạch</strong> để AI tạo lịch học 4 tuần cho bạn.</p>
                  </div>
                )}
              </div>
            )}

            {/* ── TAB: Reminders (skill review) ── */}
            {activeTab === 'reminders' && (
              <div className="reminders-tab-content">
                {/* Analytics quick summary */}
                {analytics && (
                  <div className="analytics-summary">
                    <div className={`risk-badge risk-${analytics.risk_level}`}>
                      <BarChart2 size={14} />
                      {riskLabel[analytics.risk_level]}
                    </div>
                    <span className="analytics-inactive">
                      {analytics.days_inactive > 0
                        ? `Chưa học ${analytics.days_inactive} ngày`
                        : 'Đang học đều đặn'}
                    </span>
                    <span className="analytics-avg-score">
                      Điểm TB: {analytics.avg_recent_score}%
                    </span>
                  </div>
                )}

                {/* Skill profile */}
                <div className="skill-section">
                  <h4><BookOpen size={16} /> Hồ sơ kỹ năng</h4>
                  {skillProfile && skillProfile.skills.length > 0 ? (
                    <div className="skill-bars">
                      {skillProfile.skills.map((sk) => (
                        <div key={sk.skill_id} className="skill-bar-row">
                          <span className="skill-label">{sk.label}</span>
                          <div className="skill-bar-track">
                            <div
                              className={`skill-bar-fill ${sk.confidence < 60 ? 'weak' : sk.confidence >= 80 ? 'strong' : 'medium'}`}
                              style={{ width: `${sk.confidence}%` }}
                            />
                          </div>
                          <span className="skill-pct">{sk.confidence}%</span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="skill-empty">Chưa có dữ liệu. Hoàn thành quiz để xây dựng hồ sơ kỹ năng.</p>
                  )}
                </div>

                {/* Study plan reminders */}
                {studyPlan && (studyPlan.reminders || []).length > 0 && (
                  <div className="reminders-section">
                    <h4><BellRing size={16} /> Lịch ôn tập từ kế hoạch</h4>
                    <div className="reminder-list">
                      {studyPlan.reminders.map((r, i) => (
                        <div key={i} className="reminder-card">
                          <div className="reminder-skill">{r.skill}</div>
                          <div className="reminder-days">Ôn sau {r.review_in_days} ngày</div>
                          <div className="reminder-tip">{r.tip}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Analytics weak skills */}
                {analytics && analytics.weak_skills.length > 0 && (
                  <div className="reminders-section">
                    <h4><AlertCircle size={16} /> Kỹ năng cần ôn gấp</h4>
                    <div className="reminder-list">
                      {analytics.weak_skills.map((sk, i) => (
                        <div key={i} className="reminder-card weak-skill-card">
                          <div className="reminder-skill">{sk.label}</div>
                          <div className="reminder-days">Độ tự tin: {sk.confidence}%</div>
                          <div className="reminder-tip">
                            Hãy làm quiz liên quan để nâng điểm kỹ năng này.
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {(!studyPlan || !studyPlan.reminders?.length) && (!analytics || !analytics.weak_skills.length) && (
                  <div className="plan-empty">
                    <BellRing size={48} opacity={0.3} />
                    <p>Tạo kế hoạch học hoặc hoàn thành quiz để xem lịch ôn tập tại đây.</p>
                  </div>
                )}

                {analytics && analytics.recommendation && (
                  <div className="analytics-recommendation">
                    <Target size={16} />
                    <span>{analytics.recommendation}</span>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AIAdvisorPage;
