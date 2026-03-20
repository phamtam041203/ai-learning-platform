import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI, studentAPI } from '../../services/api';
import { User, Mail, GraduationCap, BookOpen, Clock, Award, TrendingUp, Edit2, Save, X, Home, LogOut, Phone, MapPin, Calendar, Building2 } from 'lucide-react';
import SpecializationModal from '../../components/SpecializationModal';
import { buildBackendUrl } from '../../config/api';
import './ProfilePage.css';

const ProfilePage = () => {
  const navigate = useNavigate();
  const avatarInputRef = useRef(null);
  const [user, setUser] = useState(null);
  const [statistics, setStatistics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editedData, setEditedData] = useState({});
  const [saveMessage, setSaveMessage] = useState('');
  const [showSpecializationModal, setShowSpecializationModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [avatarUploading, setAvatarUploading] = useState(false);

  const syncStoredUser = (userData) => {
    const storedUser = {
      id: userData.id,
      email: userData.email,
      name: userData.full_name,
      full_name: userData.full_name,
      role: userData.role,
      specialization: userData.specialization ?? null,
      studentId: userData.student_id ?? null,
      student_id: userData.student_id ?? null,
      major: userData.major ?? null,
      className: userData.class_name ?? null,
      class_name: userData.class_name ?? null,
      phone: userData.phone ?? null,
      address: userData.address ?? null,
      dateOfBirth: userData.date_of_birth ?? null,
      date_of_birth: userData.date_of_birth ?? null,
      intakeYear: userData.intake_year ?? null,
      intake_year: userData.intake_year ?? null,
      avatar: userData.avatar ?? null,
    };

    localStorage.setItem('currentUser', JSON.stringify(storedUser));
    localStorage.setItem('user', JSON.stringify(storedUser));
  };

  const toEditableUserData = (response) => {
    const combined = {
      ...response.user,
      ...(response.profile || {}),
    };

    return {
      ...combined,
      full_name: combined.full_name || '',
      email: combined.email || '',
      phone: combined.phone || '',
      address: combined.address || '',
      date_of_birth: combined.date_of_birth || '',
      student_id: combined.student_id || '',
      major: combined.major || '',
      specialization: combined.specialization || '',
      class_name: combined.class_name || '',
      intake_year: combined.intake_year || '',
      avatar: combined.avatar || null,
    };
  };

  const buildEditState = (userData) => ({
    full_name: userData.full_name || '',
    email: userData.email || '',
    phone: userData.phone || '',
    address: userData.address || '',
    date_of_birth: userData.date_of_birth || '',
    student_id: userData.student_id || '',
    major: userData.major || '',
    specialization: userData.specialization || '',
    class_name: userData.class_name || '',
    intake_year: userData.intake_year || ''
  });

  const getSpecializationLabel = (specialization) => {
    if (specialization === 'CNPM') {
      return 'Công nghệ phần mềm (CNPM)';
    }
    return specialization || 'Chưa cập nhật';
  };

  useEffect(() => {
    fetchProfileData();
  }, []);

  const fetchProfileData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const [response, statsData] = await Promise.all([
        authAPI.getCurrentUser(),
        studentAPI.getStatistics().catch(() => null)
      ]);

      const userData = toEditableUserData(response);
      
      setUser(userData);
      setStatistics(statsData);
      setEditedData(buildEditState(userData));
      syncStoredUser(userData);
    } catch (err) {
      console.error('Error fetching profile:', err);
      setError(err.message || 'Không thể tải thông tin profile');
      
      const localUser = localStorage.getItem('user');
      if (localUser) {
        try {
          const storedUser = JSON.parse(localUser);
          const userData = {
            id: storedUser.id,
            email: storedUser.email || '',
            full_name: storedUser.full_name || storedUser.name || '',
            role: storedUser.role || 'student',
            phone: storedUser.phone || '',
            address: storedUser.address || '',
            date_of_birth: storedUser.date_of_birth || storedUser.dateOfBirth || '',
            student_id: storedUser.student_id || storedUser.studentId || '',
            major: storedUser.major || '',
            specialization: storedUser.specialization || '',
            class_name: storedUser.class_name || storedUser.className || '',
            intake_year: storedUser.intake_year || storedUser.intakeYear || '',
            avatar: storedUser.avatar || null,
          };
          setUser(userData);
          setEditedData(buildEditState(userData));
        } catch (e) {
          console.error('Error parsing local user data:', e);
        }
      }
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = () => {
    setIsEditing(true);
    setSaveMessage('');
  };

  const handleCancel = () => {
    setIsEditing(false);
    setEditedData(buildEditState(user));
    setSaveMessage('');
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      const payload = {
        full_name: editedData.full_name,
        phone: editedData.phone,
        address: editedData.address,
        date_of_birth: editedData.date_of_birth,
        class_name: editedData.class_name,
        intake_year: editedData.intake_year === '' ? null : Number(editedData.intake_year),
      };

      const response = await studentAPI.updateProfile(payload);
      const updatedUser = toEditableUserData(response);
      setUser(updatedUser);
      setEditedData(buildEditState(updatedUser));
      syncStoredUser(updatedUser);
      setIsEditing(false);
      setSaveMessage('✅ Đã lưu thay đổi thành công!');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (err) {
      console.error('Error saving profile:', err);
      setSaveMessage(`❌ ${err.message || 'Lỗi khi lưu thay đổi'}`);
    } finally {
      setSaving(false);
    }
  };

  const handleInputChange = (field, value) => {
    setEditedData(prev => ({ ...prev, [field]: value }));
  };

  const handleSpecializationSelect = (specialization) => {
    const updatedUser = { ...user, specialization };
    setUser(updatedUser);
    setEditedData(prev => ({ ...prev, specialization }));
    syncStoredUser(updatedUser);
    setShowSpecializationModal(false);
  };

  const handleAvatarButtonClick = () => {
    avatarInputRef.current?.click();
  };

  const handleAvatarChange = async (event) => {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    try {
      setAvatarUploading(true);
      setSaveMessage('');
      const response = await studentAPI.uploadAvatar(file);
      const updatedUser = { ...user, avatar: response.avatar };
      setUser(updatedUser);
      syncStoredUser(updatedUser);
      setSaveMessage('✅ Đã cập nhật ảnh đại diện thành công!');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (err) {
      console.error('Error uploading avatar:', err);
      setSaveMessage(`❌ ${err.message || 'Lỗi khi cập nhật ảnh đại diện'}`);
    } finally {
      setAvatarUploading(false);
      event.target.value = '';
    }
  };

  const avatarUrl = user?.avatar ? buildBackendUrl(user.avatar) : null;

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Đang tải thông tin...</p>
      </div>
    );
  }

  if (error && !user) {
    return (
      <div className="error-container">
        <div className="error-card">
          <X className="error-icon" />
          <h2>Không thể tải profile</h2>
          <p>{error}</p>
          <button onClick={() => navigate('/student/dashboard')} className="btn-back">
            Quay lại Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="profile-page">
      {/* Cover Background */}
      <div className="profile-cover">
        <div className="cover-gradient"></div>
        <div className="cover-pattern"></div>
      </div>

      {/* Main Content */}
      <div className="profile-container">
        {/* Header Card */}
        <div className="profile-card profile-header-card">
          <div className="profile-header-content">
            {/* Avatar Section */}
            <div className="avatar-section">
              <div className="avatar-wrapper">
                <div className="avatar-circle">
                  {avatarUrl ? (
                    <img src={avatarUrl} alt="Ảnh đại diện" className="avatar-image" />
                  ) : (
                    <span className="avatar-text">
                      {user?.full_name?.charAt(0)?.toUpperCase() || user?.email?.charAt(0)?.toUpperCase() || 'U'}
                    </span>
                  )}
                </div>
                <input
                  ref={avatarInputRef}
                  type="file"
                  accept="image/png,image/jpeg,image/webp"
                  className="sr-only"
                  onChange={handleAvatarChange}
                />
                <button
                  className="avatar-upload-btn"
                  title="Thay đổi ảnh"
                  onClick={handleAvatarButtonClick}
                  disabled={avatarUploading}
                  type="button"
                >
                  <Edit2 size={16} />
                </button>
              </div>
              <p className="avatar-help-text">
                {avatarUploading ? 'Đang tải ảnh lên...' : 'JPG, PNG hoặc WEBP, tối đa 5MB'}
              </p>
            </div>

            {/* Info Section */}
            <div className="profile-info-section">
              <h1 className="profile-title">{user?.full_name || 'Chưa cập nhật'}</h1>
              <p className="profile-subtitle">{user?.email}</p>
              <div className="profile-tags">
                <span className="tag tag-primary">
                  <GraduationCap size={14} />
                  {user?.role === 'student' ? 'Sinh viên' : user?.role}
                </span>
                {user?.specialization && (
                  <span className="tag tag-secondary">
                    <BookOpen size={14} />
                    {getSpecializationLabel(user.specialization)}
                  </span>
                )}
              </div>
            </div>

            {/* Action Buttons */}
            <div className="profile-actions">
              {!isEditing ? (
                <button onClick={handleEdit} className="btn btn-primary">
                  <Edit2 size={18} />
                  Chỉnh sửa
                </button>
              ) : (
                <div className="btn-group">
                  <button onClick={handleSave} className="btn btn-success" disabled={saving}>
                    <Save size={18} />
                    {saving ? 'Đang lưu...' : 'Lưu'}
                  </button>
                  <button onClick={handleCancel} className="btn btn-outline" disabled={saving}>
                    <X size={18} />
                    Hủy
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Save Message */}
          {saveMessage && (
            <div className={`alert ${saveMessage.includes('✅') ? 'alert-success' : 'alert-error'}`}>
              {saveMessage}
            </div>
          )}
        </div>

        {/* Content Grid */}
        <div className="profile-grid">
          {/* Left Column - Personal Info */}
          <div className="profile-column">
            {/* Personal Info Card */}
            <div className="profile-card">
              <div className="card-header">
                <h2 className="card-title">
                  <User size={20} />
                  Thông Tin Cá Nhân
                </h2>
              </div>
              <div className="card-body">
                <div className="info-group">
                  <label className="info-label">Họ và tên</label>
                  {isEditing ? (
                    <input
                      type="text"
                      value={editedData.full_name}
                      onChange={(e) => handleInputChange('full_name', e.target.value)}
                      className="info-input"
                      placeholder="Nhập họ và tên"
                    />
                  ) : (
                    <p className="info-value">{user?.full_name || 'Chưa cập nhật'}</p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <Mail size={16} />
                    Email
                  </label>
                  <p className="info-value">{user?.email || 'N/A'}</p>
                  <span className="info-note">Email không thể thay đổi</span>
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <Phone size={16} />
                    Số điện thoại
                  </label>
                  {isEditing ? (
                    <input
                      type="tel"
                      value={editedData.phone}
                      onChange={(e) => handleInputChange('phone', e.target.value)}
                      className="info-input"
                      placeholder="Nhập số điện thoại"
                    />
                  ) : (
                    <p className="info-value">{user?.phone || 'Chưa cập nhật'}</p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <Calendar size={16} />
                    Ngày sinh
                  </label>
                  {isEditing ? (
                    <input
                      type="date"
                      value={editedData.date_of_birth}
                      onChange={(e) => handleInputChange('date_of_birth', e.target.value)}
                      className="info-input"
                    />
                  ) : (
                    <p className="info-value">
                      {user?.date_of_birth 
                        ? new Date(user.date_of_birth).toLocaleDateString('vi-VN', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                          })
                        : 'Chưa cập nhật'
                      }
                    </p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <MapPin size={16} />
                    Địa chỉ
                  </label>
                  {isEditing ? (
                    <textarea
                      value={editedData.address}
                      onChange={(e) => handleInputChange('address', e.target.value)}
                      className="info-input"
                      placeholder="Nhập địa chỉ"
                      rows="2"
                    />
                  ) : (
                    <p className="info-value">{user?.address || 'Chưa cập nhật'}</p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <GraduationCap size={16} />
                    Mã sinh viên
                  </label>
                  <p className="info-value">{user?.student_id || 'Chưa cập nhật'}</p>
                  {isEditing && <span className="info-note">Mã sinh viên được khóa và không thể thay đổi.</span>}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <BookOpen size={16} />
                    Chuyên ngành
                  </label>
                  <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <p className="info-value">{getSpecializationLabel(user?.specialization)}</p>
                    <button 
                      onClick={() => setShowSpecializationModal(true)}
                      className="btn-change-specialization"
                      title="Chuẩn hóa hồ sơ về CNPM"
                    >
                      🔄 Chuẩn hóa CNPM
                    </button>
                  </div>
                  <span className="info-note">Hiện tại hồ sơ sinh viên đang được chuẩn hóa về chuyên ngành CNPM</span>
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <BookOpen size={16} />
                    Ngành học
                  </label>
                  <p className="info-value">{user?.major || 'Công nghệ thông tin'}</p>
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <GraduationCap size={16} />
                    Lớp
                  </label>
                  {isEditing ? (
                    <input
                      type="text"
                      value={editedData.class_name}
                      onChange={(e) => handleInputChange('class_name', e.target.value)}
                      className="info-input"
                      placeholder="Nhập lớp (VD: 21ĐHTT01)"
                    />
                  ) : (
                    <p className="info-value">{user?.class_name || 'Chưa cập nhật'}</p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <Calendar size={16} />
                    Khóa học
                  </label>
                  {isEditing ? (
                    <input
                      type="number"
                      value={editedData.intake_year}
                      onChange={(e) => handleInputChange('intake_year', e.target.value)}
                      className="info-input"
                      placeholder="VD: 25 (cho K25)"
                      min="20"
                      max="99"
                    />
                  ) : (
                    <p className="info-value">
                      {user?.intake_year ? `K${user.intake_year}` : 'Chưa cập nhật'}
                    </p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <Building2 size={16} />
                    Trường
                  </label>
                  <p className="info-value">Đại học Văn Lang</p>
                  <span className="info-note">Thông tin mặc định</span>
                </div>

                <div className="info-group">
                  <label className="info-label">ID Người dùng</label>
                  <p className="info-value mono">{user?.id || 'N/A'}</p>
                </div>

                <div className="info-group">
                  <label className="info-label">Ngày tạo tài khoản</label>
                  <p className="info-value">
                    {user?.created_at 
                      ? new Date(user.created_at).toLocaleDateString('vi-VN', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric'
                        })
                      : 'N/A'
                    }
                  </p>
                </div>
              </div>
            </div>

            {/* Quick Actions Card */}
            <div className="profile-card">
              <div className="card-header">
                <h2 className="card-title">Thao Tác Nhanh</h2>
              </div>
              <div className="card-body">
                <button 
                  onClick={() => navigate('/student/dashboard')}
                  className="action-item"
                >
                  <Home size={20} />
                  <span>Về Dashboard</span>
                </button>
                <button 
                  onClick={() => navigate('/student/courses')}
                  className="action-item"
                >
                  <BookOpen size={20} />
                  <span>Khóa học của tôi</span>
                </button>
                <button 
                  onClick={() => {
                    localStorage.clear();
                    navigate('/login');
                  }}
                  className="action-item danger"
                >
                  <LogOut size={20} />
                  <span>Đăng xuất</span>
                </button>
              </div>
            </div>
          </div>

          {/* Right Column - Statistics */}
          <div className="profile-column">
            {statistics && (
              <div className="profile-card">
                <div className="card-header">
                  <h2 className="card-title">
                    <TrendingUp size={20} />
                    Kết Quả Học Tập
                  </h2>
                </div>
                <div className="card-body">
                  <div className="stats-grid">
                    <div className="stat-card stat-blue">
                      <div className="stat-icon">
                        <BookOpen size={24} />
                      </div>
                      <div className="stat-content">
                        <p className="stat-label">Tổng khóa học</p>
                        <h3 className="stat-value">{statistics.overview?.total_courses || 0}</h3>
                      </div>
                    </div>

                    <div className="stat-card stat-green">
                      <div className="stat-icon">
                        <Award size={24} />
                      </div>
                      <div className="stat-content">
                        <p className="stat-label">Hoàn thành</p>
                        <h3 className="stat-value">{statistics.overview?.completed_courses || 0}</h3>
                      </div>
                    </div>

                    <div className="stat-card stat-purple">
                      <div className="stat-icon">
                        <Clock size={24} />
                      </div>
                      <div className="stat-content">
                        <p className="stat-label">Thời gian học</p>
                        <h3 className="stat-value">{statistics.time?.total_hours || 0}h</h3>
                      </div>
                    </div>

                    <div className="stat-card stat-orange">
                      <div className="stat-icon">
                        <TrendingUp size={24} />
                      </div>
                      <div className="stat-content">
                        <p className="stat-label">Tỷ lệ hoàn thành</p>
                        <h3 className="stat-value">{statistics.overview?.completion_rate || 0}%</h3>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Specialization Modal */}
        <SpecializationModal 
          isOpen={showSpecializationModal} 
          onSelect={handleSpecializationSelect}
        />
      </div>
    </div>
  );
};

export default ProfilePage;
