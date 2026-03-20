import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  BookOpen, Plus, Edit, Trash2, Eye, Users, FileText, 
  Search, Filter, X, Upload, Video, Link as LinkIcon,
  Save, AlertCircle, CheckCircle
} from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './ContentPage.css';

const ContentPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [courses, setCourses] = useState([]);
  const [filteredCourses, setFilteredCourses] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterCategory, setFilterCategory] = useState('all');
  
  // Modals
  const [showCreateCourse, setShowCreateCourse] = useState(false);
  const [showCreateLesson, setShowCreateLesson] = useState(false);
  const [selectedCourse, setSelectedCourse] = useState(null);
  
  // Forms
  const [courseForm, setCourseForm] = useState({
    title: '',
    description: '',
    category: 'programming'
  });
  
  const [lessonForm, setLessonForm] = useState({
    title: '',
    description: '',
    course_id: '',
    activity_type: 'quiz',
    activity_prompt: '',
    file: null,
    video_url: ''
  });
  
  const [alert, setAlert] = useState(null);

  useEffect(() => {
    fetchCourses();
  }, []);

  useEffect(() => {
    filterCourses();
  }, [courses, searchTerm, filterCategory]);

  const fetchCourses = async () => {
    try {
      setLoading(true);
      const data = await teacherAPI.getCourses();
      setCourses(data);
    } catch (err) {
      showAlert('error', err.message || 'Không thể tải danh sách khóa học');
    } finally {
      setLoading(false);
    }
  };

  const filterCourses = () => {
    let filtered = courses;
    
    if (searchTerm) {
      filtered = filtered.filter(course =>
        course.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        course.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        course.class_code?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    if (filterCategory !== 'all') {
      filtered = filtered.filter(course => course.category === filterCategory);
    }
    
    setFilteredCourses(filtered);
  };

  const handleCreateCourse = async (e) => {
    e.preventDefault();
    try {
      const response = await teacherAPI.createCourse(courseForm);
      setCourses([response, ...courses]);
      setShowCreateCourse(false);
      setCourseForm({ title: '', description: '', category: 'programming' });
      showAlert('success', 'Tạo khóa học thành công!');
    } catch (err) {
      showAlert('error', err.message || 'Lỗi tạo khóa học');
    }
  };

  const handleCreateLesson = async (e) => {
    e.preventDefault();
    try {
      if (lessonForm.activity_type === 'essay' && !lessonForm.activity_prompt.trim()) {
        showAlert('error', 'Bài học tự luận cần có yêu cầu hoặc đề bài');
        return;
      }
      await teacherAPI.createLesson(lessonForm);
      setShowCreateLesson(false);
      setLessonForm({ title: '', description: '', course_id: '', activity_type: 'quiz', activity_prompt: '', file: null, video_url: '' });
      showAlert('success', 'Thêm bài học thành công!');
      fetchCourses();
    } catch (err) {
      showAlert('error', err.message || 'Lỗi thêm bài học');
    }
  };

  const showAlert = (type, message) => {
    setAlert({ type, message });
    setTimeout(() => setAlert(null), 3000);
  };

  const categories = [
    { value: 'all', label: 'Tất cả' },
    { value: 'programming', label: 'Lập trình' },
    { value: 'design', label: 'Thiết kế' },
    { value: 'business', label: 'Kinh doanh' },
    { value: 'marketing', label: 'Marketing' },
    { value: 'other', label: 'Khác' }
  ];

  if (loading) {
    return (
      <TeacherLayout>
        <div className="content-page">
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
      <div className="content-page">
      {/* Alert */}
      {alert && (
        <div className={`alert alert-${alert.type}`}>
          {alert.type === 'success' ? <CheckCircle /> : <AlertCircle />}
          <span>{alert.message}</span>
          <button onClick={() => setAlert(null)}><X size={18} /></button>
        </div>
      )}

      {/* Header */}
      <div className="content-header">
        <div className="header-left">
          <h1>Quản lý nội dung</h1>
          <p>Quản lý khóa học và bài học của bạn</p>
        </div>
        <button 
          className="btn-create"
          onClick={() => setShowCreateCourse(true)}
        >
          <Plus />
          Tạo khóa học mới
        </button>
      </div>

      {/* Filters */}
      <div className="content-filters">
        <div className="search-box">
          <Search />
          <input
            type="text"
            placeholder="Tìm kiếm khóa học..."
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
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value)}
          >
            {categories.map(cat => (
              <option key={cat.value} value={cat.value}>{cat.label}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Courses List */}
      {filteredCourses.length === 0 ? (
        <div className="empty-state">
          <BookOpen size={64} />
          <h3>Chưa có khóa học nào</h3>
          <p>Tạo khóa học đầu tiên để bắt đầu giảng dạy</p>
          <button 
            className="btn-create"
            onClick={() => setShowCreateCourse(true)}
          >
            <Plus />
            Tạo khóa học
          </button>
        </div>
      ) : (
        <div className="courses-list">
          {filteredCourses.map(course => (
            <div key={course.id} className="course-item">
              <div className="course-main">
                <div className="course-icon">
                  <BookOpen />
                </div>
                
                <div className="course-info">
                  <div className="course-title-row">
                    <h3>{course.title}</h3>
                    <span className="course-category">{course.category}</span>
                  </div>
                  <p className="course-description">
                    {course.description || 'Chưa có mô tả'}
                  </p>
                  <div className="course-meta">
                    <span className="course-code">
                      Mã: {course.class_code}
                    </span>
                    <span className="meta-divider">•</span>
                    <span>
                      <Users size={14} /> {course.enrolled_count || 0} học sinh
                    </span>
                    <span className="meta-divider">•</span>
                    <span>
                      <FileText size={14} /> {course.lessons_count || 0} bài học
                    </span>
                  </div>
                </div>
              </div>

              <div className="course-actions">
                <button
                  className="btn-action"
                  onClick={() => {
                    setSelectedCourse(course);
                    setLessonForm({ ...lessonForm, course_id: course.id });
                    setShowCreateLesson(true);
                  }}
                  title="Thêm bài học"
                >
                  <Plus size={18} />
                </button>
                
                <button
                  className="btn-action"
                  onClick={() => navigate(`/teacher/courses/${course.id}`)}
                  title="Xem chi tiết"
                >
                  <Eye size={18} />
                </button>
                
                <button
                  className="btn-action"
                  onClick={() => navigate(`/teacher/courses/${course.id}`)}
                  title="Quản lý khóa học"
                >
                  <Edit size={18} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Course Modal */}
      {showCreateCourse && (
        <div className="modal-overlay" onClick={() => setShowCreateCourse(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Tạo khóa học mới</h2>
              <button onClick={() => setShowCreateCourse(false)}>
                <X />
              </button>
            </div>

            <form onSubmit={handleCreateCourse}>
              <div className="form-group">
                <label>Tên khóa học *</label>
                <input
                  type="text"
                  value={courseForm.title}
                  onChange={e => setCourseForm({ ...courseForm, title: e.target.value })}
                  placeholder="Nhập tên khóa học"
                  required
                />
              </div>

              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={courseForm.description}
                  onChange={e => setCourseForm({ ...courseForm, description: e.target.value })}
                  placeholder="Mô tả khóa học"
                  rows={4}
                />
              </div>

              <div className="form-group">
                <label>Danh mục *</label>
                <select
                  value={courseForm.category}
                  onChange={e => setCourseForm({ ...courseForm, category: e.target.value })}
                  required
                >
                  <option value="programming">Lập trình</option>
                  <option value="design">Thiết kế</option>
                  <option value="business">Kinh doanh</option>
                  <option value="marketing">Marketing</option>
                  <option value="other">Khác</option>
                </select>
              </div>

              <div className="modal-actions">
                <button 
                  type="button" 
                  className="btn-cancel"
                  onClick={() => setShowCreateCourse(false)}
                >
                  Hủy
                </button>
                <button type="submit" className="btn-submit">
                  <Save />
                  Tạo khóa học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Create Lesson Modal */}
      {showCreateLesson && (
        <div className="modal-overlay" onClick={() => setShowCreateLesson(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Thêm bài học mới</h2>
              <button onClick={() => setShowCreateLesson(false)}>
                <X />
              </button>
            </div>

            <form onSubmit={handleCreateLesson}>
              <div className="form-group">
                <label>Khóa học</label>
                <input
                  type="text"
                  value={selectedCourse?.title || ''}
                  disabled
                />
              </div>

              <div className="form-group">
                <label>Tên bài học *</label>
                <input
                  type="text"
                  value={lessonForm.title}
                  onChange={e => setLessonForm({ ...lessonForm, title: e.target.value })}
                  placeholder="Nhập tên bài học"
                  required
                />
              </div>

              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={lessonForm.description}
                  onChange={e => setLessonForm({ ...lessonForm, description: e.target.value })}
                  placeholder="Mô tả bài học"
                  rows={3}
                />
              </div>

              <div className="form-group">
                <label>Loại hoạt động của bài học *</label>
                <select
                  value={lessonForm.activity_type}
                  onChange={e => setLessonForm({ ...lessonForm, activity_type: e.target.value })}
                  required
                >
                  <option value="quiz">Bài học có quiz</option>
                  <option value="essay">Bài học tự luận</option>
                </select>
              </div>

              {lessonForm.activity_type === 'essay' && (
                <div className="form-group">
                  <label>Đề bài hoặc yêu cầu tự luận *</label>
                  <textarea
                    value={lessonForm.activity_prompt}
                    onChange={e => setLessonForm({ ...lessonForm, activity_prompt: e.target.value })}
                    placeholder="Ví dụ: Sau khi học bài này, hãy phân tích decorator trong Python và nộp ví dụ minh họa."
                    rows={4}
                    required
                  />
                </div>
              )}

              <div className="form-group">
                <label>
                  <Upload size={18} />
                  Upload tài liệu (PDF, Word, PowerPoint)
                </label>
                <input
                  type="file"
                  accept=".pdf,.doc,.docx,.ppt,.pptx"
                  onChange={e => setLessonForm({ ...lessonForm, file: e.target.files[0] })}
                />
              </div>

              <div className="form-divider">
                <span>HOẶC</span>
              </div>

              <div className="form-group">
                <label>
                  <Video size={18} />
                  Link video YouTube/Vimeo
                </label>
                <input
                  type="url"
                  value={lessonForm.video_url}
                  onChange={e => setLessonForm({ ...lessonForm, video_url: e.target.value })}
                  placeholder="https://youtube.com/watch?v=..."
                />
              </div>

              <div className="modal-actions">
                <button 
                  type="button" 
                  className="btn-cancel"
                  onClick={() => setShowCreateLesson(false)}
                >
                  Hủy
                </button>
                <button type="submit" className="btn-submit">
                  <Save />
                  Thêm bài học
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

export default ContentPage;
