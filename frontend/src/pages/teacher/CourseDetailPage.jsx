import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, BookOpen, FileText, GraduationCap, Layers3, Pencil, Plus, Trash2, Video } from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './CourseDetailPage.css';

const getFileKindLabel = (fileKind) => {
  if (fileKind === 'pdf') return 'PDF';
  if (fileKind === 'doc' || fileKind === 'docx') return 'Word';
  if (fileKind === 'ppt' || fileKind === 'pptx') return 'PowerPoint';
  return 'Tài liệu';
};

const getLessonActivityLabel = (activityType) => {
  if (activityType === 'essay') return 'Tự luận';
  return 'Quiz';
};

const CourseDetailPage = () => {
  const navigate = useNavigate();
  const { courseId } = useParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [detail, setDetail] = useState(null);
  const [showEditModal, setShowEditModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [courseForm, setCourseForm] = useState({ title: '', description: '', category: 'programming' });

  const fetchDetail = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await teacherAPI.getCourseDetail(courseId);
      setDetail(response);
      setCourseForm({
        title: response?.course?.title || '',
        description: response?.course?.description || '',
        category: response?.course?.category || 'programming'
      });
    } catch (err) {
      setError(err.message || 'Không thể tải chi tiết khóa học');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDetail();
  }, [courseId]);

  const handleUpdateCourse = async (event) => {
    event.preventDefault();
    try {
      setSaving(true);
      await teacherAPI.updateCourse(courseId, courseForm);
      setShowEditModal(false);
      await fetchDetail();
    } catch (err) {
      setError(err.message || 'Không thể cập nhật khóa học');
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteCourse = async () => {
    const confirmed = window.confirm('Xóa khóa học này sẽ xóa luôn bài học và quiz liên quan. Bạn có chắc chắn không?');
    if (!confirmed) {
      return;
    }

    try {
      setSaving(true);
      await teacherAPI.deleteCourse(courseId);
      navigate('/teacher/content');
    } catch (err) {
      setError(err.message || 'Không thể xóa khóa học');
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <TeacherLayout>
        <div className="teacher-course-detail-page">
          <div className="teacher-course-detail-state">Đang tải chi tiết khóa học...</div>
        </div>
      </TeacherLayout>
    );
  }

  if (error) {
    return (
      <TeacherLayout>
        <div className="teacher-course-detail-page">
          <div className="teacher-course-detail-state error">{error}</div>
        </div>
      </TeacherLayout>
    );
  }

  const course = detail?.course || {};
  const lessons = detail?.lessons || [];
  const quizzes = detail?.quizzes || [];

  return (
    <TeacherLayout>
      <div className="teacher-course-detail-page">
        <div className="teacher-course-detail-header">
          <button className="back-button" onClick={() => navigate('/teacher/content')}>
            <ArrowLeft size={18} />
            Quay lại quản lý nội dung
          </button>

          <div className="teacher-course-detail-title">
            <div>
              <span className="course-kicker">Khóa học giảng viên</span>
              <h1>{course.title}</h1>
              <p>{course.description || 'Chưa có mô tả cho khóa học này.'}</p>
            </div>
            <div className="teacher-course-actions">
              <button className="secondary-button" onClick={() => setShowEditModal(true)}>
                <Pencil size={18} />
                Sửa khóa học
              </button>
              <button className="secondary-button" onClick={() => navigate(`/teacher/courses/${courseId}/quizzes`)}>
                <BookOpen size={18} />
                Quản lý quiz
              </button>
              <button className="essay-button" onClick={() => navigate(`/teacher/courses/${courseId}/essays`)}>
                <FileText size={18} />
                Mở khu vực chấm bài
              </button>
              <button className="danger-button" onClick={handleDeleteCourse} disabled={saving}>
                <Trash2 size={18} />
                Xóa khóa học
              </button>
            </div>
          </div>
        </div>

        <div className="teacher-course-stats-grid">
          <div className="stat-card">
            <BookOpen size={20} />
            <div>
              <span>Mã khóa học</span>
              <strong>{course.class_code || course.course_code}</strong>
            </div>
          </div>
          <div className="stat-card">
            <GraduationCap size={20} />
            <div>
              <span>Sinh viên ghi danh</span>
              <strong>{detail?.enrolled_students || 0}</strong>
            </div>
          </div>
          <div className="stat-card">
            <Layers3 size={20} />
            <div>
              <span>Bài học</span>
              <strong>{lessons.length}</strong>
            </div>
          </div>
          <div className="stat-card">
            <FileText size={20} />
            <div>
              <span>Quiz</span>
              <strong>{quizzes.length}</strong>
            </div>
          </div>
        </div>

        <div className="teacher-course-content-grid">
          <section className="detail-panel">
            <div className="panel-header">
              <h2>Danh sách bài học</h2>
              <span>{lessons.length} mục</span>
            </div>

            {lessons.length === 0 ? (
              <div className="empty-panel">
                <Plus size={18} />
                Chưa có bài học nào cho khóa học này.
              </div>
            ) : (
              <div className="lesson-list">
                {lessons.map((lesson) => (
                  <article key={lesson.id} className="lesson-item">
                    <div className="lesson-item-header">
                      <div className="lesson-meta">
                        <span className="lesson-order">Bài {lesson.order || lesson.id}</span>
                        {lesson.video_url ? <span className="lesson-tag"><Video size={14} /> Có video</span> : null}
                        {lesson.file_name ? <span className="lesson-tag"><FileText size={14} /> {getFileKindLabel(lesson.file_kind)}</span> : null}
                        <span className="lesson-tag quiz-tag">{getLessonActivityLabel(lesson.activity_type)}</span>
                        {lesson.activity_type === 'quiz' ? <span className="lesson-tag quiz-tag">{lesson.quiz_count || 0} quiz</span> : null}
                      </div>
                      <button
                        className="secondary-button lesson-quiz-button"
                        onClick={() => navigate(lesson.activity_type === 'essay' ? `/teacher/courses/${courseId}/essays` : `/teacher/courses/${courseId}/quizzes?lessonId=${lesson.id}`)}
                      >
                        {lesson.activity_type === 'essay' ? <FileText size={16} /> : <BookOpen size={16} />}
                        {lesson.activity_type === 'essay' ? 'Chấm tự luận' : 'Quản lý quiz'}
                      </button>
                    </div>
                    <h3>{lesson.title}</h3>
                    <p>{lesson.description || 'Chưa có mô tả bài học.'}</p>
                    {lesson.activity_type === 'essay' && lesson.essay_prompt ? <div className="quiz-linked-lesson">Yêu cầu: {lesson.essay_prompt}</div> : null}
                    {lesson.file_name ? <div className="lesson-file-name">Tệp: {lesson.file_name}</div> : null}
                  </article>
                ))}
              </div>
            )}
          </section>

          <section className="detail-panel">
            <div className="panel-header">
              <h2>Quiz và bài đánh giá</h2>
              <span>{quizzes.length} mục</span>
            </div>

            {quizzes.length === 0 ? (
              <div className="empty-panel">
                <Plus size={18} />
                Chưa có quiz nào được tạo cho khóa học này.
              </div>
            ) : (
              <div className="quiz-list">
                {quizzes.map((quiz) => (
                  <article key={quiz.id} className="quiz-item">
                    <div className="quiz-status-row">
                      <strong>{quiz.title}</strong>
                      <span className={`quiz-status ${quiz.is_published ? 'published' : 'draft'}`}>
                        {quiz.is_published ? 'Đã phát hành' : 'Bản nháp'}
                      </span>
                    </div>
                    <p>{quiz.description || 'Quiz này chưa có mô tả.'}</p>
                    {quiz.lesson_title ? <div className="quiz-linked-lesson">Gắn với: {quiz.lesson_title}</div> : null}
                    <div className="quiz-meta">
                      <span>{quiz.questions_count || 0} câu hỏi</span>
                      <span>Điểm tối đa: {quiz.max_score || 0}</span>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        </div>

        {showEditModal && (
          <div className="modal-overlay" onClick={() => setShowEditModal(false)}>
            <div className="course-edit-modal" onClick={(event) => event.stopPropagation()}>
              <div className="panel-header">
                <h2>Cập nhật khóa học</h2>
                <span>Điều chỉnh thông tin cơ bản</span>
              </div>

              <form className="course-edit-form" onSubmit={handleUpdateCourse}>
                <label>
                  Tên khóa học
                  <input
                    type="text"
                    value={courseForm.title}
                    onChange={(event) => setCourseForm((current) => ({ ...current, title: event.target.value }))}
                    required
                  />
                </label>
                <label>
                  Mô tả
                  <textarea
                    rows="4"
                    value={courseForm.description}
                    onChange={(event) => setCourseForm((current) => ({ ...current, description: event.target.value }))}
                  />
                </label>
                <label>
                  Danh mục
                  <select
                    value={courseForm.category}
                    onChange={(event) => setCourseForm((current) => ({ ...current, category: event.target.value }))}
                  >
                    <option value="programming">Lập trình</option>
                    <option value="design">Thiết kế</option>
                    <option value="business">Kinh doanh</option>
                    <option value="marketing">Marketing</option>
                    <option value="other">Khác</option>
                  </select>
                </label>

                <div className="course-edit-actions">
                  <button type="button" className="secondary-button" onClick={() => setShowEditModal(false)}>
                    Hủy
                  </button>
                  <button type="submit" className="essay-button" disabled={saving}>
                    {saving ? 'Đang lưu...' : 'Lưu thay đổi'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </TeacherLayout>
  );
};

export default CourseDetailPage;