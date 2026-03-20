import { useState } from 'react';
import { buildApiUrl } from '../config/api';
import './SpecializationModal.css';

const SPECIALIZATIONS = [
  {
    id: 'CNPM',
    name: 'Chuyên ngành Công nghệ phần mềm',
    description: 'Hệ thống hiện đang tập trung cho sinh viên CNPM, bao gồm lộ trình học, tài liệu và bài đánh giá chuyên sâu cho phát triển phần mềm.',
    icon: '💻',
    courses: ['Lập trình web', 'Phát triển backend', 'Thiết kế cơ sở dữ liệu']
  }
];

const SpecializationModal = ({ isOpen, onSelect }) => {
  const [selectedId, setSelectedId] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSelectSpecialization = async (id) => {
    setSelectedId(id);
    setError('');
    setIsLoading(true);

    try {
      // Lấy token từ localStorage
      const token = localStorage.getItem('token');
      
      if (!token) {
        setError('Không tìm thấy token. Vui lòng đăng nhập lại.');
        setIsLoading(false);
        return;
      }

      // Gọi API lưu specialization
      const response = await fetch(buildApiUrl('/student/set-specialization'), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ specialization: id })
      });

      if (!response.ok) {
        const data = await response.json();
        setError(data.detail || 'Lỗi khi lưu chuyên ngành');
        setIsLoading(false);
        return;
      }

      // Cập nhật localStorage
      const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}');
      currentUser.specialization = id;
      localStorage.setItem('currentUser', JSON.stringify(currentUser));

      // Gọi callback
      onSelect(id);

    } catch (err) {
      console.error('Error:', err);
      setError('Lỗi khi lưu chuyên ngành. Vui lòng thử lại.');
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="specialization-modal-overlay">
      <div className="specialization-modal">
        <div className="modal-header">
          <h2>🎓 Xác Nhận Chuyên Ngành Học Tập</h2>
          <p className="modal-subtitle">Giai đoạn hiện tại hệ thống chỉ mở cho chuyên ngành CNPM, nên hồ sơ sinh viên sẽ được chuẩn hóa về Công nghệ phần mềm</p>
        </div>

        {error && (
          <div className="error-message">
            ❌ {error}
          </div>
        )}

        <div className="specializations-grid">
          {SPECIALIZATIONS.map((spec) => (
            <div
              key={spec.id}
              className={`specialization-card ${selectedId === spec.id ? 'selected' : ''}`}
              onClick={() => !isLoading && handleSelectSpecialization(spec.id)}
            >
              <div className="spec-icon">{spec.icon}</div>
              <h3>{spec.name}</h3>
              <p>{spec.description}</p>
              
              <div className="spec-courses">
                <h4>Các môn học:</h4>
                <ul>
                  {spec.courses.map((course, idx) => (
                    <li key={idx}>✓ {course}</li>
                  ))}
                </ul>
              </div>

              {selectedId === spec.id && (
                <div className="selection-loader">
                  {isLoading ? (
                    <div className="spinner"></div>
                  ) : (
                    <span className="check-mark">✓ Đã chọn</span>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>

        <div className="modal-footer">
          <p className="info-text">⚠️ Khi mở rộng sang các chuyên ngành khác, phần lựa chọn này sẽ được cập nhật lại</p>
        </div>
      </div>
    </div>
  );
};

export default SpecializationModal;
