# Hướng dẫn tích hợp ChatGPT vào AI Learning Advisor

## Tính năng đã cập nhật ✨

### 1. **Dark Mode** 🌙
- Nhấn nút Moon/Sun ở góc phải header để chuyển đổi
- Tự động lưu preference vào localStorage
- Toàn bộ giao diện hỗ trợ dark mode

### 2. **Lưu lịch sử chat** 💾
- Tất cả tin nhắn được lưu vào localStorage
- Khi reload trang, lịch sử chat vẫn còn
- Nút "🗑️" để xóa toàn bộ lịch sử

### 3. **Nút toggle sidebar** ↔️
- Nút "←" trong header sidebar để đóng
- Khi đóng, xuất hiện nút floating bên trái để mở lại
- Trạng thái mở/đóng được lưu vào localStorage

### 4. **Tích hợp ChatGPT** 🤖
- Frontend gọi API `/api/chatbot/chatgpt`
- Backend tự động fallback về local advisor nếu:
  - Không có API key
  - API timeout
  - API lỗi
- Hiển thị source (chatgpt/local) trong response

## Cách cấu hình ChatGPT API

### Bước 1: Lấy API Key từ OpenAI

1. Truy cập https://platform.openai.com/
2. Đăng ký/Đăng nhập tài khoản
3. Vào **API Keys** section
4. Click **Create new secret key**
5. Copy API key (dạng: `sk-...`)

### Bước 2: Thêm API Key vào Backend

Tạo file `.env` trong thư mục `backend/`:

```bash
cd backend
cp .env.example .env
```

Mở file `.env` và thêm:

```env
OPENAI_API_KEY=sk-your-actual-api-key-here
```

### Bước 3: Cài đặt dependencies

Backend cần thư viện `httpx` để call OpenAI API:

```bash
cd backend
pip install httpx
```

Hoặc thêm vào `requirements.txt`:
```
httpx==0.24.1
```

### Bước 4: Restart Backend

```bash
cd backend
python run.py
```

## Kiểm tra hoạt động

### Test 1: Không có API key (Local fallback)
Nếu không có `OPENAI_API_KEY` trong `.env`:
- Chat vẫn hoạt động
- Sử dụng local advisor (rule-based)
- Response có `source: 'local'`

### Test 2: Có API key (ChatGPT)
Nếu có `OPENAI_API_KEY`:
- Chat gọi OpenAI GPT-3.5-turbo
- Response tiếng Việt tự nhiên hơn
- Response có `source: 'chatgpt'`
- Hiển thị tokens used

### Test 3: Dark Mode
1. Mở AI Advisor
2. Click nút Moon ở header
3. Giao diện chuyển sang dark mode
4. Refresh trang → vẫn giữ dark mode

### Test 4: Lịch sử chat
1. Chat vài câu
2. Refresh trang
3. Lịch sử vẫn còn
4. Click nút 🗑️ để xóa

### Test 5: Toggle sidebar
1. Click nút ← trong sidebar
2. Sidebar đóng lại
3. Xuất hiện nút floating bên trái
4. Click nút floating → sidebar mở lại

## Cấu trúc Code

### Frontend (`frontend/src/pages/student/AIAdvisorPage.jsx`)
```javascript
// State management
const [isDarkMode, setIsDarkMode] = useState(false);
const [messages, setMessages] = useState([]);

// LocalStorage persistence
useEffect(() => {
  localStorage.setItem('ai_advisor_messages', JSON.stringify(messages));
}, [messages]);

// ChatGPT call với fallback
const response = await chatbotAPI.askChatGPT(message);
```

### Backend (`backend/app/api/chatbot.py`)
```python
@router.post("/chatgpt")
async def ask_chatgpt(request: ChatMessage):
    # Get student context
    analysis = advisor.analyze_student_profile(user.id)
    
    # Call OpenAI with context
    async with httpx.AsyncClient() as client:
        response = await client.post(OPENAI_API_URL, ...)
    
    # Fallback nếu lỗi
    except Exception:
        return local_advisor_response
```

## Chi phí API

- GPT-3.5-turbo: ~$0.002 / 1K tokens
- 1 câu hỏi ≈ 200-500 tokens
- Chi phí: ~$0.0004 - $0.001 / câu hỏi
- 1000 câu hỏi ≈ $0.40 - $1.00

## Lưu ý

1. **API Key bảo mật**: Không commit `.env` vào git
2. **Rate limit**: OpenAI có giới hạn request/phút
3. **Timeout**: Set 30s timeout cho API call
4. **Error handling**: Luôn có fallback về local advisor
5. **Cost monitoring**: Theo dõi usage trên OpenAI dashboard

## Troubleshooting

### Lỗi: "OpenAI API key not configured"
→ Kiểm tra file `.env` có `OPENAI_API_KEY`

### Lỗi: "ChatGPT timeout"
→ Mạng chậm hoặc OpenAI quá tải. Hệ thống tự fallback.

### Dark mode không lưu
→ Kiểm tra localStorage trong DevTools

### Lịch sử chat mất
→ Kiểm tra console có lỗi JSON parse không

### Nút floating không hiện
→ Đảm bảo CSS đã load và `.analysis-panel.hide` có width: 0

## Demo

Xem video demo tại: [link demo]

hoặc test trực tiếp tại: http://localhost:3000/student/ai-advisor
