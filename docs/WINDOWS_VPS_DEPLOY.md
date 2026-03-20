# Deploy tren may Windows cua ban de nguoi khac truy cap

Tai lieu nay dung cho truong hop ban muon dung chinh may Windows hien tai nhu mot may chu cong khai toi thieu.

## Kien truc de xuat

- Frontend va API di qua cung mot dia chi cong khai.
- Nginx trong container frontend proxy `/api` va `/uploads` sang backend.
- Backend, PostgreSQL, Redis, Mongo chi nam trong Docker network noi bo.
- Nguoi dung ben ngoai chi can truy cap cong web cua frontend.

## 1. Chuan bi dia chi cong khai

Ban can mot trong hai cach sau:

- Co IP public va router cho phep port forwarding cong 80 vao may nay.
- Hoac dung ten mien/domain tro ve IP public cua ban.

Neu ban o sau modem/router, can forward:

- TCP 80 -> IP LAN cua may Windows chay Docker

## 2. Tao file cau hinh VPS

Tu thu muc goc du an:

```bat
scripts\setup.bat
```

Sau do sua file `.env.vps`:

- `PUBLIC_BASE_URL=http://YOUR_PUBLIC_IP` hoac domain cua ban
- `POSTGRES_PASSWORD=` doi mat khau manh
- `SECRET_KEY=` doi key manh
- `GEMINI_API_KEY=` neu can AI Tutor
- `ALLOWED_ORIGINS=` dat dung origin cong khai

Vi du:

```env
PUBLIC_BASE_URL=http://203.0.113.10
FRONTEND_PORT=80
ALLOWED_ORIGINS=["http://203.0.113.10"]
VITE_API_URL=/api
VITE_API_BASE_URL=http://203.0.113.10
```

## 3. Mo Windows Firewall

Chay PowerShell bang quyen Administrator:

```powershell
New-NetFirewallRule -DisplayName "AI Learning Platform HTTP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80
```

Neu ban muon dung HTTPS bang reverse proxy khac, mo them cong 443.

## 4. Deploy

```bat
scripts\deploy.bat
```

Hoac start lai stack:

```bat
scripts\start.bat
```

Dung stack:

```bat
scripts\stop.bat
```

## 5. Kiem tra tu ngoai Internet

Tren mot may khac ngoai mang LAN, truy cap:

- `http://YOUR_PUBLIC_IP`

Neu khong vao duoc, kiem tra theo thu tu:

1. Docker Desktop dang chay
2. `scripts\deploy.bat` da chay thanh cong
3. Windows Firewall da mo cong 80
4. Router da forward cong 80 dung IP LAN cua may nay
5. ISP co chan cong 80 hay khong

## 6. Gioi han thuc te

May Windows lam VPS van chay duoc cho demo, bao cao, noi bo, hoac so luong nguoi dung nho. Nhung ban can biet:

- May phai mo 24/7
- Mat dien, ngu dong, restart Windows se lam app dung
- IP public gia dinh co the thay doi
- Khong co HTTPS mac dinh

Neu ban muon on dinh hon cho nguoi dung that, dung VPS Linux hoac Cloudflare Tunnel se hop ly hon.