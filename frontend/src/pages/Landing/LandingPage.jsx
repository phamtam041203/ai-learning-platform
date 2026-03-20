import { Link } from 'react-router-dom';
import './LandingPage.css';

const heroHighlights = [
  { value: 'AI + LMS', label: 'học tập thông minh' },
  { value: '5 Giai đoạn', label: 'lộ trình rõ ràng' },
  { value: 'CNPM', label: 'tối ưu theo chuyên ngành' },
];

const platformFeatures = [
  {
    kicker: 'Cá nhân hóa',
    title: 'Học theo tiến độ của từng sinh viên',
    description: 'Theo dõi tiến độ, điểm số và gợi ý học tiếp theo trong một màn hình.',
  },
  {
    kicker: 'Quản lý học tập',
    title: 'Bài học, quiz và chứng chỉ tập trung',
    description: 'Giữ toàn bộ quy trình học trên một nền tảng gọn, dễ theo dõi và dễ dùng.',
  },
  {
    kicker: 'Hỗ trợ AI',
    title: 'Chatbot và cố vấn học tập 24/7',
    description: 'Giải đáp nhanh theo ngữ cảnh môn học, giúp sinh viên học hiệu quả hơn.',
  },
];

function LandingPage() {
  return (
    <div className="landing-page">
      <header className="landing-nav">
        <div className="container landing-nav-inner">
          <a href="#top" className="landing-brand">
            <div className="landing-brand-mark">
              <img src="/iconvlu.webp" alt="Van Lang University logo" className="landing-brand-logo" />
            </div>
            <div>
              <strong>AI Learning Platform</strong>
              <span>Van Lang University</span>
            </div>
          </a>

          <nav className="landing-links">
            <a href="#platform">Nền tảng</a>
            <a href="#contact">Liên hệ</a>
          </nav>

          <div className="landing-actions">
            <Link to="/login" className="btn btn-ghost">Đăng nhập</Link>
            <Link to="/register" className="btn btn-solid">Tạo tài khoản sinh viên</Link>
          </div>
        </div>
      </header>

      <main id="top">
        <section className="hero-shell">
          <div className="hero-noise" />
          <div className="container hero-grid">
            <div className="hero-copy">
              <div className="hero-pill">Nền tảng học tập số cho sinh viên Văn Lang</div>
              <h1>
                Học tập đơn giản hơn,
                <br />
                hiệu quả hơn với <span>AI Learning Platform</span>.
              </h1>


              <div className="hero-cta-row">
                <Link to="/login" className="btn btn-solid btn-large">Vào hệ thống ngay</Link>
                <Link to="/register" className="btn btn-outline btn-large">Đăng ký sinh viên</Link>
                <a
                  href="https://www.vlu.edu.vn/about-us"
                  target="_blank"
                  rel="noreferrer"
                  className="btn btn-text"
                >
                  Xem thông tin Văn Lang
                </a>
              </div>

              <div className="hero-highlights">
                {heroHighlights.map((item) => (
                  <div key={item.label} className="hero-highlight-card">
                    <strong>{item.value}</strong>
                    <span>{item.label}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="hero-stage">
              <div className="stage-orbit orbit-one" />
              <div className="stage-orbit orbit-two" />
              <div className="hero-main-panel">
                <div className="panel-topline">
                  <span className="panel-chip">VLU x AI</span>
                  <span className="panel-chip muted">Personalized learning</span>
                </div>

                <div className="hero-panel-body">
                  <div className="hero-panel-copy">
                    <h2>Một nơi duy nhất cho toàn bộ hành trình học.</h2>
                    <p>
                      Theo dõi tiến độ, làm bài học, nhận tư vấn và hoàn thành lộ trình tốt nghiệp ngay trên một nền tảng.
                    </p>
                  </div>

                  <div className="hero-panel-stack">
                    <article className="floating-metric accent-red">
                      <span className="metric-label">Roadmap</span>
                      <strong>5 giai đoạn học tập</strong>
                      <p>Lộ trình rõ ràng, dễ bám theo.</p>
                    </article>

                    <article className="floating-metric accent-sand">
                      <span className="metric-label">Progress</span>
                      <strong>Theo dõi kết quả theo thời gian thực</strong>
                      <p>Cập nhật điểm và tiến độ tức thì.</p>
                    </article>

                    <article className="floating-metric accent-dark">
                      <span className="metric-label">Support</span>
                      <strong>AI hỗ trợ học tập liên tục</strong>
                      <p>Hỏi nhanh, nhận hướng dẫn ngay.</p>
                    </article>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="platform" className="platform-section">
          <div className="container">
            <div className="section-heading centered">
              <span className="section-kicker">Giá trị chính</span>
              <h2>Những gì quan trọng nhất cho người học</h2>
            </div>

            <div className="feature-masonry">
              {platformFeatures.map((feature) => (
                <article key={feature.title} className="feature-tile">
                  <span>{feature.kicker}</span>
                  <h3>{feature.title}</h3>
                  <p>{feature.description}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="cta-section">
          <div className="container">
            <div className="cta-panel">
              <div>
                <span className="section-kicker light">Sẵn sàng bắt đầu</span>
                <h2>Đăng nhập để bắt đầu học ngay hôm nay.</h2>
              </div>

              <div className="cta-actions">
                <Link to="/register" className="btn btn-light">Đăng ký sinh viên</Link>
                <Link to="/login" className="btn btn-dark">Đăng nhập</Link>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer id="contact" className="landing-footer">
        <div className="container footer-grid">
          <div>
            <h3>AI Learning Platform</h3>
            <p>
              Nền tảng học tập thông minh cho sinh viên Văn Lang.
            </p>
          </div>

          <div>
            <h4>Liên kết nhanh</h4>
            <ul>
              <li><a href="https://www.vlu.edu.vn/about-us" target="_blank" rel="noreferrer">Về Văn Lang</a></li>
              <li><a href="https://tuyensinh.vlu.edu.vn/" target="_blank" rel="noreferrer">Tuyển sinh Văn Lang</a></li>
              <li><a href="https://www.vlu.edu.vn/academics/faculty-group?faculty=truong-cong-nghe-van-lang#faculties" target="_blank" rel="noreferrer">Trường Công nghệ Văn Lang</a></li>
            </ul>
          </div>

          <div>
            <h4>Liên hệ</h4>
            <ul>
              <li>Cơ sở chính: 69/68 Đặng Thùy Trâm, Phường Bình Lợi Trung, TP. Hồ Chí Minh</li>
              <li>Tuyển sinh: 028.7105.9999</li>
              <li>Email tuyển sinh: tuyensinh@vlu.edu.vn</li>
            </ul>
          </div>
        </div>

        <div className="container footer-bottom">
          <span>© 2026 AI Learning Platform</span>
        </div>
      </footer>
    </div>
  );
}

export default LandingPage;
