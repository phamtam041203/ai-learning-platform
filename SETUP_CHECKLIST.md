# 🚀 AI Learning Platform - Setup Checklist

## ✅ Kiểm Tra Trước Khi Cài Đặt

### 1. Phần Mềm Cần Thiết
- [ ] Python 3.10+ đã cài đặt
- [ ] Node.js 18+ đã cài đặt
- [ ] PostgreSQL 14+ đã cài đặt và đang chạy
- [ ] Redis đã cài đặt và đang chạy
- [ ] MongoDB (tùy chọn) đã cài đặt và đang chạy
- [ ] Git đã cài đặt

### 2. Biến Môi Trường
- [ ] Đã tạo file `.env` trong thư mục `backend/`
- [ ] Đã cấu hình DATABASE_URL
- [ ] Đã cấu hình REDIS_URL
- [ ] Đã cấu hình SECRET_KEY
- [ ] Đã cấu hình OPENAI_API_KEY (nếu sử dụng)

---

## 📦 Cài Đặt Backend

### Bước 1: Tạo Virtual Environment
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
```

### Bước 2: Cài Đặt Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-ml.txt  # Nếu cần ML features
pip install -r requirements-dev.txt  # Nếu phát triển
```

### Bước 3: Cấu Hình Database
```bash
# Tạo database
createdb learning_db  # PostgreSQL

# Chạy migrations
alembic upgrade head

# Seed dữ liệu mẫu (tùy chọn)
python scripts/seed_database.py
```

### Bước 4: Chạy Backend Server
```bash
python run.py
# hoặc
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Kiểm tra:** Truy cập http://localhost:8000/docs

---

## 🎨 Cài Đặt Frontend

### Bước 1: Cài Đặt Dependencies
```bash
cd frontend
npm install
```

### Bước 2: Cấu Hình Environment
- [ ] Kiểm tra file `.env` (nếu có)
- [ ] Đảm bảo API URL đúng trong `src/services/api.js`

### Bước 3: Chạy Development Server
```bash
npm run dev
```

**Kiểm tra:** Truy cập http://localhost:5173

---

## 🐳 Cài Đặt với Docker (Tùy Chọn)

### Bước 1: Chạy tất cả services
```bash
docker-compose up -d
```

### Bước 2: Kiểm tra services
```bash
docker-compose ps
```

### Bước 3: Xem logs
```bash
docker-compose logs -f backend
```

---

## 🧪 Chạy Tests

### Backend Tests
```bash
cd backend
pytest
pytest --cov=app tests/  # Với coverage
```

### Frontend Tests
```bash
cd frontend
npm test
```

---

## 🔧 Khắc Phục Sự Cố Thường Gặp

### ❌ Lỗi "Module not found"
```bash
pip install -r requirements.txt --force-reinstall
```

### ❌ Lỗi Database Connection
- Kiểm tra PostgreSQL đang chạy: `pg_isready`
- Kiểm tra cấu hình DATABASE_URL trong `.env`
- Thử tạo lại database: `dropdb learning_db && createdb learning_db`

### ❌ Lỗi Redis Connection
- Kiểm tra Redis đang chạy: `redis-cli ping`
- Nếu chưa cài Redis: `choco install redis-64` (Windows)

### ❌ Lỗi CORS trong Frontend
- Kiểm tra backend cho phép origin: http://localhost:5173
- Xem file `backend/app/main.py` - phần CORS middleware

### ❌ Lỗi npm install
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### ❌ Lỗi PyTorch (Windows)
```bash
# Cài đặt CPU version
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

---

## 📊 Kiểm Tra Sau Khi Setup

### Backend Health Check
- [ ] http://localhost:8000 trả về message thành công
- [ ] http://localhost:8000/docs hiển thị Swagger UI
- [ ] http://localhost:8000/health trả về status: healthy

### Frontend Check
- [ ] http://localhost:5173 hiển thị trang chủ
- [ ] Đăng nhập/đăng ký hoạt động
- [ ] Gọi API backend thành công

### Database Check
```bash
# Kết nối PostgreSQL
psql -U postgres -d learning_db -c "SELECT COUNT(*) FROM users;"
```

---

## 🎯 Các Bước Tiếp Theo

### Development
1. [ ] Tạo tài khoản admin đầu tiên
2. [ ] Tạo courses mẫu
3. [ ] Test các tính năng chính
4. [ ] Cấu hình logging

### ML Models
1. [ ] Download pre-trained models (nếu có)
2. [ ] Train recommendation model với dữ liệu mẫu
3. [ ] Test chatbot functionality

### Production
1. [ ] Thay đổi SECRET_KEY
2. [ ] Disable DEBUG mode
3. [ ] Cấu hình HTTPS
4. [ ] Setup monitoring và backup

---

## 📝 File Cấu Hình Mẫu

### backend/.env
```env
# Application
APP_NAME="AI Learning Platform"
DEBUG=True

# Database
DATABASE_URL=postgresql://postgres:admin@localhost:5432/learning_db
MONGODB_URL=mongodb://localhost:27017
REDIS_URL=redis://localhost:6379

# Security
SECRET_KEY=your-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AI Models
OPENAI_API_KEY=your-openai-key-here
BERT_MODEL_NAME=vinai/phobert-base

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

---

## 🆘 Hỗ Trợ

- **Issues:** Tạo issue trên GitHub repository
- **Documentation:** Xem thư mục `docs/`
- **Email:** [your-email@example.com]

---

**Cập nhật lần cuối:** 22/01/2026
**Phiên bản:** 1.0.0
