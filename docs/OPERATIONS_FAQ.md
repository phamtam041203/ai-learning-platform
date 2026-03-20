# FAQ VẬN HÀNH NGẮN - AI Learning Platform

## 1) Không vào được web công khai thì kiểm tra gì trước?
- Kiểm tra frontend container có trạng thái healthy.
- Kiểm tra stack VPS đã chạy bằng `scripts/deploy.bat`.
- Kiểm tra port 80 trên máy host.

## 2) Vừa deploy xong nhưng giao diện chưa đổi?
- Hard refresh bằng `Ctrl+F5`.
- Xóa cache trình duyệt nếu cần.
- Kiểm tra container frontend đã recreate.

## 3) Backend báo thiếu module khi chạy local?
- Chạy bằng đúng Python của `backend/venv/Scripts/python.exe`.
- Không dùng Python hệ thống.

## 4) API trả 401 liên tục?
- Kiểm tra token trong localStorage/sessionStorage.
- Đăng xuất/đăng nhập lại để cấp token mới.

## 5) Dữ liệu điểm bị lệch giữa các trang?
- So sánh `my-courses` và `my-grades/summary`.
- Với cập nhật từ admin, ưu tiên nguồn enrollment để gần realtime.

## 6) Chứng chỉ hiện sai điểm hoặc sai số môn?
- Kiểm tra route `/student/certificate` đang lấy dữ liệu mới nhất.
- Refresh lại trang sau khi admin hoàn thành cập nhật.

## 7) Chứng chỉ tải PDF không được?
- Kiểm tra trình duyệt có chặn popup/tải file không.
- Thử lại sau khi trang tải xong hoàn toàn.

## 8) Admin muốn hỗ trợ tốt nghiệp nhanh cho sinh viên?
- Vào `/admin/progress`.
- Chọn sinh viên, nhập điểm trung bình admin cấp (0-10).
- Dùng nút hỗ trợ tốt nghiệp theo điểm admin cấp.

## 9) Vì sao đã hỗ trợ tốt nghiệp nhưng student chưa thấy ngay?
- Có thể cache trình duyệt hoặc dữ liệu vừa đồng bộ.
- Yêu cầu student `Ctrl+F5` hoặc đăng nhập lại.

## 10) Teacher không tự đăng ký được là lỗi?
- Không phải lỗi.
- Luồng self-register teacher đã tắt, teacher do admin tạo tài khoản.

## 11) Lesson assistant không tự phát giọng trên mobile?
- Đây là hạn chế autoplay của trình duyệt mobile.
- Cần thao tác chạm để phát thủ công khi bị chặn.

## 12) Endpoint tiến độ nào là nguồn chuẩn cho roadmap student?
- Dùng `GET /api/student/curriculum-status`.

## 13) Đã sửa code backend nhưng không có hiệu lực?
- Kiểm tra chế độ chạy hiện tại có auto-reload thật hay không.
- Nếu không, restart backend/container.

## 14) Deploy lỗi ngẫu nhiên kiểu EOF/build interrupted?
- Lỗi hạ tầng tạm thời, chạy lại `scripts/deploy.bat`.

## 15) Cần đối chiếu nhanh file khi lỗi UI?
- Landing: `frontend/src/pages/Landing/LandingPage.jsx`
- Certificate: `frontend/src/pages/student/CertificatePage.jsx`
- Admin progress: `frontend/src/pages/admin/AdminProgressPage.jsx`
- API frontend: `frontend/src/services/api.js`

## 16) Cần chạy môi trường public trên máy Windows hiện tại?
- Dùng stack VPS trong dự án với `scripts/setup.bat` và `scripts/deploy.bat`.
- Frontend public qua nginx, backend/db nằm mạng nội bộ Docker.

## 17) Nếu user hỏi "hệ thống dùng engine AI gì" thì trả lời ngắn gọn thế nào?
- Dùng Gemini cho các chức năng AI chính (chat, tư vấn, TTS/phân tích).
- XGBoost có thể là thành phần hỗ trợ, không phải engine hội thoại chính.

## 18) Nếu cần khôi phục nhanh trạng thái sau lỗi thao tác admin?
- Vào `/admin/progress` và dùng chức năng reset tiến độ cho student mục tiêu.
- Sau đó áp lại phase/course theo đúng điểm mong muốn.
