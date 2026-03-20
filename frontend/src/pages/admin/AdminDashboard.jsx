import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import adminAPI from '../../services/adminAPI';
import Loading from '../../components/common/Loading';
import './AdminDashboard.css';

const AdminDashboard = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('overview');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [overview, setOverview] = useState(null);
  const [teachers, setTeachers] = useState([]);
  const [students, setStudents] = useState([]);
  const [courses, setCourses] = useState([]);
  const [assessments, setAssessments] = useState([]);
  const [selectedCourse, setSelectedCourse] = useState(null);
  const [courseDetailLoading, setCourseDetailLoading] = useState(false);

  const [showCreateTeacher, setShowCreateTeacher] = useState(false);
  const [showCreateStudent, setShowCreateStudent] = useState(false);
  const [showCreateAssessment, setShowCreateAssessment] = useState(false);
  const [teacherFormMessage, setTeacherFormMessage] = useState(null);

  const [teacherForm, setTeacherForm] = useState({
    email: '',
    password: '',
    full_name: '',
    teacher_id: '',
    department: 'Khoa CNTT',
    position: '',
    phone: '',
    specialization: '',
    office_location: '',
    years_of_experience: ''
  });

  const [studentForm, setStudentForm] = useState({
    email: '',
    password: '',
    full_name: '',
    major: '',
    specialization: '',
    class_name: '',
    intake_year: '',
    phone: '',
    education_type: '0'
  });

  const [assessmentForm, setAssessmentForm] = useState({
    course_id: '',
    title: '',
    description: '',
    instructions: '',
    assessment_type: 'assignment',
    max_score: 10,
    weight: 1,
    due_date: '',
    start_date: '',
    duration_minutes: '',
    is_published: false,
    allow_late_submission: true,
    attachment: null
  });

  useEffect(() => {
    fetchAdminData();
  }, []);

  const fetchAdminData = async () => {
    try {
      setLoading(true);
      const [overviewRes, teachersRes, studentsRes, coursesRes, assessmentsRes] = await Promise.all([
        adminAPI.getOverview(),
        adminAPI.getTeachers(),
        adminAPI.getStudents(),
        adminAPI.getCourses(),
        adminAPI.getAssessments()
      ]);

      setOverview(overviewRes);
      setTeachers(teachersRes);
      setStudents(studentsRes);
      setCourses(coursesRes);
      setAssessments(assessmentsRes);
      setError(null);
    } catch (err) {
      setError(err.message || 'Không thể tải dữ liệu');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('token');
    navigate('/login');
  };

  const handleCreateTeacher = async (event) => {
    event.preventDefault();
    try {
      setTeacherFormMessage(null);
      const created = await adminAPI.createTeacher(teacherForm);
      setTeachers([created, ...teachers]);
      setShowCreateTeacher(false);
      setTeacherForm({
        email: '',
        password: '',
        full_name: '',
        teacher_id: '',
        department: 'Khoa CNTT',
        position: '',
        phone: '',
        specialization: '',
        office_location: '',
        years_of_experience: ''
      });
      setTeacherFormMessage({ type: 'success', text: 'Đã tạo tài khoản giảng viên thành công.' });
    } catch (err) {
      setTeacherFormMessage({ type: 'error', text: err.message || 'Không thể tạo giảng viên' });
    }
  };

  const handleCreateStudent = async (event) => {
    event.preventDefault();
    try {
      const created = await adminAPI.createStudent(studentForm);
      setStudents([created, ...students]);
      setShowCreateStudent(false);
      setStudentForm({
        email: '',
        password: '',
        full_name: '',
        major: '',
        specialization: '',
        class_name: '',
        intake_year: '',
        phone: '',
        education_type: '0'
      });
    } catch (err) {
      alert(err.message || 'Không thể tạo sinh viên');
    }
  };

  const handleCreateAssessment = async (event) => {
    event.preventDefault();
    try {
      const payload = {
        ...assessmentForm,
        max_score: Number(assessmentForm.max_score || 10),
        weight: Number(assessmentForm.weight || 1),
        duration_minutes: assessmentForm.duration_minutes ? Number(assessmentForm.duration_minutes) : '',
        is_published: assessmentForm.is_published,
        allow_late_submission: assessmentForm.allow_late_submission
      };
      await adminAPI.createAssessment(payload);
      setShowCreateAssessment(false);
      setAssessmentForm({
        course_id: '',
        title: '',
        description: '',
        instructions: '',
        assessment_type: 'assignment',
        max_score: 10,
        weight: 1,
        due_date: '',
        start_date: '',
        duration_minutes: '',
        is_published: false,
        allow_late_submission: true,
        attachment: null
      });
      await fetchAdminData();
    } catch (err) {
      alert(err.message || 'Không thể tạo bài tập');
    }
  };

  const handleToggleStatus = async (target, listSetter, list) => {
    try {
      const updated = await adminAPI.updateUserStatus(target.id, !target.is_active);
      listSetter(list.map(item => (
        item.id === target.id ? { ...item, is_active: updated.is_active } : item
      )));
    } catch (err) {
      alert(err.message || 'Không thể cập nhật trạng thái');
    }
  };

  const handleDeleteUser = async (target, listSetter, list) => {
    const resolvedId = target?.id ?? target?.user_id;
    if (!resolvedId) {
      alert('Không tìm thấy ID người dùng để xóa.');
      return;
    }
    const confirmed = window.confirm(`Xóa người dùng ${target.full_name || target.email}?`);
    if (!confirmed) return;

    try {
      await adminAPI.deleteUser(resolvedId);
      listSetter(list.filter(item => item.id !== resolvedId));
    } catch (err) {
      alert(err.message || 'Không thể xóa người dùng');
    }
  };

  const handleOpenCourseDetail = async (course) => {
    try {
      setCourseDetailLoading(true);
      const detail = await adminAPI.getCourseDetail(course.id);
      setSelectedCourse({ ...detail, course_id: course.id });
    } catch (err) {
      alert(err.message || 'Không thể tải chi tiết khóa học');
    } finally {
      setCourseDetailLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="admin-dashboard">
        <div className="admin-dashboard-loading-shell">
          <Loading
            title="Dang tai du lieu quan tri"
            subtitle="He thong dang tong hop so lieu tong quan, danh sach nguoi dung, khoa hoc va bai danh gia."
          />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="admin-dashboard">
        <div className="error-container">
          <h2>⚠️ Lỗi</h2>
          <p>{error}</p>
          <button onClick={fetchAdminData} className="btn-primary">Thử lại</button>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <div className="header-left">
            <h1>🛠️ Admin Dashboard</h1>
            <p className="welcome-text">Quản trị hệ thống học tập</p>
          </div>
          <div className="header-right">
            <button onClick={handleLogout} className="btn-logout">🚪 Đăng xuất</button>
          </div>
        </div>
      </header>

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
          className={activeTab === 'teachers' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('teachers')}
        >
          👨‍🏫 Giảng viên
        </button>
        <button
          className={activeTab === 'students' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('students')}
        >
          👨‍🎓 Sinh viên
        </button>
        <button
          className={activeTab === 'assignments' ? 'nav-tab active' : 'nav-tab'}
          onClick={() => setActiveTab('assignments')}
        >
          📝 Bài tập
        </button>
        <button
          className="nav-tab nav-tab-special"
          onClick={() => navigate('/admin/progress')}
        >
          🎓 Quản lý tiến độ
        </button>
      </nav>

      <main className="dashboard-content">
        {activeTab === 'overview' && (
          <div className="overview-section">
            <h2>📊 Thống kê hệ thống</h2>
            <div className="stats-grid">
              <div className="stat-card">
                <div className="stat-icon">👥</div>
                <div className="stat-info">
                  <h3>{overview?.total_users || 0}</h3>
                  <p>Người dùng</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">👨‍🎓</div>
                <div className="stat-info">
                  <h3>{overview?.total_students || 0}</h3>
                  <p>Sinh viên</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">👨‍🏫</div>
                <div className="stat-info">
                  <h3>{overview?.total_teachers || 0}</h3>
                  <p>Giảng viên</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">📚</div>
                <div className="stat-info">
                  <h3>{overview?.total_courses || 0}</h3>
                  <p>Khóa học</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">📝</div>
                <div className="stat-info">
                  <h3>{overview?.total_assessments || 0}</h3>
                  <p>Bài tập</p>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">✅</div>
                <div className="stat-info">
                  <h3>{overview?.active_users || 0}</h3>
                  <p>Tài khoản hoạt động</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'courses' && (
          <div className="management-section">
            <div className="section-header">
              <h2>📚 Danh sách khóa học</h2>
            </div>

            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Mã</th>
                    <th>Tên khóa học</th>
                    <th>Ngành</th>
                    <th>Chuyên ngành</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {courses.map((course) => (
                    <tr key={course.id}>
                      <td>{course.course_code}</td>
                      <td>{course.course_name}</td>
                      <td>{course.major || 'N/A'}</td>
                      <td>{course.specialization || 'N/A'}</td>
                      <td>
                        <span className={course.is_active ? 'status active' : 'status inactive'}>
                          {course.is_active ? 'Hoạt động' : 'Ẩn'}
                        </span>
                      </td>
                      <td>
                        <button
                          className="btn-secondary"
                          onClick={() => handleOpenCourseDetail(course)}
                        >
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'teachers' && (
          <div className="management-section">
            <div className="section-header">
              <h2>👨‍🏫 Quản lý giảng viên</h2>
              <button className="btn-primary" onClick={() => setShowCreateTeacher(!showCreateTeacher)}>
                ➕ Thêm giảng viên
              </button>
            </div>

            <div className="admin-info-banner">
              <strong>Đăng ký giảng viên công khai đã bị tắt.</strong>
              <span> Chỉ admin mới được tạo tài khoản và cấp quyền giảng viên từ màn hình này.</span>
            </div>

            {teacherFormMessage && (
              <div className={`admin-inline-message ${teacherFormMessage.type}`}>
                {teacherFormMessage.text}
              </div>
            )}

            {showCreateTeacher && (
              <form className="form-card" onSubmit={handleCreateTeacher}>
                <div className="form-card-header">
                  <h3>Tạo tài khoản giảng viên</h3>
                  <p>Admin cấp email, mật khẩu ban đầu và thông tin hồ sơ giảng viên tại đây.</p>
                </div>
                <div className="form-grid">
                  <input
                    type="text"
                    placeholder="Họ tên"
                    value={teacherForm.full_name}
                    onChange={(e) => setTeacherForm({ ...teacherForm, full_name: e.target.value })}
                    required
                  />
                  <input
                    type="email"
                    placeholder="Email"
                    value={teacherForm.email}
                    onChange={(e) => setTeacherForm({ ...teacherForm, email: e.target.value })}
                    required
                  />
                  <input
                    type="password"
                    placeholder="Mật khẩu"
                    value={teacherForm.password}
                    onChange={(e) => setTeacherForm({ ...teacherForm, password: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Mã giảng viên"
                    value={teacherForm.teacher_id}
                    onChange={(e) => setTeacherForm({ ...teacherForm, teacher_id: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Khoa/Bộ môn"
                    value={teacherForm.department}
                    onChange={(e) => setTeacherForm({ ...teacherForm, department: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Chức vụ"
                    value={teacherForm.position}
                    onChange={(e) => setTeacherForm({ ...teacherForm, position: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="Số điện thoại"
                    value={teacherForm.phone}
                    onChange={(e) => setTeacherForm({ ...teacherForm, phone: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="Chuyên môn / chuyên ngành phụ trách"
                    value={teacherForm.specialization}
                    onChange={(e) => setTeacherForm({ ...teacherForm, specialization: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="Văn phòng / phòng làm việc"
                    value={teacherForm.office_location}
                    onChange={(e) => setTeacherForm({ ...teacherForm, office_location: e.target.value })}
                  />
                  <input
                    type="number"
                    min="0"
                    placeholder="Số năm kinh nghiệm"
                    value={teacherForm.years_of_experience}
                    onChange={(e) => setTeacherForm({ ...teacherForm, years_of_experience: e.target.value })}
                  />
                </div>
                <div className="form-actions">
                  <button className="btn-secondary" type="button" onClick={() => setShowCreateTeacher(false)}>
                    Hủy
                  </button>
                  <button className="btn-primary" type="submit">Lưu giảng viên</button>
                </div>
              </form>
            )}

            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Tên</th>
                    <th>Email</th>
                    <th>Mã GV</th>
                    <th>Khoa</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {teachers.map((teacher) => (
                    <tr key={teacher.id}>
                      <td>{teacher.full_name}</td>
                      <td>{teacher.email}</td>
                      <td>{teacher.teacher_profile?.teacher_id}</td>
                      <td>{teacher.teacher_profile?.department}</td>
                      <td>
                        <span className={teacher.is_active ? 'status active' : 'status inactive'}>
                          {teacher.is_active ? 'Hoạt động' : 'Khóa'}
                        </span>
                      </td>
                      <td>
                        <button
                          className="btn-secondary"
                          onClick={() => handleToggleStatus(teacher, setTeachers, teachers)}
                        >
                          {teacher.is_active ? 'Khóa' : 'Mở'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'students' && (
          <div className="management-section">
            <div className="section-header">
              <h2>👨‍🎓 Quản lý sinh viên</h2>
              <button className="btn-primary" onClick={() => setShowCreateStudent(!showCreateStudent)}>
                ➕ Thêm sinh viên
              </button>
            </div>

            {showCreateStudent && (
              <form className="form-card" onSubmit={handleCreateStudent}>
                <div className="form-grid">
                  <input
                    type="text"
                    placeholder="Họ tên"
                    value={studentForm.full_name}
                    onChange={(e) => setStudentForm({ ...studentForm, full_name: e.target.value })}
                    required
                  />
                  <input
                    type="email"
                    placeholder="Email"
                    value={studentForm.email}
                    onChange={(e) => setStudentForm({ ...studentForm, email: e.target.value })}
                    required
                  />
                  <input
                    type="password"
                    placeholder="Mật khẩu"
                    value={studentForm.password}
                    onChange={(e) => setStudentForm({ ...studentForm, password: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Ngành học"
                    value={studentForm.major}
                    onChange={(e) => setStudentForm({ ...studentForm, major: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Chuyên ngành"
                    value={studentForm.specialization}
                    onChange={(e) => setStudentForm({ ...studentForm, specialization: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="Lớp"
                    value={studentForm.class_name}
                    onChange={(e) => setStudentForm({ ...studentForm, class_name: e.target.value })}
                  />
                  <input
                    type="number"
                    placeholder="Khóa (VD: 27)"
                    value={studentForm.intake_year}
                    onChange={(e) => setStudentForm({ ...studentForm, intake_year: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Số điện thoại"
                    value={studentForm.phone}
                    onChange={(e) => setStudentForm({ ...studentForm, phone: e.target.value })}
                  />
                </div>
                <button className="btn-primary" type="submit">Lưu sinh viên</button>
              </form>
            )}

            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Tên</th>
                    <th>Email</th>
                    <th>MSSV</th>
                    <th>Ngành</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  {students.map((student) => (
                    <tr key={student.id}>
                      <td>{student.full_name}</td>
                      <td>{student.email}</td>
                      <td>{student.student_profile?.student_id}</td>
                      <td>{student.student_profile?.major}</td>
                      <td>
                        <span className={student.is_active ? 'status active' : 'status inactive'}>
                          {student.is_active ? 'Hoạt động' : 'Khóa'}
                        </span>
                      </td>
                      <td>
                        <button
                          className="btn-secondary"
                          onClick={() => handleToggleStatus(student, setStudents, students)}
                        >
                          {student.is_active ? 'Khóa' : 'Mở'}
                        </button>
                        <button
                          className="btn-secondary"
                          onClick={() => handleDeleteUser(student, setStudents, students)}
                        >
                          Xóa
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'assignments' && (
          <div className="management-section">
            <div className="section-header">
              <h2>📝 Quản lý bài tập</h2>
              <button className="btn-primary" onClick={() => setShowCreateAssessment(!showCreateAssessment)}>
                ➕ Tạo bài tập
              </button>
            </div>

            {showCreateAssessment && (
              <form className="form-card" onSubmit={handleCreateAssessment}>
                <div className="form-grid">
                  <select
                    value={assessmentForm.course_id}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, course_id: e.target.value })}
                    required
                  >
                    <option value="">Chọn khóa học</option>
                    {courses.map(course => (
                      <option key={course.id} value={course.id}>
                        {course.course_code} - {course.course_name}
                      </option>
                    ))}
                  </select>
                  <input
                    type="text"
                    placeholder="Tiêu đề"
                    value={assessmentForm.title}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, title: e.target.value })}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Mô tả"
                    value={assessmentForm.description}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, description: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="Hướng dẫn"
                    value={assessmentForm.instructions}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, instructions: e.target.value })}
                  />
                  <select
                    value={assessmentForm.assessment_type}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, assessment_type: e.target.value })}
                  >
                    <option value="assignment">Bài tập</option>
                    <option value="quiz">Quiz</option>
                    <option value="midterm">Giữa kỳ</option>
                    <option value="final">Cuối kỳ</option>
                    <option value="project">Dự án</option>
                    <option value="lab">Lab</option>
                  </select>
                  <input
                    type="number"
                    placeholder="Điểm tối đa"
                    value={assessmentForm.max_score}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, max_score: e.target.value })}
                  />
                  <input
                    type="number"
                    step="0.1"
                    placeholder="Trọng số"
                    value={assessmentForm.weight}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, weight: e.target.value })}
                  />
                  <input
                    type="datetime-local"
                    value={assessmentForm.start_date}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, start_date: e.target.value })}
                  />
                  <input
                    type="datetime-local"
                    value={assessmentForm.due_date}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, due_date: e.target.value })}
                  />
                  <input
                    type="number"
                    placeholder="Thời lượng (phút)"
                    value={assessmentForm.duration_minutes}
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, duration_minutes: e.target.value })}
                  />
                  <input
                    type="file"
                    onChange={(e) => setAssessmentForm({ ...assessmentForm, attachment: e.target.files[0] })}
                  />
                  <label className="checkbox-row">
                    <input
                      type="checkbox"
                      checked={assessmentForm.is_published}
                      onChange={(e) => setAssessmentForm({ ...assessmentForm, is_published: e.target.checked })}
                    />
                    Xuất bản
                  </label>
                  <label className="checkbox-row">
                    <input
                      type="checkbox"
                      checked={assessmentForm.allow_late_submission}
                      onChange={(e) => setAssessmentForm({ ...assessmentForm, allow_late_submission: e.target.checked })}
                    />
                    Cho phép nộp trễ
                  </label>
                </div>
                <button className="btn-primary" type="submit">Lưu bài tập</button>
              </form>
            )}

            <div className="table-wrapper">
              <table>
                <thead>
                  <tr>
                    <th>Tiêu đề</th>
                    <th>Loại</th>
                    <th>Khóa học</th>
                    <th>Hạn nộp</th>
                    <th>Tệp đính kèm</th>
                  </tr>
                </thead>
                <tbody>
                  {assessments.map((assessment) => (
                    <tr key={assessment.id}>
                      <td>{assessment.title}</td>
                      <td>{assessment.assessment_type}</td>
                      <td>{assessment.course?.course_code} - {assessment.course?.course_name}</td>
                      <td>{assessment.due_date ? new Date(assessment.due_date).toLocaleString('vi-VN') : 'N/A'}</td>
                      <td>{assessment.attachment_name || 'Không có'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </main>

      {selectedCourse && (
        <div className="modal-overlay" onClick={() => setSelectedCourse(null)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>📘 {selectedCourse.course?.course_name || selectedCourse.course?.course_code}</h3>
              <button className="btn-secondary" onClick={() => setSelectedCourse(null)}>Đóng</button>
            </div>

            {courseDetailLoading ? (
              <p>Đang tải chi tiết...</p>
            ) : (
              <div className="modal-content">
                <div className="detail-grid">
                  <div>
                    <h4>Thông tin khóa học</h4>
                    <p><strong>Mã:</strong> {selectedCourse.course?.course_code}</p>
                    <p><strong>Tên:</strong> {selectedCourse.course?.course_name}</p>
                    <p><strong>Ngành:</strong> {selectedCourse.course?.major || 'N/A'}</p>
                    <p><strong>Chuyên ngành:</strong> {selectedCourse.course?.specialization || 'N/A'}</p>
                    <p><strong>Mô tả:</strong> {selectedCourse.course?.description || 'Chưa có mô tả'}</p>
                  </div>
                  <div>
                    <h4>Thống kê</h4>
                    <p><strong>Số bài học:</strong> {selectedCourse.stats?.lesson_count || 0}</p>
                    <p><strong>Số sinh viên:</strong> {selectedCourse.stats?.enrolled_count || 0}</p>
                    <p><strong>Tổng thời lượng:</strong> {selectedCourse.stats?.total_duration || 0} phút</p>
                  </div>
                </div>

                <div className="detail-list">
                  <h4>Bài học</h4>
                  {selectedCourse.lessons?.length ? (
                    <ul>
                      {selectedCourse.lessons.map((lesson) => (
                        <li key={lesson.id}>{lesson.title}</li>
                      ))}
                    </ul>
                  ) : (
                    <p>Chưa có bài học.</p>
                  )}
                </div>

                <div className="detail-list">
                  <h4>Bài tập / Đánh giá</h4>
                  {selectedCourse.assessments?.length ? (
                    <ul>
                      {selectedCourse.assessments.map((assessment) => (
                        <li key={assessment.id}>{assessment.title}</li>
                      ))}
                    </ul>
                  ) : (
                    <p>Chưa có bài tập.</p>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminDashboard;
