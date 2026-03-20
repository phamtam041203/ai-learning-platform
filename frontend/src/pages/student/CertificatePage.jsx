import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Award, Download, GraduationCap, Loader2, ShieldCheck, TrendingUp } from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import { authAPI, courseAPI, studentAPI } from '../../services/api';
import './StudentDashboard.css';
import './CertificatePage.css';

const REQUIRED_STAGE_IDS = [1, 2, 3, 4, 5];

const getGraduationRank = (averageScore) => {
  if (averageScore >= 8) return 'Giỏi';
  if (averageScore >= 6.5) return 'Khá';
  return 'Trung bình';
};

const normalizeToTenScale = (value) => {
  const numeric = Number.parseFloat(value);
  if (!Number.isFinite(numeric) || numeric <= 0) return 0;
  if (numeric <= 10) return numeric;
  if (numeric <= 100) return numeric / 10;
  return 10;
};

const CertificatePage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [certificate, setCertificate] = useState(null);
  const [downloadLoading, setDownloadLoading] = useState(false);
  const [downloadError, setDownloadError] = useState(null);
  const certificateRef = useRef(null);

  useEffect(() => {
    const storedDarkMode = localStorage.getItem('darkMode') === 'true';
    setDarkMode(storedDarkMode);
    if (storedDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  const toggleDarkMode = () => {
    const newDarkMode = !darkMode;
    setDarkMode(newDarkMode);
    localStorage.setItem('darkMode', newDarkMode);
    if (newDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  };

  useEffect(() => {
    const fetchCertificateData = async () => {
      try {
        setLoading(true);
        setError(null);

        const [roadmap, enrollments, gradesSummary, learningAnalytics, me] = await Promise.all([
          studentAPI.getCurriculumStatus(),
          courseAPI.getMyCourses().catch(() => []),
          courseAPI.getGradesSummary().catch(() => null),
          studentAPI.getLearningAnalytics().catch(() => null),
          authAPI.getCurrentUser().catch(() => null)
        ]);

        const phases = roadmap?.phases || [];
        const allStagesCompleted = REQUIRED_STAGE_IDS.every((stageId) => {
          const stage = phases.find((phase) => phase.id === stageId);
          return Boolean(stage?.is_completed);
        });

        const storedUser = JSON.parse(localStorage.getItem('currentUser') || localStorage.getItem('user') || '{}');

        const enrollmentList = Array.isArray(enrollments) ? enrollments : [];
        const normalizedEnrollmentScores = enrollmentList
          .map((enrollment) => normalizeToTenScale(enrollment?.grades?.total))
          .filter((score) => score > 0);
        const snapshotAverage10 = normalizedEnrollmentScores.length
          ? normalizedEnrollmentScores.reduce((sum, score) => sum + score, 0) / normalizedEnrollmentScores.length
          : 0;
        const snapshotHighest10 = normalizedEnrollmentScores.length
          ? Math.max(...normalizedEnrollmentScores)
          : 0;
        const snapshotCompletedCourses = enrollmentList.filter((enrollment) => (enrollment?.progress || 0) >= 100).length;
        const snapshotTotalCourses = enrollmentList.length;

        const overallScore100 = Number.parseFloat(learningAnalytics?.overall_score?.overall_score || 0) || 0;
        const averageFromGrades10 = normalizeToTenScale(gradesSummary?.average_10 || 0);
        const averageFromAnalytics10 = overallScore100 > 0 ? overallScore100 / 10 : 0;
        const averageScore10 = snapshotAverage10 > 0
          ? snapshotAverage10
          : (averageFromGrades10 > 0 ? averageFromGrades10 : averageFromAnalytics10);

        const completedCourses =
          snapshotTotalCourses > 0
            ? snapshotCompletedCourses
            : (gradesSummary?.completed_courses || 0) > 0
            ? gradesSummary.completed_courses
            : (learningAnalytics?.performance_summary?.completed_courses || 0);

        const totalCourses =
          snapshotTotalCourses > 0
            ? snapshotTotalCourses
            : (gradesSummary?.total_courses || 0) > 0
            ? gradesSummary.total_courses
            : (learningAnalytics?.performance_summary?.total_courses || 0);

        setCertificate({
          eligible: allStagesCompleted,
          studentName: me?.full_name || storedUser.full_name || storedUser.name || 'Sinh viên',
          studentId: me?.student_id || storedUser.student_id || storedUser.studentId || 'N/A',
          major: me?.major || storedUser.major || 'Công nghệ phần mềm',
          averageScore: averageScore10.toFixed(2),
          overallScore100: overallScore100 > 0 ? overallScore100.toFixed(2) : null,
          highestScore: normalizeToTenScale(snapshotHighest10 || gradesSummary?.highest_score || 0).toFixed(2),
          completedCourses,
          totalCourses,
          evaluation: getGraduationRank(averageScore10),
          issuedAt: new Date().toLocaleDateString('vi-VN')
        });
      } catch (err) {
        console.error('Error loading certificate:', err);
        setError('Không thể tải dữ liệu chứng chỉ. Vui lòng thử lại.');
      } finally {
        setLoading(false);
      }
    };

    fetchCertificateData();
  }, []);

  const isEligible = certificate?.eligible;

  const stats = useMemo(() => {
    if (!certificate) return [];

    const scoreValue = `${certificate.averageScore}/10`;

    return [
      { icon: <TrendingUp size={18} />, label: 'Điểm tổng kết', value: scoreValue },
      { icon: <Award size={18} />, label: 'Tốt nghiệp loại', value: certificate.evaluation },
      { icon: <ShieldCheck size={18} />, label: 'Khóa học hoàn thành', value: `${certificate.completedCourses}/${certificate.totalCourses}` }
    ];
  }, [certificate]);

  const handleDownloadCertificate = async () => {
    if (!certificateRef.current || !certificate) {
      return;
    }

    try {
      setDownloadLoading(true);
      setDownloadError(null);

      const [{ default: html2canvas }, { default: jsPDF }] = await Promise.all([
        import('html2canvas'),
        import('jspdf')
      ]);

      const canvas = await html2canvas(certificateRef.current, {
        scale: 2,
        useCORS: true,
        backgroundColor: '#fff'
      });

      const imageData = canvas.toDataURL('image/png');
      const pdf = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = pdf.internal.pageSize.getHeight();
      const imageRatio = canvas.width / canvas.height;

      let renderWidth = pdfWidth - 10;
      let renderHeight = renderWidth / imageRatio;

      if (renderHeight > pdfHeight - 10) {
        renderHeight = pdfHeight - 10;
        renderWidth = renderHeight * imageRatio;
      }

      const x = (pdfWidth - renderWidth) / 2;
      const y = (pdfHeight - renderHeight) / 2;

      pdf.addImage(imageData, 'PNG', x, y, renderWidth, renderHeight, undefined, 'FAST');

      const safeStudentId = String(certificate.studentId || 'sinh-vien').replace(/[^a-zA-Z0-9-_]/g, '_');
      pdf.save(`bang-khen-${safeStudentId}.pdf`);
    } catch (downloadErr) {
      console.error('Error downloading certificate:', downloadErr);
      setDownloadError('Không thể tải bằng lúc này. Vui lòng thử lại.');
    } finally {
      setDownloadLoading(false);
    }
  };

  return (
    <div className="student-page-shell">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />

      <div className="student-page-main">
        <div className="student-page-header">
          <div className="student-page-header-inner">
            <div className="student-page-title-row">
              <GraduationCap size={32} style={{ color: 'var(--primary)' }} />
              <h1 style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--text-primary)', margin: 0 }}>
                Chứng Chỉ Hoàn Thành
              </h1>
            </div>
            <p style={{ color: 'var(--text-secondary)', margin: 0 }}>
              Chứng chỉ được cấp khi sinh viên hoàn thành đầy đủ 5 giai đoạn trong lộ trình học.
            </p>
          </div>
        </div>

        <div className="student-page-body">
          {loading ? (
            <div className="certificate-loading">
              Đang tải chứng chỉ...
            </div>
          ) : error ? (
            <div className="certificate-error">
              {error}
            </div>
          ) : !isEligible ? (
            <div className="certificate-locked-card">
              <h3>Bạn chưa đủ điều kiện cấp chứng chỉ</h3>
              <p>
                Vui lòng hoàn thành toàn bộ 5 giai đoạn trong lộ trình để mở khóa chứng chỉ tốt nghiệp khóa học.
              </p>
              <button
                type="button"
                onClick={() => navigate('/student/progress')}
                className="certificate-go-progress"
              >
                Đến trang tiến độ
              </button>
            </div>
          ) : (
            <>
              <div className="certificate-actions">
                <button
                  type="button"
                  className="certificate-download-btn"
                  onClick={handleDownloadCertificate}
                  disabled={downloadLoading}
                >
                  {downloadLoading ? <Loader2 size={16} className="spin" /> : <Download size={16} />}
                  {downloadLoading ? 'Đang tạo file...' : 'Tải bằng PDF'}
                </button>
                {downloadError ? <span className="certificate-download-error">{downloadError}</span> : null}
              </div>

              <div className="certificate-award-shell">
                <div className="certificate-award-frame" ref={certificateRef}>
                <div className="certificate-ornament certificate-ornament-top"></div>
                <div className="certificate-ornament certificate-ornament-bottom"></div>

                <div className="certificate-award-header">
                  <span className="certificate-award-kicker">CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</span>
                  <span className="certificate-award-motto">Độc lập - Tự do - Hạnh phúc</span>
                  <h2>Bằng khen hoàn thành khoá học</h2>
                  <p>VLU AI LEARNING PLATFORM CHỨNG NHẬN</p>
                </div>

                <div className="certificate-award-body">
                  <p className="certificate-award-label">Trao tặng sinh viên</p>
                  <h3>{certificate.studentName}</h3>
                  <p className="certificate-award-meta">MSSV: {certificate.studentId} | Ngành: {certificate.major}</p>

                  <p className="certificate-award-quote">
                    Đã hoàn thành đầy đủ 5 giai đoạn đào tạo và đạt yêu cầu đầu ra của chương trình học.
                  </p>

                  <div className="certificate-award-stats-grid">
                    {stats.map((item) => (
                      <div key={item.label} className="certificate-award-stat">
                        <div className="certificate-award-stat-label">
                          {item.icon}
                          <span>{item.label}</span>
                        </div>
                        <strong>{item.value}</strong>
                      </div>
                    ))}
                  </div>

                  <div className="certificate-award-signatures">
                    <div>
                      <span>Ngày cấp</span>
                      <strong>{certificate.issuedAt}</strong>
                    </div>
                    <div>
                      <span>Hội đồng đào tạo</span>
                      <strong>VLU AI Learning</strong>
                    </div>
                  </div>
                </div>

                <div className="certificate-award-seal" aria-hidden="true">
                  <Award size={34} />
                  <span className="certificate-award-seal-main">CERTIFIED</span>
                  <span className="certificate-award-seal-sub">VAN LANG UNIVERSITY</span>
                </div>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default CertificatePage;
