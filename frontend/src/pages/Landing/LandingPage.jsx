import { Link } from 'react-router-dom'
import './LandingPage.css'

function LandingPage() {
  return (
    <div className="landing-page">
      {/* Hero Section */}
      <section className="hero">
        <div className="hero-background"></div>
        <div className="hero-content">
          <div className="hero-badge">
            <span>🎓</span>
            <span>Đại học Văn Lang - CNTT</span>
          </div>
          
          <h1 className="hero-title">
            AI Learning Platform
          </h1>
          
          <p className="hero-subtitle">
            Hệ thống học tập thông minh với AI cá nhân hóa
          </p>
          
          <p className="hero-description">
            Trải nghiệm học tập được tối ưu hóa với công nghệ AI tiên tiến. 
            Gợi ý nội dung phù hợp, chatbot hỗ trợ 24/7, và phân tích tiến độ thông minh.
          </p>
          
          <div className="hero-buttons">
            <Link to="/login" className="btn btn-primary">
              <span>Đăng nhập</span>
              <span>→</span>
            </Link>
            <Link to="/register" className="btn btn-secondary">
              <span>Đăng ký ngay</span>
            </Link>
          </div>
          
          <div className="hero-stats">
            <div className="stat">
              <div className="stat-number">1000+</div>
              <div className="stat-label">Sinh viên</div>
            </div>
            <div className="stat">
              <div className="stat-number">50+</div>
              <div className="stat-label">Khóa học</div>
            </div>
            <div className="stat">
              <div className="stat-number">95%</div>
              <div className="stat-label">Hài lòng</div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features">
        <div className="container">
          <div className="section-header">
            <h2 className="section-title">Tính năng nổi bật</h2>
            <p className="section-subtitle">
              Công nghệ AI giúp tối ưu hóa trải nghiệm học tập của bạn
            </p>
          </div>
          
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">🎯</div>
              <h3 className="feature-title">Gợi ý Cá nhân hóa</h3>
              <p className="feature-description">
                AI phân tích hành vi học tập và đề xuất nội dung phù hợp với năng lực của bạn
              </p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">💬</div>
              <h3 className="feature-title">Chatbot AI</h3>
              <p className="feature-description">
                Trợ lý ảo thông minh hỗ trợ 24/7, giải đáp thắc mắc và tóm tắt tài liệu
              </p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">📊</div>
              <h3 className="feature-title">Phân tích Tiến độ</h3>
              <p className="feature-description">
                Theo dõi chi tiết quá trình học tập với dashboard trực quan và insights thông minh
              </p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">🚀</div>
              <h3 className="feature-title">Học Thích ứng</h3>
              <p className="feature-description">
                Hệ thống tự động điều chỉnh độ khó và nội dung dựa trên tiến độ của bạn
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Technology Section */}
      <section className="technology">
        <div className="container">
          <div className="section-header">
            <h2 className="section-title">Công nghệ tiên tiến</h2>
            <p className="section-subtitle">
              Xây dựng trên nền tảng AI và Machine Learning hiện đại
            </p>
          </div>
          
          <div className="tech-grid">
            <div className="tech-card">
              <div className="tech-icon">🤖</div>
              <h4>Machine Learning</h4>
              <p>Collaborative Filtering, Matrix Factorization, XGBoost</p>
            </div>
            
            <div className="tech-card">
              <div className="tech-icon">🧠</div>
              <h4>Deep Learning</h4>
              <p>BERT, GPT - Mô hình ngôn ngữ lớn</p>
            </div>
            
            <div className="tech-card">
              <div className="tech-icon">📈</div>
              <h4>Analytics</h4>
              <p>Learning Analytics, Predictive Modeling</p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="cta">
        <div className="container">
          <div className="cta-content">
            <h2 className="cta-title">Sẵn sàng bắt đầu?</h2>
            <p className="cta-description">
              Tham gia ngay để trải nghiệm học tập với AI
            </p>
            <Link to="/register" className="btn btn-primary btn-large">
              Đăng ký miễn phí
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-section">
              <h3>AI Learning Platform</h3>
              <p>Đồ án tốt nghiệp - Đại học Văn Lang</p>
            </div>
            
            <div className="footer-section">
              <h4>Thông tin</h4>
              <p>Sinh viên: Phạm Thành Tâm</p>
              <p>MSSV: 2174802010372</p>
            </div>
            
            <div className="footer-section">
              <h4>Liên hệ</h4>
              <p>Khoa CNTT - Đại học Văn Lang</p>
              <p>GV: ThS. Trần Kim Mỹ Vân</p>
            </div>
          </div>
          
          <div className="footer-bottom">
            <p>© 2025 AI Learning Platform. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default LandingPage