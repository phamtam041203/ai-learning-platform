# Cloudflare Quick Tunnel cho stack hien tai

Tai lieu nay dung khi ban muon public nhanh du an dang chay tren `http://localhost:80` ma khong mo router hay port forwarding.

## Cach hoat dong

- Docker stack cua ban van chay tren may local.
- `cloudflared` mo mot ket noi outbound tu may ban len Cloudflare.
- Cloudflare cap mot URL ngau nhien dang `https://something.trycloudflare.com`.
- Nguoi khac truy cap URL do va duoc proxy ve `http://localhost:80`.

## Gioi han

- URL thay doi moi lan start tunnel.
- Quick Tunnel phu hop demo, testing, review, khong phu hop production on dinh.
- Cloudflare ghi ro co gioi han request dong thoi va khong co SLA.

## Script du an

- `scripts/start-cloudflare-tunnel.bat`

Script nay se tro tunnel vao `http://localhost:80`.

## Neu quick tunnel khong chay

Cloudflare docs ghi ro quick tunnel co the khong chay neu ton tai file:

- `%USERPROFILE%\.cloudflared\config.yml`

Neu co, doi ten tam file do roi chay lai.

## Stable tunnel

Neu ban muon URL co dinh tren domain cua ban, dung bo script stable tunnel thay vi quick tunnel:

- `scripts/cloudflare-login.bat`
- `scripts/cloudflare-create-stable-tunnel.bat`
- `scripts/start-cloudflare-stable-tunnel.bat`
- `scripts/stop-cloudflare-tunnel.bat`
- `scripts/write-cloudflare-url.bat`

Can file cau hinh:

- `.cloudflare-tunnel.env`

Tao no tu:

- `.cloudflare-tunnel.env.example`

Trong do `CF_TUNNEL_HOSTNAME` phai la hostname day du nam trong mot zone Cloudflare, vi du:

- `phamtamailearning.example.com`