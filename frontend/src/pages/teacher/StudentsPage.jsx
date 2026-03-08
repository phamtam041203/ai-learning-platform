import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Users, Search, Filter, Eye, TrendingUp, Award, 
  BookOpen, CheckCircle, X, AlertCircle, Mail, Calendar
} from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './StudentsPage.css';

const StudentsPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [students, setStudents] = useState([]);
  const [courses, setCourses] = useState([]);
  const [filteredStudents, setFilteredStudents] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterCourse, setFilterCourse] = useState('all');
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [showDetail, setShowDetail] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    filterStudents();
  }, [students, searchTerm, filterCourse]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [studentsData, coursesData] = await Promise.all([
        teacherAPI.getStudents(),
        teacherAPI.getCourses()
      ]);
      setStudents(studentsData);
      setCourses(coursesData);
    } catch (err) {
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const filterStudents = () => {
    let filtered = students;
    
    if (searchTerm) {
      filtered = filtered.filter(student =>
        student.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        student.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        student.student_id?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    if (filterCourse !== 'all') {
      filtered = filtered.filter(student => 
        student.enrolled_courses?.includes(parseInt(filterCourse))
      );
    }
    
    setFilteredStudents(filtered);
  };

  const handleViewDetail = (student) => {
    setSelectedStudent(student);
    setShowDetail(true);
  };

  if (loading) {
    return (
      <TeacherLayout>
        <div className="students-page">
          <div className="loading-state">
            <div className="spinner"></div>
            <p>Đang tải dữ liệu...</p>
          </div>
        </div>
      </TeacherLayout>
    );
  }

  return (
    <TeacherLayout>
      <div className="students-page">
      {/* Header */}
      <div className="students-header">
        <div className="header-left">
          <h1>Danh sách học sinh</h1>
          <p>Quản lý và theo dõi tiến độ học sinh</p>
        </div>
        <div className="header-stats">
          <div className="stat-badge">
            <Users />
            <span>{students.length} học sinh</span>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="students-filters">
        <div className="search-box">
          <Search />
          <input
            type="text"
            placeholder="Tìm kiếm theo tên, email, MSSV..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button onClick={() => setSearchTerm('')}>
              <X size={18} />
            </button>
          )}
        </div>

        <div className="filter-box">
          <Filter />
          <select
            value={filterCourse}
            onChange={(e) => setFilterCourse(e.target.value)}
          >
            <option value="all">Tất cả khóa học</option>
            {courses.map(course => (
              <option key={course.id} value={course.id}>
                {course.title}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Students List */}
      {filteredStudents.length === 0 ? (
        <div className="empty-state">
          <Users size={64} />
          <h3>Không tìm thấy học sinh</h3>
          <p>
            {searchTerm || filterCourse !== 'all'
              ? 'Thử thay đổi bộ lọc để xem kết quả khác'
              : 'Chưa có học sinh nào đăng ký khóa học của bạn'}
          </p>
        </div>
      ) : (
        <div className="students-grid">
          {filteredStudents.map(student => (
            <div key={student.id} className="student-card">
              <div className="student-header">
                <div className="student-avatar">
                  {student.full_name?.charAt(0) || 'S'}
                </div>
                <div className="student-info">
                  <h3>{student.full_name || 'Chưa cập nhật'}</h3>
                  <p className="student-id">MSSV: {student.student_id || 'N/A'}</p>
                </div>
              </div>

              <div className="student-details">
                <div className="detail-item">
                  <Mail size={16} />
                  <span>{student.email}</span>
                </div>
                
                {student.major && (
                  <div className="detail-item">
                    <BookOpen size={16} />
                    <span>{student.major}</span>
                  </div>
                )}

                {student.enrolled_at && (
                  <div className="detail-item">
                    <Calendar size={16} />
                    <span>
                      Tham gia: {new Date(student.enrolled_at).toLocaleDateString('vi-VN')}
                    </span>
                  </div>
                )}
              </div>

              <div className="student-stats">
                <div className="stat-item">
                  <BookOpen size={18} />
                  <div>
                    <span className="stat-value">
                      {student.enrolled_courses?.length || 0}
                    </span>
                    <span className="stat-label">Khóa học</span>
                  </div>
                </div>

                <div className="stat-item">
                  <TrendingUp size={18} />
                  <div>
                    <span className="stat-value">
                      {student.progress_avg || 0}%
                    </span>
                    <span className="stat-label">Tiến độ</span>
                  </div>
                </div>

                <div className="stat-item">
                  <Award size={18} />
                  <div>
                    <span className="stat-value">
                      {student.grade_avg?.toFixed(1) || 'N/A'}
                    </span>
                    <span className="stat-label">Điểm TB</span>
                  </div>
                </div>
              </div>

              <button
                className="btn-view-detail"
                onClick={() => handleViewDetail(student)}
              >
                <Eye size={18} />
                Xem chi tiết
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Student Detail Modal */}
      {showDetail && selectedStudent && (
        <div className="modal-overlay" onClick={() => setShowDetail(false)}>
          <div className="modal-content student-detail-modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Thông tin chi tiết</h2>
              <button onClick={() => setShowDetail(false)}>
                <X />
              </button>
            </div>

            <div className="modal-body">
              {/* Student Info */}
              <div className="detail-section">
                <div className="student-avatar-large">
                  {selectedStudent.full_name?.charAt(0) || 'S'}
                </div>
                <h3>{selectedStudent.full_name}</h3>
                <p className="student-email">{selectedStudent.email}</p>
                <p className="student-id-large">MSSV: {selectedStudent.student_id}</p>
              </div>

              {/* Academic Info */}
              <div className="detail-section">
                <h4>Thông tin học vấn</h4>
                <div className="info-grid">
                  <div className="info-item">
                    <label>Chuyên ngành:</label>
                    <span>{selectedStudent.major || 'Chưa cập nhật'}</span>
                  </div>
                  <div className="info-item">
                    <label>Năm học:</label>
                    <span>{selectedStudent.year || 'N/A'}</span>
                  </div>
                  <div className="info-item">
                    <label>Ngày tham gia:</label>
                    <span>
                      {selectedStudent.enrolled_at 
                        ? new Date(selectedStudent.enrolled_at).toLocaleDateString('vi-VN')
                        : 'N/A'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Performance Stats */}
              <div className="detail-section">
                <h4>Thành tích</h4>
                <div className="performance-grid">
                  <div className="performance-card">
                    <BookOpen />
                    <span className="perf-value">
                      {selectedStudent.enrolled_courses?.length || 0}
                    </span>
                    <span className="perf-label">Khóa học đã đăng ký</span>
                  </div>

                  <div className="performance-card">
                    <CheckCircle />
                    <span className="perf-value">
                      {selectedStudent.completed_courses || 0}
                    </span>
                    <span className="perf-label">Hoàn thành</span>
                  </div>

                  <div className="performance-card">
                    <TrendingUp />
                    <span className="perf-value">
                      {selectedStudent.progress_avg || 0}%
                    </span>
                    <span className="perf-label">Tiến độ trung bình</span>
                  </div>

                  <div className="performance-card">
                    <Award />
                    <span className="perf-value">
                      {selectedStudent.grade_avg?.toFixed(1) || 'N/A'}
                    </span>
                    <span className="perf-label">Điểm trung bình</span>
                  </div>
                </div>
              </div>

              {/* Enrolled Courses */}
              {selectedStudent.courses && selectedStudent.courses.length > 0 && (
                <div className="detail-section">
                  <h4>Khóa học đang học</h4>
                  <div className="courses-list">
                    {selectedStudent.courses.map(course => (
                      <div key={course.id} className="course-item-small">
                        <div className="course-info-small">
                          <span className="course-title">{course.title}</span>
                          <span className="course-progress">
                            Tiến độ: {course.progress || 0}%
                          </span>
                        </div>
                        <div className="course-grade">
                          {course.grade ? `${course.grade}/10` : 'Chưa chấm'}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
      </div>
    </TeacherLayout>
  );
};

export default StudentsPage;
