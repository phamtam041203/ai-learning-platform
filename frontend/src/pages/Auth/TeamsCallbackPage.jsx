import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import SpecializationModal from '../../components/SpecializationModal';
import { API_BASE_URL } from '../../config/api';
import './LoginPage.css';

const TeamsCallbackPage = () => {
  const navigate = useNavigate();
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [showSpecializationModal, setShowSpecializationModal] = useState(false);

  useEffect(() => {
    const syncLogin = async () => {
      const params = new URLSearchParams(window.location.search);
      const accessToken = params.get('access_token');
      const errorCode = params.get('error');
      const errorDescription = params.get('error_description');

      if (errorCode) {
        setError(errorDescription || 'Đăng nhập Teams thất bại');
        setIsLoading(false);
        return;
      }

      if (!accessToken) {
        setError('Không nhận được token từ Teams');
        setIsLoading(false);
        return;
      }

      try {
        localStorage.setItem('token', accessToken);
        localStorage.setItem('access_token', accessToken);

        const response = await fetch(`${API_BASE_URL}/api/auth/me`, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });

        if (!response.ok) {
          const data = await response.json();
          setError(data.detail || 'Không thể lấy thông tin người dùng');
          setIsLoading(false);
          return;
        }

        const data = await response.json();

        const currentUser = {
          id: data.user.id,
          email: data.user.email,
          name: data.user.full_name,
          role: data.user.role,
          specialization: data.profile?.specialization ?? null,
          studentId: data.profile?.student_id ?? null,
          major: data.profile?.major ?? null,
          className: data.profile?.class_name ?? null,
          phone: data.profile?.phone ?? null,
          address: data.profile?.address ?? null,
          dateOfBirth: data.profile?.date_of_birth ?? null,
          intakeYear: data.profile?.intake_year ?? null,
          gender: data.profile?.gender ?? 'male',
          bio: data.profile?.bio ?? null,
          avatar: data.profile?.avatar ?? null,
        };

        localStorage.setItem('currentUser', JSON.stringify(currentUser));
        localStorage.setItem('user', JSON.stringify(currentUser));

        if (currentUser.role === 'student') {
          if (!currentUser.studentId) {
            navigate('/auth/teams/complete-profile', { replace: true });
            return;
          }

          const validSpecializations = ['CNPM'];
          const hasValidSpecialization = validSpecializations.includes(currentUser.specialization);

          if (!currentUser.specialization || !hasValidSpecialization) {
            setShowSpecializationModal(true);
            setIsLoading(false);
            return;
          }

          navigate('/student/dashboard', { replace: true });
        } else if (currentUser.role === 'teacher') {
          navigate('/teacher/dashboard', { replace: true });
        } else if (currentUser.role === 'admin') {
          navigate('/admin/dashboard', { replace: true });
        } else {
          navigate('/', { replace: true });
        }
      } catch (err) {
        setError(err?.message ? String(err.message) : 'Đã có lỗi xảy ra');
      } finally {
        setIsLoading(false);
      }
    };

    syncLogin();
  }, [navigate]);

  const handleSpecializationSelect = () => {
    setShowSpecializationModal(false);
    navigate('/student/dashboard', { replace: true });
  };

  return (
    <div className="login-page">
      <div className="login-container">
        <div className="login-form-section">
          <div className="login-content">
            <h2 className="welcome-title">Đang đăng nhập bằng Teams...</h2>
            {isLoading && (
              <button className="submit-button" disabled>
                <div className="loading-spinner"></div>
                Đang xác thực...
              </button>
            )}
            {!isLoading && error && (
              <div className="form-error">
                <span>{error}</span>
              </div>
            )}
          </div>
        </div>
      </div>
      <SpecializationModal
        isOpen={showSpecializationModal}
        onSelect={handleSpecializationSelect}
      />
    </div>
  );
};

export default TeamsCallbackPage;
