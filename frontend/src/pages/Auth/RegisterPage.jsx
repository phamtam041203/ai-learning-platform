import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './RegisterPage.css';

const RegisterPage = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState({
    fullName: '',
    intake_year: 25,
    email: '',
    password: '',
    confirmPassword: '',
    major: 'Công nghệ thông tin',
    specialization: 'Công nghệ phần mềm',
    class_name: '',
    phone: '',
    agreedToTerms: false
  });
  const [errors, setErrors] = useState({});
  const [isLoading, setIsLoading] = useState(false);
  const [previewMSSV, setPreviewMSSV] = useState(null);
  const [loadingPreview, setLoadingPreview] = useState(false);
  const [registrationSuccess, setRegistrationSuccess] = useState(false);
  const [generatedMSSV, setGeneratedMSSV] = useState('');

  // Reset dark mode when entering register page
  useEffect(() => {
    document.documentElement.removeAttribute('data-theme');
  }, []);

  // ⭐ SVG ICONS
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

  const BookIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
    </svg>
  );

  const GraduationCapIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
      <path d="M6 12v5c3 3 9 3 12 0v-5"/>
    </svg>
  );

  const CalendarIcon = () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
      <line x1="16" y1="2" x2="16" y2="6"/>
      <line x1="8" y1="2" x2="8" y2="6"/>
      <line x1="3" y1="10" x2="21" y2="10"/>
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
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
      <polyline points="22 4 12 14.01 9 11.01"/>
    </svg>
  );

  // Auto-update class_name based on specialization
  useEffect(() => {
    if (!formData.intake_year || !formData.specialization) return;

    const specializationMap = {
      'Công nghệ phần mềm': 'CNPM',
      'Công nghệ dữ liệu': 'CNDL',
      'An ninh mạng': 'ANM',
    };

    const newClassName = `${specializationMap[formData.specialization] || 'CNTT'}-K${formData.intake_year}`;

    if (formData.class_name !== newClassName) {
      setFormData(prev => ({
        ...prev,
        class_name: newClassName
      }));
    }
  }, [formData.intake_year, formData.specialization]);


  // // Fetch preview MSSV
  // useEffect(() => {
  //   if (formData.intake_year >= 20 && formData.intake_year <= 99) {
  //     fetchMSSVPreview(formData.intake_year);
  //   }
  // }, [formData.intake_year]);

  const fetchMSSVPreview = async (intakeYear) => {
    setLoadingPreview(true);
    try {
      const response = await fetch(`http://localhost:8000/api/auth/preview-mssv/${intakeYear}`);
      if (response.ok) {
        const data = await response.json();
        setPreviewMSSV(data);
      }
    } catch (error) {
      console.error('Error fetching MSSV preview:', error);
    } finally {
      setLoadingPreview(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;

    setFormData(prev => ({
      ...prev,
      [name]:
        name === 'intake_year'
          ? Number(value)
          : type === 'checkbox'
          ? checked
          : value
    }));

    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };


  const validateStep1 = () => {
    const newErrors = {};
    
    if (!formData.fullName.trim()) {
      newErrors.fullName = 'Họ tên là bắt buộc';
    } else if (formData.fullName.length < 2) {
      newErrors.fullName = 'Họ tên quá ngắn';
    }
    
    if (!formData.intake_year) {
      newErrors.intake_year = 'Vui lòng chọn khóa';
    }
    
    if (!formData.email) {
      newErrors.email = 'Email là bắt buộc';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email không hợp lệ';
    } else if (!formData.email.includes('@vanlanguni.vn')) {
      newErrors.email = 'Vui lòng sử dụng email @vanlanguni.vn';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateStep2 = () => {
    const newErrors = {};
    
    if (!formData.password) {
      newErrors.password = 'Mật khẩu là bắt buộc';
    } else if (formData.password.length < 8) {
      newErrors.password = 'Mật khẩu phải có ít nhất 8 ký tự';
    } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(formData.password)) {
      newErrors.password = 'Mật khẩu phải chứa chữ hoa, chữ thường và số';
    }
    
    if (!formData.confirmPassword) {
      newErrors.confirmPassword = 'Vui lòng xác nhận mật khẩu';
    } else if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Mật khẩu không khớp';
    }
    
    if (!formData.agreedToTerms) {
      newErrors.agreedToTerms = 'Bạn phải đồng ý với điều khoản sử dụng';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (currentStep === 1 && validateStep1()) {
      setCurrentStep(2);
    }
  };

  const handleBack = () => {
    setCurrentStep(1);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateStep2()) return;
    
    setIsLoading(true);
    
    try {
      const submitData = {
        email: formData.email,
        password: formData.password,
        full_name: formData.fullName,
        role: 'student',
        intake_year: parseInt(formData.intake_year),
        major: formData.major,
        specialization: formData.specialization,
        class_name: formData.class_name,
        phone: formData.phone || null,
        education_type: '0'
      };

      const response = await fetch('http://localhost:8000/api/auth/register/student', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(submitData)
      });

      const data = await response.json();

      if (response.ok) {
        setGeneratedMSSV(data.generated_student_id);
        setRegistrationSuccess(true);
        
        setTimeout(() => {
          navigate('/login');
        }, 5000);
      } else {
        if (data.detail) {
          if (data.detail.includes('Email')) {
            setErrors({ submit: 'Email đã được sử dụng' });
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

  const passwordStrength = () => {
    const password = formData.password;
    if (!password) return { label: '', strength: 0, color: '' };
    
    let strength = 0;
    if (password.length >= 8) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z\d]/.test(password)) strength++;
    
    if (strength <= 2) return { label: 'Yếu', strength: 33, color: '#ef4444' };
    if (strength === 3) return { label: 'Trung bình', strength: 66, color: '#f59e0b' };
    return { label: 'Mạnh', strength: 100, color: '#10b981' };
  };

  const strength = passwordStrength();

  // Cho phép K23 đến K30
  const yearOptions = [23, 24, 25, 26, 27, 28, 29, 30];

  // SUCCESS SCREEN
  if (registrationSuccess) {
    return (
      <div className="register-page">
        <div className="success-screen">
          <div className="success-card">
            <div className="success-icon">
              <CheckCircleIcon />
            </div>
            
            <h2 className="success-title">Đăng ký thành công!</h2>
            
            <div className="mssv-display">
              <p className="mssv-label">Mã số sinh viên của bạn:</p>
              <h1 className="mssv-code">{generatedMSSV}</h1>
            </div>
            
            <div className="success-info">
              <div className="info-item">
                <UserIcon />
                <span>{formData.fullName}</span>
              </div>
              <div className="info-item">
                <BookIcon />
                <span>{formData.class_name}</span>
              </div>
              <div className="info-item">
                <MailIcon />
                <span>{formData.email}</span>
              </div>
            </div>
            
            <p className="success-note">
              📝 Vui lòng ghi nhớ MSSV để sử dụng trong quá trình học tập
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
    <div className="register-page">
      <div className="register-container">
        {/* Left Side - Form */}
        <div className="register-form-section">
          <div className="register-header">
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

          <div className="register-content">
            {/* Progress Steps */}
            <div className="progress-steps">
              <div className={`step ${currentStep >= 1 ? 'active' : ''} ${currentStep > 1 ? 'completed' : ''}`}>
                <div className="step-circle">
                  {currentStep > 1 ? <CheckCircleIcon /> : '1'}
                </div>
                <span className="step-label">Thông tin cá nhân</span>
              </div>
              <div className="step-line"></div>
              <div className={`step ${currentStep >= 2 ? 'active' : ''}`}>
                <div className="step-circle">2</div>
                <span className="step-label">Bảo mật</span>
              </div>
            </div>

            <div className="welcome-text">
              <h2 className="welcome-title">
                {currentStep === 1 ? 'Đăng Ký Sinh Viên 🎓' : 'Thiết Lập Bảo Mật 🔒'}
              </h2>
              <p className="welcome-description">
                {currentStep === 1 
                  ? 'Điền thông tin để bắt đầu hành trình học tập thông minh' 
                  : 'Tạo mật khẩu mạnh để bảo vệ tài khoản'}
              </p>
            </div>

            <form onSubmit={handleSubmit} className="register-form">
              {/* STEP 1 */}
              {currentStep === 1 && (
                <div className="form-step">
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
                        placeholder="Nguyễn Văn A"
                      />
                    </div>
                    {errors.fullName && (
                      <div className="error-message">
                        <AlertIcon />
                        <span>{errors.fullName}</span>
                      </div>
                    )}
                  </div>

                  {/* Intake Year */}
                  <div className="form-group highlight-group">
                    <label className="form-label">
                      <GraduationCapIcon />
                      Khóa học
                    </label>
                    <div className="input-wrapper">
                      <div className="input-icon"><CalendarIcon /></div>
                      <select
                        name="intake_year"
                        value={formData.intake_year}
                        onChange={handleChange}
                        className={`form-input ${errors.intake_year ? 'error' : ''}`}
                      >
                        <option value="">Chọn khóa</option>
                        {yearOptions.map(year => (
                          <option key={year} value={year}>
                            K{year}
                          </option>
                        ))}
                      </select>
                    </div>
                    {errors.intake_year && (
                      <div className="error-message">
                        <AlertIcon />
                        <span>{errors.intake_year}</span>
                      </div>
                    )}
                    
                    {/* MSSV Preview */}
                    {previewMSSV && !loadingPreview && (
                      <div className="mssv-preview">
                        <div className="preview-header">
                          <span className="preview-icon">📋</span>
                          <span className="preview-title">MSSV dự kiến của bạn:</span>
                        </div>
                        <div className="preview-mssv">{previewMSSV.preview_mssv}</div>
                        <div className="preview-info">
                          <div className="info-row">
                            <span className="info-label">Năm nhập học:</span>
                            <span className="info-value">{previewMSSV.intake_info.nam_nhap_hoc}</span>
                          </div>
                          <div className="info-row">
                            <span className="info-label">Dự kiến tốt nghiệp:</span>
                            <span className="info-value">{previewMSSV.intake_info.nam_tot_nghiep_du_kien}</span>
                          </div>
                        </div>
                        <p className="preview-note">
                          * MSSV thực tế sẽ được tạo tự động khi đăng ký
                        </p>
                      </div>
                    )}
                  </div>

                  {/* Major - Fixed as CNTT */}
                  <div className="form-group">
                    <label className="form-label">Ngành học</label>
                    <div className="input-wrapper">
                      <div className="input-icon"><BookIcon /></div>
                      <input
                        type="text"
                        name="major"
                        value="Công nghệ thông tin"
                        readOnly
                        className="form-input auto-filled"
                      />
                    </div>
                  </div>

                  {/* Specialization - Chuyên ngành */}
                  <div className="form-group">
                    <label className="form-label">Chuyên ngành</label>
                    <div className="input-wrapper">
                      <div className="input-icon"><BookIcon /></div>
                      <select
                        name="specialization"
                        value={formData.specialization}
                        onChange={handleChange}
                        className="form-input"
                      >
                        <option value="Công nghệ phần mềm">Công nghệ phần mềm</option>
                        <option value="Công nghệ dữ liệu">Công nghệ dữ liệu</option>
                        <option value="An ninh mạng">An ninh mạng</option>
                      </select>
                    </div>
                  </div>

                  {/* Class (Auto) */}
                  <div className="form-group">
                    <label className="form-label">Lớp (Tự động)</label>
                    <div className="input-wrapper">
                      <div className="input-icon"><BookIcon /></div>
                      <input
                        type="text"
                        name="class_name"
                        value={formData.class_name}
                        readOnly
                        className="form-input auto-filled"
                        placeholder="CNTT-K27"
                      />
                    </div>
                    <small className="form-hint">Tự động điền theo khóa và ngành</small>
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
                        placeholder="your.email@vanlanguni.vn"
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

                  {errors.submit && (
                    <div className="form-error">
                      <AlertIcon />
                      <span>{errors.submit}</span>
                    </div>
                  )}

                  <button type="button" onClick={handleNext} className="submit-button">
                    Tiếp tục
                    <ArrowRightIcon />
                  </button>
                </div>
              )}

              {/* STEP 2 */}
              {currentStep === 2 && (
                <div className="form-step">
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
                      />
                      <button
                        type="button"
                        className="toggle-password"
                        onClick={() => setShowPassword(!showPassword)}
                      >
                        {showPassword ? <EyeOffIcon /> : <EyeIcon />}
                      </button>
                    </div>
                    {formData.password && (
                      <div className="password-strength">
                        <div className="strength-bar">
                          <div 
                            className="strength-fill" 
                            style={{ 
                              width: `${strength.strength}%`,
                              background: strength.color
                            }}
                          ></div>
                        </div>
                        <span style={{ color: strength.color }}>{strength.label}</span>
                      </div>
                    )}
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

                  <div className="button-group">
                    <button type="button" onClick={handleBack} className="back-button">
                      Quay lại
                    </button>
                    <button type="submit" className="submit-button" disabled={isLoading}>
                      {isLoading ? (
                        <>
                          <div className="loading-spinner"></div>
                          Đang đăng ký...
                        </>
                      ) : (
                        <>
                          Đăng ký
                          <ArrowRightIcon />
                        </>
                      )}
                    </button>
                  </div>
                </div>
              )}
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
        <div className="register-illustration-section">
          <div className="illustration-content">
            <div className="illustration-badge">
              <span className="badge-dot"></span>
              Hơn 1000+ sinh viên đã đăng ký
            </div>
            
            <h2 className="illustration-title">
              Bắt Đầu Hành Trình
              <br />
              Học Tập Thông Minh
            </h2>
            
            <div className="benefits-list">
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>AI phân tích phong cách học tập cá nhân</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Đề xuất tài liệu phù hợp với độ chính xác 85%</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Chatbot hỗ trợ 24/7</span>
              </div>
              <div className="benefit-item">
                <div className="benefit-icon">✓</div>
                <span>Theo dõi tiến độ chi tiết</span>
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

export default RegisterPage;