import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, BookOpen, Play, CheckCircle, Loader,
  AlertCircle, Home, Clock, GraduationCap
} from 'lucide-react';
import { buildApiUrl } from '../../config/api';
import './CourseLessonsPage.css';

const CourseLessonsPage = () => {
  const { courseId } = useParams();
  const navigate = useNavigate();

  const [course, setCourse] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [enrollment, setEnrollment] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchCourseAndLessons();
  }, [courseId]);

  const fetchCourseAndLessons = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const token = localStorage.getItem('token');
      
      // Fetch course info, lessons, and enrollment data
      console.log(`📚 [CourseLessonsPage] Fetching data for course ${courseId}...`);
      
      const [lessonsResponse, enrollmentResponse] = await Promise.all([
        fetch(buildApiUrl(`/courses/${courseId}/lessons`), {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }),
        fetch(buildApiUrl('/courses/my-courses'), {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        })
      ]);

      if (!lessonsResponse.ok) {
        throw new Error(`Failed to fetch lessons: ${lessonsResponse.status}`);
      }

      const lessonsData = await lessonsResponse.json();
      const enrollmentsData = await enrollmentResponse.json();
      
      console.log('✅ Lessons loaded:', lessonsData);
      console.log('✅ Enrollments loaded:', enrollmentsData);
      
      // Find enrollment for this course
      const currentEnrollment = enrollmentsData.find(e => e.course?.id === parseInt(courseId));
      console.log('Current enrollment:', currentEnrollment);
      
      setLessons(lessonsData);
      setEnrollment(currentEnrollment);
      
      // Extract course info from first lesson if available
      if (lessonsData.length > 0) {
        setCourse({
          id: courseId,
          name: lessonsData[0].course_name || currentEnrollment?.course?.course_name || 'Khoá học',
          totalLessons: lessonsData.length
        });
      }

    } catch (err) {
      console.error('Error fetching lessons:', err);
      setError(err.message || 'Không thể tải danh sách bài học');
    } finally {
      setLoading(false);
    }
  };

  const getProgressPercentage = () => {
    return enrollment?.progress || 0;
  };

  const getCompletedLessons = () => {
    const completedQuizLessons = lessons.filter((lesson) => lesson.quiz_result?.completed).length;
    return Math.max(enrollment?.completed_lessons || 0, completedQuizLessons);
  };

  const getTotalStudyTime = () => {
    const totalMinutes = lessons
      .filter((lesson) => lesson.quiz_result?.completed)
      .reduce((sum, l) => sum + (l.duration_minutes || 30), 0);
    
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return `${hours} giờ ${minutes > 0 ? minutes + ' phút' : ''}`;
    }
    return `${minutes} phút`;
  };

  if (loading) {
    return (
      <div className="course-lessons-page">
        <div className="loading-container">
          <Loader className="loading-spinner" size={48} />
          <p>Đang tải danh sách bài học...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="course-lessons-page">
        <div className="error-container">
          <AlertCircle size={48} />
          <h2>Không thể tải bài học</h2>
          <p>{error}</p>
          <button onClick={() => navigate('/student/courses')} className="btn-primary">
            <ArrowLeft size={18} />
            Quay lại danh sách khóa học
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="course-lessons-page">
      {/* Header */}
      <div className="lessons-header">
        <div className="header-top">
          <button onClick={() => navigate('/student/courses')} className="btn-back">
            <ArrowLeft size={20} />
            Quay lại
          </button>
          <button onClick={() => navigate('/student/dashboard')} className="btn-home">
            <Home size={20} />
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="lessons-container">
        {/* Course Info */}
        <div className="course-info-card">
          <div className="course-header">
            <h1>{course?.name}</h1>
            <div className="course-stats">
              <div className="stat">
                <BookOpen size={20} />
                <div>
                  <span className="stat-label">Tổng bài học</span>
                  <span className="stat-value">{lessons.length}</span>
                </div>
              </div>
              <div className="stat">
                <CheckCircle size={20} />
                <div>
                  <span className="stat-label">Hoàn thành</span>
                  <span className="stat-value">{getCompletedLessons()}/{lessons.length}</span>
                </div>
              </div>
              <div className="stat">
                <Clock size={20} />
                <div>
                  <span className="stat-label">Thời gian học</span>
                  <span className="stat-value">{getTotalStudyTime()}</span>
                </div>
              </div>
              <div className="stat">
                <GraduationCap size={20} />
                <div>
                  <span className="stat-label">Tiến độ</span>
                  <span className="stat-value">{Math.round(getProgressPercentage())}%</span>
                </div>
              </div>
            </div>
          </div>

          {/* Progress Bar */}
          <div className="progress-section">
            <div className="progress-header">
              <span>Tiến độ học tập</span>
              <span className="progress-text">{getProgressPercentage()}%</span>
            </div>
            <div className="progress-bar">
              <div 
                className="progress-fill" 
                style={{ width: `${getProgressPercentage()}%` }}
              />
            </div>
          </div>
        </div>

        {/* Lessons List */}
        <div className="lessons-list">
          <h2 className="lessons-title">Danh sách bài học</h2>
          
          {lessons.length === 0 ? (
            <div className="empty-state">
              <BookOpen size={48} />
              <p>Chưa có bài học nào trong khóa học này</p>
            </div>
          ) : (
            <div className="lessons-grid">
              {lessons.map((lesson, index) => {
                const quizResult = lesson.quiz_result;
                const isCompleted = Boolean(quizResult?.completed);
                const score = quizResult?.score;
                const passed = typeof score === 'number' ? score >= 70 : false;
                
                return (
                  <div key={lesson.id} className={`lesson-card ${isCompleted ? 'completed' : ''}`}>
                    <div className="lesson-number">Bài {lesson.order || index + 1}</div>
                    
                    <div className="lesson-content">
                      <h3 className="lesson-title">{lesson.title}</h3>
                      <p className="lesson-description">
                        {lesson.content || lesson.description || 'Nội dung sẽ được tải khi bắt đầu'}
                      </p>
                      
                      <div className="lesson-meta">
                        {lesson.has_quiz && (
                          <div className="meta-item">
                            <BookOpen size={16} />
                            <span>Có bài kiểm tra</span>
                          </div>
                        )}
                        {lesson.duration_minutes && (
                          <div className="meta-item">
                            <Clock size={16} />
                            <span>{lesson.duration_minutes} phút</span>
                          </div>
                        )}
                      </div>
                      
                      {isCompleted && (
                        <div className={`quiz-score ${passed ? 'passed' : 'failed'}`}>
                          <span className="score-label">Điểm quiz:</span>
                          <span className="score-value">{Math.round(score)}%</span>
                        </div>
                      )}
                    </div>

                    <div className="lesson-status">
                      {isCompleted ? (
                        <div className={`status-completed ${passed ? 'passed' : 'failed'}`}>
                          <CheckCircle size={20} />
                          <span>{passed ? 'Hoàn thành' : 'Chưa đạt'}</span>
                        </div>
                      ) : (
                        <span className="status-pending">Chưa làm</span>
                      )}
                    </div>

                    <button
                      onClick={() => navigate(`/student/courses/${courseId}/lessons/${lesson.id}`)}
                      className="btn-start"
                    >
                      {isCompleted ? (
                        <>
                          <CheckCircle size={18} />
                          Xem lại
                        </>
                      ) : (
                        <>
                          <Play size={18} />
                          Bắt đầu
                        </>
                      )}
                    </button>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default CourseLessonsPage;
