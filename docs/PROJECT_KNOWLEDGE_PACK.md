# PROJECT KNOWLEDGE PACK - AI Learning Platform

## 1) Mục tiêu hệ thống
- Nền tảng học tập cho sinh viên Văn Lang (hiện tại tập trung CNPM), gồm dashboard, khóa học, bài học, quiz, tiến độ, AI advisor, chatbot và luồng quản trị teacher/admin.
- Frontend: React + Vite.
- Backend: FastAPI + SQLAlchemy.
- Dữ liệu: PostgreSQL (chính), Redis, MongoDB.
- AI: Gemini (chat/tts/phân tích học tập).

## 2) Kiến trúc và route chính
- Public: `/`, `/login`, `/register`.
- Student: `/student/dashboard`, `/student/courses`, `/student/progress`, `/student/roadmap`, `/student/grades`, `/student/ai-advisor`, `/student/certificate`.
- Teacher: `/teacher/dashboard`, `/teacher/content`, `/teacher/students`, `/teacher/analytics`.
- Admin: `/admin/dashboard`, `/admin/progress`.

## 3) API backend quan trọng (app/api)
- `auth.py`: login/register/profile, auth me.
- `student.py`: dashboard, curriculum-status, profile, learning analytics, personalization.
- `courses.py`: my-courses, course detail, grades summary, learning stats, enroll/update progress.
- `admin.py`: quản lý student/teacher, complete-course, complete-phase, reset-progress, complete-all-quizzes.
- `chatbot.py`: lesson assistant, TTS, AI support.
- `teacher.py`: tạo/sửa khóa học, bài học, quiz và danh sách học viên.

## 4) Luồng dữ liệu cần nhớ khi debug
- Tiến độ/roadmap student: ưu tiên `GET /api/student/curriculum-status`.
- Điểm và khóa học: cần đối chiếu `GET /api/courses/my-courses` với `GET /api/courses/my-grades/summary` nếu số liệu lệch.
- Certificate: đã cấu hình lấy score theo enrollment và chuẩn hóa về thang 10.
- Admin progress: có chức năng hỗ trợ tốt nghiệp theo điểm admin cấp (thang 10) và complete phase/course.

## 5) Các thay đổi gần đây (quan trọng để trả lời hỏi đáp)

- Lesson assistant đã tối ưu TTS/voice và hành vi mobile autoplay.
- Progress map 2D đã sửa theo phase active, thêm visual progression.
- Certificate:
  - tách thành trang riêng `/student/certificate`;
  - nội dung tiếng Việt có dấu;
  - style bằng khen;
  - thêm tải PDF trên trang certificate;
  - sửa logic điểm thang 10, graduation rank, completed courses.
- Admin progress:
  - thêm block "Hỗ trợ hoàn thành tốt nghiệp";
  - cho phép nhập điểm trung bình admin cấp.
- Landing page:
  - đã rút gọn content, giữ các thông điệp cốt lõi và CTA.

## 6) Vị trí file cần xem ngay khi có vấn đề
- Landing: `frontend/src/pages/Landing/LandingPage.jsx`, `frontend/src/pages/Landing/LandingPage.css`.
- Certificate: `frontend/src/pages/student/CertificatePage.jsx`, `frontend/src/pages/student/CertificatePage.css`.
- Admin Progress: `frontend/src/pages/admin/AdminProgressPage.jsx`, `frontend/src/pages/admin/AdminProgressPage.css`.
- API config frontend: `frontend/src/config/api.js`, `frontend/src/services/api.js`.
- Backend APIs: `backend/app/api/*.py`.

## 7) Lỗi hay gặp và cách xử lý nhanh
- Điểm/trạng thái lệch giữa trang:
  - so sánh dữ liệu `my-courses` và `my-grades/summary`;
  - ưu tiên enrollment score cho realtime sau khi admin thao tác.
- Frontend chưa cập nhật sau deploy:
  - Ctrl+F5, xóa cache trình duyệt, kiểm tra nginx/container frontend recreate.
- Lỗi env/backend Python:
  - dùng đúng venv backend (`backend/venv/Scripts/python.exe`) khi chạy script local.
- Docker deploy thất bại ngẫu nhiên (EOF/build transient):
  - chạy lại `scripts/deploy.bat`.

## 8) Lệnh vận hành nhanh
- Deploy VPS stack (Windows):
  - `scripts/setup.bat`
  - `scripts/deploy.bat`
- Compose VPS: `docker/docker-compose.vps.yml`.
- Frontend public qua nginx port 80; backend/db/redis/mongo nằm trong network nội bộ.

## 9) Cách trả lời nhanh khi được hỏi vấn đề
- B1: Xác định nhóm vấn đề: UI/UX, route, API, dữ liệu, deploy, auth.
- B2: Đối chiếu endpoint + file UI liên quan.
- B3: Nếu vấn đề là số liệu: ưu tiên endpoint nguồn và fallback theo thực tế đã triển khai.
- B4: Nếu vấn đề là production: deploy + hard refresh + xác nhận container health.

## 10) Phạm vi hiện tại
- Luồng student hiện đã tối ưu cho CNPM.
- Teacher self-register đang bị tắt; admin tạo teacher là luồng chính.
- Các tính năng mới nên giữ tương thích với luồng route hiện có trong `App.jsx`.
