# Chi tiết chức năng hệ thống AI Learning Platform

## 1. Nhóm chức năng công khai

### 1.1. Trang giới thiệu hệ thống
- Mục đích: giới thiệu nền tảng học tập, định hướng người dùng theo từng vai trò và tạo điểm vào cho đăng nhập, đăng ký.
- Đối tượng sử dụng: khách truy cập chưa đăng nhập.
- Dữ liệu vào: không yêu cầu dữ liệu cá nhân.
- Xử lý chính: hiển thị thông tin tổng quan về hệ thống, lợi ích học tập, khả năng cá nhân hóa và điều hướng đến các màn hình xác thực.
- Kết quả đầu ra: người dùng hiểu được mục tiêu của hệ thống và chuyển sang đăng nhập hoặc đăng ký.
- Giá trị đem lại: tăng khả năng tiếp cận hệ thống và tạo trải nghiệm khởi đầu rõ ràng.

### 1.2. Đăng nhập
- Mục đích: xác thực người dùng và cấp quyền truy cập đúng theo vai trò.
- Đối tượng sử dụng: sinh viên, giảng viên, quản trị viên.
- Dữ liệu vào: email và mật khẩu.
- Xử lý chính:
  - gửi thông tin đến API xác thực;
  - kiểm tra tính hợp lệ của tài khoản;
  - nhận access token từ backend;
  - lưu token để sử dụng cho các request tiếp theo;
  - điều hướng người dùng đến khu vực phù hợp với vai trò.
- Kết quả đầu ra: phiên đăng nhập hợp lệ, có thể truy cập dashboard tương ứng.
- Giá trị đem lại: đảm bảo an toàn truy cập và phân quyền chính xác.

### 1.3. Đăng ký tài khoản sinh viên
- Mục đích: tạo mới tài khoản sinh viên để tham gia hệ thống học tập.
- Đối tượng sử dụng: sinh viên mới.
- Dữ liệu vào: thông tin cá nhân, email, mật khẩu và một số trường học vụ cơ bản.
- Xử lý chính: kiểm tra trùng lặp tài khoản, tạo hồ sơ người dùng và hồ sơ sinh viên, lưu vai trò student trong cơ sở dữ liệu.
- Kết quả đầu ra: sinh viên có tài khoản để đăng nhập và bắt đầu học.
- Giá trị đem lại: tự động hóa bước khởi tạo người dùng mới.

### 1.4. Đăng ký tài khoản giảng viên
- Mục đích: tạo mới tài khoản giảng viên cho tác vụ giảng dạy và quản lý học liệu.
- Đối tượng sử dụng: giảng viên.
- Dữ liệu vào: email, mật khẩu, thông tin khoa/bộ môn, mã giảng viên, vị trí công tác.
- Xử lý chính: backend tạo user role là teacher và liên kết với hồ sơ giảng viên.
- Kết quả đầu ra: tài khoản giảng viên có quyền truy cập các màn hình nghiệp vụ giảng dạy.
- Giá trị đem lại: tách bạch quyền giáo viên với sinh viên và quản trị viên.

### 1.5. Đăng nhập Microsoft Teams/Azure AD
- Mục đích: hỗ trợ xác thực thông qua tài khoản tổ chức.
- Đối tượng sử dụng: người dùng có tài khoản Microsoft/Azure AD.
- Dữ liệu vào: mã xác thực trả về từ nhà cung cấp OAuth.
- Xử lý chính:
  - nhận callback sau xác thực;
  - đối chiếu thông tin người dùng từ dịch vụ ngoài;
  - hoàn tất hồ sơ nếu còn thiếu dữ liệu.
- Kết quả đầu ra: người dùng đăng nhập bằng tài khoản tổ chức mà không cần nhập lại mật khẩu hệ thống.
- Giá trị đem lại: tăng thuận tiện, giảm ma sát khi xác thực.

## 2. Nhóm chức năng dành cho sinh viên

### 2.1. Dashboard sinh viên
- Mục đích: cung cấp màn hình trung tâm để sinh viên nắm nhanh tình trạng học tập.
- Dữ liệu hiển thị:
  - tiến độ tổng thể;
  - các khóa học đang học;
  - chỉ báo cá nhân hóa;
  - lối tắt đến các khu vực như tiến độ, chatbot, AI advisor.
- Xử lý chính: frontend gọi API dashboard, tổng hợp dữ liệu học tập hiện tại, hiển thị dưới dạng thẻ thống kê và thành phần trực quan.
- Kết quả đầu ra: sinh viên nhìn thấy trạng thái học tập hiện tại ngay sau khi đăng nhập.
- Ý nghĩa báo cáo: đây là điểm điều phối trải nghiệm học tập cá nhân hóa.

### 2.2. Danh sách khóa học theo chuyên ngành
- Mục đích: hiển thị các học phần phù hợp với chuyên ngành và trạng thái học hiện tại của sinh viên.
- Dữ liệu vào: hồ sơ sinh viên, chuyên ngành, trạng thái ghi danh, dữ liệu chương trình đào tạo.
- Xử lý chính ở backend:
  - đọc hồ sơ sinh viên;
  - lấy các khóa học đã ghi danh;
  - đối chiếu chương trình CNPM theo từng giai đoạn;
  - xác định môn đã học, đang học, môn bị khóa và nguyên nhân bị khóa;
  - tính phần trăm tiến độ từng học phần dựa trên lesson progress.
- Kết quả đầu ra: danh sách khóa học có thông tin tên môn, mã môn, tín chỉ, tiến độ, trạng thái khóa/mở, giai đoạn tương ứng.
- Giá trị đem lại: sinh viên không chỉ thấy môn học, mà còn hiểu vì sao môn đó có thể hoặc chưa thể đăng ký.

### 2.3. Khám phá khóa học
- Mục đích: cho phép sinh viên xem toàn bộ khóa học khả dụng ngoài danh sách đang học.
- Xử lý chính:
  - lọc khóa học theo ngành, cấp độ, từ khóa;
  - hiển thị thông tin tóm tắt, mô tả, cấp độ, thời lượng;
  - hỗ trợ điều hướng đến trang chi tiết khóa học.
- Kết quả đầu ra: người học có thêm khả năng tự tìm kiếm môn học phù hợp.
- Giá trị đem lại: mở rộng khả năng tự định hướng học tập.

### 2.4. Xem chi tiết khóa học
- Mục đích: cung cấp thông tin đầy đủ trước khi học hoặc đăng ký học phần.
- Nội dung hiển thị:
  - mô tả khóa học;
  - mục tiêu học tập;
  - số tín chỉ;
  - danh sách bài học;
  - tiến độ hiện tại;
  - trạng thái ghi danh.
- Xử lý chính: frontend gọi API chi tiết khóa học, backend trả về thông tin học phần và lesson liên quan.
- Kết quả đầu ra: sinh viên hiểu phạm vi nội dung và quyết định học tập chính xác hơn.

### 2.5. Ghi danh khóa học
- Mục đích: cho phép sinh viên đăng ký tham gia một học phần.
- Dữ liệu vào: mã hoặc id khóa học.
- Xử lý chính:
  - kiểm tra điều kiện tiên quyết;
  - kiểm tra khóa học đã mở cho sinh viên hay chưa;
  - tạo bản ghi enrollment;
  - với một số trường hợp có thể phát sinh bước chờ giảng viên duyệt.
- Kết quả đầu ra: khóa học chuyển sang trạng thái đang học hoặc chờ duyệt.
- Giá trị đem lại: quản lý đăng ký môn học có kiểm soát.

### 2.6. Danh sách bài học trong khóa học
- Mục đích: tổ chức nội dung học tập theo lesson để sinh viên theo dõi tuần tự.
- Nội dung hiển thị:
  - tiêu đề bài học;
  - mô tả ngắn;
  - thứ tự bài học;
  - trạng thái hoàn thành.
- Xử lý chính: lấy danh sách lesson theo course, đồng bộ với tiến độ cá nhân của sinh viên.
- Kết quả đầu ra: sinh viên biết mình đang ở bài nào và bài nào cần hoàn thành tiếp theo.

### 2.7. Học bài trực tuyến
- Mục đích: hỗ trợ sinh viên học trực tiếp trên nền tảng từ nội dung bài giảng, PDF, video hoặc tài liệu đính kèm.
- Xử lý chính:
  - tải nội dung bài học và tài liệu liên quan;
  - hiển thị nội dung học;
  - cập nhật lesson progress khi người học hoàn thành;
  - cho phép tích hợp hỏi đáp theo ngữ cảnh bài học.
- Kết quả đầu ra: dữ liệu học tập được ghi nhận theo từng bài học.
- Giá trị đem lại: biến hệ thống thành môi trường học tập thực sự, không chỉ là cổng quản lý.

### 2.8. Theo dõi điểm số
- Mục đích: giúp sinh viên xem điểm bài tập, bài quiz và kết quả học tập tổng quát.
- Dữ liệu hiển thị:
  - điểm theo từng đầu mục;
  - GPA quy đổi;
  - các chỉ số tiến bộ học tập.
- Xử lý chính: backend tổng hợp Submission, QuizResult, Assessment và các dữ liệu liên quan để tạo bức tranh điểm số hoàn chỉnh.
- Kết quả đầu ra: sinh viên theo dõi được năng lực hiện tại theo dữ liệu định lượng.

### 2.9. Theo dõi tiến độ học tập
- Mục đích: hiển thị tiến độ học tập theo mô hình lộ trình và theo từng giai đoạn của chương trình.
- Thành phần chính:
  - bản đồ tiến trình;
  - tỷ lệ hoàn thành lesson;
  - gợi ý bước tiếp theo;
  - tích hợp dữ liệu cá nhân hóa đầu vào.
- Xử lý chính: lấy curriculum status, lesson progress, enrollment status và dữ liệu đánh giá năng lực đầu vào để hiển thị tiến độ thực tế.
- Kết quả đầu ra: sinh viên nhìn được chặng học hiện tại thay vì chỉ xem danh sách môn rời rạc.

### 2.10. Bài test năng lực đầu vào
- Mục đích: đánh giá mức sẵn sàng ban đầu của sinh viên để cá nhân hóa hành trình học.
- Dữ liệu vào:
  - nhóm câu hỏi kiến thức nền về lập trình, cơ sở dữ liệu, web, kiểm thử, tư duy giải quyết vấn đề;
  - nhóm câu hỏi về phong cách học và mức độ khó mong muốn.
- Xử lý chính:
  - backend cung cấp bộ câu hỏi chuẩn;
  - sinh viên trả lời toàn bộ câu hỏi;
  - hệ thống chấm điểm phần kiến thức;
  - phân tích theo domain;
  - suy ra phong cách học;
  - xác định giai đoạn được mở khóa;
  - Gemini tạo phần tóm tắt AI và khuyến nghị tiếp theo.
- Kết quả đầu ra:
  - điểm đánh giá đầu vào;
  - điểm mạnh;
  - điểm yếu;
  - phong cách học tập;
  - độ khó đề xuất;
  - danh sách giai đoạn được mở khóa;
  - hành động tiếp theo.
- Giá trị đem lại: đây là hạt nhân của cơ chế adaptive learning trong hệ thống.

### 2.11. Lộ trình học cá nhân hóa
- Mục đích: hiển thị toàn bộ chương trình học CNPM theo các giai đoạn và trạng thái mở khóa thực tế của từng sinh viên.
- Cách tổ chức:
  - chương trình được chia thành 5 giai đoạn;
  - mỗi giai đoạn gồm môn bắt buộc và môn tự chọn;
  - hệ thống đánh dấu đã hoàn thành, đang học, có thể học hoặc chưa mở.
- Xử lý chính:
  - backend đọc curriculum JSON;
  - đối chiếu với enrollment và lesson progress;
  - tính điều kiện mở khóa từng phase;
  - trả về roadmap có trạng thái chi tiết theo môn và theo giai đoạn.
- Kết quả đầu ra: sinh viên biết mình đang ở phase nào và còn thiếu điều kiện gì để mở phase kế tiếp.
- Giá trị đem lại: hỗ trợ lập kế hoạch học tập dài hạn, giảm học lệch hoặc học sai thứ tự.

### 2.12. Bản đồ tiến trình 3D
- Mục đích: trực quan hóa lộ trình học bằng hình ảnh 3D dạng hành trình leo núi hoặc chinh phục từng chặng.
- Xử lý chính:
  - ánh xạ 5 phase của chương trình vào 5 chặng trong mô hình 3D;
  - hiển thị tiến độ và tình trạng mở khóa theo trạng thái học thực tế;
  - kết hợp dữ liệu cá nhân hóa để làm nổi bật vùng đã được AI mở khóa.
- Kết quả đầu ra: người học quan sát được tiến trình theo cách trực quan, dễ hiểu hơn so với bảng số liệu.
- Giá trị đem lại: tăng tính tương tác, động lực học tập và khả năng truyền thông trong báo cáo sản phẩm.

### 2.13. Hồ sơ kỹ năng sinh viên
- Mục đích: biểu diễn năng lực của sinh viên theo từng nhóm kỹ năng.
- Xử lý chính: hệ thống tổng hợp kết quả bài test đầu vào, quiz, tiến độ học, lịch sử hoạt động để tạo hồ sơ kỹ năng.
- Kết quả đầu ra: mức tự tin hoặc mức thành thạo trên từng kỹ năng nền tảng.
- Giá trị đem lại: hỗ trợ cho AI advisor và study plan đưa ra gợi ý đúng trọng tâm.

### 2.14. Học liệu gợi ý và khóa học đề xuất
- Mục đích: đưa ra đề xuất học tập phù hợp với hồ sơ hiện tại của sinh viên.
- Cơ sở đề xuất:
  - chuyên ngành;
  - phase hiện tại;
  - kết quả quiz;
  - lịch sử học;
  - mức độ hoàn thành chương trình.
- Kết quả đầu ra: danh sách học phần hoặc định hướng học tiếp theo.
- Giá trị đem lại: tăng khả năng tự học theo dữ liệu thay vì học theo cảm tính.

### 2.15. AI Advisor học tập
- Mục đích: cung cấp tư vấn học tập cá nhân hóa cho từng sinh viên.
- Dữ liệu được sử dụng:
  - khóa học đã ghi danh;
  - tiến độ hoàn thành;
  - kết quả quiz;
  - điểm mạnh và điểm yếu;
  - hồ sơ kỹ năng hiện tại.
- Xử lý chính:
  - backend dùng dịch vụ StudentAdvisor để phân tích dữ liệu học tập;
  - tính điểm tổng quan;
  - suy ra điểm mạnh, điểm yếu, lĩnh vực cần cải thiện;
  - sinh khuyến nghị hành động hoặc nội dung cần ưu tiên.
- Kết quả đầu ra: lời khuyên học tập mang tính cá nhân, có thể dùng ngay trong kỳ học.
- Giá trị đem lại: mô phỏng vai trò cố vấn học tập số cho sinh viên.

### 2.16. Chatbot hỗ trợ học tập
- Mục đích: trả lời câu hỏi học tập của sinh viên ngay trong hệ thống.
- Chế độ hoạt động:
  - hỏi đáp chung;
  - giải thích khái niệm;
  - tư vấn học tập;
  - hỏi đáp theo ngữ cảnh bài học.
- Xử lý chính:
  - nhận câu hỏi từ sinh viên;
  - xác định loại hội thoại;
  - với câu hỏi theo lesson, hệ thống nạp thông tin khóa học, nội dung bài học và đoạn trích PDF;
  - trích các câu liên quan nhất trong tài liệu;
  - gọi Gemini để sinh câu trả lời;
  - trong trường hợp phù hợp có thể trả lời bằng logic nội bộ dựa trên context bài học.
- Kết quả đầu ra: câu trả lời sát nội dung bài học và bối cảnh học tập thực tế.
- Giá trị đem lại: hỗ trợ học ngay khi phát sinh thắc mắc, giảm phụ thuộc vào hỗ trợ thủ công.

### 2.17. Gia sư AI bằng giọng nói
- Mục đích: chuyển câu trả lời từ chatbot hoặc tutor thành âm thanh tiếng Việt.
- Xử lý chính:
  - tạo prompt mô tả phong cách giọng nói;
  - gọi Gemini TTS;
  - nhận dữ liệu âm thanh base64;
  - chuyển về định dạng phù hợp để phát trên giao diện.
- Kết quả đầu ra: phản hồi bằng giọng đọc nam hoặc nữ.
- Giá trị đem lại: tăng tính tự nhiên trong tương tác và hỗ trợ người học thích tiếp nhận bằng âm thanh.

### 2.18. Kế hoạch học tập cá nhân
- Mục đích: sinh kế hoạch học theo tuần hoặc theo mục tiêu học tập.
- Dữ liệu vào: mục tiêu học tập do sinh viên nhập thêm, cùng dữ liệu năng lực hiện có.
- Xử lý chính: backend gọi dịch vụ personalisation để sinh study plan phù hợp với mức độ, điểm yếu và phase hiện tại.
- Kết quả đầu ra: danh sách hành động hoặc kế hoạch học ưu tiên trong ngắn hạn.
- Giá trị đem lại: chuyển dữ liệu phân tích thành kế hoạch hành động cụ thể.

### 2.19. Hồ sơ cá nhân
- Mục đích: cho phép sinh viên xem và quản lý thông tin tài khoản cá nhân.
- Dữ liệu hiển thị: thông tin cơ bản, chuyên ngành, lớp, khóa học, một số thiết lập cá nhân.
- Kết quả đầu ra: hồ sơ người dùng được cập nhật và dùng thống nhất trong toàn hệ thống.

## 3. Nhóm chức năng dành cho giảng viên

### 3.1. Dashboard giảng viên
- Mục đích: cung cấp bức tranh tổng quan về hoạt động giảng dạy.
- Thông tin hiển thị:
  - số lượng khóa học phụ trách;
  - số lượng sinh viên;
  - số yêu cầu chờ duyệt;
  - hành động nhanh như tạo khóa học, tải bài học, tạo quiz.
- Kết quả đầu ra: giảng viên kiểm soát nhanh tình hình lớp học và học liệu.

### 3.2. Quản lý khóa học
- Mục đích: cho phép giảng viên tạo và theo dõi các khóa học mình phụ trách.
- Dữ liệu vào: tiêu đề, mô tả, nhóm môn học hoặc category.
- Xử lý chính:
  - gửi dữ liệu lên API tạo khóa học;
  - hệ thống sinh mã khóa học riêng cho giảng viên;
  - lưu khóa học mới vào cơ sở dữ liệu;
  - cập nhật danh sách khóa học đang quản lý.
- Kết quả đầu ra: khóa học mới xuất hiện trong dashboard giảng viên và khu vực quản lý nội dung.
- Giá trị đem lại: giúp giảng viên chủ động mở lớp học và tổ chức nội dung đào tạo.

### 3.3. Xem chi tiết khóa học giảng viên
- Mục đích: cung cấp một màn hình tổng hợp để giảng viên theo dõi toàn bộ lesson, quiz và số lượng sinh viên của một khóa học.
- Nội dung hiển thị:
  - tên khóa học và mô tả;
  - mã khóa học;
  - số lượng sinh viên đã ghi danh;
  - danh sách bài học;
  - danh sách quiz thuộc khóa học.
- Xử lý chính: frontend gọi API chi tiết khóa học, backend trả về đầy đủ lesson, quiz và thống kê liên quan.
- Kết quả đầu ra: giảng viên có một điểm quản lý tập trung cho từng khóa học.
- Giá trị đem lại: giảm việc phải chuyển qua nhiều màn hình rời rạc khi quản lý một học phần.

### 3.4. Cập nhật và xóa khóa học
- Mục đích: cho phép giảng viên chỉnh sửa thông tin khóa học hoặc xóa khóa học khi không còn sử dụng.
- Dữ liệu vào: tên khóa học, mô tả, danh mục, yêu cầu xác nhận xóa.
- Xử lý chính:
  - cập nhật lại thông tin hiển thị của khóa học;
  - ghi thay đổi xuống cơ sở dữ liệu;
  - khi xóa, hệ thống xóa khóa học cùng các lesson và quiz liên quan theo quan hệ dữ liệu.
- Kết quả đầu ra: khóa học được chỉnh sửa hoặc bị xóa khỏi danh sách quản lý.
- Giá trị đem lại: hoàn thiện vòng đời quản lý khóa học từ tạo mới đến chỉnh sửa và hủy bỏ.

### 3.5. Tải lên bài học
- Mục đích: đưa nội dung giảng dạy vào hệ thống dưới dạng lesson.
- Dữ liệu vào: tiêu đề bài học, mô tả, course id, file tài liệu, video URL.
- Xử lý chính:
  - upload dữ liệu bằng multipart form;
  - backend lưu file vào thư mục uploads;
  - tạo lesson và liên kết với khóa học.
- Kết quả đầu ra: lesson xuất hiện trong khóa học và sinh viên có thể truy cập.
- Giá trị đem lại: giảng viên chủ động cập nhật học liệu mà không cần can thiệp kỹ thuật sâu.

### 3.6. Tạo quiz từ tệp DOCX
- Mục đích: rút ngắn thời gian tạo câu hỏi kiểm tra.
- Dữ liệu vào: file DOCX chứa câu hỏi quiz, thông tin khóa học, tiêu đề, mô tả.
- Xử lý chính:
  - upload file DOCX;
  - backend phân tích nội dung file;
  - trích xuất câu hỏi và đáp án;
  - sinh bài quiz và gắn vào khóa học.
- Kết quả đầu ra: giảng viên có bài kiểm tra sẵn dùng trong hệ thống.
- Giá trị đem lại: giảm thao tác nhập tay, tăng hiệu quả số hóa ngân hàng câu hỏi.

### 3.7. Quản lý quiz chi tiết
- Mục đích: cho phép giảng viên tạo quiz thủ công, chỉnh sửa câu hỏi, phát hành hoặc xóa quiz ngay trong hệ thống.
- Dữ liệu vào:
  - tiêu đề quiz;
  - mô tả;
  - trạng thái phát hành;
  - danh sách câu hỏi, đáp án, giải thích và số điểm từng câu.
- Xử lý chính:
  - tạo quiz mới theo biểu mẫu thủ công;
  - cho phép cập nhật nội dung quiz đã có;
  - thay đổi trạng thái phát hành để quyết định sinh viên có thể làm bài hay chưa;
  - xóa quiz khi không còn sử dụng.
- Kết quả đầu ra: ngân hàng quiz của từng khóa học được quản lý đầy đủ từ giao diện giảng viên.
- Giá trị đem lại: giảng viên không phụ thuộc hoàn toàn vào import DOCX, có thể tinh chỉnh trực tiếp nội dung kiểm tra.

### 3.8. Quản lý sinh viên
- Mục đích: theo dõi danh sách sinh viên thuộc các lớp hoặc khóa học do giảng viên phụ trách.
- Nội dung hiển thị:
  - danh sách sinh viên;
  - khóa học đang tham gia;
  - tiến độ trung bình;
  - điểm trung bình;
  - danh sách các khóa học mà từng sinh viên đang học.
- Xử lý chính: backend tổng hợp dữ liệu từ enrollment, lesson progress, quiz result và hồ sơ sinh viên để trả về góc nhìn theo từng sinh viên thay vì từng bản ghi đơn lẻ.
- Giá trị đem lại: hỗ trợ giảng viên nắm được đối tượng học tập mình đang quản lý.

### 3.9. Duyệt yêu cầu ghi danh
- Mục đích: kiểm soát việc tham gia khóa học của sinh viên trong các trường hợp cần xét duyệt.
- Xử lý chính:
  - lấy danh sách enrollment đang chờ;
  - giảng viên phê duyệt hoặc từ chối;
  - cập nhật trạng thái enrollment trong hệ thống.
- Kết quả đầu ra: sinh viên được phép vào học hoặc bị từ chối theo quyết định giảng viên.

### 3.10. Chấm bài tự luận
- Mục đích: hỗ trợ giảng viên xem và chấm các bài nộp dạng tự luận.
- Dữ liệu hiển thị: bài nộp, thông tin sinh viên, câu trả lời, trạng thái chấm.
- Kết quả đầu ra: điểm và phản hồi được lưu lại cho sinh viên tra cứu.
- Giá trị đem lại: bổ sung đánh giá định tính, không chỉ dựa vào trắc nghiệm.

### 3.11. Dashboard phân tích giảng dạy
- Mục đích: hỗ trợ giảng viên theo dõi hiệu quả giảng dạy qua các chỉ báo tổng hợp.
- Nội dung gồm:
  - tổng số khóa học;
  - tổng số sinh viên;
  - tổng số bài học;
  - tổng số quiz;
  - số yêu cầu đang chờ duyệt;
  - các khối thống kê và khu vực dành cho biểu đồ mở rộng sau này.
- Xử lý chính: backend trả về số liệu tổng hợp từ course, enrollment, lesson và assessment; frontend hiển thị dưới dạng dashboard phân tích.
- Giá trị đem lại: tạo một không gian theo dõi vận hành lớp học tương đối toàn diện cho giảng viên.

## 4. Nhóm chức năng dành cho quản trị viên

### 4.1. Dashboard quản trị
- Mục đích: giám sát tổng thể tình trạng vận hành của hệ thống.
- Dữ liệu hiển thị:
  - số lượng giảng viên;
  - số lượng sinh viên;
  - số lượng khóa học;
  - số lượng bài đánh giá;
  - thông tin tổng quan từ toàn nền tảng.
- Kết quả đầu ra: quản trị viên nắm nhanh quy mô và trạng thái hệ thống.

### 4.2. Quản lý giảng viên
- Mục đích: tạo, bật/tắt trạng thái hoạt động và xóa tài khoản giảng viên.
- Dữ liệu vào: thông tin cá nhân và nghiệp vụ của giảng viên.
- Xử lý chính:
  - tạo user role teacher;
  - cập nhật trạng thái active/inactive;
  - xóa user khi cần.
- Kết quả đầu ra: đội ngũ giảng viên trong hệ thống được quản lý tập trung.

### 4.3. Quản lý sinh viên
- Mục đích: tạo và quản trị hồ sơ sinh viên từ phía nhà trường.
- Dữ liệu vào: email, họ tên, ngành, chuyên ngành, lớp, khóa tuyển sinh, số điện thoại.
- Xử lý chính: tạo user student và hồ sơ student profile tương ứng.
- Kết quả đầu ra: sinh viên có thể được khởi tạo hàng loạt hoặc thủ công từ phía quản trị.

### 4.4. Quản lý trạng thái người dùng
- Mục đích: khóa hoặc kích hoạt lại tài khoản khi cần.
- Xử lý chính: gửi yêu cầu cập nhật `is_active` đến backend và áp dụng lên tài khoản tương ứng.
- Kết quả đầu ra: kiểm soát quyền truy cập của người dùng trên toàn hệ thống.

### 4.5. Xóa người dùng
- Mục đích: loại bỏ tài khoản không còn sử dụng hoặc tạo sai.
- Xử lý chính: quản trị viên chọn người dùng, hệ thống yêu cầu xác nhận và thực hiện xóa dữ liệu người dùng.
- Kết quả đầu ra: dữ liệu tài khoản được loại bỏ khỏi hệ thống theo quyền admin.

### 4.6. Quản lý khóa học
- Mục đích: theo dõi tất cả khóa học toàn hệ thống và xem chi tiết từng khóa học.
- Xử lý chính: lấy danh sách khóa học, mở chi tiết course để xem dữ liệu đầy đủ.
- Kết quả đầu ra: admin kiểm soát được tài nguyên đào tạo đang tồn tại trên nền tảng.

### 4.7. Tạo bài đánh giá
- Mục đích: cho phép quản trị viên tạo assignment hoặc assessment cho khóa học.
- Dữ liệu vào:
  - course id;
  - tiêu đề;
  - mô tả;
  - hướng dẫn;
  - loại bài đánh giá;
  - điểm tối đa;
  - trọng số;
  - thời gian bắt đầu, hạn nộp, thời lượng;
  - tệp đính kèm.
- Xử lý chính: backend lưu assessment và cấu hình trạng thái publish hoặc cho phép nộp muộn.
- Kết quả đầu ra: bài đánh giá mới xuất hiện trong hệ thống và có thể giao cho sinh viên.

### 4.8. Theo dõi tiến độ toàn hệ thống
- Mục đích: theo dõi mức độ học tập ở quy mô quản trị.
- Xử lý chính: tổng hợp dữ liệu từ nhiều user và khóa học để hiển thị trên trang admin progress.
- Kết quả đầu ra: quản trị viên có góc nhìn vĩ mô để ra quyết định vận hành hoặc cải tiến chương trình.

## 5. Nhóm chức năng AI và cá nhân hóa

### 5.1. Cá nhân hóa đầu vào bằng Gemini
- Mục đích: tạo hồ sơ học tập cá nhân ngay từ khi sinh viên bắt đầu sử dụng hệ thống.
- Cơ chế hoạt động:
  - hệ thống cung cấp bộ câu hỏi intake assessment;
  - backend chấm điểm kiến thức theo từng domain;
  - xây dựng phase readiness;
  - suy ra phase được mở khóa;
  - Gemini sinh phần tóm tắt và gợi ý bằng ngôn ngữ tự nhiên.
- Kết quả đầu ra: hồ sơ AI cá nhân hóa ban đầu cho từng sinh viên.

### 5.2. Tư vấn học tập từ dữ liệu học thật
- Mục đích: không chỉ dùng câu hỏi đầu vào, mà còn dùng dữ liệu học thật trong quá trình học để cập nhật khuyến nghị.
- Dữ liệu phân tích:
  - enrollment;
  - progress;
  - quiz results;
  - skill profile;
  - điểm mạnh, điểm yếu được phát hiện dần theo thời gian.
- Kết quả đầu ra: lời khuyên học tập có khả năng phản ánh trạng thái hiện tại hơn.

### 5.3. Hỏi đáp theo ngữ cảnh bài học
- Mục đích: làm cho chatbot không trả lời chung chung mà bám sát bài học đang học.
- Cơ chế hoạt động:
  - nạp thông tin khóa học và lesson hiện tại;
  - trích nội dung text từ PDF bài học;
  - tìm các câu hoặc đoạn liên quan đến câu hỏi;
  - đưa context này vào prompt cho mô hình.
- Kết quả đầu ra: câu trả lời gắn trực tiếp với nội dung môn học, phù hợp hơn với nhu cầu học tập.

### 5.4. Sinh giọng nói AI
- Mục đích: tạo trải nghiệm tutor gần với giao tiếp thật.
- Cơ chế hoạt động: Gemini TTS chuyển nội dung text thành audio, sau đó frontend phát lại cho người học.
- Kết quả đầu ra: sinh viên có thể nghe lời giải thích thay vì chỉ đọc văn bản.

### 5.5. Kế hoạch học tập thích ứng
- Mục đích: chuyển khuyến nghị AI thành lịch hoặc danh sách hành động thực tiễn.
- Dữ liệu đầu vào: mục tiêu học tập, mức độ khó mong muốn, điểm yếu hiện tại, phase đang học.
- Kết quả đầu ra: study plan cá nhân hóa theo thời gian ngắn hạn.

## 6. Nhóm chức năng quản lý dữ liệu học tập

### 6.1. Quản lý người dùng và vai trò
- Hệ thống phân 3 vai trò chính: sinh viên, giảng viên, quản trị viên.
- Mỗi vai trò có tập quyền truy cập, giao diện và nghiệp vụ riêng.
- Ý nghĩa: đây là cơ chế nền để đảm bảo bảo mật và đúng quy trình quản lý đào tạo.

### 6.2. Quản lý khóa học, bài học, tiến độ
- Các thực thể trung tâm gồm Course, Lesson, Enrollment, LessonProgress.
- Hệ thống ghi nhận sinh viên học môn nào, đã hoàn thành bao nhiêu phần trăm, đang ở giai đoạn nào.
- Ý nghĩa: đây là phần dữ liệu lõi cho dashboard, roadmap, advisor và analytics.

### 6.3. Quản lý bài đánh giá
- Hệ thống hỗ trợ Assessment, Submission, QuizResult, EssaySubmission.
- Ý nghĩa: cung cấp dữ liệu đánh giá cả trắc nghiệm lẫn tự luận, từ đó làm cơ sở cho theo dõi điểm số và AI phân tích.

### 6.4. Ghi nhận hoạt động học tập
- Hệ thống có khả năng lưu Learning Activity để phân tích hành vi học tập.
- Ý nghĩa: mở đường cho learning analytics và cảnh báo sớm.

## 7. Nhận xét tổng hợp cho báo cáo

- Hệ thống không dừng ở mức LMS cơ bản, mà kết hợp quản lý học tập với cá nhân hóa bằng AI.
- Điểm nổi bật nhất là chuỗi chức năng liên thông: bài test đầu vào -> phân tích Gemini -> mở khóa phase -> bản đồ tiến trình 3D -> AI advisor -> study plan.
- Về mặt quản trị, nền tảng đã tách rõ nghiệp vụ cho sinh viên, giảng viên và quản trị viên.
- Về mặt kỹ thuật, dữ liệu học thật như lesson progress, enrollment, quiz result được dùng để phục vụ cả báo cáo tiến độ lẫn tư vấn cá nhân hóa.
- Đây là cơ sở tốt để trình bày trong báo cáo theo các nhóm: chức năng nghiệp vụ, chức năng AI, chức năng quản trị và chức năng hỗ trợ ra quyết định học tập.