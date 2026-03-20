# AI Learning Platform

## Docker

### Yêu cầu trước khi chạy

- Cài Docker Desktop hoặc Docker Engine
- Đảm bảo 2 lệnh `docker` và `docker-compose` chạy được trong terminal
- Đứng tại thư mục gốc dự án: `d:\KLTN\ai-learning-platform`

Chuẩn bị file môi trường:

```powershell
cd d:\KLTN\ai-learning-platform
Copy-Item .env.docker .env
```

Các file compose trong repo:

- `docker/docker-compose.dev.yml`: môi trường phát triển, frontend chạy Vite ở cổng `5173`, backend chạy Uvicorn với `--reload`
- `docker/docker-compose.prod.yml`: môi trường production/local production test, frontend chạy bằng Nginx ở cổng `3000`
- `docker/docker-compose.vps.yml`: môi trường public cho máy Windows của bạn, chỉ public frontend; backend và database nằm trong Docker network nội bộ
- `docker-compose.yml`: file full-stack cũ ở thư mục gốc, vẫn dùng được nhưng nên ưu tiên 2 file `dev` và `prod` mới

Tên project Docker Compose:

- `ai-learning-platform-dev` cho file `docker/docker-compose.dev.yml`
- `ai-learning-platform-prod` cho file `docker/docker-compose.prod.yml`
- `ai-learning-platform-vps` cho file `docker/docker-compose.vps.yml`
- `ai-learning-platform` cho file `docker-compose.yml`

Lưu ý: `dev` và `prod` dùng chung các cổng mặc định `8000`, `5432`, `6379`, `27017`, nên không chạy song song được nếu không đổi port mapping.

### Chạy môi trường development

Development phù hợp khi bạn cần sửa code và thấy thay đổi ngay trong container.

```powershell
cd d:\KLTN\ai-learning-platform
Copy-Item .env.docker .env -Force
docker-compose -f docker/docker-compose.dev.yml --env-file .env up --build
```

Các cổng sau khi chạy:

- Frontend Vite: http://localhost:5173
- Backend API: http://localhost:8000
- Swagger Docs: http://localhost:8000/docs
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- MongoDB: localhost:27017

Chạy nền:

```powershell
docker-compose -f docker/docker-compose.dev.yml --env-file .env up -d --build
```

### Chạy môi trường production

Production dùng đúng Dockerfile hiện có của frontend và backend.

```powershell
cd d:\KLTN\ai-learning-platform
Copy-Item .env.docker .env -Force
docker-compose -f docker/docker-compose.prod.yml --env-file .env up --build -d
```

Các cổng sau khi chạy:

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- Swagger Docs: http://localhost:8000/docs
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- MongoDB: localhost:27017

### Chạy public trên chính máy Windows của bạn

Nếu bạn muốn dùng máy hiện tại như một máy chủ public để người khác truy cập qua Internet, dùng stack VPS riêng:

```powershell
cd d:\KLTN\ai-learning-platform
scripts\setup.bat
notepad .env.vps
scripts\deploy.bat
```

Stack này dùng `docker/docker-compose.vps.yml` với kiến trúc:

- frontend public ra ngoài ở cổng `80`
- frontend proxy `/api` và `/uploads` sang backend nội bộ
- backend, PostgreSQL, Redis, Mongo không public trực tiếp ra Internet

Tài liệu đầy đủ xem tại:

- `docs/WINDOWS_VPS_DEPLOY.md`

### Chạy public nhanh bằng Cloudflare Tunnel free

Nếu bạn không muốn mở port router hoặc cấu hình NAT, có thể dùng Cloudflare Quick Tunnel để public ngay stack đang chạy ở `localhost:80`.

Tài liệu:

- `docs/CLOUDFLARE_TUNNEL_QUICK.md`

Script chạy tunnel:

- `scripts/start-cloudflare-tunnel.bat`

Lưu ý: Quick Tunnel cho URL ngẫu nhiên `trycloudflare.com`, phù hợp demo/testing, không phải endpoint production ổn định.

Nếu muốn chuyển sang stable tunnel với hostname cố định trên domain Cloudflare của bạn, dùng thêm:

- `.cloudflare-tunnel.env.example`
- `scripts/cloudflare-login.bat`
- `scripts/cloudflare-create-stable-tunnel.bat`
- `scripts/start-cloudflare-stable-tunnel.bat`
- `scripts/stop-cloudflare-tunnel.bat`
- `scripts/write-cloudflare-url.bat`

### Xem log và kiểm tra container lỗi

Xem toàn bộ trạng thái:

```powershell
docker-compose -f docker/docker-compose.dev.yml --env-file .env ps
docker-compose -f docker/docker-compose.prod.yml --env-file .env ps
```

Xem log chi tiết từng service:

```powershell
docker-compose -f docker/docker-compose.dev.yml --env-file .env logs -f frontend
docker-compose -f docker/docker-compose.dev.yml --env-file .env logs -f backend
docker-compose -f docker/docker-compose.dev.yml --env-file .env logs -f db
docker-compose -f docker/docker-compose.dev.yml --env-file .env logs -f redis
docker-compose -f docker/docker-compose.dev.yml --env-file .env logs -f mongo
```

Nếu một container lỗi, kiểm tra theo thứ tự này:

1. `docker-compose ... ps` để xem service nào ở trạng thái `Exit`, `Restarting` hoặc `Unhealthy`
2. `docker-compose ... logs -f <service-name>` để đọc lỗi khởi động thực tế
3. Kiểm tra file `.env` có đủ `POSTGRES_*`, `SECRET_KEY`, `GEMINI_API_KEY` nếu service AI cần dùng
4. Với `ALLOWED_ORIGINS`, dùng JSON array string như `[`"http://localhost:3000"`,`"http://localhost:5173"`]`
5. Kiểm tra cổng `3000`, `5173`, `8000`, `5432`, `6379`, `27017` có bị chiếm hay không

### Dừng và dọn dữ liệu

Dừng container:

```powershell
docker-compose -f docker/docker-compose.dev.yml --env-file .env down
docker-compose -f docker/docker-compose.prod.yml --env-file .env down
```

Dừng và xóa volume dữ liệu:

```powershell
docker-compose -f docker/docker-compose.dev.yml --env-file .env down -v
docker-compose -f docker/docker-compose.prod.yml --env-file .env down -v
```

### Biến môi trường quan trọng

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `SECRET_KEY`
- `GEMINI_API_KEY`
- `AZURE_AD_CLIENT_ID`
- `AZURE_AD_CLIENT_SECRET`
- `AZURE_AD_TENANT_ID`
- `FRONTEND_BASE_URL`
- `ALLOWED_ORIGINS` với định dạng JSON array string, ví dụ `[`"http://localhost:3000"`,`"http://localhost:5173"`]`
- `VITE_API_URL`
- `VITE_API_BASE_URL`

### Lưu ý

- Trong môi trường hiện tại, nếu terminal báo không nhận ra `docker` hoặc `docker-compose`, cần cài Docker Desktop và mở lại terminal
- Development dùng frontend ở cổng `5173`; production dùng frontend ở cổng `3000`
- Backend image vẫn sẽ khá lớn nếu giữ toàn bộ dependency ML; tối ưu hiện tại đã bỏ build tool khỏi runtime image và loại test/dev package khỏi image backend
