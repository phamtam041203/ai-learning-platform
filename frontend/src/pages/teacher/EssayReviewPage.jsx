import { useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  FileText, User, Clock, CheckCircle, AlertCircle, Download,
  ArrowLeft, Send, Star, Eye, Filter, Search
} from 'lucide-react';
import { buildApiUrl, buildBackendUrl } from '../../config/api';
import './EssayReviewPage.css';

const EssayReviewPage = () => {
  const navigate = useNavigate();
  const { courseId } = useParams();
  
  const [submissions, setSubmissions] = useState([]);
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [courseInfo, setCourseInfo] = useState(null);
  const [filterStatus, setFilterStatus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const detailPanelRef = useRef(null);
  
  // Grading state
  const [gradeScore, setGradeScore] = useState('');
  const [gradeFeedback, setGradeFeedback] = useState('');
  const [grading, setGrading] = useState(false);
  const [gradeSuccess, setGradeSuccess] = useState(false);

  useEffect(() => {
    if (courseId) {
      fetchSubmissions();
    } else {
      fetchAllPending();
    }
  }, [courseId, filterStatus]);

  const fetchSubmissions = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const statusParam = filterStatus !== 'all' ? `?status=${filterStatus}` : '';
      
      const response = await fetch(
        buildApiUrl(`/teacher/courses/${courseId}/essay-submissions${statusParam}`),
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );

      if (response.ok) {
        const data = await response.json();
        setSubmissions(data.submissions);
        setCourseInfo(data.course);
      } else {
        const err = await response.json();
        setError(err.detail || 'Không thể tải danh sách bài nộp');
      }
    } catch (err) {
      setError('Lỗi kết nối: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const fetchAllPending = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      
      const response = await fetch(
        buildApiUrl('/teacher/pending-essays'),
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );

      if (response.ok) {
        const data = await response.json();
        setSubmissions(data.submissions);
      } else {
        const err = await response.json();
        setError(err.detail || 'Không thể tải danh sách bài chờ chấm');
      }
    } catch (err) {
      setError('Lỗi kết nối: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectSubmission = async (submissionId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/teacher/essay-submissions/${submissionId}`),
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );

      if (response.ok) {
        const data = await response.json();
        setSelectedSubmission(data);
        setGradeScore(data.score?.toString() || '');
        setGradeFeedback(data.feedback || '');
        setGradeSuccess(false);

        if (window.innerWidth <= 1100) {
          requestAnimationFrame(() => {
            detailPanelRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
          });
        }
      }
    } catch (err) {
      console.error('Error fetching submission detail:', err);
    }
  };

  const handleGradeSubmit = async () => {
    if (!selectedSubmission) return;
    
    const score = parseFloat(gradeScore);
    if (isNaN(score) || score < 0 || score > selectedSubmission.max_score) {
      alert(`Điểm phải từ 0 đến ${selectedSubmission.max_score}`);
      return;
    }

    try {
      setGrading(true);
      const token = localStorage.getItem('token');
      
      const formData = new FormData();
      formData.append('score', score.toString());
      if (gradeFeedback) {
        formData.append('feedback', gradeFeedback);
      }

      const response = await fetch(
        buildApiUrl(`/teacher/essay-submissions/${selectedSubmission.id}/grade`),
        {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
          body: formData
        }
      );

      if (response.ok) {
        setGradeSuccess(true);
        // Refresh the list
        if (courseId) {
          fetchSubmissions();
        } else {
          fetchAllPending();
        }
        // Update selected submission
        setSelectedSubmission({
          ...selectedSubmission,
          score,
          feedback: gradeFeedback,
          status: 'graded'
        });
      } else {
        const err = await response.json();
        alert(err.detail || 'Không thể chấm điểm');
      }
    } catch (err) {
      alert('Lỗi: ' + err.message);
    } finally {
      setGrading(false);
    }
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  const filteredSubmissions = submissions.filter(s => {
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      return (
        s.student_name?.toLowerCase().includes(term) ||
        s.lesson_title?.toLowerCase().includes(term) ||
        s.course_title?.toLowerCase().includes(term)
      );
    }
    return true;
  });

  const getStatusBadge = (status) => {
    switch (status) {
      case 'submitted':
        return <span className="status-badge pending"><Clock size={14} /> Chờ chấm</span>;
      case 'graded':
        return <span className="status-badge graded"><CheckCircle size={14} /> Đã chấm</span>;
      default:
        return <span className="status-badge">{status}</span>;
    }
  };

  if (loading) {
    return (
      <div className="essay-review-page">
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Đang tải danh sách bài nộp...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="essay-review-page">
      {/* Header */}
      <div className="review-header">
        <button onClick={() => navigate(-1)} className="btn-back">
          <ArrowLeft size={20} />
          Quay lại
        </button>
        <div className="header-info">
          <h1>
            <FileText size={28} />
            {courseInfo ? `Bài tự luận - ${courseInfo.title}` : 'Bài tự luận chờ chấm'}
          </h1>
          {courseInfo && <p className="course-code">{courseInfo.code}</p>}
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="error-message">
          <AlertCircle size={20} />
          {error}
        </div>
      )}

      <div className="review-content">
        {/* Left Panel - Submission List */}
        <div className="submissions-panel">
          <div className="panel-header">
            <h2>Danh sách bài nộp ({filteredSubmissions.length})</h2>
            
            {/* Filters */}
            <div className="filters">
              <div className="search-box">
                <Search size={18} />
                <input
                  type="text"
                  placeholder="Tìm sinh viên..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              
              {courseId && (
                <select 
                  value={filterStatus} 
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="filter-select"
                >
                  <option value="all">Tất cả</option>
                  <option value="submitted">Chờ chấm</option>
                  <option value="graded">Đã chấm</option>
                </select>
              )}
            </div>
          </div>

          <div className="submissions-list">
            {filteredSubmissions.length === 0 ? (
              <div className="no-submissions">
                <FileText size={48} />
                <p>Chưa có bài nộp nào</p>
              </div>
            ) : (
              filteredSubmissions.map((sub) => (
                <div
                  key={sub.id}
                  className={`submission-item ${selectedSubmission?.id === sub.id ? 'selected' : ''} ${sub.status}`}
                  onClick={() => handleSelectSubmission(sub.id)}
                >
                  <div className="submission-main">
                    <div className="student-info">
                      <User size={16} />
                      <span className="student-name">{sub.student_name}</span>
                    </div>
                    <div className="lesson-info">
                      <FileText size={14} />
                      <span>{sub.lesson_title || sub.course_title}</span>
                    </div>
                  </div>
                  <div className="submission-meta">
                    {getStatusBadge(sub.status)}
                    {sub.score !== null && sub.score !== undefined && (
                      <span className="score-badge">
                        <Star size={12} />
                        {sub.score}/{sub.max_score || 10}
                      </span>
                    )}
                    {sub.has_file && (
                      <span className="file-indicator" title={sub.file_name}>
                        📎
                      </span>
                    )}
                  </div>
                  <div className="submission-time">
                    <Clock size={12} />
                    {new Date(sub.submitted_at).toLocaleString('vi-VN')}
                  </div>
                  <button
                    type="button"
                    className="submission-action"
                    onClick={(event) => {
                      event.stopPropagation();
                      handleSelectSubmission(sub.id);
                    }}
                  >
                    <Eye size={14} />
                    Xem và chấm
                  </button>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right Panel - Detail & Grading */}
        <div className="detail-panel" ref={detailPanelRef}>
          {selectedSubmission ? (
            <>
              <div className="detail-header">
                <h2>Chi tiết bài nộp</h2>
                {getStatusBadge(selectedSubmission.status)}
              </div>

              {/* Student Info */}
              <div className="detail-section">
                <h3><User size={18} /> Thông tin sinh viên</h3>
                <div className="info-grid">
                  <div className="info-item">
                    <span className="label">Họ tên:</span>
                    <span className="value">{selectedSubmission.student?.name}</span>
                  </div>
                  <div className="info-item">
                    <span className="label">Email:</span>
                    <span className="value">{selectedSubmission.student?.email}</span>
                  </div>
                  <div className="info-item">
                    <span className="label">Bài học:</span>
                    <span className="value">Bài {selectedSubmission.lesson?.order}: {selectedSubmission.lesson?.title}</span>
                  </div>
                  <div className="info-item">
                    <span className="label">Thời gian nộp:</span>
                    <span className="value">{new Date(selectedSubmission.submitted_at).toLocaleString('vi-VN')}</span>
                  </div>
                </div>
              </div>

              {/* Content */}
              <div className="detail-section">
                <h3><FileText size={18} /> Nội dung bài làm</h3>
                
                {selectedSubmission.text_content && (
                  <div className="text-content">
                    <pre>{selectedSubmission.text_content}</pre>
                  </div>
                )}
                
                {selectedSubmission.file_url && (
                  <div className="file-attachment">
                    <FileText size={20} />
                    <div className="file-info">
                      <span className="file-name">{selectedSubmission.file_name}</span>
                      <span className="file-size">{formatFileSize(selectedSubmission.file_size)}</span>
                    </div>
                    <a
                      href={buildBackendUrl(selectedSubmission.file_url)}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn-download"
                    >
                      <Download size={16} />
                      Tải xuống
                    </a>
                    <a
                      href={buildBackendUrl(selectedSubmission.file_url)}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn-view"
                    >
                      <Eye size={16} />
                      Xem
                    </a>
                  </div>
                )}

                {!selectedSubmission.text_content && !selectedSubmission.file_url && (
                  <p className="no-content">Không có nội dung bài làm</p>
                )}
              </div>

              {/* Grading Form */}
              <div className="detail-section grading-section">
                <h3><Star size={18} /> Chấm điểm</h3>
                
                {gradeSuccess && (
                  <div className="grade-success">
                    <CheckCircle size={18} />
                    Đã lưu điểm thành công!
                  </div>
                )}

                <div className="grading-form">
                  <div className="form-row">
                    <label>
                      Điểm (0 - {selectedSubmission.max_score || 10}):
                      <input
                        type="number"
                        min="0"
                        max={selectedSubmission.max_score || 10}
                        step="0.5"
                        value={gradeScore}
                        onChange={(e) => setGradeScore(e.target.value)}
                        className="score-input"
                      />
                    </label>
                  </div>
                  
                  <div className="form-row">
                    <label>
                      Nhận xét:
                      <textarea
                        value={gradeFeedback}
                        onChange={(e) => setGradeFeedback(e.target.value)}
                        placeholder="Nhập nhận xét cho sinh viên..."
                        rows={4}
                      />
                    </label>
                  </div>

                  <button
                    onClick={handleGradeSubmit}
                    disabled={grading || !gradeScore}
                    className="btn-grade"
                  >
                    {grading ? (
                      <>
                        <div className="btn-spinner"></div>
                        Đang lưu...
                      </>
                    ) : (
                      <>
                        <Send size={18} />
                        {selectedSubmission.status === 'graded' ? 'Cập nhật điểm' : 'Chấm điểm'}
                      </>
                    )}
                  </button>
                </div>
              </div>
            </>
          ) : (
            <div className="no-selection">
              <Eye size={48} />
              <p>Chọn một bài nộp để xem chi tiết và chấm điểm</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default EssayReviewPage;
