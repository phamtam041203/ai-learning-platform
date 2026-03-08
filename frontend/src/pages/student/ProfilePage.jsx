import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI, studentAPI } from '../../services/api';
import { User, Mail, GraduationCap, BookOpen, Clock, Award, TrendingUp, Edit2, Save, X, Home, LogOut, Phone, MapPin, Calendar, Building2 } from 'lucide-react';
import SpecializationModal from '../../components/SpecializationModal';
import './ProfilePage.css';

const ProfilePage = () => {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [statistics, setStatistics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editedData, setEditedData] = useState({});
  const [saveMessage, setSaveMessage] = useState('');
  const [showSpecializationModal, setShowSpecializationModal] = useState(false);

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
      
      // ⭐ Merge user and profile data từ API response
      const userData = {
        ...response.user,
        ...response.profile
      };
      
      setUser(userData);
      setStatistics(statsData);
      setEditedData({
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
    } catch (err) {
      console.error('Error fetching profile:', err);
      setError(err.message || 'Không thể tải thông tin profile');
      
      const localUser = localStorage.getItem('user');
      if (localUser) {
        try {
          const userData = JSON.parse(localUser);
          setUser(userData);
          setEditedData({
            full_name: userData.full_name || userData.name || '',
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
    setEditedData({
      full_name: user.full_name || '',
      email: user.email || ''
    });
    setSaveMessage('');
  };

  const handleSave = async () => {
    try {
      const updatedUser = { ...user, ...editedData };
      setUser(updatedUser);
      localStorage.setItem('user', JSON.stringify(updatedUser));
      
      setIsEditing(false);
      setSaveMessage('✅ Đã lưu thay đổi thành công!');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (err) {
      console.error('Error saving profile:', err);
      setSaveMessage('❌ Lỗi khi lưu thay đổi');
    }
  };

  const handleInputChange = (field, value) => {
    setEditedData(prev => ({ ...prev, [field]: value }));
  };

  const handleSpecializationSelect = (specialization) => {
    // Update local state
    setUser(prev => ({ ...prev, specialization }));
    setEditedData(prev => ({ ...prev, specialization }));
    setShowSpecializationModal(false);
  };

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
                  <span className="avatar-text">
                    {user?.full_name?.charAt(0)?.toUpperCase() || user?.email?.charAt(0)?.toUpperCase() || 'U'}
                  </span>
                </div>
                <button className="avatar-upload-btn" title="Thay đổi ảnh">
                  <Edit2 size={16} />
                </button>
              </div>
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
                    {user.specialization}
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
                  <button onClick={handleSave} className="btn btn-success">
                    <Save size={18} />
                    Lưu
                  </button>
                  <button onClick={handleCancel} className="btn btn-outline">
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
                  {isEditing ? (
                    <input
                      type="text"
                      value={editedData.student_id}
                      onChange={(e) => handleInputChange('student_id', e.target.value)}
                      className="info-input"
                      placeholder="Nhập mã sinh viên"
                    />
                  ) : (
                    <p className="info-value">{user?.student_id || 'Chưa cập nhật'}</p>
                  )}
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <BookOpen size={16} />
                    Chuyên ngành
                  </label>
                  <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <p className="info-value">{user?.specialization || 'Chưa cập nhật'}</p>
                    <button 
                      onClick={() => setShowSpecializationModal(true)}
                      className="btn-change-specialization"
                      title="Chọn chuyên ngành khác"
                    >
                      🔄 Thay đổi
                    </button>
                  </div>
                </div>

                <div className="info-group">
                  <label className="info-label">
                    <BookOpen size={16} />
                    Ngành học
                  </label>
                  <p className="info-value">{user?.major || 'Chưa cập nhật'}</p>
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
