import { useState, useEffect } from 'react';
import { Upload, FileText, Send, CheckCircle, Clock, AlertCircle, X, Download } from 'lucide-react';
import { buildApiUrl, buildBackendUrl } from '../config/api';
import './EssaySubmission.css';

const EssaySubmission = ({ lessonId, lessonTitle, onSubmitSuccess }) => {
  const [textContent, setTextContent] = useState('');
  const [file, setFile] = useState(null);
  const [existingSubmission, setExistingSubmission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  // Load existing submission
  useEffect(() => {
    fetchExistingSubmission();
  }, [lessonId]);

  const fetchExistingSubmission = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      const response = await fetch(
        buildApiUrl(`/lessons/${lessonId}/essay-submission`),
        {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }
      );

      if (response.ok) {
        const data = await response.json();
        if (data.submission) {
          setExistingSubmission(data.submission);
          setTextContent(data.submission.text_content || '');
        }
      }
    } catch (err) {
      console.error('Error fetching submission:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      // Check file size (50MB limit)
      if (selectedFile.size > 50 * 1024 * 1024) {
        setError('File quá lớn. Giới hạn 50MB');
        return;
      }
      setFile(selectedFile);
      setError(null);
    }
  };

  const handleRemoveFile = () => {
    setFile(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!textContent.trim() && !file) {
      setError('Vui lòng nhập nội dung bài làm hoặc tải file lên');
      return;
    }

    try {
      setSubmitting(true);
      setError(null);
      setSuccess(false);

      const token = localStorage.getItem('token');
      const formData = new FormData();
      
      if (textContent.trim()) {
        formData.append('text_content', textContent.trim());
      }
      
      if (file) {
        formData.append('file', file);
      }

      const response = await fetch(
        buildApiUrl(`/lessons/${lessonId}/essay-submit`),
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`
          },
          body: formData
        }
      );

      if (response.ok) {
        const data = await response.json();
        setSuccess(true);
        setExistingSubmission(data.submission);
        setFile(null);
        
        if (onSubmitSuccess) {
          onSubmitSuccess(data);
        }
      } else {
        const errorData = await response.json();
        setError(errorData.detail || 'Không thể nộp bài');
      }
    } catch (err) {
      console.error('Error submitting:', err);
      setError('Lỗi khi nộp bài: ' + err.message);
    } finally {
      setSubmitting(false);
    }
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  const getStatusInfo = (status) => {
    switch (status) {
      case 'submitted':
        return { text: 'Đã nộp - Chờ chấm điểm', icon: Clock, className: 'status-pending' };
      case 'graded':
        return { text: 'Đã chấm điểm', icon: CheckCircle, className: 'status-graded' };
      case 'returned':
        return { text: 'Đã trả bài', icon: CheckCircle, className: 'status-returned' };
      default:
        return { text: status, icon: AlertCircle, className: '' };
    }
  };

  if (loading) {
    return (
      <div className="essay-submission-loading">
        <div className="loading-spinner"></div>
        <p>Đang tải...</p>
      </div>
    );
  }

  return (
    <div className="essay-submission-container">
      <div className="essay-header">
        <FileText size={24} />
        <div>
          <h3>Bài tập tự luận</h3>
          <p>Nộp bài bằng cách viết vào ô văn bản hoặc tải file lên</p>
        </div>
      </div>

      {/* Existing Submission Info */}
      {existingSubmission && (
        <div className={`existing-submission ${existingSubmission.status}`}>
          <div className="submission-status">
            {(() => {
              const statusInfo = getStatusInfo(existingSubmission.status);
              const StatusIcon = statusInfo.icon;
              return (
                <>
                  <StatusIcon size={20} />
                  <span className={statusInfo.className}>{statusInfo.text}</span>
                </>
              );
            })()}
          </div>
          
          <div className="submission-details">
            <p><strong>Thời gian nộp:</strong> {new Date(existingSubmission.submitted_at).toLocaleString('vi-VN')}</p>
            
            {existingSubmission.file_name && (
              <p className="file-info">
                <FileText size={16} />
                <strong>File đã nộp:</strong> {existingSubmission.file_name}
                {existingSubmission.file_url && (
                  <a 
                    href={buildBackendUrl(existingSubmission.file_url)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="download-link"
                  >
                    <Download size={14} /> Tải xuống
                  </a>
                )}
              </p>
            )}
          </div>

          {/* Grade Result */}
          {existingSubmission.status === 'graded' && (
            <div className="grade-result">
              <div className="grade-score">
                <span className="score-value">{existingSubmission.score}</span>
                <span className="score-max">/ {existingSubmission.max_score}</span>
              </div>
              {existingSubmission.feedback && (
                <div className="grade-feedback">
                  <strong>Nhận xét của giảng viên:</strong>
                  <p>{existingSubmission.feedback}</p>
                </div>
              )}
              {existingSubmission.graded_by && (
                <p className="graded-info">
                  Chấm bởi: {existingSubmission.graded_by} 
                  {existingSubmission.graded_at && ` - ${new Date(existingSubmission.graded_at).toLocaleString('vi-VN')}`}
                </p>
              )}
            </div>
          )}

          <div className="resubmit-note">
            <AlertCircle size={16} />
            <span>Bạn có thể nộp lại bài nếu cần sửa đổi</span>
          </div>
        </div>
      )}

      {/* Success Message */}
      {success && (
        <div className="submit-success">
          <CheckCircle size={20} />
          <span>Nộp bài thành công! Giảng viên sẽ xem và chấm điểm bài làm của bạn.</span>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="submit-error">
          <AlertCircle size={20} />
          <span>{error}</span>
        </div>
      )}

      {/* Submission Form */}
      <form onSubmit={handleSubmit} className="essay-form">
        {/* Text Content */}
        <div className="form-group">
          <label htmlFor="textContent">
            <FileText size={16} />
            Nội dung bài làm (viết tại đây):
          </label>
          <textarea
            id="textContent"
            value={textContent}
            onChange={(e) => setTextContent(e.target.value)}
            placeholder="Nhập nội dung bài làm của bạn tại đây..."
            rows={10}
            disabled={submitting}
          />
          <p className="char-count">{textContent.length} ký tự</p>
        </div>

        {/* Divider */}
        <div className="form-divider">
          <span>HOẶC</span>
        </div>

        {/* File Upload */}
        <div className="form-group">
          <label>
            <Upload size={16} />
            Tải file bài làm:
          </label>
          
          <div className="file-upload-area">
            {file ? (
              <div className="selected-file">
                <FileText size={24} />
                <div className="file-info">
                  <span className="file-name">{file.name}</span>
                  <span className="file-size">{formatFileSize(file.size)}</span>
                </div>
                <button 
                  type="button" 
                  className="remove-file-btn"
                  onClick={handleRemoveFile}
                  disabled={submitting}
                >
                  <X size={18} />
                </button>
              </div>
            ) : (
              <label className="file-drop-zone">
                <input
                  type="file"
                  onChange={handleFileChange}
                  accept=".pdf,.doc,.docx,.txt,.zip,.rar,.py,.java,.js,.html,.css,.png,.jpg,.jpeg"
                  disabled={submitting}
                />
                <Upload size={32} />
                <p>Kéo thả file vào đây hoặc click để chọn</p>
                <span className="file-types">
                  Hỗ trợ: PDF, Word, TXT, ZIP, RAR, Python, Java, JS, HTML, CSS, hình ảnh
                </span>
                <span className="file-limit">Giới hạn: 50MB</span>
              </label>
            )}
          </div>
        </div>

        {/* Submit Button */}
        <div className="form-actions">
          <button 
            type="submit" 
            className="submit-btn"
            disabled={submitting || (!textContent.trim() && !file)}
          >
            {submitting ? (
              <>
                <div className="btn-spinner"></div>
                Đang nộp bài...
              </>
            ) : (
              <>
                <Send size={18} />
                {existingSubmission ? 'Nộp lại bài' : 'Nộp bài'}
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EssaySubmission;
