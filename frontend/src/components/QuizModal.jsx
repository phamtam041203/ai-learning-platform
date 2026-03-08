import { useState, useEffect } from 'react';
import { X, CheckCircle, XCircle, Award } from 'lucide-react';
import './QuizModal.css';

const QuizModal = ({ isOpen, onClose, lessonFileName, lessonTitle, onQuizComplete }) => {
  const [quizData, setQuizData] = useState(null);
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswers, setSelectedAnswers] = useState({});
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);

  // Load quiz when modal opens
  useEffect(() => {
    if (isOpen && lessonFileName && !quizData) {
      loadQuiz();
    }
  }, [isOpen, lessonFileName, quizData]);

  const loadQuiz = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/lessons/${encodeURIComponent(lessonFileName)}/quiz`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        setQuizData(data);
      } else {
        alert('Không thể tải quiz');
      }
    } catch (error) {
      console.error('Error loading quiz:', error);
      alert('Lỗi khi tải quiz');
    } finally {
      setLoading(false);
    }
  };

  const handleAnswerSelect = (questionId, optionIndex) => {
    if (!isSubmitted) {
      setSelectedAnswers({
        ...selectedAnswers,
        [questionId]: optionIndex
      });
    }
  };

  const handleSubmit = async () => {
    // Check if all questions are answered
    const unanswered = quizData.questions.filter(q => selectedAnswers[q.id] === undefined);
    if (unanswered.length > 0) {
      alert(`Bạn chưa trả lời ${unanswered.length} câu hỏi!`);
      return;
    }

    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      const submitUrl = `/api/lessons/${encodeURIComponent(lessonFileName)}/quiz/submit`;
      console.log('Submitting quiz to:', submitUrl);
      console.log('Selected answers:', selectedAnswers);
      
      const response = await fetch(submitUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(selectedAnswers)
      });

      console.log('Response status:', response.status);
      
      if (response.ok) {
        const data = await response.json();
        console.log('Quiz result:', data);
        setResults(data);
        setIsSubmitted(true);
        
        // Notify parent component
        if (onQuizComplete) {
          onQuizComplete(data);
        }
      } else {
        const errorText = await response.text();
        console.error('Submit error:', response.status, errorText);
        alert(`Không thể nộp bài quiz: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      console.error('Error submitting quiz:', error);
      alert(`Lỗi khi nộp bài: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setQuizData(null);
    setCurrentQuestion(0);
    setSelectedAnswers({});
    setIsSubmitted(false);
    setResults(null);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="quiz-modal-overlay" onClick={handleClose}>
      <div className="quiz-modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="quiz-modal-header">
          <h2>{lessonTitle} - Quiz</h2>
          <button className="quiz-close-btn" onClick={handleClose}>
            <X size={24} />
          </button>
        </div>

        <div className="quiz-modal-body">
          {loading && <div className="quiz-loading">Đang tải...</div>}

          {!loading && !isSubmitted && quizData && (
            <>
              <div className="quiz-progress">
                <div className="progress-text">
                  Câu {currentQuestion + 1} / {quizData.questions.length}
                </div>
                <div className="progress-bar">
                  <div 
                    className="progress-fill" 
                    style={{ width: `${((currentQuestion + 1) / quizData.questions.length) * 100}%` }}
                  />
                </div>
              </div>

              <div className="quiz-question">
                <h3>{quizData.questions[currentQuestion].question}</h3>
                <div className="quiz-options">
                  {quizData.questions[currentQuestion].options.map((option, index) => (
                    <button
                      key={index}
                      className={`quiz-option ${selectedAnswers[quizData.questions[currentQuestion].id] === index ? 'selected' : ''}`}
                      onClick={() => handleAnswerSelect(quizData.questions[currentQuestion].id, index)}
                    >
                      <span className="option-letter">{String.fromCharCode(65 + index)}</span>
                      <span className="option-text">{option}</span>
                    </button>
                  ))}
                </div>
              </div>

              <div className="quiz-navigation">
                <button
                  className="nav-btn"
                  onClick={() => setCurrentQuestion(Math.max(0, currentQuestion - 1))}
                  disabled={currentQuestion === 0}
                >
                  ← Câu trước
                </button>
                
                {currentQuestion === quizData.questions.length - 1 ? (
                  <button className="submit-btn" onClick={handleSubmit}>
                    Nộp bài
                  </button>
                ) : (
                  <button
                    className="nav-btn"
                    onClick={() => setCurrentQuestion(Math.min(quizData.questions.length - 1, currentQuestion + 1))}
                  >
                    Câu tiếp →
                  </button>
                )}
              </div>

              <div className="answered-count">
                Đã trả lời: {Object.keys(selectedAnswers).length} / {quizData.questions.length}
              </div>
            </>
          )}

          {!loading && isSubmitted && results && (
            <div className="quiz-results">
              <div className={`results-header ${results.passed ? 'passed' : 'failed'}`}>
                <Award size={64} />
                <h2>{results.message}</h2>
                <div className="score-display">
                  <div className="score-large">{results.score}%</div>
                  <div className="score-detail">
                    {results.correct_count} / {results.total_questions} câu đúng
                  </div>
                </div>
              </div>

              <div className="results-details">
                <h3>Chi tiết câu trả lời:</h3>
                {results.results.map((result, index) => (
                  <div key={index} className={`result-item ${result.is_correct ? 'correct' : 'incorrect'}`}>
                    <div className="result-question">
                      <span className="result-icon">
                        {result.is_correct ? <CheckCircle size={20} /> : <XCircle size={20} />}
                      </span>
                      <span>Câu {index + 1}: {result.question}</span>
                    </div>
                    
                    {!result.is_correct && result.options && result.user_answer !== undefined && result.correct_answer !== undefined && (
                      <div className="result-answers">
                        <div className="user-answer-info">
                          <strong>Bạn đã chọn:</strong> {String.fromCharCode(65 + result.user_answer)}. {result.options[result.user_answer]}
                        </div>
                        <div className="correct-answer-info">
                          <strong>Đáp án đúng:</strong> {String.fromCharCode(65 + result.correct_answer)}. {result.options[result.correct_answer]}
                        </div>
                      </div>
                    )}
                    
                    {!result.is_correct && result.explanation && (
                      <div className="result-explanation">
                        <strong>Giải thích:</strong> {result.explanation}
                      </div>
                    )}
                  </div>
                ))}
              </div>

              <button className="close-results-btn" onClick={handleClose}>
                Đóng
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default QuizModal;
