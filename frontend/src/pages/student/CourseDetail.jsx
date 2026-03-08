import { useState, useEffect } from 'react';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import {
  ChevronLeft, CheckCircle, Clock,
  Play, MessageSquare, Loader2, BookOpen
} from 'lucide-react';
import './CourseDetail.css';

const CourseDetail = () => {
  const navigate = useNavigate();
  const { courseId } = useParams();
  const location = useLocation();
  const enrollmentState = location.state?.enrollment;

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [courseData, setCourseData] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [activeLesson, setActiveLesson] = useState(null);
  const [selectedLesson, setSelectedLesson] = useState(null);
  const [userProgress, setUserProgress] = useState(null);

  useEffect(() => {
    const fetchCourseDetails = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('token');
        
        // Fetch course details - uses /api/courses/{courseId} endpoint
        const courseResponse = await fetch(`http://localhost:8000/api/courses/${courseId}`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (!courseResponse.ok) throw new Error('Failed to fetch course');
        const data = await courseResponse.json();
        
        // Extract course info from response
        setCourseData(data.course);
        
        // Extract and set lessons from response
        const lessonsData = data.lessons || [];
        setLessons(lessonsData);
        
        // Set user progress
        setUserProgress(data.user_progress);
        
        // Set first lesson as active
        if (lessonsData.length > 0) {
          setActiveLesson(lessonsData[0]);
        }
      } catch (err) {
        console.error('Error fetching course details:', err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    if (courseId) {
      fetchCourseDetails();
    }
  }, [courseId]);

  if (loading) {
    return (
      <div className="course-detail-loading">
        <Loader2 className="animate-spin" />
        <p>Đang tải khóa học...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="course-detail-error">
        <p>Lỗi: {error}</p>
        <button onClick={() => navigate('/student/dashboard')}>Quay lại</button>
      </div>
    );
  }

  return (
    <div className="course-detail-container">
      {/* Header */}
      <div className="course-detail-header">
        <button 
          className="back-button"
          onClick={() => navigate('/student/dashboard')}
        >
          <ChevronLeft className="w-5 h-5" />
          Quay lại
        </button>
        <div className="course-header-info">
          <span className="course-code-badge">{courseData?.course_code}</span>
          <h1>{courseData?.course_name}</h1>
          {userProgress && (
            <div className="enrollment-info">
              <span className="progress-percent">{userProgress.progress_percent}% hoàn thành</span>
              <span className="progress-lessons">
                <BookOpen className="w-4 h-4" />
                {userProgress.completed_lessons}/{userProgress.total_lessons} bài học
              </span>
            </div>
          )}
        </div>
      </div>

      <div className="course-detail-content">
        {/* Sidebar */}
        <div className="course-detail-sidebar">
          <div className="lessons-section">
            <h2>Bài học ({lessons.length})</h2>
            <div className="lessons-list">
              {lessons.map((lesson, index) => {
                const quizResult = lesson.quiz_result;
                const isCompleted = quizResult?.completed;
                const score = quizResult?.score;
                
                return (
                  <div
                    key={lesson.id || index}
                    className={`lesson-item ${activeLesson?.id === lesson.id ? 'active' : ''} ${isCompleted ? 'completed' : ''}`}
                    onClick={() => setActiveLesson(lesson)}
                  >
                    <div className="lesson-index">
                      {isCompleted ? (
                        <CheckCircle className="w-5 h-5 text-green-500" />
                      ) : (
                        <Play className="w-4 h-4" />
                      )}
                      <span className="lesson-number">{index + 1}</span>
                    </div>
                    <div className="lesson-info">
                      <div className="lesson-title">{lesson.title}</div>
                      {isCompleted && score !== null && (
                        <div className="lesson-score">
                          <span className="score-badge">{Math.round(score)}%</span>
                          <span className="score-detail">
                            {quizResult.correct_answers}/{quizResult.total_questions} câu đúng
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Main Content */}
        <div className="course-detail-main">
          {activeLesson ? (
            <div className="lesson-viewer">
              <div className="lesson-header">
                <h2>{activeLesson.title}</h2>
                <div className="lesson-meta">
                  <span><Clock className="w-4 h-4" /> {activeLesson.duration_minutes || '30'} phút</span>
                </div>
              </div>

              <div className="lesson-content">
                <div className="lesson-description">
                  <p>{activeLesson.content || activeLesson.description || 'Nội dung bài học'}</p>
                </div>

                <div className="lesson-actions">
                  <button className="btn-mark-complete">
                    <CheckCircle className="w-4 h-4" />
                    Đánh dấu hoàn thành
                  </button>
                  <button className="btn-discussion">
                    <MessageSquare className="w-4 h-4" />
                    Thảo luận
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="no-lesson">
              <p>Chọn một bài học để bắt đầu</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const PlayIcon = () => <Play className="w-4 h-4" />;

export default CourseDetail;
