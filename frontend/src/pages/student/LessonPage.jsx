import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Play, CheckCircle, Clock, BookOpen,
  AlertCircle, Loader, Home, FileText, ExternalLink, Edit3
} from 'lucide-react';
import { authAPI } from '../../services/api';
import EssaySubmission from '../../components/EssaySubmission';
import LessonAssistant from '../../components/LessonAssistant';
import DiscussionBoard from '../../components/DiscussionBoard';
import './LessonPage.css';

const LessonPage = () => {
  const { courseId, lessonId } = useParams();
  const navigate = useNavigate();
  
  const [lesson, setLesson] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showQuiz, setShowQuiz] = useState(false);
  const [showEssay, setShowEssay] = useState(false);
  const [quizAnswers, setQuizAnswers] = useState({});
  const [submittingQuiz, setSubmittingQuiz] = useState(false);
  const [quizResult, setQuizResult] = useState(null);

  useEffect(() => {
    fetchLessonData();
  }, [courseId, lessonId]);

  const fetchLessonData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const token = localStorage.getItem('token');
      console.log(`📚 [LessonPage] Fetching lesson ${lessonId} from course ${courseId}...`);

      const response = await fetch(
        `http://localhost:8000/api/courses/${courseId}/lessons/${lessonId}`,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to fetch lesson: ${response.status}`);
      }

      const data = await response.json();
      console.log('✅ Lesson loaded:', data);
      setLesson(data);

    } catch (err) {
      console.error('Error fetching lesson:', err);
      setError(err.message || 'Không thể tải bài học');
    } finally {
      setLoading(false);
    }
  };

  const handleAnswerChange = (questionId, answer) => {
    setQuizAnswers(prev => ({
      ...prev,
      [questionId]: answer
    }));
  };

  const handleSubmitQuiz = async () => {
    try {
      setSubmittingQuiz(true);
      const token = localStorage.getItem('token');

      console.log('📝 Submitting quiz answers:', quizAnswers);

      const response = await fetch(
        `http://localhost:8000/api/courses/${courseId}/lessons/${lessonId}/quiz-submit`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(quizAnswers)
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to submit quiz: ${response.status}`);
      }

      const result = await response.json();
      console.log('✅ Quiz submitted:', result);
      setQuizResult(result);
      setShowQuiz(false);

    } catch (err) {
      console.error('Error submitting quiz:', err);
      alert(`Lỗi: ${err.message}`);
    } finally {
      setSubmittingQuiz(false);
    }
  };

  if (loading) {
    return (
      <div className="lesson-page">
        <div className="loading-container">
          <Loader className="loading-spinner" size={48} />
          <p>Đang tải bài học...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="lesson-page">
        <div className="error-container">
          <AlertCircle size={48} />
          <h2>Không thể tải bài học</h2>
          <p>{error}</p>
          <button onClick={() => navigate(`/student/courses`)} className="btn-primary">
            <ArrowLeft size={18} />
            Quay lại danh sách khóa học
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="lesson-page">
      {/* Header */}
      <div className="lesson-header">
        <div className="header-top">
          <button onClick={() => navigate(`/student/courses`)} className="btn-back">
            <ArrowLeft size={20} />
            Quay lại
          </button>
          <button onClick={() => navigate('/student/dashboard')} className="btn-home">
            <Home size={20} />
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="lesson-container">
        {/* Lesson Content Section */}
        <div className="lesson-content-section">
          <div className="lesson-header-info">
            <div className="lesson-badge">Bài {lesson?.order}</div>
            <h1 className="lesson-title">{lesson?.title}</h1>
            <p className="lesson-description">{lesson?.description}</p>
          </div>

          <div className="lesson-body">
            {/* PDF Viewer */}
            {lesson?.pdf_url && (
              <div className="pdf-section">
                <div className="pdf-header">
                  <FileText size={20} />
                  <span>Tài liệu bài học</span>
                  <a 
                    href={`http://localhost:8000${lesson.pdf_url}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="btn-open-pdf"
                  >
                    <ExternalLink size={16} />
                    Mở tab mới
                  </a>
                </div>
                <iframe
                  src={`http://localhost:8000${lesson.pdf_url}`}
                  className="pdf-viewer"
                  title={lesson.title}
                />
              </div>
            )}
            
            {/* Text Content if no PDF */}
            {!lesson?.pdf_url && lesson?.content && (
              <div className="content-text">
                {lesson.content}
              </div>
            )}
            
            {/* No content message */}
            {!lesson?.pdf_url && !lesson?.content && (
              <div className="no-content">
                <AlertCircle size={48} />
                <p>Chưa có nội dung cho bài học này</p>
              </div>
            )}
          </div>

          <LessonAssistant
            courseId={courseId}
            lessonId={lessonId}
            lessonTitle={lesson?.title || 'Bài học hiện tại'}
            lessonDescription={lesson?.description || ''}
          />

          {/* Quiz Section */}
          {lesson?.quiz && (
            <div className="quiz-section">
              <div className="quiz-header">
                <BookOpen size={24} />
                <div>
                  <h2>Quiz: {lesson?.title}</h2>
                  <p>{lesson?.quiz?.description}</p>
                </div>
              </div>

              {quizResult ? (
                // Quiz Result
                <div className={`quiz-result ${quizResult.passed ? 'passed' : 'failed'}`}>
                  <div className="result-icon">
                    {quizResult.passed ? (
                      <CheckCircle size={64} />
                    ) : (
                      <AlertCircle size={64} />
                    )}
                  </div>
                  <h3>{quizResult.passed ? 'Bạn đã vượt qua!' : 'Bạn chưa vượt qua'}</h3>
                  <div className="result-stats">
                    <div className="stat">
                      <span className="label">Điểm số:</span>
                      <span className="value">{quizResult.score}/{quizResult.max_score}</span>
                    </div>
                    <div className="stat">
                      <span className="label">Tỷ lệ:</span>
                      <span className="value">{quizResult.percentage.toFixed(1)}%</span>
                    </div>
                  </div>

                  {quizResult.adaptive_learning ? (
                    <div className="adaptive-learning-card">
                      <div className="adaptive-learning-header">
                        <h4>Adaptive Learning từ Gemini</h4>
                        <span className={`adaptive-difficulty ${quizResult.adaptive_learning.recommended_difficulty}`}>
                          Độ khó tiếp theo: {quizResult.adaptive_learning.recommended_difficulty}
                        </span>
                      </div>

                      <p className="adaptive-learning-feedback">{quizResult.adaptive_learning.ai_feedback}</p>
                      <p className="adaptive-learning-reason">{quizResult.adaptive_learning.adaptation_reason}</p>

                      {(quizResult.adaptive_learning.weak_topics || []).length > 0 ? (
                        <div className="adaptive-learning-section">
                          <strong>Phần cần củng cố</strong>
                          <div className="adaptive-learning-tags">
                            {quizResult.adaptive_learning.weak_topics.map((topic, index) => (
                              <span key={`weak-topic-${index}`} className="adaptive-learning-tag">{topic}</span>
                            ))}
                          </div>
                        </div>
                      ) : null}

                      {(quizResult.adaptive_learning.next_steps || []).length > 0 ? (
                        <div className="adaptive-learning-section">
                          <strong>Bước tiếp theo</strong>
                          <div className="adaptive-learning-list">
                            {quizResult.adaptive_learning.next_steps.map((step, index) => (
                              <div key={`adaptive-step-${index}`} className="adaptive-learning-item">{step}</div>
                            ))}
                          </div>
                        </div>
                      ) : null}

                      {(quizResult.adaptive_learning.supplementary_materials || []).length > 0 ? (
                        <div className="adaptive-learning-section">
                          <strong>Tài liệu bổ trợ</strong>
                          <div className="adaptive-learning-materials">
                            {quizResult.adaptive_learning.supplementary_materials.map((material, index) => (
                              <div key={`material-${index}`} className="adaptive-learning-material">
                                <span className="material-type">{material.type}</span>
                                <div>
                                  <h5>{material.title}</h5>
                                  <p>{material.description}</p>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      ) : null}
                    </div>
                  ) : null}

                  {/* Remedial lesson suggestions after failed quiz */}
                  {!quizResult.passed && (quizResult.remedial_lessons || []).length > 0 && (
                    <div className="remedial-lessons-card">
                      <h4>📚 Ôn lại bài trước để cải thiện điểm</h4>
                      <p className="remedial-hint">Bạn chưa đạt 70%. Hãy ôn lại những bài này rồi thử lại:</p>
                      <div className="remedial-lessons-list">
                        {quizResult.remedial_lessons.map((rl) => (
                          <button
                            key={rl.lesson_id}
                            className="remedial-lesson-btn"
                            onClick={() => navigate(`/student/courses/${courseId}/lessons/${rl.lesson_id}`)}
                          >
                            <BookOpen size={16} />
                            Bài {rl.order}: {rl.title}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  <button
                    onClick={() => {
                      setShowQuiz(false);
                      setQuizResult(null);
                      setQuizAnswers({});
                    }}
                    className="btn-primary"
                  >
                    Làm lại Quiz
                  </button>
                </div>
              ) : showQuiz ? (
                // Quiz Form
                <div className="quiz-form">
                  <div className="quiz-instructions">
                    <Clock size={18} />
                    <p>{lesson?.quiz?.instructions}</p>
                    {lesson?.quiz?.duration_minutes && (
                      <p className="duration">⏱️ Thời gian: {lesson.quiz.duration_minutes} phút</p>
                    )}
                  </div>

                  <div className="questions">
                    {lesson?.quiz?.questions?.map((question) => (
                      <div key={question.id} className="question-card">
                        <div className="question-header">
                          <h4>Câu {question.order}</h4>
                          <span className="points">({question.points} điểm)</span>
                        </div>
                        <p className="question-text">{question.question_text}</p>

                        <div className="options">
                          {question.question_type === 'multiple_choice' && (
                            <>
                              {['a', 'b', 'c', 'd'].map((option) => {
                                const optionKey = `option_${option}`;
                                const optionText = question[optionKey];
                                if (!optionText) return null;

                                return (
                                  <label key={option} className="option-label">
                                    <input
                                      type="radio"
                                      name={`question-${question.id}`}
                                      value={option}
                                      checked={quizAnswers[question.id] === option}
                                      onChange={(e) =>
                                        handleAnswerChange(question.id, e.target.value)
                                      }
                                    />
                                    <span className="option-text">
                                      <strong>{option.toUpperCase()}.</strong> {optionText}
                                    </span>
                                  </label>
                                );
                              })}
                            </>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="quiz-actions">
                    <button
                      onClick={() => setShowQuiz(false)}
                      className="btn-outline"
                    >
                      Hủy
                    </button>
                    <button
                      onClick={handleSubmitQuiz}
                      disabled={submittingQuiz}
                      className="btn-primary"
                    >
                      {submittingQuiz ? 'Đang gửi...' : 'Nộp bài'}
                    </button>
                  </div>
                </div>
              ) : (
                // Quiz Start Button
                <div className="quiz-start">
                  <button
                    onClick={() => setShowQuiz(true)}
                    className="btn-quiz"
                  >
                    <Play size={20} />
                    Bắt đầu Quiz
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Essay/Assignment Section - Show when no quiz or alongside quiz */}
          {lesson?.supports_essay && (
            <div className="essay-section">
              <div className="essay-section-header">
                <Edit3 size={24} />
                <div>
                  <h2>Bài tập tự luận</h2>
                  <p>Nộp bài làm bằng cách viết văn bản hoặc tải file lên</p>
                </div>
              </div>
              
              {showEssay ? (
                <div className="essay-form-wrapper">
                  <EssaySubmission 
                    lessonId={parseInt(lessonId)}
                    lessonTitle={lesson?.title}
                    onSubmitSuccess={() => {
                      // Optionally refresh lesson data
                      fetchLessonData();
                    }}
                  />
                  <button 
                    className="btn-outline essay-collapse-btn"
                    onClick={() => setShowEssay(false)}
                  >
                    Thu gọn
                  </button>
                </div>
              ) : (
                <div className="essay-start">
                  {lesson?.essay_submission ? (
                    <div className="essay-status">
                      <CheckCircle size={18} className="status-icon submitted" />
                      <span>
                        Đã nộp bài - {lesson.essay_submission.status === 'graded' 
                          ? `Điểm: ${lesson.essay_submission.score}/${lesson.essay_submission.max_score}` 
                          : 'Chờ chấm điểm'}
                      </span>
                    </div>
                  ) : null}
                  <button
                    onClick={() => setShowEssay(true)}
                    className="btn-essay"
                  >
                    <Edit3 size={20} />
                    {lesson?.essay_submission ? 'Xem/Sửa bài nộp' : 'Nộp bài tự luận'}
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Discussion Board */}
      <div className="lesson-discussion-wrapper">
        <DiscussionBoard lessonId={parseInt(lessonId)} />
      </div>
    </div>
  );
};

export default LessonPage;
