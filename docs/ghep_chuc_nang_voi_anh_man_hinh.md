# Ghép chức năng với ảnh màn hình tương ứng

## 1. Nguyên tắc sử dụng trong báo cáo

- Tài liệu này dùng để ghép từng chức năng nghiệp vụ với ảnh màn hình tương ứng trong báo cáo.
- Hiện tại repo chưa có bộ screenshot giao diện hoàn chỉnh trong `docs/images`, vì vậy bảng dưới đây đóng vai trò danh mục ảnh cần chụp.
- Mỗi ảnh nên được chụp theo đúng màn hình thật khi chạy hệ thống, sau đó lưu theo tên file đề xuất để dễ chèn vào báo cáo.
- Khi chèn vào báo cáo, nên đặt chú thích theo mẫu: `Hình x.y. [Tên chức năng/màn hình]`.

## 2. Bảng ghép chức năng với ảnh màn hình

| STT | Chức năng | Màn hình cần chụp | Route hoặc khu vực | File frontend liên quan | Tên ảnh đề xuất | Ghi chú chụp ảnh |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Trang giới thiệu hệ thống | Trang landing page | `/` | `frontend/src/pages/Landing/LandingPage` | `01-landing-page.png` | Chụp toàn bộ phần hero và các nút đăng nhập, đăng ký |
| 2 | Đăng nhập | Trang đăng nhập | `/login` | `frontend/src/pages/Auth/LoginPage.jsx` | `02-login-page.png` | Chụp form email, mật khẩu và nút đăng nhập |
| 3 | Đăng ký sinh viên | Trang đăng ký sinh viên | `/register` | `frontend/src/pages/Auth/RegisterPage.jsx` | `03-student-register.png` | Chụp form đăng ký đầy đủ trường dữ liệu |
| 4 | Đăng ký giảng viên | Trang đăng ký giảng viên | `/register/teacher` | `frontend/src/pages/Auth/TeacherRegisterPage.jsx` | `04-teacher-register.png` | Chụp các trường email, mã giảng viên, bộ môn |
| 5 | Đăng nhập Teams/Azure AD | Màn hình callback hoặc hoàn tất hồ sơ | `/auth/teams/callback`, `/auth/teams/complete-profile` | `frontend/src/pages/Auth/TeamsCallbackPage.jsx`, `frontend/src/pages/Auth/TeamsCompleteProfilePage.jsx` | `05-teams-auth.png` | Nếu khó chụp callback, dùng màn hình hoàn tất hồ sơ để minh họa |
| 6 | Dashboard sinh viên | Trang tổng quan sinh viên | `/student/dashboard` | `frontend/src/pages/student/DashboardPage.jsx` | `06-student-dashboard.png` | Chụp thống kê chính, sidebar và khối tiến độ |
| 7 | Danh sách khóa học theo chuyên ngành | Trang khóa học của sinh viên | `/student/courses` | `frontend/src/pages/student/CoursesPage.jsx` | `07-student-courses.png` | Chụp danh sách khóa học có trạng thái đang học, khóa, mở |
| 8 | Khám phá khóa học | Trang browse courses | `/student/browse-courses` | `frontend/src/pages/student/BrowseCoursesPage.jsx` | `08-browse-courses.png` | Chụp phần bộ lọc và danh sách môn học |
| 9 | Chi tiết khóa học | Trang course detail | `/student/course/:courseId` | `frontend/src/pages/student/CourseDetail.jsx` | `09-course-detail.png` | Chụp mô tả khóa học, lesson và nút ghi danh nếu có |
| 10 | Ghi danh khóa học | Nút hoặc trạng thái enroll trên chi tiết khóa học | `/student/course/:courseId` hoặc `/student/browse-courses` | `frontend/src/pages/student/CourseDetail.jsx`, `frontend/src/pages/student/BrowseCoursesPage.jsx` | `10-course-enrollment.png` | Chụp lúc nút đăng ký hoặc trạng thái chờ duyệt xuất hiện |
| 11 | Danh sách bài học | Trang lesson list của khóa học | `/student/courses/:courseId/lessons` | `frontend/src/pages/student/CourseLessonsPage.jsx` | `11-course-lessons.png` | Chụp danh sách bài học và trạng thái hoàn thành |
| 12 | Học bài trực tuyến | Trang lesson page | `/student/courses/:courseId/lessons/:lessonId` | `frontend/src/pages/student/LessonPage.jsx` | `12-lesson-page.png` | Chụp nội dung bài học, tài liệu hoặc video nếu có |
| 13 | Theo dõi điểm số | Trang grades | `/student/grades` | `frontend/src/pages/student/GradesPage.jsx` | `13-student-grades.png` | Chụp bảng điểm hoặc thống kê kết quả |
| 14 | Theo dõi tiến độ học tập | Trang progress | `/student/progress` | `frontend/src/pages/student/ProgressPage.jsx` | `14-student-progress.png` | Chụp phần tiến độ tổng thể và khu vực điều hướng sang roadmap |
| 15 | Bài test năng lực đầu vào | Trang skill assessment | `/student/skill-assessment` | `frontend/src/pages/student/StudentSkillAssessmentPage.jsx` | `15-skill-assessment.png` | Chụp ít nhất một nhóm câu hỏi và thanh tiến độ trả lời |
| 16 | Kết quả bài test năng lực | Màn hình kết quả phân tích AI | `/student/skill-assessment` | `frontend/src/pages/student/StudentSkillAssessmentPage.jsx` | `16-skill-assessment-result.png` | Chụp điểm đầu vào, điểm mạnh, điểm yếu, phase mở khóa |
| 17 | Lộ trình học cá nhân hóa | Trang roadmap | `/student/roadmap` | `frontend/src/pages/student/StudentRoadmapPage.jsx` | `17-student-roadmap.png` | Chụp toàn bộ phase, trạng thái môn học, yêu cầu mở khóa |
| 18 | Bản đồ tiến trình 3D | Thành phần ProgressJourney3D trên trang progress | `/student/progress` | `frontend/src/components/student/ProgressJourney3D.jsx` | `18-progress-journey-3d.png` | Chụp góc thấy rõ các chặng 3D và phase đang mở |
| 19 | AI Advisor học tập | Trang AI advisor | `/student/ai-advisor` | `frontend/src/pages/student/AIAdvisorPage.jsx` | `19-ai-advisor.png` | Chụp khu vực gợi ý học tập hoặc phân tích cá nhân |
| 20 | Chatbot hỗ trợ học tập | Trang chatbot | `/student/chatbot` | `frontend/src/pages/student/ChatbotPage.jsx` | `20-chatbot-page.png` | Chụp khung chat với ví dụ câu hỏi và câu trả lời |
| 21 | Gia sư AI bằng giọng nói | Khu vực phát âm thanh trong chatbot hoặc tutor | `/student/chatbot` hoặc luồng tutor | `frontend/src/pages/student/ChatbotPage.jsx` và backend chatbot | `21-ai-voice-tutor.png` | Chụp nút phát giọng đọc hoặc trạng thái voice tutor nếu đang hiện |
| 22 | Khóa học gợi ý | Trang recommendations | `/student/recommendations` | `frontend/src/pages/student/RecommendationsPage.jsx` | `22-recommendations.png` | Chụp danh sách gợi ý môn học hoặc định hướng học tiếp |
| 23 | Hồ sơ cá nhân sinh viên | Trang profile | `/student/profile` | `frontend/src/pages/student/ProfilePage.jsx` | `23-student-profile.png` | Chụp thông tin cá nhân và học vụ cơ bản |
| 24 | Dashboard giảng viên | Trang teacher dashboard | `/teacher` hoặc `/teacher/dashboard` | `frontend/src/pages/teacher/TeacherDashboard.jsx`, `frontend/src/pages/teacher/DashboardPage` | `24-teacher-dashboard.png` | Chụp thống kê khóa học, sinh viên, chờ duyệt |
| 25 | Tạo khóa học | Popup hoặc form tạo khóa học | Trong dashboard giảng viên | `frontend/src/pages/teacher/TeacherDashboard.jsx` | `25-teacher-create-course.png` | Chụp form tạo course đang mở |
| 26 | Tải lên bài học | Popup upload lesson | Trong dashboard giảng viên | `frontend/src/pages/teacher/TeacherDashboard.jsx` | `26-teacher-upload-lesson.png` | Chụp form có trường file và video URL |
| 27 | Tạo quiz từ DOCX | Popup tạo quiz | Trong dashboard giảng viên | `frontend/src/pages/teacher/TeacherDashboard.jsx` | `27-teacher-create-quiz-docx.png` | Chụp form upload DOCX |
| 28 | Chi tiết khóa học của giảng viên | Trang course detail cho giảng viên | `/teacher/courses/:courseId` | `frontend/src/pages/teacher/CourseDetailPage.jsx` | `28-teacher-course-detail.png` | Chụp thống kê khóa học, danh sách bài học và danh sách quiz |
| 29 | Cập nhật khóa học | Hộp thoại sửa khóa học | Trong trang chi tiết khóa học giảng viên | `frontend/src/pages/teacher/CourseDetailPage.jsx` | `29-teacher-edit-course.png` | Chụp form cập nhật tên, mô tả, danh mục |
| 30 | Quản lý quiz chi tiết | Trang quản lý quiz | `/teacher/courses/:courseId/quizzes` | `frontend/src/pages/teacher/QuizManagerPage.jsx` | `30-teacher-quiz-manager.png` | Chụp đồng thời danh sách quiz và khu vực tạo hoặc sửa câu hỏi |
| 31 | Quản lý sinh viên của giảng viên | Tab students | Trong khu vực giảng viên | `frontend/src/pages/teacher/TeacherDashboard.jsx`, `frontend/src/pages/teacher/StudentsPage` | `31-teacher-students.png` | Chụp danh sách sinh viên đang được giảng viên quản lý |
| 32 | Duyệt yêu cầu ghi danh | Tab approvals | Trong khu vực giảng viên | `frontend/src/pages/teacher/TeacherDashboard.jsx` | `32-teacher-approvals.png` | Chụp nút duyệt hoặc từ chối yêu cầu |
| 33 | Chấm bài tự luận | Trang essay review | `/teacher/essays` hoặc `/teacher/courses/:courseId/essays` | `frontend/src/pages/teacher/EssayReviewPage.jsx` | `33-teacher-essay-review.png` | Chụp danh sách bài nộp hoặc form chấm bài |
| 34 | Dashboard quản trị | Trang admin dashboard | `/admin/dashboard` | `frontend/src/pages/admin/AdminDashboard.jsx` | `34-admin-dashboard.png` | Chụp overview của toàn hệ thống |
| 35 | Quản lý giảng viên | Tab teachers trong admin | Trong dashboard admin | `frontend/src/pages/admin/AdminDashboard.jsx` | `35-admin-teachers.png` | Chụp danh sách giảng viên và nút tạo mới |
| 36 | Quản lý sinh viên | Tab students trong admin | Trong dashboard admin | `frontend/src/pages/admin/AdminDashboard.jsx` | `36-admin-students.png` | Chụp danh sách sinh viên và thao tác quản trị |
| 37 | Quản lý khóa học toàn hệ thống | Tab courses trong admin | Trong dashboard admin | `frontend/src/pages/admin/AdminDashboard.jsx` | `37-admin-courses.png` | Chụp danh sách khóa học hoặc màn hình xem chi tiết |
| 38 | Tạo bài đánh giá | Form create assessment | Trong dashboard admin | `frontend/src/pages/admin/AdminDashboard.jsx` | `38-admin-create-assessment.png` | Chụp form nhập tiêu đề, loại bài, hạn nộp, điểm tối đa |
| 39 | Theo dõi tiến độ toàn hệ thống | Trang admin progress | `/admin/progress` | `frontend/src/pages/admin/AdminProgressPage.jsx` | `39-admin-progress.png` | Chụp báo cáo tiến độ ở góc nhìn quản trị |

## 3. Cặp ảnh nên ưu tiên đưa vào báo cáo

Nếu báo cáo chỉ cần một số hình tiêu biểu, nên ưu tiên các ảnh sau:

1. `06-student-dashboard.png`: đại diện cho khu vực chính của sinh viên.
2. `15-skill-assessment.png`: thể hiện đầu vào của cơ chế cá nhân hóa.
3. `16-skill-assessment-result.png`: thể hiện kết quả phân tích AI.
4. `17-student-roadmap.png`: thể hiện roadmap học tập theo phase.
5. `18-progress-journey-3d.png`: thể hiện điểm khác biệt trực quan của hệ thống.
6. `19-ai-advisor.png`: thể hiện vai trò cố vấn học tập AI.
7. `20-chatbot-page.png`: thể hiện chức năng hỏi đáp học tập.
8. `24-teacher-dashboard.png`: thể hiện nghiệp vụ giảng viên.
9. `28-teacher-course-detail.png`: thể hiện điểm quản lý tập trung của giảng viên theo từng khóa học.
10. `30-teacher-quiz-manager.png`: thể hiện chức năng tạo và quản lý quiz chi tiết.

## 4. Gợi ý cách chèn vào báo cáo

Bạn có thể ghép theo cấu trúc sau:

- Nhóm chức năng sinh viên:
  - Hình giao diện dashboard sinh viên.
  - Hình bài test năng lực.
  - Hình kết quả AI phân tích.
  - Hình roadmap hoặc bản đồ 3D.
  - Hình chatbot hoặc AI advisor.
- Nhóm chức năng giảng viên:
  - Hình dashboard giảng viên.
  - Hình chi tiết khóa học giảng viên.
  - Hình quản lý quiz chi tiết.
  - Hình tạo học liệu hoặc quiz DOCX.
  - Hình chấm bài tự luận.
- Nhóm chức năng quản trị:
  - Hình dashboard admin.
  - Hình quản lý người dùng.
  - Hình tạo bài đánh giá.

## 5. Tình trạng ảnh hiện tại trong repo

- `docs/images`: đang trống.
- `docs/diagrams`: đang trống.
- Ảnh tìm thấy trong repo hiện tại không phải screenshot chức năng nghiệp vụ, nên chưa thể dùng trực tiếp cho phần minh họa báo cáo.

## 6. Đề xuất thao tác tiếp theo

- Chạy hệ thống và chụp theo đúng tên ảnh đề xuất trong bảng trên.
- Lưu ảnh vào thư mục `docs/images/screenshots/` để tiện quản lý.
- Khi viết báo cáo, ghép phần mô tả chức năng trong file `docs/bao_cao_chi_tiet_chuc_nang.md` với ảnh tương ứng trong tài liệu này.