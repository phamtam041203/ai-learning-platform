import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { API_BASE_URL } from '../../config/api';
import './LoginPage.css';

const TeamsCompleteProfilePage = () => {
  const navigate = useNavigate();
  const [studentId, setStudentId] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    document.documentElement.removeAttribute('data-theme');
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!studentId.trim()) {
      setError('Vui lòng nhập MSSV');
      return;
    }

    const token = localStorage.getItem('access_token') || localStorage.getItem('token');
    if (!token) {
      setError('Không tìm thấy token. Vui lòng đăng nhập lại.');
      return;
    }

    setIsLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/api/auth/teams/complete-profile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ student_id: studentId.trim() }),
      });

      if (!response.ok) {
        const data = await response.json();
        setError(data.detail || 'Không thể lưu MSSV');
        setIsLoading(false);
        return;
      }

      const currentUserRaw = localStorage.getItem('currentUser');
      if (currentUserRaw) {
        const currentUser = JSON.parse(currentUserRaw);
        currentUser.studentId = studentId.trim();
        localStorage.setItem('currentUser', JSON.stringify(currentUser));
      }

      navigate('/student/dashboard', { replace: true });
    } catch (err) {
      setError(err?.message ? String(err.message) : 'Đã có lỗi xảy ra');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-container">
        <div className="login-form-section">
          <div className="login-content">
            <h2 className="welcome-title">Nhập MSSV lần đầu</h2>
            <p className="welcome-description">Vui lòng nhập MSSV để hoàn tất đăng nhập.</p>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">MSSV</label>
                <div className="input-wrapper">
                  <input
                    className="form-input"
                    value={studentId}
                    onChange={(e) => setStudentId(e.target.value)}
                    placeholder="VD: 2174802XXXXKXX"
                    disabled={isLoading}
                  />
                </div>
              </div>

              {error && (
                <div className="form-error">
                  <span>{error}</span>
                </div>
              )}

              <button
                type="submit"
                className="submit-button"
                disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <div className="loading-spinner"></div>
                    Đang lưu...
                  </>
                ) : (
                  'Hoàn tất'
                )}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TeamsCompleteProfilePage;
