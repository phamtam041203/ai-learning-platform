import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  BarChart3, TrendingUp, Users, BookOpen, Award, 
  Clock, CheckCircle, ArrowUp, ArrowDown
} from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './AnalyticsPage.css';

const AnalyticsPage = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [analytics, setAnalytics] = useState(null);

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      const data = await teacherAPI.getDashboard();
      setAnalytics(data);
    } catch (err) {
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <TeacherLayout>
        <div className="analytics-page">
          <div className="loading">
            <div className="spinner"></div>
            <p>Đang tải phân tích...</p>
          </div>
        </div>
      </TeacherLayout>
    );
  }

  const stats = analytics?.stats || {};

  return (
    <TeacherLayout>
      <div className="analytics-page">
      <div className="analytics-header">
        <div>
          <h1>Thống kê & Phân tích</h1>
          <p>Xem tổng quan hiệu suất giảng dạy</p>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="overview-grid">
        <div className="overview-card">
          <div className="card-header">
            <div className="card-icon courses">
              <BookOpen />
            </div>
            <div className="trend positive">
              <ArrowUp size={16} />
              <span>+12%</span>
            </div>
          </div>
          <div className="card-body">
            <h3>{stats.total_courses || 0}</h3>
            <p>Khóa học</p>
          </div>
        </div>

        <div className="overview-card">
          <div className="card-header">
            <div className="card-icon students">
              <Users />
            </div>
            <div className="trend positive">
              <ArrowUp size={16} />
              <span>+25%</span>
            </div>
          </div>
          <div className="card-body">
            <h3>{stats.total_students || 0}</h3>
            <p>Học sinh</p>
          </div>
        </div>

        <div className="overview-card">
          <div className="card-header">
            <div className="card-icon rating">
              <Award />
            </div>
            <div className="trend positive">
              <ArrowUp size={16} />
              <span>+0.2</span>
            </div>
          </div>
          <div className="card-body">
            <h3>{stats.average_rating?.toFixed(1) || '0.0'}</h3>
            <p>Đánh giá TB</p>
          </div>
        </div>

        <div className="overview-card">
          <div className="card-header">
            <div className="card-icon completion">
              <CheckCircle />
            </div>
            <div className="trend negative">
              <ArrowDown size={16} />
              <span>-5%</span>
            </div>
          </div>
          <div className="card-body">
            <h3>78%</h3>
            <p>Tỷ lệ hoàn thành</p>
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="charts-section">
        <div className="chart-card">
          <h3>Xu hướng ghi danh</h3>
          <div className="chart-placeholder">
            <BarChart3 size={48} />
            <p>Biểu đồ đang được phát triển</p>
          </div>
        </div>

        <div className="chart-card">
          <h3>Hiệu suất khóa học</h3>
          <div className="chart-placeholder">
            <TrendingUp size={48} />
            <p>Biểu đồ đang được phát triển</p>
          </div>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="metrics-section">
        <h2>Chỉ số hiệu suất</h2>
        <div className="metrics-grid">
          <div className="metric-item">
            <div className="metric-label">Tổng số bài học</div>
            <div className="metric-value">{stats.total_lessons || 0}</div>
            <div className="metric-progress">
              <div className="progress-bar" style={{ width: '75%' }}></div>
            </div>
          </div>

          <div className="metric-item">
            <div className="metric-label">Tổng số quiz</div>
            <div className="metric-value">{stats.total_quizzes || 0}</div>
            <div className="metric-progress">
              <div className="progress-bar" style={{ width: '60%' }}></div>
            </div>
          </div>

          <div className="metric-item">
            <div className="metric-label">Bài tập chờ chấm</div>
            <div className="metric-value">{stats.pending_approvals || 0}</div>
            <div className="metric-progress">
              <div className="progress-bar alert" style={{ width: '30%' }}></div>
            </div>
          </div>

          <div className="metric-item">
            <div className="metric-label">Tỷ lệ phản hồi</div>
            <div className="metric-value">95%</div>
            <div className="metric-progress">
              <div className="progress-bar success" style={{ width: '95%' }}></div>
            </div>
          </div>
        </div>
      </div>
      </div>
    </TeacherLayout>
  );
};

export default AnalyticsPage;
