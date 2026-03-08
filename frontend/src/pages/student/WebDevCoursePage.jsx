import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Clock, User, Star, Download, Play, CheckCircle, Lock, ArrowLeft } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import PDFViewer from '../../components/PDFViewer';
import './WebDevCoursePage.css';

const WebDevCoursePage = () => {
  const navigate = useNavigate();
  const [selectedLesson, setSelectedLesson] = useState(null);
  const [expandedLesson, setExpandedLesson] = useState(null);
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [showPDFViewer, setShowPDFViewer] = useState(false);
  const [currentPDFFile, setCurrentPDFFile] = useState(null);
  const [course, setCourse] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [userProgress, setUserProgress] = useState(null);
  const [loading, setLoading] = useState(true);

  // Fetch course data from API
  useEffect(() => {
    const fetchCourseData = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('token');
        const response = await fetch('http://localhost:8000/api/courses/1', {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (!response.ok) throw new Error('Failed to fetch course');
        const data = await response.json();
        
        setCourse(data.course);
        setLessons(data.lessons || []);
        setUserProgress(data.user_progress);
      } catch (error) {
        console.error('Error fetching course:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchCourseData();
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

  const handleLessonClick = (lesson) => {
    setSelectedLesson(lesson);
  };

  const handleExpandClick = (lessonId) => {
    setExpandedLesson(expandedLesson === lessonId ? null : lessonId);
  };

  const handleStartLesson = (lesson) => {
    // Hiển thị PDF viewer với file bài học
    if (lesson.pdf_file_name) {
      // Use the actual PDF file name from database
      const fileName = lesson.pdf_file_name;
      // Add timestamp to prevent browser cache issues
      const fileUrl = `http://localhost:8000/api/lessons/${encodeURIComponent(fileName)}?t=${Date.now()}`;
      setCurrentPDFFile({
        url: fileUrl,
        name: fileName
      });
      setShowPDFViewer(true);
    } else {
      console.error('No PDF file associated with this lesson');
      alert('Bài học này chưa có tài liệu PDF');
    }
  };

  if (loading) {
    return (
      <div className="web-dev-course-page">
        <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />
        <div className="course-main-wrapper">
          <div className="loading-state">Đang tải khóa học...</div>
        </div>
      </div>
    );
  }

  if (!course) {
    return (
      <div className="web-dev-course-page">
        <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />
        <div className="course-main-wrapper">
          <div className="error-state">Không tìm thấy khóa học</div>
        </div>
      </div>
    );
  }

  const handleProgressUpdate = () => {
    // Reload page data or refetch progress
    console.log('Progress updated - should reload data here');
    // In a real app, you would fetch updated enrollment data
    // For now, just log
  };

  return (
    <div className="web-dev-course-page">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="course-main-wrapper">
        {/* Header */}
        <div className="course-header">
          <div className="header-content">
            <div className="breadcrumb">
              <button 
                className="breadcrumb-back"
                onClick={() => navigate('/student/dashboard')}
                title="Quay lại dashboard"
              >
                <ArrowLeft size={18} />
              </button>
              <span>Trang chủ</span>
              <span className="separator">›</span>
              <span>Khóa học</span>
              <span className="separator">›</span>
              <span className="current">{course.title}</span>
            </div>
            
            <h1 className="course-title">{course.course_name}</h1>
            <p className="course-description">{course.description}</p>
            
            <div className="course-meta">
              <div className="meta-item">
                <User size={18} />
                <span>Giảng viên</span>
              </div>
              <div className="meta-item">
                <Clock size={18} />
                <span>{course.duration_weeks} tuần</span>
              </div>
              <div className="meta-item">
                <BookOpen size={18} />
                <span>{lessons.length} Bài học</span>
              </div>
              <div className="meta-item">
                <Star size={18} />
                <span>{course.level || 'Beginner'}</span>
              </div>
            </div>
          </div>
        </div>

      {/* Main Content */}
      <div className="course-container">
        {/* Lessons List - Left Side */}
        <div className="lessons-section">
          <div className="section-header">
            <h2>📚 Danh sách bài học ({lessons.length})</h2>
            <span className="section-info">Bấm để xem chi tiết</span>
          </div>

          <div className="lessons-grid">
            {lessons.map((lesson, index) => {
              const quizResult = lesson.quiz_result;
              const isCompleted = quizResult?.completed;
              const score = quizResult?.score;
              
              return (
                <div
                  key={lesson.id}
                  className={`lesson-card ${selectedLesson?.id === lesson.id ? 'active' : ''} ${isCompleted ? 'completed' : ''}`}
                >
                  <div className="lesson-card-header">
                    <div className="lesson-number-badge">
                      {isCompleted ? (
                        <CheckCircle size={20} className="completed-icon" />
                      ) : (
                        <span className="badge-text">Lecture {lesson.order || index}</span>
                      )}
                    </div>
                    <div className="lesson-info">
                      <h3 className="lesson-title">{lesson.title}</h3>
                      <p className="lesson-duration">
                        <Clock size={14} />
                        {lesson.duration_minutes} phút
                      </p>
                      {isCompleted && score !== null && (
                        <div className="lesson-score-inline">
                          <span className="score-badge">{Math.round(score)}%</span>
                          <span className="score-detail">
                            {quizResult.correct_answers}/{quizResult.total_questions} đúng
                          </span>
                        </div>
                      )}
                    </div>
                  </div>

                  <p className="lesson-description">{lesson.description}</p>

                  <div className="lesson-actions">
                    <button
                      className="btn-view"
                      onClick={() => handleLessonClick(lesson)}
                    >
                      <Play size={16} />
                      Xem chi tiết
                    </button>
                    <button
                      className="btn-expand"
                      onClick={() => handleExpandClick(lesson.id)}
                      title="Xem chủ đề"
                    >
                      {expandedLesson === lesson.id ? '▼' : '▶'}
                    </button>
                  </div>

                  {/* Expanded Topics */}
                  {expandedLesson === lesson.id && (
                    <div className="lesson-topics">
                      <h4>Nội dung bài học:</h4>
                      <p>{lesson.description}</p>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Selected Lesson Preview - Right Side */}
        <div className="lesson-preview-section">
          {selectedLesson ? (
            <div className="lesson-preview">
              <div className="preview-header">
                <div className="preview-badge">Lecture {selectedLesson.order}</div>
                <h2>{selectedLesson.title}</h2>
                <p className="preview-duration">
                  <Clock size={16} />
                  Thời lượng: {selectedLesson.duration_minutes} phút
                </p>
              </div>

              <div className="preview-content">
                <div className="preview-description">
                  <h3>📖 Mô tả bài học:</h3>
                  <p>{selectedLesson.description}</p>
                </div>

                <div className="preview-file">
                  <h3>📄 Tài liệu bài học:</h3>
                  <div className="file-info">
                    <BookOpen size={24} className="file-icon" />
                    <div className="file-details">
                      <p className="file-name">{selectedLesson.title}.pdf</p>
                      <p className="file-type">PDF Document</p>
                    </div>
                  </div>
                </div>

                {selectedLesson.quiz_result?.completed && (
                  <div className="preview-quiz-result">
                    <h3>✅ Kết quả quiz:</h3>
                    <div className="quiz-score-box">
                      <div className="score-large">{Math.round(selectedLesson.quiz_result.score)}%</div>
                      <p>{selectedLesson.quiz_result.correct_answers}/{selectedLesson.quiz_result.total_questions} câu trả lời đúng</p>
                    </div>
                  </div>
                )}

                <div className="preview-actions">
                  <button 
                    className="btn-start-lesson"
                    onClick={() => handleStartLesson(selectedLesson)}
                  >
                    <Play size={18} />
                    Bắt đầu bài học
                  </button>
                  {selectedLesson.quiz_result?.completed && (
                    <div className="completion-badge">
                      <CheckCircle size={18} />
                      <span>Đã hoàn thành</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div className="lesson-preview-empty">
              <BookOpen size={64} />
              <h2>Chọn một bài học</h2>
              <p>Bấm vào bất kỳ bài học nào ở bên trái để xem chi tiết</p>
            </div>
          )}
        </div>
      </div>

      {/* Progress Section */}
      <div className="course-progress-section">
        <h2>📊 Tiến độ học tập</h2>
        <div className="progress-stats">
          <div className="stat-box">
            <div className="stat-number">{userProgress?.completed_lessons || 0}</div>
            <p>Bài hoàn thành</p>
          </div>
          <div className="stat-box">
            <div className="stat-number">{userProgress?.total_lessons || lessons.length}</div>
            <p>Tổng bài</p>
          </div>
          <div className="stat-box">
            <div className="stat-percentage">{userProgress?.progress_percent || 0}%</div>
            <p>Hoàn thành khóa học</p>
          </div>
          <div className="stat-box">
            <div className="stat-number">0 giờ</div>
            <p>Thời gian học</p>
          </div>
        </div>
        <div className="progress-bar-container">
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${userProgress?.progress_percent || 0}%` }}
            ></div>
          </div>
          <p className="progress-text">
            {userProgress?.completed_lessons || 0} / {userProgress?.total_lessons || lessons.length} bài hoàn thành
          </p>
        </div>
      </div>
      </div>

      {/* PDF Viewer Modal */}
      {showPDFViewer && currentPDFFile && (
        <PDFViewer
          fileUrl={currentPDFFile.url}
          fileName={currentPDFFile.name}
          onClose={() => setShowPDFViewer(false)}
          onProgressUpdate={handleProgressUpdate}
        />
      )}
    </div>
  );
};

export default WebDevCoursePage;
