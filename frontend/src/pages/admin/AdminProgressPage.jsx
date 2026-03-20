import { useState, useEffect } from 'react';
import { 
  Users, Search, GraduationCap, CheckCircle, 
  RotateCcw, Loader, AlertCircle, ChevronDown,
  BookOpen, Award, Eye, Zap, X, FileText
} from 'lucide-react';
import { buildApiUrl } from '../../config/api';
import Loading from '../../components/common/Loading';
import './AdminProgressPage.css';

const AdminProgressPage = () => {
  const [students, setStudents] = useState([]);
  const [allCourses, setAllCourses] = useState([]);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [enrollments, setEnrollments] = useState([]);
  const [curriculum, setCurriculum] = useState(null);
  const [loading, setLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [message, setMessage] = useState(null);
  const [courseDetail, setCourseDetail] = useState(null);
  const [showCourseModal, setShowCourseModal] = useState(false);
  const [adminAverageScore, setAdminAverageScore] = useState('8.0');
  const [selectedCourseId, setSelectedCourseId] = useState('');

  const getValidatedScore = () => {
    const score = Number.parseFloat(adminAverageScore);
    if (Number.isNaN(score)) return null;
    if (score < 0 || score > 10) return null;
    return Number(score.toFixed(2));
  };

  const getApiErrorText = (error) => {
    if (typeof error?.detail === 'string') return error.detail;
    if (Array.isArray(error?.detail)) return error.detail.map((e) => e.msg).join(', ');
    return 'Có lỗi xảy ra';
  };

  useEffect(() => {
    fetchStudents();
    fetchCurriculum();
    fetchAllCourses();
  }, []);

  const fetchStudents = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(buildApiUrl('/admin/students'), {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setStudents(data);
      }
    } catch (err) {
      console.error('Error fetching students:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCurriculum = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(buildApiUrl('/curriculum/cnpm'), {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setCurriculum(data);
      }
    } catch (err) {
      console.error('Error fetching curriculum:', err);
    }
  };

  const fetchAllCourses = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(buildApiUrl('/admin/courses'), {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setAllCourses(Array.isArray(data) ? data : []);
      }
    } catch (err) {
      console.error('Error fetching all courses:', err);
    }
  };

  const fetchStudentEnrollments = async (studentId) => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(buildApiUrl(`/admin/students/${studentId}/enrollments`), {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setEnrollments(data.enrollments || []);
      }
    } catch (err) {
      console.error('Error fetching enrollments:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectStudent = (student) => {
    setSelectedStudent(student);
    fetchStudentEnrollments(student.id);
    setMessage(null);
  };

  const handleCompletePhase = async (phaseId, phaseName) => {
    if (!selectedStudent) return;

    const score = getValidatedScore();
    if (score === null) {
      setMessage({ type: 'error', text: 'Điểm trung bình phải nằm trong khoảng 0 đến 10.' });
      return;
    }
    
    const confirm = window.confirm(`Xác nhận hoàn thành giai đoạn "${phaseName}" cho sinh viên ${selectedStudent.full_name} với điểm ${score.toFixed(2)}?`);
    if (!confirm) return;

    try {
      setActionLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/admin/students/${selectedStudent.id}/complete-phase/${phaseId}?score=${score}`),
        {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      if (response.ok) {
        const result = await response.json();
        setMessage({ type: 'success', text: result.message });
        fetchStudentEnrollments(selectedStudent.id);
      } else {
        const error = await response.json();
        setMessage({ type: 'error', text: getApiErrorText(error) });
      }
    } catch (err) {
      setMessage({ type: 'error', text: 'Không thể kết nối server' });
    } finally {
      setActionLoading(false);
    }
  };

  const handleCompleteCourse = async (courseId, courseName) => {
    if (!selectedStudent) return;

    const score = getValidatedScore();
    if (score === null) {
      setMessage({ type: 'error', text: 'Điểm trung bình phải nằm trong khoảng 0 đến 10.' });
      return;
    }

    try {
      setActionLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/admin/students/${selectedStudent.id}/complete-course/${courseId}?score=${score}`),
        {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      if (response.ok) {
        const result = await response.json();
        setMessage({ type: 'success', text: result.message });
        fetchStudentEnrollments(selectedStudent.id);
      } else {
        const error = await response.json();
        setMessage({ type: 'error', text: getApiErrorText(error) });
      }
    } catch (err) {
      setMessage({ type: 'error', text: 'Không thể kết nối server' });
    } finally {
      setActionLoading(false);
    }
  };

  const handleCompleteSelectedCourse = async () => {
    if (!selectedStudent) return;
    if (!selectedCourseId) {
      setMessage({ type: 'error', text: 'Vui lòng chọn môn học cần cập nhật tiến độ.' });
      return;
    }

    const selectedCourse = allCourses.find((course) => String(course.id) === String(selectedCourseId));
    if (!selectedCourse) {
      setMessage({ type: 'error', text: 'Không tìm thấy môn học đã chọn.' });
      return;
    }

    await handleCompleteCourse(selectedCourse.id, selectedCourse.course_name);
  };

  // Fetch course lessons detail
  const fetchCourseDetail = async (courseId) => {
    if (!selectedStudent) return;
    
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/admin/students/${selectedStudent.id}/courses/${courseId}/lessons`),
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      if (response.ok) {
        const data = await response.json();
        setCourseDetail(data);
        setShowCourseModal(true);
      } else {
        setMessage({ type: 'error', text: 'Không thể tải chi tiết môn học' });
      }
    } catch (err) {
      setMessage({ type: 'error', text: 'Không thể kết nối server' });
    } finally {
      setLoading(false);
    }
  };

  // Auto-complete all quizzes in a course
  const handleCompleteAllQuizzes = async (courseId) => {
    if (!selectedStudent) return;
    
    const confirm = window.confirm(`Xác nhận hoàn thành TẤT CẢ bài quiz với điểm tối đa cho môn học này?`);
    if (!confirm) return;

    try {
      setActionLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/admin/students/${selectedStudent.id}/courses/${courseId}/complete-all-quizzes?score=100`),
        {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      if (response.ok) {
        const result = await response.json();
        setMessage({ type: 'success', text: result.message });
        // Refresh data
        fetchStudentEnrollments(selectedStudent.id);
        fetchCourseDetail(courseId);
      } else {
        const error = await response.json();
        const errorText = typeof error.detail === 'string' 
          ? error.detail 
          : Array.isArray(error.detail) 
            ? error.detail.map(e => e.msg).join(', ')
            : 'Có lỗi xảy ra';
        setMessage({ type: 'error', text: errorText });
      }
    } catch (err) {
      setMessage({ type: 'error', text: 'Không thể kết nối server' });
    } finally {
      setActionLoading(false);
    }
  };

  const handleResetProgress = async () => {
    if (!selectedStudent) return;
    
    const confirm = window.confirm(`⚠️ Xác nhận XÓA TOÀN BỘ tiến độ học tập của sinh viên ${selectedStudent.full_name}?`);
    if (!confirm) return;

    try {
      setActionLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/admin/students/${selectedStudent.id}/reset-progress`),
        {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      if (response.ok) {
        const result = await response.json();
        setMessage({ type: 'success', text: result.message });
        setEnrollments([]);
      } else {
        const error = await response.json();
        const errorText = typeof error.detail === 'string' 
          ? error.detail 
          : Array.isArray(error.detail) 
            ? error.detail.map(e => e.msg).join(', ')
            : 'Có lỗi xảy ra';
        setMessage({ type: 'error', text: errorText });
      }
    } catch (err) {
      setMessage({ type: 'error', text: 'Không thể kết nối server' });
    } finally {
      setActionLoading(false);
    }
  };

  const handleAssistGraduation = async () => {
    if (!selectedStudent) return;

    const score = getValidatedScore();
    if (score === null) {
      setMessage({ type: 'error', text: 'Điểm trung bình phải nằm trong khoảng 0 đến 10.' });
      return;
    }

    const phases = curriculum?.phases || [];
    if (!phases.length) {
      setMessage({ type: 'error', text: 'Chưa có dữ liệu lộ trình để hỗ trợ tốt nghiệp.' });
      return;
    }

    const confirm = window.confirm(
      `Xác nhận hỗ trợ tốt nghiệp cho ${selectedStudent.full_name}?\n` +
      `Hệ thống sẽ hoàn thành tất cả giai đoạn với điểm trung bình ${score.toFixed(2)}.`
    );
    if (!confirm) return;

    try {
      setActionLoading(true);
      setMessage(null);

      const token = localStorage.getItem('token');
      for (const phase of phases) {
        const response = await fetch(
          buildApiUrl(`/admin/students/${selectedStudent.id}/complete-phase/${phase.id}?score=${score}`),
          {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` }
          }
        );

        if (!response.ok) {
          const error = await response.json();
          throw new Error(`Giai đoạn ${phase.id}: ${getApiErrorText(error)}`);
        }
      }

      setMessage({
        type: 'success',
        text: `Đã hỗ trợ hoàn thành tốt nghiệp cho ${selectedStudent.full_name} với điểm trung bình ${score.toFixed(2)}.`
      });
      fetchStudentEnrollments(selectedStudent.id);
    } catch (err) {
      setMessage({ type: 'error', text: err.message || 'Không thể hỗ trợ tốt nghiệp lúc này.' });
    } finally {
      setActionLoading(false);
    }
  };

  const isPhaseCompleted = (phaseId) => {
    if (!curriculum || !enrollments.length) return false;
    const phase = curriculum.phases?.find(p => p.id === phaseId);
    if (!phase) return false;
    
    // Support new structure with required_courses and elective_courses
    const requiredCourses = phase.required_courses || phase.courses || [];
    const electiveCourses = phase.elective_courses || [];
    const minElective = phase.elective_min_select || 0;
    
    // Check all required courses are completed
    const allRequiredCompleted = requiredCourses.every(code =>
      enrollments.some(e => e.course_code === code && e.status === 'completed')
    );
    
    // Check minimum electives are completed
    const completedElectives = electiveCourses.filter(code =>
      enrollments.some(e => e.course_code === code && e.status === 'completed')
    ).length;
    
    return allRequiredCompleted && completedElectives >= minElective;
  };

  const getPhaseProgress = (phaseId) => {
    if (!curriculum || !enrollments.length) return { completed: 0, total: 0, requiredCompleted: 0, electiveCompleted: 0 };
    const phase = curriculum.phases?.find(p => p.id === phaseId);
    if (!phase) return { completed: 0, total: 0, requiredCompleted: 0, electiveCompleted: 0 };
    
    const requiredCourses = phase.required_courses || phase.courses || [];
    const electiveCourses = phase.elective_courses || [];
    const minElective = phase.elective_min_select || 0;
    
    const requiredCompleted = requiredCourses.filter(code =>
      enrollments.some(e => e.course_code === code && e.status === 'completed')
    ).length;
    
    const electiveCompleted = electiveCourses.filter(code =>
      enrollments.some(e => e.course_code === code && e.status === 'completed')
    ).length;
    
    const total = requiredCourses.length + minElective;
    const completed = requiredCompleted + Math.min(electiveCompleted, minElective);
    
    return { 
      completed, 
      total,
      requiredCompleted,
      requiredTotal: requiredCourses.length,
      electiveCompleted,
      electiveMin: minElective
    };
  };

  const getPhaseCourses = (phase) => {
    const required = phase.required_courses || phase.courses || [];
    const elective = phase.elective_courses || [];
    return { required, elective };
  };

  const filteredStudents = students.filter(s => 
    s.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.student_id?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="admin-progress-page">
      <div className="page-header">
        <h1><GraduationCap size={28} /> Quản lý tiến độ sinh viên</h1>
        <p>Công cụ hỗ trợ test: Đánh dấu hoàn thành môn học / giai đoạn cho sinh viên</p>
      </div>

      <div className="content-grid">
        {/* Student List */}
        <div className="student-list-section">
          <div className="section-header">
            <h2><Users size={20} /> Danh sách sinh viên</h2>
          </div>
          
          <div className="search-box">
            <Search size={18} />
            <input
              type="text"
              placeholder="Tìm sinh viên..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          <div className="student-list">
            {loading && !selectedStudent ? (
              <Loading
                compact
                className="admin-progress-loading"
                title="Dang tai danh sach sinh vien"
                subtitle="Dang lay du lieu hoc vien va thong tin tien do de quan tri."
              />
            ) : (
              filteredStudents.map(student => (
                <div 
                  key={student.id}
                  className={`student-item ${selectedStudent?.id === student.id ? 'selected' : ''}`}
                  onClick={() => handleSelectStudent(student)}
                >
                  <div className="student-info">
                    <span className="student-name">{student.full_name}</span>
                    <span className="student-email">{student.email}</span>
                  </div>
                  <ChevronDown size={16} />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Progress Management */}
        <div className="progress-section">
          {selectedStudent ? (
            <>
              <div className="section-header">
                <div>
                  <h2>{selectedStudent.full_name}</h2>
                  <p>{selectedStudent.email}</p>
                </div>
                <button 
                  className="btn-danger"
                  onClick={handleResetProgress}
                  disabled={actionLoading}
                >
                  <RotateCcw size={16} />
                  Reset tiến độ
                </button>
              </div>

              {message && (
                <div className={`message ${message.type}`}>
                  {message.type === 'success' ? <CheckCircle size={18} /> : <AlertCircle size={18} />}
                  {message.text}
                </div>
              )}

              {/* Current Progress */}
              <div className="enrollments-summary">
                <h3><BookOpen size={18} /> Tiến độ hiện tại</h3>
                <div className="enrollment-stats">
                  <div className="stat">
                    <span className="value">{enrollments.length}</span>
                    <span className="label">Đã đăng ký</span>
                  </div>
                  <div className="stat">
                    <span className="value">{enrollments.filter(e => e.status === 'completed').length}</span>
                    <span className="label">Hoàn thành</span>
                  </div>
                </div>
              </div>

              <div className="graduation-assist-card">
                <h3><GraduationCap size={18} /> Hỗ trợ hoàn thành tốt nghiệp</h3>
                <p>Admin cấp điểm trung bình (thang 10) để hoàn thành toàn bộ giai đoạn cho sinh viên.</p>
                <div className="graduation-assist-controls">
                  <label htmlFor="admin-average-score">Điểm trung bình admin cấp</label>
                  <input
                    id="admin-average-score"
                    type="number"
                    min="0"
                    max="10"
                    step="0.1"
                    value={adminAverageScore}
                    onChange={(e) => setAdminAverageScore(e.target.value)}
                    disabled={actionLoading}
                  />
                  <button
                    className="btn-primary"
                    onClick={handleAssistGraduation}
                    disabled={actionLoading}
                  >
                    {actionLoading ? (
                      <>
                        <Loader size={16} className="spin" />
                        Đang xử lý...
                      </>
                    ) : (
                      <>
                        <GraduationCap size={16} />
                        Hỗ trợ tốt nghiệp theo điểm admin cấp
                      </>
                    )}
                  </button>
                </div>
              </div>

              <div className="graduation-assist-card">
                <h3><BookOpen size={18} /> Quản lý môn học bất kỳ</h3>
                <p>Admin có thể cập nhật tiến độ cho mọi môn trong hệ thống, kể cả môn do giảng viên khác tạo.</p>
                <div className="graduation-assist-controls">
                  <label htmlFor="admin-select-course">Chọn môn học</label>
                  <select
                    id="admin-select-course"
                    value={selectedCourseId}
                    onChange={(e) => setSelectedCourseId(e.target.value)}
                    disabled={actionLoading}
                  >
                    <option value="">-- Chọn môn học --</option>
                    {allCourses.map((course) => (
                      <option key={course.id} value={course.id}>
                        {course.course_code} - {course.course_name}
                        {course.teacher_name ? ` (GV: ${course.teacher_name})` : ''}
                      </option>
                    ))}
                  </select>
                  <button
                    className="btn-primary"
                    onClick={handleCompleteSelectedCourse}
                    disabled={actionLoading || !selectedCourseId}
                  >
                    {actionLoading ? (
                      <>
                        <Loader size={16} className="spin" />
                        Đang cập nhật...
                      </>
                    ) : (
                      <>
                        <CheckCircle size={16} />
                        Cập nhật tiến độ môn đã chọn
                      </>
                    )}
                  </button>
                </div>
              </div>

              {/* Phase Actions */}
              <div className="phases-section">
                <h3><Award size={18} /> Hoàn thành theo giai đoạn</h3>
                {curriculum?.phases?.map(phase => {
                  const progress = getPhaseProgress(phase.id);
                  const completed = isPhaseCompleted(phase.id);
                  const courses = getPhaseCourses(phase);
                  
                  return (
                    <div key={phase.id} className={`phase-card ${completed ? 'completed' : ''}`}>
                      <div className="phase-info">
                        <div className="phase-header">
                          <span className="phase-id">Giai đoạn {phase.id}</span>
                          <span className="phase-name">{phase.name}</span>
                        </div>
                        <div className="phase-progress">
                          {progress.completed}/{progress.total} môn hoàn thành
                        </div>
                        {courses.required.length > 0 && (
                          <div className="phase-courses required">
                            <strong>Bắt buộc ({progress.requiredCompleted}/{courses.required.length}):</strong> {courses.required.join(', ')}
                          </div>
                        )}
                        {courses.elective.length > 0 && (
                          <div className="phase-courses elective">
                            <strong>Tự chọn ({progress.electiveCompleted}/{progress.electiveMin}):</strong> {courses.elective.join(', ')}
                          </div>
                        )}
                      </div>
                      <button
                        className={`btn-complete ${completed ? 'completed' : ''}`}
                        onClick={() => handleCompletePhase(phase.id, phase.name)}
                        disabled={actionLoading || completed}
                      >
                        {completed ? (
                          <>
                            <CheckCircle size={16} />
                            Đã hoàn thành
                          </>
                        ) : (
                          <>
                            <GraduationCap size={16} />
                            Hoàn thành
                          </>
                        )}
                      </button>
                    </div>
                  );
                })}
              </div>

              {/* Completed Courses */}
              {enrollments.length > 0 && (
                <div className="completed-courses">
                  <h3><CheckCircle size={18} /> Các môn đã hoàn thành</h3>
                  <div className="course-grid">
                    {enrollments.filter(e => e.status === 'completed').map(e => (
                      <div key={e.id} className="course-badge">
                        <span className="code">{e.course_code}</span>
                        <span className="grade">{e.grade_letter}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* All Enrollments with Detail View */}
              {enrollments.length > 0 && (
                <div className="enrollments-detail">
                  <h3><FileText size={18} /> Chi tiết các môn học</h3>
                  <div className="enrollments-table">
                    <table>
                      <thead>
                        <tr>
                          <th>Mã môn</th>
                          <th>Tên môn</th>
                          <th>Tiến độ</th>
                          <th>Điểm</th>
                          <th>Trạng thái</th>
                          <th>Thao tác</th>
                        </tr>
                      </thead>
                      <tbody>
                        {enrollments.map(e => (
                          <tr key={e.id}>
                            <td><strong>{e.course_code}</strong></td>
                            <td>{e.course_name}</td>
                            <td>
                              <div className="progress-bar-small">
                                <div 
                                  className="progress-fill" 
                                  style={{ width: `${e.progress || 0}%` }}
                                />
                                <span>{e.progress || 0}%</span>
                              </div>
                            </td>
                            <td>{e.grade_letter || '-'}</td>
                            <td>
                              <span className={`status-tag ${e.status}`}>
                                {e.status === 'completed' ? 'Hoàn thành' : 'Đang học'}
                              </span>
                            </td>
                            <td>
                              <div className="action-buttons">
                                <button 
                                  className="btn-icon" 
                                  onClick={() => fetchCourseDetail(e.course_id)}
                                  title="Xem chi tiết bài học"
                                >
                                  <Eye size={16} />
                                </button>
                                <button 
                                  className="btn-icon success" 
                                  onClick={() => handleCompleteAllQuizzes(e.course_id)}
                                  disabled={actionLoading}
                                  title="Hoàn thành tất cả quiz với điểm tối đa"
                                >
                                  <Zap size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="no-selection">
              <Users size={48} />
              <p>Chọn một sinh viên để quản lý tiến độ</p>
            </div>
          )}
        </div>
      </div>

      {/* Course Detail Modal */}
      {showCourseModal && courseDetail && (
        <div className="modal-overlay" onClick={() => setShowCourseModal(false)}>
          <div className="modal-content course-detail-modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <div>
                <h2>{courseDetail.course_code} - {courseDetail.course_name}</h2>
                <p>Chi tiết bài học và quiz của {courseDetail.student_name}</p>
              </div>
              <button className="btn-close" onClick={() => setShowCourseModal(false)}>
                <X size={20} />
              </button>
            </div>
            
            <div className="modal-body">
              <div className="lessons-summary">
                <span>Tổng số bài: <strong>{courseDetail.total_lessons}</strong></span>
                <span>Đã hoàn thành: <strong>{courseDetail.lessons.filter(l => l.is_completed).length}</strong></span>
                <span>Có quiz: <strong>{courseDetail.lessons.filter(l => l.quiz_result).length}</strong></span>
              </div>
              
              <div className="lessons-list-detail">
                {courseDetail.lessons.map((lesson, index) => (
                  <div key={lesson.id} className={`lesson-item-detail ${lesson.is_completed ? 'completed' : ''}`}>
                    <div className="lesson-order">Bài {lesson.order || index + 1}</div>
                    <div className="lesson-info">
                      <h4>{lesson.title}</h4>
                      {lesson.quiz_result ? (
                        <div className={`quiz-status ${lesson.quiz_result.passed ? 'passed' : 'failed'}`}>
                          <CheckCircle size={14} />
                          <span>Quiz: {lesson.quiz_result.score}% ({lesson.quiz_result.correct_answers}/{lesson.quiz_result.total_questions})</span>
                        </div>
                      ) : (
                        <div className="quiz-status pending">
                          <AlertCircle size={14} />
                          <span>Chưa làm quiz</span>
                        </div>
                      )}
                    </div>
                    <div className="lesson-status-icon">
                      {lesson.is_completed ? (
                        <CheckCircle size={20} className="icon-success" />
                      ) : (
                        <div className="icon-pending" />
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
            
            <div className="modal-footer">
              <button 
                className="btn-primary"
                onClick={() => handleCompleteAllQuizzes(courseDetail.course_id)}
                disabled={actionLoading}
              >
                <Zap size={18} />
                {actionLoading ? 'Đang xử lý...' : 'Hoàn thành tất cả Quiz (100%)'}
              </button>
              <button className="btn-secondary" onClick={() => setShowCourseModal(false)}>
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminProgressPage;
