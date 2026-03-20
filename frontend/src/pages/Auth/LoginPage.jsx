import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './LoginPage.css';
import { Link } from 'react-router-dom';
import axios from "axios";
import SpecializationModal from '../../components/SpecializationModal';
import { API_BASE_URL } from '../../config/api';

const LoginPage = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showSpecializationModal, setShowSpecializationModal] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    rememberMe: false
  });
  const [errors, setErrors] = useState({});
  const [isLoading, setIsLoading] = useState(false);

  // Reset dark mode when entering login page
  useEffect(() => {
    document.documentElement.removeAttribute('data-theme');
  }, []);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.email) {
      newErrors.email = 'Email không được để trống';
    } else if (formData.email !== 'admin' && !/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email không hợp lệ';
    }

    if (!formData.password) {
      newErrors.password = 'Mật khẩu không được để trống';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSpecializationSelect = (specialization) => {
    console.log(' Specialization selected:', specialization);
    setShowSpecializationModal(false);
    navigate('/student/dashboard', { replace: true });
  };

  const formatErrorDetail = (detail) => {
    if (!detail) return 'Email hoặc mật khẩu không đúng';
    if (Array.isArray(detail)) {
      return detail.map((item) => item?.msg || JSON.stringify(item)).join(', ');
    }
    if (typeof detail === 'object') {
      return detail.msg || JSON.stringify(detail);
    }
    return String(detail);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) return;

    setIsLoading(true);
    setErrors({});

    try {
      console.log('🔄 Attempting login...');

      // ===============================
      // STEP 1: LOGIN
      // ===============================
      const response = await fetch(`${API_BASE_URL}/api/auth/login-basic`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: formData.email,
          password: formData.password,
        }),
      });

      console.log('📡 Response status:', response.status);

      const data = await response.json();
      console.log('📦 Response data:', data);

      if (!response.ok) {
        console.log('❌ Login failed:', data);
        setErrors({ submit: formatErrorDetail(data.detail) });
        setIsLoading(false);
        return;
      }

      console.log(' Login successful!');

      // ===============================
      // 🔥 CLEAR DỮ LIỆU CŨ
      // ===============================
      localStorage.removeItem('currentUser');
      localStorage.removeItem('profile');
      localStorage.removeItem('token');
      sessionStorage.removeItem('token');

      // ===============================
      // ⭐ LƯU TOKEN
      // ===============================
      const token = data.access_token;
      console.log('🔑 Token received:', token ? 'Yes' : 'No');
      console.log('🔑 Token value:', token?.substring(0, 50) + '...');

      if (!token) {
        throw new Error('Không nhận được token từ server');
      }

      // ⭐ Lưu token vào localStorage (luôn luôn để API calls hoạt động)
      localStorage.setItem('token', token);
      localStorage.setItem('access_token', token);
      console.log(' Token saved to localStorage');
      
      // Nếu remember me, cũng lưu vào sessionStorage
      if (formData.rememberMe) {
        sessionStorage.setItem('token', token);
        console.log(' Token also saved to sessionStorage (remember me)');
      }

      // ===============================
      // ⭐ LƯU USER HIỆN TẠI (từ login response)
      // ===============================
      console.log('👤 User data from login response:', data);
      console.log('📋 Profile data:', data.profile);
      console.log('🎓 Specialization from profile:', data.profile?.specialization);
      
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

      console.log('💾 Saving current user:', currentUser);
      localStorage.setItem('currentUser', JSON.stringify(currentUser));
      localStorage.setItem('user', JSON.stringify(currentUser));

      // ===============================
      // ⭐ REDIRECT THEO ROLE
      // ===============================
      console.log('🎯 User role detected:', currentUser.role);

      if (currentUser.role === 'student') {
        // ⭐ Giai đoạn hiện tại chỉ hỗ trợ CNPM
        const validSpecializations = ['CNPM'];
        const hasValidSpecialization = validSpecializations.includes(currentUser.specialization);
        
        if (!currentUser.specialization || !hasValidSpecialization) {
          console.log('➡️ Showing specialization modal (specialization:', currentUser.specialization, ')');
          setShowSpecializationModal(true);
          setIsLoading(false);
          return;
        }
        console.log('➡️ Redirecting to STUDENT dashboard');
        navigate('/student/dashboard', { replace: true });
      } else if (currentUser.role === 'teacher') {
        console.log('➡️ Redirecting to TEACHER dashboard');
        navigate('/teacher/dashboard', { replace: true });
      } else if (currentUser.role === 'admin') {
        console.log('➡️ Redirecting to ADMIN dashboard');
        navigate('/admin/dashboard', { replace: true });
      } else {
        console.log('⚠️ Unknown role, redirecting to home');
        navigate('/', { replace: true });
      }

    } catch (error) {
      console.error('❌ Login error:', error);
      setErrors({
        submit: error?.message ? String(error.message) : 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleTeamsLogin = () => {
    const frontendRedirect = `${window.location.origin}/auth/teams/callback`;
    window.location.href = `${API_BASE_URL}/api/auth/teams/login?redirect=${encodeURIComponent(frontendRedirect)}`;
  };

  // ============================================
  // SVG ICONS
  // ============================================
  
  const MailIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
      <polyline points="22,6 12,13 2,6"/>
    </svg>
  );

  const LockIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
      <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
    </svg>
  );

  const EyeIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
      <circle cx="12" cy="12" r="3"/>
    </svg>
  );

  const EyeOffIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
      <line x1="1" y1="1" x2="23" y2="23"/>
    </svg>
  );

  const BrainIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"/>
      <path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"/>
    </svg>
  );

  const AlertIcon = () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10"/>
      <line x1="12" y1="8" x2="12" y2="12"/>
      <line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>
  );

  const ArrowRightIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <line x1="5" y1="12" x2="19" y2="12"/>
      <polyline points="12 5 19 12 12 19"/>
    </svg>
  );

  const UserIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
      <circle cx="12" cy="7" r="4"/>
    </svg>
  );

  const GraduationCapIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
      <path d="M6 12v5c3 3 9 3 12 0v-5"/>
    </svg>
  );

  return (
    <div className="login-page">
      <div className="login-container">
        {/* Left Side - Form */}
        <div className="login-form-section">
          <div className="login-header">
            <div className="logo-section">
              <div className="logo-icon">
                <BrainIcon />
              </div>
              <div>
                <h1 className="logo-title">AI Learning Platform</h1>
                <p className="logo-subtitle">Trường ĐH Văn Lang</p>
              </div>
            </div>
          </div>

          <div className="login-content">
            <div className="welcome-text">
              <h2 className="welcome-title">Chào mừng trở lại! 👋</h2>
              <p className="welcome-description">
                Đăng nhập để tiếp tục hành trình học tập của bạn
              </p>
            </div>

            <form onSubmit={handleSubmit} className="login-form">
              {/* Email */}
              <div className="form-group">
                <label className="form-label">Email</label>
                <div className="input-wrapper">
                  <div className="input-icon">
                    <MailIcon />
                  </div>
                  <input
                    type="text"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className={`form-input ${errors.email ? 'error' : ''}`}
                    placeholder="your.email@vanlanguni.vn"
                    disabled={isLoading}
                  />
                </div>
                {errors.email && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.email}</span>
                  </div>
                )}
              </div>

              {/* Password */}
              <div className="form-group">
                <label className="form-label">Mật khẩu</label>
                <div className="input-wrapper">
                  <div className="input-icon">
                    <LockIcon />
                  </div>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    className={`form-input ${errors.password ? 'error' : ''}`}
                    placeholder="••••••••"
                    disabled={isLoading}
                  />
                  <button
                    type="button"
                    className="toggle-password"
                    onClick={() => setShowPassword(!showPassword)}
                    tabIndex="-1"
                  >
                    {showPassword ? <EyeOffIcon /> : <EyeIcon />}
                  </button>
                </div>
                {errors.password && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.password}</span>
                  </div>
                )}
              </div>

              {/* Remember me & Forgot password */}
              <div className="form-options">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    name="rememberMe"
                    checked={formData.rememberMe}
                    onChange={handleChange}
                    disabled={isLoading}
                    className="checkbox-input"
                  />
                  <span>Ghi nhớ đăng nhập</span>
                </label>
                <a href="/forgot-password" className="forgot-link">
                  Quên mật khẩu?
                </a>
              </div>

              {/* Submit Error */}
              {errors.submit && (
                <div className="form-error">
                  <AlertIcon />
                  <span>{formatErrorDetail(errors.submit)}</span>
                </div>
              )}

              {/* Submit Button */}
              <button 
                type="submit" 
                className="submit-button"
                disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <div className="loading-spinner"></div>
                    Đang đăng nhập...
                  </>
                ) : (
                  <>
                    Đăng nhập
                    <ArrowRightIcon />
                  </>
                )}
              </button>

              <button
                type="button"
                className="teams-login-button"
                onClick={handleTeamsLogin}
                disabled={isLoading}
              >
                <span className="teams-icon">T</span>
                Đăng nhập bằng Microsoft Teams
              </button>
            </form>

            {/* Divider */}
            <div className="divider">
              <span>Chưa có tài khoản?</span>
            </div>

            {/* Register Options */}
            <div className="register-options">
              <a href="/register" className="register-link student">
                <UserIcon />
                <span>Đăng ký Sinh viên</span>
              </a>
            </div>

            <div className="back-to-home">
              <p className="back-link" style={{ cursor: 'default' }}>
                Tài khoản giảng viên do admin tạo và cấp quyền trong hệ thống
              </p>
            </div>

            {/* Back to home */}
            <div className="back-to-home">
              <a href="/" className="back-link">
                ← Về trang chủ
              </a>
            </div>
          </div>
        </div>

        {/* Right Side - Illustration */}
        <div className="login-illustration-section">
          <div className="illustration-content">
            <div className="illustration-badge">
              <span className="badge-dot"></span>
              Được tin dùng bởi hơn 1000+ người dùng
            </div>
            
            <h2 className="illustration-title">
              Học Tập Thông Minh
              <br />
              Cùng AI
            </h2>
            
            <div className="features-list">
              <div className="feature-item">
                <div className="feature-icon">🎯</div>
                <div className="feature-content">
                  <h3>Phân tích cá nhân hóa</h3>
                  <p>AI phân tích phong cách học tập riêng của bạn</p>
                </div>
              </div>
              
              <div className="feature-item">
                <div className="feature-icon">📚</div>
                <div className="feature-content">
                  <h3>Đề xuất thông minh</h3>
                  <p>Tài liệu phù hợp với độ chính xác 85%</p>
                </div>
              </div>
              
              <div className="feature-item">
                <div className="feature-icon">💬</div>
                <div className="feature-content">
                  <h3>Hỗ trợ 24/7</h3>
                  <p>Chatbot AI luôn sẵn sàng giải đáp</p>
                </div>
              </div>
              
              <div className="feature-item">
                <div className="feature-icon">📊</div>
                <div className="feature-content">
                  <h3>Theo dõi tiến độ</h3>
                  <p>Dashboard chi tiết về quá trình học</p>
                </div>
              </div>
            </div>

            <div className="stats-row">
              <div className="stat-item">
                <div className="stat-number">1000+</div>
                <div className="stat-label">Sinh viên</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">100+</div>
                <div className="stat-label">Giảng viên</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">85%</div>
                <div className="stat-label">Độ chính xác</div>
              </div>
            </div>
          </div>
          
          <div className="illustration-decoration">
            <div className="decoration-circle circle-1"></div>
            <div className="decoration-circle circle-2"></div>
            <div className="decoration-circle circle-3"></div>
          </div>
        </div>
      </div>

      {/* Specialization Selection Modal */}
      <SpecializationModal 
        isOpen={showSpecializationModal} 
        onSelect={handleSpecializationSelect}
      />
    </div>
  );
};

export default LoginPage;