import { useState } from 'react';
import './SpecializationModal.css';

const SPECIALIZATIONS = [
  {
    id: 'CNPM',
    name: 'Chuyên ngành Phát triển phần mềm',
    description: 'Tập trung vào phát triển ứng dụng web, mobile, và hệ thống phần mềm',
    icon: '💻',
    courses: ['Web Development', 'Backend Development', 'Database Design']
  },
  {
    id: 'CNDL',
    name: 'Chuyên ngành Dữ liệu lớn',
    description: 'Xử lý, phân tích, và khai thác dữ liệu lớn với các công nghệ hiện đại',
    icon: '📊',
    courses: ['Big Data Fundamentals', 'Apache Spark', 'Data Analytics']
  },
  {
    id: 'ANM',
    name: 'Chuyên ngành An toàn mạng',
    description: 'Bảo vệ hệ thống, mạng, và dữ liệu từ các mối đe dọa an ninh mạng',
    icon: '🔒',
    courses: ['Cybersecurity', 'Cryptography', 'Network Security']
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
      const response = await fetch('http://localhost:8000/api/student/set-specialization', {
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
          <h2>🎓 Chọn Chuyên Ngành Học Tập</h2>
          <p className="modal-subtitle">Lựa chọn này sẽ quyết định các khóa học, tài liệu, và bài kiểm tra của bạn</p>
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
          <p className="info-text">⚠️ Bạn có thể thay đổi chuyên ngành sau trong phần Cài đặt hồ sơ</p>
        </div>
      </div>
    </div>
  );
};

export default SpecializationModal;
