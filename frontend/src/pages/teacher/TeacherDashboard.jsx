import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import teacherAPI from '../../services/teacherAPI';
import './TeacherDashboard.css';

const TeacherDashboard = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('overview');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // States
  const [teacherData, setTeacherData] = useState(null);
  const [courses, setCourses] = useState([]);
  const [students, setStudents] = useState([]);
  const [pendingApprovals, setPendingApprovals] = useState([]);
  
  // Form states
  const [showCreateCourse, setShowCreateCourse] = useState(false);
  const [showUploadLesson, setShowUploadLesson] = useState(false);
  const [showCreateQuiz, setShowCreateQuiz] = useState(false);
  const [selectedCourse, setSelectedCourse] = useState(null);

  // Form data
  const [courseForm, setCourseForm] = useState({
    title: '',
    description: '',
    category: 'programming'
  });

  const [lessonForm, setLessonForm] = useState({
    title: '',
    description: '',
    course_id: '',
    file: null,
    video_url: ''
  });

  const [quizForm, setQuizForm] = useState({
    title: '',
    description: '',
    course_id: '',
    docx_file: null
  });

  // Fetch teacher data
  useEffect(() => {
    fetchTeacherData();
  }, []);

  const fetchTeacherData = async () => {
    try {
      setLoading(true);
      const [teacherRes, coursesRes, studentsRes, approvalsRes] = await Promise.all([
        teacherAPI.getProfile(),
        teacherAPI.getCourses(),
        teacherAPI.getStudents(),
        teacherAPI.getPendingApprovals()
      ]);

      setTeacherData(teacherRes);
      setCourses(coursesRes);
      setStudents(studentsRes);
      setPendingApprovals(approvalsRes);
    } catch (err) {
      setError(err.message || 'Không thể tải dữ liệu');
      console.error('Error fetching teacher data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Handle create course
  const handleCreateCourse = async (e) => {
    e.preventDefault();
    try {
      const response = await teacherAPI.createCourse(courseForm);
      setCourses([...courses, response]);
      setShowCreateCourse(false);
      setCourseForm({ title: '', description: '', category: 'programming' });
      alert('Tạo khóa học thành công!');
    } catch (err) {
      alert(err.message || 'Lỗi tạo khóa học');
    }
  };

  // Handle upload lesson
  const handleUploadLesson = async (e) => {
    e.preventDefault();
    try {
      await teacherAPI.createLesson(lessonForm);
      setShowUploadLesson(false);
      setLessonForm({ title: '', description: '', course_id: '', file: null, video_url: '' });
      alert('Upload bài học thành công!');
      fetchTeacherData();
    } catch (err) {
      alert(err.message || 'Lỗi upload bài học');
    }
  };

  // Handle create quiz from DOCX
  const handleCreateQuiz = async (e) => {
    e.preventDefault();
    try {
      await teacherAPI.createQuizFromDocx(quizForm);
      setShowCreateQuiz(false);
      setQuizForm({ title: '', description: '', course_id: '', docx_file: null });
      alert('Tạo quiz thành công!');
      fetchTeacherData();
    } catch (err) {
      alert(err.message || 'Lỗi tạo quiz');
    }
  };

  // Handle approve student
  const handleApproveStudent = async (enrollmentId, approve) => {
    try {
      await teacherAPI.approveEnrollment(enrollmentId, approve);
      setPendingApprovals(pendingApprovals.filter(e => e.id !== enrollmentId));
      alert(approve ? 'Đã duyệt sinh viên' : 'Đã từ chối sinh viên');
      fetchTeacherData();
    } catch (err) {
      alert(err.message || 'Lỗi xử lý yêu cầu');
    }
  };

  // Handle logout
  const handleLogout = () => {
    localStorage.removeItem('access_token');
    navigate('/login');
  };

  if (loading) {
    return (
      <div className="teacher-dashboard">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="teacher-dashboard">
        <div className="error-container">
          <h2>⚠️ Lỗi</h2>
          <p>{error}</p>
          <button onClick={fetchTeacherData} className="btn-primary">Thử lại</button>
        </div>
      </div>
    );
  }

  return (
    <div className="teacher-dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <div className="header-left">
            <h1>🎓 Teacher Dashboard</h1>
            <p className="welcome-text">
              Xin chào, <strong>{teacherData?.full_name || 'Giáo viên'}</strong>
            </p>
          </div>
          <div className="header-right">
            <button onClick={handleLogout} className="btn-logout">
              🚪 Đăng xuất
            </button>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <nav className="dashboard-nav">
        <button
          className={activeTab === 'overview' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('overview')}
        >
          📊 Tổng quan
        </button>
        <button
          className={activeTab === 'courses' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('courses')}
        >
          📚 Khóa học
        </button>
        <button
          className={activeTab === 'students' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('students')}
        >
          👥 Sinh viên
        </button>
        <button
          className={activeTab === 'approvals' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('approvals')}
        >
          ✅ Duyệt yêu cầu
          {pendingApprovals.length > 0 && (
            <span className="badge">{pendingApprovals.length}</span>
          )}
        </button>
        <button
          className="nav-tab essay-btn"
          onClick={() => navigate('/teacher/essays')}
        >
          📝 Chấm bài tự luận
        </button>
      </nav>

      {/* Main Content */}
      <main className="dashboard-content">
        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="overview-section">
            <h2>📊 Thống kê tổng quan</h2>
            <div className="stats-grid">
              <div className="stat-card">
                <div className="stat-icon">📚</div>
                <div className="stat-info">
                  <h3>{courses.length}</h3>
                  <p>Khóa học</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">👥</div>
                <div className="stat-info">
                  <h3>{students.length}</h3>
                  <p>Sinh viên</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">⏳</div>
                <div className="stat-info">
                  <h3>{pendingApprovals.length}</h3>
                  <p>Chờ duyệt</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">⭐</div>
                <div className="stat-info">
                  <h3>4.8</h3>
                  <p>Đánh giá TB</p>
                </div>
              </div>
            </div>

            <div className="quick-actions">
              <h3>🚀 Hành động nhanh</h3>
              <div className="action-buttons">
                <button
                  onClick={() => setShowCreateCourse(true)}
                  className="btn-action"
                >
                  ➕ Tạo khóa học mới
                </button>
                <button
                  onClick={() => setShowUploadLesson(true)}
                  className="btn-action"
                >
                  📤 Upload bài học
                </button>
                <button
                  onClick={() => setShowCreateQuiz(true)}
                  className="btn-action"
                >
                  📝 Tạo quiz
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Courses Tab */}
        {activeTab === 'courses' && (
          <div className="courses-section">
            <div className="section-header">
              <h2>📚 Quản lý khóa học</h2>
              <button
                onClick={() => setShowCreateCourse(true)}
                className="btn-primary"
              >
                ➕ Tạo khóa học mới
              </button>
            </div>

            {courses.length === 0 ? (
              <div className="empty-state">
                <p>📭 Chưa có khóa học nào</p>
                <button
                  onClick={() => setShowCreateCourse(true)}
                  className="btn-primary"
                >
                  Tạo khóa học đầu tiên
                </button>
              </div>
            ) : (
              <div className="courses-grid">
                {courses.map(course => (
                  <div key={course.id} className="course-card">
                    <div className="course-header">
                      <h3>{course.title}</h3>
                      <span className="course-code">Mã: {course.class_code}</span>
                    </div>
                    <p className="course-description">{course.description}</p>
                    <div className="course-stats">
                      <span>👥 {course.enrolled_count || 0} sinh viên</span>
                      <span>📖 {course.lessons_count || 0} bài học</span>
                    </div>
                    <div className="course-actions">
                      <button
                        onClick={() => setSelectedCourse(course)}
                        className="btn-secondary"
                      >
                        Xem chi tiết
                      </button>
                      <button className="btn-secondary">Chỉnh sửa</button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Students Tab */}
        {activeTab === 'students' && (
          <div className="students-section">
            <h2>👥 Danh sách sinh viên</h2>
            {students.length === 0 ? (
              <div className="empty-state">
                <p>📭 Chưa có sinh viên nào</p>
              </div>
            ) : (
              <div className="students-table">
                <table>
                  <thead>
                    <tr>
                      <th>Tên sinh viên</th>
                      <th>Email</th>
                      <th>Khóa học</th>
                      <th>Tiến độ</th>
                      <th>Điểm TB</th>
                      <th>Hành động</th>
                    </tr>
                  </thead>
                  <tbody>
                    {students.map(student => (
                      <tr key={student.id}>
                        <td>{student.full_name}</td>
                        <td>{student.email}</td>
                        <td>{student.course_title}</td>
                        <td>
                          <div className="progress-bar">
                            <div
                              className="progress-fill"
                              style={{ width: `${student.progress || 0}%` }}
                            ></div>
                            <span>{student.progress || 0}%</span>
                          </div>
                        </td>
                        <td>{student.average_score?.toFixed(1) || 'N/A'}</td>
                        <td>
                          <button className="btn-small">Xem chi tiết</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Approvals Tab */}
        {activeTab === 'approvals' && (
          <div className="approvals-section">
            <h2>✅ Duyệt yêu cầu tham gia</h2>
            {pendingApprovals.length === 0 ? (
              <div className="empty-state">
                <p>✅ Không có yêu cầu nào đang chờ duyệt</p>
              </div>
            ) : (
              <div className="approvals-list">
                {pendingApprovals.map(approval => (
                  <div key={approval.id} className="approval-card">
                    <div className="approval-info">
                      <h3>{approval.student_name}</h3>
                      <p>Email: {approval.student_email}</p>
                      <p>Khóa học: {approval.course_title}</p>
                      <p className="approval-date">
                        Yêu cầu lúc: {new Date(approval.created_at).toLocaleString('vi-VN')}
                      </p>
                    </div>
                    <div className="approval-actions">
                      <button
                        onClick={() => handleApproveStudent(approval.id, true)}
                        className="btn-approve"
                      >
                        ✅ Duyệt
                      </button>
                      <button
                        onClick={() => handleApproveStudent(approval.id, false)}
                        className="btn-reject"
                      >
                        ❌ Từ chối
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </main>

      {/* Modal: Create Course */}
      {showCreateCourse && (
        <div className="modal-overlay" onClick={() => setShowCreateCourse(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>➕ Tạo khóa học mới</h2>
            <form onSubmit={handleCreateCourse}>
              <div className="form-group">
                <label>Tên khóa học *</label>
                <input
                  type="text"
                  required
                  value={courseForm.title}
                  onChange={(e) => setCourseForm({...courseForm, title: e.target.value})}
                  placeholder="VD: Lập trình Python cơ bản"
                />
              </div>
              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={courseForm.description}
                  onChange={(e) => setCourseForm({...courseForm, description: e.target.value})}
                  placeholder="Mô tả về khóa học..."
                  rows="4"
                />
              </div>
              <div className="form-group">
                <label>Danh mục</label>
                <select
                  value={courseForm.category}
                  onChange={(e) => setCourseForm({...courseForm, category: e.target.value})}
                >
                  <option value="programming">Lập trình</option>
                  <option value="design">Thiết kế</option>
                  <option value="business">Kinh doanh</option>
                  <option value="language">Ngoại ngữ</option>
                  <option value="other">Khác</option>
                </select>
              </div>
              <div className="modal-actions">
                <button type="button" onClick={() => setShowCreateCourse(false)} className="btn-secondary">
                  Hủy
                </button>
                <button type="submit" className="btn-primary">
                  Tạo khóa học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Upload Lesson */}
      {showUploadLesson && (
        <div className="modal-overlay" onClick={() => setShowUploadLesson(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>📤 Upload bài học</h2>
            <form onSubmit={handleUploadLesson}>
              <div className="form-group">
                <label>Khóa học *</label>
                <select
                  required
                  value={lessonForm.course_id}
                  onChange={(e) => setLessonForm({...lessonForm, course_id: e.target.value})}
                >
                  <option value="">-- Chọn khóa học --</option>
                  {courses.map(course => (
                    <option key={course.id} value={course.id}>{course.title}</option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label>Tiêu đề bài học *</label>
                <input
                  type="text"
                  required
                  value={lessonForm.title}
                  onChange={(e) => setLessonForm({...lessonForm, title: e.target.value})}
                  placeholder="VD: Bài 1 - Giới thiệu Python"
                />
              </div>
              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={lessonForm.description}
                  onChange={(e) => setLessonForm({...lessonForm, description: e.target.value})}
                  placeholder="Mô tả bài học..."
                  rows="3"
                />
              </div>
              <div className="form-group">
                <label>Upload file tài liệu (PDF, DOCX, PPT...)</label>
                <input
                  type="file"
                  onChange={(e) => setLessonForm({...lessonForm, file: e.target.files[0]})}
                  accept=".pdf,.docx,.pptx,.txt"
                />
              </div>
              <div className="form-group">
                <label>Link video (YouTube, Vimeo...)</label>
                <input
                  type="url"
                  value={lessonForm.video_url}
                  onChange={(e) => setLessonForm({...lessonForm, video_url: e.target.value})}
                  placeholder="https://youtube.com/watch?v=..."
                />
              </div>
              <div className="modal-actions">
                <button type="button" onClick={() => setShowUploadLesson(false)} className="btn-secondary">
                  Hủy
                </button>
                <button type="submit" className="btn-primary">
                  Upload bài học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Create Quiz */}
      {showCreateQuiz && (
        <div className="modal-overlay" onClick={() => setShowCreateQuiz(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>📝 Tạo quiz từ file Word</h2>
            <form onSubmit={handleCreateQuiz}>
              <div className="form-group">
                <label>Khóa học *</label>
                <select
                  required
                  value={quizForm.course_id}
                  onChange={(e) => setQuizForm({...quizForm, course_id: e.target.value})}
                >
                  <option value="">-- Chọn khóa học --</option>
                  {courses.map(course => (
                    <option key={course.id} value={course.id}>{course.title}</option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label>Tiêu đề quiz *</label>
                <input
                  type="text"
                  required
                  value={quizForm.title}
                  onChange={(e) => setQuizForm({...quizForm, title: e.target.value})}
                  placeholder="VD: Quiz - Kiểm tra Python cơ bản"
                />
              </div>
              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={quizForm.description}
                  onChange={(e) => setQuizForm({...quizForm, description: e.target.value})}
                  placeholder="Mô tả quiz..."
                  rows="3"
                />
              </div>
              <div className="form-group">
                <label>Upload file Word (.docx) *</label>
                <input
                  type="file"
                  required
                  onChange={(e) => setQuizForm({...quizForm, docx_file: e.target.files[0]})}
                  accept=".docx"
                />
                <small>File Word cần có định dạng câu hỏi chuẩn</small>
              </div>
              <div className="modal-actions">
                <button type="button" onClick={() => setShowCreateQuiz(false)} className="btn-secondary">
                  Hủy
                </button>
                <button type="submit" className="btn-primary">
                  Tạo quiz
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default TeacherDashboard;