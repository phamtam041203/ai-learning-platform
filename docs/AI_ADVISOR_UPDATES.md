# ✨ AI Advisor - Cập nhật mới

## 🎉 Tính năng mới đã thêm

### 1. 🌙 Dark Mode
- **Toggle**: Nhấn nút Moon/Sun ở header
- **Tự động lưu**: Preference được lưu vào localStorage
- **Toàn diện**: Tất cả components đều hỗ trợ dark mode

### 2. 💾 Lưu lịch sử chat
- **Persistent**: Tất cả tin nhắn được lưu vào localStorage
- **Không mất dữ liệu**: Refresh trang vẫn giữ lịch sử chat
- **Xóa dễ dàng**: Nút 🗑️ để clear toàn bộ lịch sử

### 3. ↔️ Toggle Sidebar có thể mở lại
- **Nút trong sidebar**: Click ← để đóng panel phân tích
- **Floating button**: Khi đóng, xuất hiện nút tròn bên trái để mở lại
- **Luôn truy cập được**: Không bao giờ bị "mất" sidebar
- **Lưu trạng thái**: Preference được lưu vào localStorage

### 4. 🤖 Tích hợp ChatGPT
- **OpenAI GPT-3.5-turbo**: Chat với AI thật, không phải rule-based
- **Context-aware**: ChatGPT nhận thông tin học tập của sinh viên
- **Fallback thông minh**: Tự động dùng local advisor nếu:
  - Không có API key
  - API timeout
  - API lỗi hoặc quá tải
- **Tiếng Việt tự nhiên**: Response của ChatGPT mượt mà hơn

## 📸 Screenshots

### Dark Mode
```
Trước: Light theme với background gradient tím
Sau: Dark theme với background gradient xanh đậm
```

### Lịch sử chat
```
- Tin nhắn cũ vẫn hiển thị sau reload
- Nút 🗑️ ở header để xóa
```

### Floating Toggle
```
Sidebar đóng → Nút tròn xuất hiện bên trái
Click nút → Sidebar mở lại
```

### ChatGPT Response
```
User: "Tôi đang học tốt như thế nào?"

ChatGPT: "Dựa trên phân tích hồ sơ học tập của bạn, tôi thấy bạn 
đang có một kết quả khá tốt với điểm trung bình 66.67/100. Tuy nhiên, 
bạn cần cải thiện ở một số mặt..."

Source: chatgpt ✓
```

## 🚀 Hướng dẫn sử dụng

### Bật Dark Mode
1. Vào AI Advisor page
2. Click nút 🌙 (Moon) ở góc phải header
3. Giao diện chuyển sang dark mode
4. Click nút ☀️ (Sun) để chuyển lại light mode

### Xem/Xóa lịch sử chat
1. Scroll lên xem tin nhắn cũ
2. Tất cả chat được lưu tự động
3. Muốn xóa → Click nút 🗑️ ở header
4. Confirm → Lịch sử bị xóa, chat mới bắt đầu

### Đóng/Mở sidebar phân tích
1. Click nút ← trong header sidebar
2. Sidebar thu nhỏ về width: 0
3. Nút floating (⊳) xuất hiện bên trái màn hình
4. Click nút floating → Sidebar mở lại

### Sử dụng ChatGPT
#### Không cần cấu hình (Local fallback)
- Chỉ cần chat bình thường
- Hệ thống tự động dùng local advisor
- Response có `source: 'local'`

#### Có ChatGPT API key (Recommended)
1. Lấy API key từ https://platform.openai.com/
2. Tạo file `backend/.env`:
   ```env
   OPENAI_API_KEY=sk-your-key-here
   ```
3. Restart backend
4. Chat như bình thường
5. Response có `source: 'chatgpt'` và tokens used

## 🔧 Cấu hình ChatGPT API

### Lấy API Key

1. **Đăng ký OpenAI**
   - Truy cập https://platform.openai.com/signup
   - Đăng ký với email/Google account
   
2. **Tạo API Key**
   - Vào https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Copy key (dạng: `sk-...`)
   - **Lưu ý**: Key chỉ hiển thị 1 lần, lưu lại ngay!

3. **Nạp credit** (Nếu cần)
   - Vào https://platform.openai.com/account/billing
   - Add payment method
   - Nạp tối thiểu $5

### Thêm vào Backend

1. **Tạo file .env**
   ```bash
   cd backend
   copy .env.example .env
   ```

2. **Thêm API key**
   ```env
   OPENAI_API_KEY=sk-proj-abc123...xyz
   ```

3. **Restart backend**
   ```bash
   python run.py
   ```

4. **Kiểm tra**
   - Mở AI Advisor
   - Chat 1 câu hỏi
   - Check console → Response có `source: 'chatgpt'`

## 💰 Chi phí ChatGPT

### Giá cả
- **GPT-3.5-turbo**: $0.002 / 1K tokens
- **1 câu hỏi**: ~200-500 tokens
- **Cost per query**: ~$0.0004 - $0.001

### Ước tính
- 100 câu hỏi: ~$0.04 - $0.10
- 1000 câu hỏi: ~$0.40 - $1.00
- 10000 câu hỏi: ~$4.00 - $10.00

### Tiết kiệm
- Dùng GPT-3.5-turbo thay vì GPT-4 (rẻ hơn 10x)
- Set max_tokens: 500 (đủ dùng)
- Fallback về local khi không cần thiết

## 🐛 Troubleshooting

### Dark mode không lưu
**Nguyên nhân**: localStorage bị block
**Giải pháp**: 
- Mở DevTools → Application → Local Storage
- Clear và thử lại
- Kiểm tra browser không ở chế độ incognito

### Lịch sử chat bị mất
**Nguyên nhân**: localStorage bị clear hoặc lỗi JSON
**Giải pháp**:
- Check console có error không
- Xóa key `ai_advisor_messages` trong localStorage
- Refresh lại trang

### Nút floating không hiện
**Nguyên nhân**: CSS chưa load hoặc state chưa update
**Giải pháp**:
- Hard refresh (Ctrl+Shift+R)
- Check trong Elements có class `.floating-toggle-btn`
- Kiểm tra state `showAnalysis` trong React DevTools

### ChatGPT không hoạt động
**Nguyên nhân 1**: Không có API key
**Giải pháp**: 
- Check file `.env` có `OPENAI_API_KEY`
- Restart backend sau khi thêm key

**Nguyên nhân 2**: API key hết hạn/invalid
**Giải pháp**:
- Login vào https://platform.openai.com/
- Tạo key mới và thay thế

**Nguyên nhân 3**: Hết credit
**Giải pháp**:
- Check https://platform.openai.com/account/usage
- Nạp thêm credit

**Nguyên nhân 4**: Rate limit
**Giải pháp**:
- Đợi 1 phút rồi thử lại
- Upgrade plan nếu cần RPM cao hơn

### Backend lỗi "ModuleNotFoundError: httpx"
**Nguyên nhân**: Chưa cài httpx
**Giải pháp**:
```bash
cd backend
.\venv\Scripts\python.exe -m pip install httpx
```

## 📝 Technical Details

### LocalStorage Keys
- `ai_advisor_messages`: Array of chat messages
- `ai_advisor_dark_mode`: Boolean dark mode state
- `ai_advisor_show_analysis`: Boolean sidebar state

### API Endpoints
- `POST /api/chatbot/chatgpt`: ChatGPT integration
- `POST /api/chatbot/advisor/ask`: Local advisor
- `GET /api/chatbot/advisor/analyze`: Student analysis

### ChatGPT Context
Backend gửi cho ChatGPT:
- Overall score & grade
- Completed courses / Total courses
- Average quiz score & pass rate
- Top 3 strengths
- Top 3 weaknesses
- Study hours

### Fallback Logic
```
Try ChatGPT
  ↓ Failed
Try Local Advisor
  ↓ Failed
Show error message
```

## 🎯 Best Practices

### Sử dụng Dark Mode
- Bật khi học ban đêm để giảm mỏi mắt
- Tắt khi học ban ngày để tăng độ tương phản

### Quản lý lịch sử
- Xóa chat cũ định kỳ để tăng performance
- Export chat quan trọng trước khi xóa

### Tối ưu chi phí ChatGPT
- Chỉ bật khi cần câu trả lời sâu
- Dùng local advisor cho câu hỏi đơn giản
- Monitor usage thường xuyên

### Security
- Không share API key
- Không commit `.env` vào git
- Rotate key định kỳ (3-6 tháng)

## 📚 Further Reading
- OpenAI API Docs: https://platform.openai.com/docs
- React LocalStorage: https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
- CSS Dark Mode: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme
