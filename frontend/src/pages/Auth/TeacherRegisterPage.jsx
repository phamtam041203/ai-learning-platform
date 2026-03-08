import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './TeacherRegisterPage.css';

const TeacherRegisterPage = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [formData, setFormData] = useState({
    fullName: '',
    teacherId: '',
    email: '',
    password: '',
    confirmPassword: '',
    department: 'Khoa CNTT',
    position: '',
    phone: '',
    agreedToTerms: false
  });
  const [errors, setErrors] = useState({});
  const [isLoading, setIsLoading] = useState(false);
  const [registrationSuccess, setRegistrationSuccess] = useState(false);

  // Reset dark mode when entering register page
  useEffect(() => {
    document.documentElement.removeAttribute('data-theme');
  }, []);

  // SVG ICONS (same as RegisterPage)
  const BrainIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"/>
      <path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"/>
    </svg>
  );

  const UserIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
      <circle cx="12" cy="7" r="4"/>
    </svg>
  );

  const MailIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
      <polyline points="22,6 12,13 2,6"/>
    </svg>
  );

  const LockIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
      <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
    </svg>
  );

  const EyeIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
      <circle cx="12" cy="12" r="3"/>
    </svg>
  );

  const EyeOffIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
      <line x1="1" y1="1" x2="23" y2="23"/>
    </svg>
  );

  const BadgeIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
    </svg>
  );

  const BuildingIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="4" y="2" width="16" height="20" rx="2" ry="2"/>
      <path d="M9 22v-4h6v4M8 6h.01M16 6h.01M12 6h.01M12 10h.01M12 14h.01M16 10h.01M16 14h.01M8 10h.01M8 14h.01"/>
    </svg>
  );

  const AlertIcon = () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10"/>
      <line x1="12" y1="8" x2="12" y2="12"/>
      <line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>
  );

  const ArrowRightIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="5" y1="12" x2="19" y2="12"/>
      <polyline points="12 5 19 12 12 19"/>
    </svg>
  );

  const CheckCircleIcon = () => (
    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
      <polyline points="22 4 12 14.01 9 11.01"/>
    </svg>
  );

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
    
    if (!formData.fullName.trim()) {
      newErrors.fullName = 'Họ tên là bắt buộc';
    }
    
    if (!formData.teacherId.trim()) {
      newErrors.teacherId = 'Mã giảng viên là bắt buộc';
    } else if (formData.teacherId.length < 3) {
      newErrors.teacherId = 'Mã giảng viên quá ngắn';
    }
    
    if (!formData.email) {
      newErrors.email = 'Email là bắt buộc';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email không hợp lệ';
    } else if (!formData.email.includes('@vanlanguni.vn')) {
      newErrors.email = 'Vui lòng sử dụng email @vanlanguni.vn';
    }
    
    if (!formData.password) {
      newErrors.password = 'Mật khẩu là bắt buộc';
    } else if (formData.password.length < 8) {
      newErrors.password = 'Mật khẩu phải có ít nhất 8 ký tự';
    } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(formData.password)) {
      newErrors.password = 'Mật khẩu phải chứa chữ hoa, chữ thường và số';
    }
    
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Mật khẩu không khớp';
    }
    
    if (!formData.agreedToTerms) {
      newErrors.agreedToTerms = 'Bạn phải đồng ý với điều khoản sử dụng';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setIsLoading(true);
    
    try {
      const submitData = {
        email: formData.email,
        password: formData.password,
        full_name: formData.fullName,
        role: 'teacher',
        teacher_id: formData.teacherId,
        department: formData.department,
        position: formData.position || null,
        phone: formData.phone || null
      };

      const response = await fetch('http://localhost:8000/api/auth/register/teacher', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(submitData)
      });

      const data = await response.json();

      if (response.ok) {
        setRegistrationSuccess(true);
        
        setTimeout(() => {
          navigate('/login');
        }, 5000);
      } else {
        if (data.detail) {
          if (data.detail.includes('Email')) {
            setErrors({ submit: 'Email đã được sử dụng' });
          } else if (data.detail.includes('teacher_id') || data.detail.includes('Mã giảng viên')) {
            setErrors({ submit: 'Mã giảng viên đã tồn tại' });
          } else {
            setErrors({ submit: data.detail });
          }
        } else {
          setErrors({ submit: 'Đăng ký thất bại. Vui lòng thử lại.' });
        }
        setIsLoading(false);
      }
    } catch (error) {
      console.error('Registration error:', error);
      setErrors({ 
        submit: 'Lỗi kết nối. Vui lòng kiểm tra backend đang chạy' 
      });
      setIsLoading(false);
    }
  };

  // SUCCESS SCREEN
  if (registrationSuccess) {
    return (
      <div className="teacher-register-page">
        <div className="success-screen">
          <div className="success-card">
            <div className="success-icon">
              <CheckCircleIcon />
            </div>
            
            <h2 className="success-title">Đăng ký thành công!</h2>
            
            <div className="teacher-info">
              <div className="info-item">
                <UserIcon />
                <span>{formData.fullName}</span>
              </div>
              <div className="info-item">
                <BadgeIcon />
                <span>Mã GV: {formData.teacherId}</span>
              </div>
              <div className="info-item">
                <BuildingIcon />
                <span>{formData.department}</span>
              </div>
              <div className="info-item">
                <MailIcon />
                <span>{formData.email}</span>
              </div>
            </div>
            
            <p className="success-note">
              🎓 Tài khoản giảng viên của bạn đã được tạo thành công
            </p>
            
            <div className="redirect-info">
              <div className="redirect-spinner"></div>
              <span>Đang chuyển đến trang đăng nhập...</span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="teacher-register-page">
      <div className="register-container">
        {/* Left Side */}
        <div className="register-form-section">
          <div className="register-header">
            <div className="logo-section">
              <div className="logo-icon teacher">
                <BrainIcon />
              </div>
              <div>
                <h1 className="logo-title">AI Learning Platform</h1>
                <p className="logo-subtitle">Trường ĐH Văn Lang - Giảng viên</p>
              </div>
            </div>
          </div>

          <div className="register-content">
            <div className="welcome-text">
              <h2 className="welcome-title">Đăng Ký Giảng Viên 👨‍🏫</h2>
              <p className="welcome-description">
                Tạo tài khoản để quản lý lớp học và hỗ trợ sinh viên
              </p>
            </div>

            <form onSubmit={handleSubmit} className="register-form">
              {/* Full Name */}
              <div className="form-group">
                <label className="form-label">Họ và tên</label>
                <div className="input-wrapper">
                  <div className="input-icon"><UserIcon /></div>
                  <input
                    type="text"
                    name="fullName"
                    value={formData.fullName}
                    onChange={handleChange}
                    className={`form-input ${errors.fullName ? 'error' : ''}`}
                    placeholder="TS. Nguyễn Văn A"
                    disabled={isLoading}
                  />
                </div>
                {errors.fullName && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.fullName}</span>
                  </div>
                )}
              </div>

              {/* Teacher ID */}
              <div className="form-group">
                <label className="form-label">Mã giảng viên</label>
                <div className="input-wrapper">
                  <div className="input-icon"><BadgeIcon /></div>
                  <input
                    type="text"
                    name="teacherId"
                    value={formData.teacherId}
                    onChange={handleChange}
                    className={`form-input ${errors.teacherId ? 'error' : ''}`}
                    placeholder="GV001"
                    disabled={isLoading}
                  />
                </div>
                {errors.teacherId && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.teacherId}</span>
                  </div>
                )}
              </div>

              {/* Email */}
              <div className="form-group">
                <label className="form-label">Email</label>
                <div className="input-wrapper">
                  <div className="input-icon"><MailIcon /></div>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className={`form-input ${errors.email ? 'error' : ''}`}
                    placeholder="teacher@vanlanguni.vn"
                    disabled={isLoading}
                  />
                </div>
                {errors.email && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.email}</span>
                  </div>
                )}
                <small className="form-hint">Sử dụng email @vanlanguni.vn</small>
              </div>

              {/* Department */}
              <div className="form-group">
                <label className="form-label">Khoa</label>
                <div className="input-wrapper">
                  <div className="input-icon"><BuildingIcon /></div>
                  <select
                    name="department"
                    value={formData.department}
                    onChange={handleChange}
                    className="form-input"
                    disabled={isLoading}
                  >
                    <option value="Khoa CNTT">Khoa CNTT</option>
                    <option value="Khoa Kỹ thuật">Khoa Kỹ thuật</option>
                    <option value="Khoa Kinh tế">Khoa Kinh tế</option>
                    <option value="Khoa Ngoại ngữ">Khoa Ngoại ngữ</option>
                  </select>
                </div>
              </div>

              {/* Position (Optional) */}
              <div className="form-group">
                <label className="form-label">Chức danh (Tùy chọn)</label>
                <div className="input-wrapper">
                  <div className="input-icon"><UserIcon /></div>
                  <input
                    type="text"
                    name="position"
                    value={formData.position}
                    onChange={handleChange}
                    className="form-input"
                    placeholder="Tiến sĩ, Giảng viên chính..."
                    disabled={isLoading}
                  />
                </div>
              </div>

              {/* Phone (Optional) */}
              <div className="form-group">
                <label className="form-label">Số điện thoại (Tùy chọn)</label>
                <div className="input-wrapper">
                  <div className="input-icon">📱</div>
                  <input
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    className="form-input"
                    placeholder="0987654321"
                    disabled={isLoading}
                  />
                </div>
              </div>

              {/* Password */}
              <div className="form-group">
                <label className="form-label">Mật khẩu</label>
                <div className="input-wrapper">
                  <div className="input-icon"><LockIcon /></div>
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

              {/* Confirm Password */}
              <div className="form-group">
                <label className="form-label">Xác nhận mật khẩu</label>
                <div className="input-wrapper">
                  <div className="input-icon"><LockIcon /></div>
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    name="confirmPassword"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    className={`form-input ${errors.confirmPassword ? 'error' : ''}`}
                    placeholder="••••••••"
                    disabled={isLoading}
                  />
                  <button
                    type="button"
                    className="toggle-password"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? <EyeOffIcon /> : <EyeIcon />}
                  </button>
                </div>
                {errors.confirmPassword && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.confirmPassword}</span>
                  </div>
                )}
              </div>

              {/* Terms */}
              <div className="form-group">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    name="agreedToTerms"
                    checked={formData.agreedToTerms}
                    onChange={handleChange}
                    className="checkbox-input"
                    disabled={isLoading}
                  />
                  <span>
                    Tôi đồng ý với{' '}
                    <a href="/terms" className="link">Điều khoản sử dụng</a>
                    {' '}và{' '}
                    <a href="/privacy" className="link">Chính sách bảo mật</a>
                  </span>
                </label>
                {errors.agreedToTerms && (
                  <div className="error-message">
                    <AlertIcon />
                    <span>{errors.agreedToTerms}</span>
                  </div>
                )}
              </div>

              {errors.submit && (
                <div className="form-error">
                  <AlertIcon />
                  <span>{errors.submit}</span>
                </div>
              )}

              <button type="submit" className="submit-button teacher" disabled={isLoading}>
                {isLoading ? (
                  <>
                    <div className="loading-spinner"></div>
                    Đang đăng ký...
                  </>
                ) : (
                  <>
                    Đăng ký Giảng viên
                    <ArrowRightIcon />
                  </>
                )}
              </button>
            </form>

            <div className="login-prompt">
              Đã có tài khoản?{' '}
              <a href="/login" className="login-link">
                Đăng nhập ngay
              </a>
            </div>
          </div>
        </div>

        {/* Right Side */}
        <div className="register-illustration-section teacher">
          <div className="illustration-content">
            <div className="illustration-badge">
              <span className="badge-dot"></span>
              500+ giảng viên đang sử dụng
            </div>
            
            <h2 className="illustration-title">
              Công Cụ Hỗ Trợ
              <br />
              Giảng Dạy Hiện Đại
            </h2>
            
            <div className="benefits-list">
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Quản lý lớp học dễ dàng</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Theo dõi tiến độ học tập sinh viên</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>AI hỗ trợ đánh giá tự động</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Dashboard phân tích chi tiết</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Tài liệu số hóa và chia sẻ</span>
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
    </div>
  );
};

export default TeacherRegisterPage;