import { useState, useEffect } from 'react';
import {
  AlertTriangle,
  Award,
  BookOpen,
  CheckCircle2,
  Clock3,
  GraduationCap,
  ShieldAlert,
  TrendingUp,
  Users,
} from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './AnalyticsPage.css';

const riskMeta = {
  low: { label: 'Ổn định', className: 'low' },
  medium: { label: 'Cần chú ý', className: 'medium' },
  high: { label: 'Nguy cơ rớt môn', className: 'high' }
};

const formatPercent = (value) => `${Math.round(Number(value || 0))}%`;

const AnalyticsPage = () => {
  const [loading, setLoading] = useState(true);
  const [analytics, setAnalytics] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await teacherAPI.getAnalytics();
      setAnalytics(data);
    } catch (err) {
      console.error('Error:', err);
      setError(err.message || 'Không thể tải dữ liệu phân tích');
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

  if (error) {
    return (
      <TeacherLayout>
        <div className="analytics-page">
          <div className="analytics-empty-state">
            <ShieldAlert size={48} />
            <h2>Không thể tải dữ liệu phân tích</h2>
            <p>{error}</p>
            <button type="button" className="analytics-refresh-btn" onClick={fetchAnalytics}>
              Thử lại
            </button>
          </div>
        </div>
      </TeacherLayout>
    );
  }

  const overview = analytics?.overview || {};
  const riskDistribution = analytics?.risk_distribution || [];
  const topPerformers = analytics?.top_performers || [];
  const atRiskStudents = analytics?.at_risk_students || [];
  const courseInsights = analytics?.course_insights || [];
  const actionSummary = analytics?.action_summary || {};

  const overviewCards = [
    {
      title: 'Tổng sinh viên theo dõi',
      value: overview.total_students || 0,
      subtitle: `${overview.total_courses || 0} học phần đang giảng dạy`,
      icon: Users,
      tone: 'blue'
    },
    {
      title: 'Học tốt và ổn định',
      value: overview.students_on_track || 0,
      subtitle: 'Nhóm có thể giao thêm thử thách',
      icon: Award,
      tone: 'green'
    },
    {
      title: 'Cần can thiệp ngay',
      value: overview.high_risk_students || 0,
      subtitle: 'Sinh viên có nguy cơ rớt môn',
      icon: ShieldAlert,
      tone: 'red'
    },
    {
      title: 'Mất nhịp học tập',
      value: overview.inactive_students || 0,
      subtitle: 'Không hoạt động trong ít nhất 5 ngày',
      icon: Clock3,
      tone: 'amber'
    },
    {
      title: 'Tiến độ trung bình',
      value: formatPercent(overview.avg_progress),
      subtitle: 'So với lộ trình học hiện tại',
      icon: TrendingUp,
      tone: 'teal'
    },
    {
      title: 'Điểm trung bình',
      value: formatPercent(overview.avg_score),
      subtitle: `Tỷ lệ hoàn thành ${formatPercent(overview.completion_rate)}`,
      icon: GraduationCap,
      tone: 'violet'
    }
  ];

  return (
    <TeacherLayout>
      <div className="analytics-page">
        <div className="analytics-header">
          <div>
            <h1>AI Thống Kê Cho Giảng Viên</h1>
            <p>Nhận diện nhanh sinh viên học tốt, nhóm có nguy cơ rớt môn và các học phần cần can thiệp.</p>
          </div>
          <button type="button" className="analytics-refresh-btn" onClick={fetchAnalytics}>
            Làm mới phân tích
          </button>
        </div>

        <div className="overview-grid">
          {overviewCards.map((card) => {
            const Icon = card.icon;
            return (
              <article key={card.title} className={`overview-card tone-${card.tone}`}>
                <div className="overview-card-top">
                  <div className="card-icon">
                    <Icon size={22} />
                  </div>
                </div>
                <div className="card-body">
                  <span className="overview-label">{card.title}</span>
                  <h3>{card.value}</h3>
                  <p>{card.subtitle}</p>
                </div>
              </article>
            );
          })}
        </div>

        <div className="analytics-grid analytics-grid-primary">
          <section className="analytics-panel">
            <div className="panel-heading">
              <div>
                <h2>Phân bố rủi ro</h2>
                <p>Tóm tắt nhanh để ưu tiên hành động trong tuần.</p>
              </div>
            </div>
            <div className="risk-distribution-list">
              {riskDistribution.map((item) => (
                <div key={item.level} className={`risk-row risk-${item.level}`}>
                  <div>
                    <span className="risk-pill">{riskMeta[item.level]?.label || item.label}</span>
                    <p>{item.level === 'high' ? 'Ưu tiên trao đổi trực tiếp hoặc nhắc học.' : item.level === 'medium' ? 'Theo dõi thêm điểm và tiến độ.' : 'Nhóm đang bám sát kế hoạch học.'}</p>
                  </div>
                  <strong>{item.count}</strong>
                </div>
              ))}
            </div>

            <div className="action-summary-grid">
              <div className="mini-stat-card emphasis-red">
                <span>Cần xử lý ngay</span>
                <strong>{actionSummary.needs_intervention_now || 0}</strong>
              </div>
              <div className="mini-stat-card emphasis-amber">
                <span>Cần theo dõi thêm</span>
                <strong>{actionSummary.needs_follow_up || 0}</strong>
              </div>
              <div className="mini-stat-card emphasis-green">
                <span>Đang học tốt</span>
                <strong>{actionSummary.best_performers || 0}</strong>
              </div>
            </div>
          </section>

          <section className="analytics-panel">
            <div className="panel-heading">
              <div>
                <h2>Học phần cần chú ý</h2>
                <p>Ưu tiên những lớp có nhiều sinh viên mất nhịp hoặc điểm thấp.</p>
              </div>
              <BookOpen size={20} />
            </div>
            <div className="course-insight-list compact">
              {courseInsights.slice(0, 4).map((course) => (
                <article key={course.course_id} className="course-insight-card compact">
                  <div className="course-insight-header">
                    <div>
                      <h3>{course.course_name}</h3>
                      <span>{course.course_code}</span>
                    </div>
                    <span className="course-alert-count">{course.attention_needed}</span>
                  </div>
                  <div className="course-metrics-grid compact">
                    <div>
                      <span>Tiến độ TB</span>
                      <strong>{formatPercent(course.avg_progress)}</strong>
                    </div>
                    <div>
                      <span>Điểm TB</span>
                      <strong>{formatPercent(course.avg_score)}</strong>
                    </div>
                    <div>
                      <span>Nguy cơ cao</span>
                      <strong>{course.high_risk_students}</strong>
                    </div>
                    <div>
                      <span>Mất nhịp</span>
                      <strong>{course.inactive_students}</strong>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          </section>
        </div>

        <div className="analytics-grid analytics-grid-secondary">
          <section className="analytics-panel">
            <div className="panel-heading">
              <div>
                <h2>Sinh viên học tốt</h2>
                <p>Nhóm có thể giao bài nâng cao hoặc dùng làm hạt nhân hỗ trợ nhóm.</p>
              </div>
              <Award size={20} />
            </div>

            {topPerformers.length === 0 ? (
              <div className="analytics-empty-inline">
                <CheckCircle2 size={20} />
                <span>Chưa đủ dữ liệu để xếp hạng nhóm học tốt.</span>
              </div>
            ) : (
              <div className="student-card-list">
                {topPerformers.map((student) => (
                  <article key={student.id} className="student-insight-card performer-card">
                    <div className="student-card-header">
                      <div>
                        <h3>{student.full_name}</h3>
                        <p>{student.student_id || student.email}</p>
                      </div>
                      <span className="performance-badge">{student.performance_index}</span>
                    </div>
                    <div className="student-score-grid">
                      <div>
                        <span>Tiến độ</span>
                        <strong>{formatPercent(student.avg_progress)}</strong>
                      </div>
                      <div>
                        <span>Điểm TB</span>
                        <strong>{formatPercent(student.avg_score)}</strong>
                      </div>
                      <div>
                        <span>Học phần</span>
                        <strong>{student.course_count}</strong>
                      </div>
                    </div>
                    <div className="student-highlight good">
                      <TrendingUp size={16} />
                      <span>{student.highlight}</span>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>

          <section className="analytics-panel danger-panel">
            <div className="panel-heading">
              <div>
                <h2>Sinh viên có nguy cơ rớt môn</h2>
                <p>Danh sách ưu tiên để nhắc học, tư vấn hoặc điều chỉnh kế hoạch học.</p>
              </div>
              <AlertTriangle size={20} />
            </div>

            {atRiskStudents.length === 0 ? (
              <div className="analytics-empty-inline">
                <CheckCircle2 size={20} />
                <span>Hiện chưa có sinh viên nằm trong nhóm rủi ro đáng chú ý.</span>
              </div>
            ) : (
              <div className="student-card-list">
                {atRiskStudents.map((student) => {
                  const meta = riskMeta[student.risk_level] || riskMeta.medium;
                  return (
                    <article key={student.id} className="student-insight-card risk-card">
                      <div className="student-card-header">
                        <div>
                          <h3>{student.full_name}</h3>
                          <p>{student.student_id || student.email}</p>
                        </div>
                        <span className={`risk-status ${meta.className}`}>{meta.label}</span>
                      </div>

                      <div className="student-score-grid">
                        <div>
                          <span>Tiến độ</span>
                          <strong>{formatPercent(student.avg_progress)}</strong>
                        </div>
                        <div>
                          <span>Điểm TB</span>
                          <strong>{formatPercent(student.avg_score)}</strong>
                        </div>
                        <div>
                          <span>Không hoạt động</span>
                          <strong>{student.days_inactive} ngày</strong>
                        </div>
                      </div>

                      <div className="student-warning-list">
                        {student.warning_messages.slice(0, 3).map((message) => (
                          <span key={message} className="warning-chip">{message}</span>
                        ))}
                      </div>

                      <div className="student-recommendation">
                        <strong>Khuyến nghị:</strong>
                        <p>{student.recommendation}</p>
                      </div>

                      <div className="risk-course-note">
                        <span>Học phần đáng lo nhất</span>
                        <strong>{student.most_at_risk_course?.course_name || 'Chưa xác định'}</strong>
                      </div>
                    </article>
                  );
                })}
              </div>
            )}
          </section>
        </div>

        <section className="analytics-panel analytics-panel-full">
          <div className="panel-heading">
            <div>
              <h2>Chi tiết theo học phần</h2>
              <p>So sánh chất lượng lớp học để biết môn nào cần tăng nhắc nhở hoặc hỗ trợ bổ sung.</p>
            </div>
            <BookOpen size={20} />
          </div>

          {courseInsights.length === 0 ? (
            <div className="analytics-empty-inline">
              <BookOpen size={20} />
              <span>Chưa có dữ liệu ghi danh để phân tích theo học phần.</span>
            </div>
          ) : (
            <div className="course-insight-list">
              {courseInsights.map((course) => (
                <article key={course.course_id} className="course-insight-card">
                  <div className="course-insight-header">
                    <div>
                      <h3>{course.course_name}</h3>
                      <span>{course.course_code}</span>
                    </div>
                    <div className="course-attention-summary">
                      <span>{course.students_count} sinh viên</span>
                      <strong>{course.attention_needed} cần chú ý</strong>
                    </div>
                  </div>

                  <div className="course-metrics-grid">
                    <div>
                      <span>Tiến độ TB</span>
                      <strong>{formatPercent(course.avg_progress)}</strong>
                    </div>
                    <div>
                      <span>Điểm TB</span>
                      <strong>{formatPercent(course.avg_score)}</strong>
                    </div>
                    <div>
                      <span>Hoàn thành</span>
                      <strong>{formatPercent(course.completion_rate)}</strong>
                    </div>
                    <div>
                      <span>Nguy cơ cao</span>
                      <strong>{course.high_risk_students}</strong>
                    </div>
                    <div>
                      <span>Cần theo dõi</span>
                      <strong>{course.medium_risk_students}</strong>
                    </div>
                    <div>
                      <span>Mất nhịp</span>
                      <strong>{course.inactive_students}</strong>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
      </div>
    </TeacherLayout>
  );
};

export default AnalyticsPage;
