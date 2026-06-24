# 🎮 GameLearn - Nền Tảng Game Hóa Học Tập K-12

> Biến việc học thành cuộc phiêu lưu - Học vui, Chơi giỏi!

## Cấu trúc dự án

```
GameLearn/
├── 📁 backend/               # NestJS API Server
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/         # JWT Authentication
│   │   │   ├── users/        # Quản lý người dùng
│   │   │   ├── schools/      # Quản lý trường
│   │   │   ├── classes/      # Quản lý lớp học
│   │   │   ├── questions/    # Ngân hàng câu hỏi + Import Excel
│   │   │   ├── games/        # Game engine + WebSocket
│   │   │   ├── statistics/   # Thống kê học tập
│   │   │   ├── ai/           # AI phân loại + phân tích
│   │   │   ├── achievements/ # Huy hiệu + Thành tích
│   │   │   ├── missions/     # Nhiệm vụ hàng ngày
│   │   │   ├── leaderboard/  # Bảng xếp hạng
│   │   │   ├── notifications/# Push notifications
│   │   │   ├── storage/      # MinIO/S3
│   │   │   └── admin/        # Admin panel API
│   │   └── common/           # Filters, interceptors
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
│
├── 📁 frontend/              # Flutter App
│   ├── lib/
│   │   ├── core/
│   │   │   ├── di/           # Dependency injection (GetIt)
│   │   │   ├── network/      # Dio + Socket.IO client
│   │   │   ├── router/       # GoRouter navigation
│   │   │   └── theme/        # Material Design 3
│   │   └── features/
│   │       ├── auth/         # Login, Register, BLoC
│   │       ├── student/      # Student dashboard, profile, leaderboard
│   │       ├── teacher/      # Teacher dashboard, class, analytics
│   │       ├── admin/        # Admin panel
│   │       ├── games/        # Game play, lobby, results (WebSocket)
│   │       ├── questions/    # Question banks, Excel import
│   │       └── notifications/# FCM push notifications
│   └── pubspec.yaml
│
├── 📁 database/
│   └── schema.sql            # PostgreSQL complete schema
│
├── 📁 docs/
│   ├── ARCHITECTURE.md       # Kiến trúc hệ thống
│   ├── API.md                # API documentation
│   └── DEPLOYMENT.md         # Hướng dẫn triển khai
│
├── 📁 nginx/
│   └── nginx.conf            # Load balancer + SSL
│
└── docker-compose.yml        # Full stack deployment
```

## Tính năng

### 🎓 Hệ thống câu hỏi
- Trắc nghiệm 4 đáp án (A/B/C/D)
- Đúng / Sai
- Điền số (hỗ trợ phân số, số thập phân: `1/2`, `0.5`, `0,5`)
- Import hàng loạt từ Excel (3 sheet: MULTIPLE_CHOICE, TRUE_FALSE, NUMERIC)
- AI tự động phân loại môn, chủ đề, độ khó

### 🎮 6 Trò chơi
| Game | Mô tả | Người chơi |
|------|--------|-----------|
| 🎣 Câu Cá | Câu cá kiến thức, combo, boss | 1-30 |
| ⛏️ Đào Vàng | Tìm vàng, kim cương | 1-50 |
| 🏎️ Đua Xe | Đua xe multi-player real-time | 2-20 |
| 🗺️ Kho Báu | Bản đồ ô vuông, tìm kho báu | 1-20 |
| 🧩 Ghép Tranh | Mở mảnh ghép dần | 1-30 |
| ⚔️ Đấu Trường | PvP real-time, rank theo điểm+tốc độ | 2-50 |

### 🏆 Gamification
- XP + Level (1-100)
- Huy hiệu (Bronze → Legend)
- Nhiệm vụ hàng ngày/tuần
- Bảng xếp hạng (Lớp/Trường/Toàn quốc)
- Streak hàng ngày
- Kho đồ, nhân vật, giao diện

### 🤖 AI (OpenAI GPT-4)
- Phân loại câu hỏi tự động (môn, chủ đề, độ khó)
- Sinh câu hỏi tương tự
- Phân tích điểm mạnh/yếu học sinh
- Đề xuất bài luyện cá nhân hóa

### 📊 Thống kê
- Dashboard học sinh (biểu đồ ngày/tuần/tháng)
- Dashboard giáo viên (heatmap, top/yếu)
- Export PDF & Excel
- AI báo cáo chi tiết

## Khởi chạy nhanh

```bash
# 1. Clone repo
git clone <repo>
cd gamelearn

# 2. Cấu hình environment
cp backend/.env.example backend/.env
# Điền API keys vào .env

# 3. Chạy với Docker
docker compose up -d

# 4. Xem API docs
open http://localhost:3000/api/docs

# 5. Build Flutter web
cd frontend
flutter pub get
flutter run -d chrome
```

## Công nghệ

| Lớp | Công nghệ |
|-----|-----------|
| Backend | NestJS 10, TypeScript, TypeORM |
| Database | PostgreSQL 16 |
| Cache/Queue | Redis 7, Bull |
| Realtime | Socket.IO |
| Storage | MinIO (S3-compatible) |
| AI | OpenAI GPT-4 / Gemini Pro |
| Push | Firebase Cloud Messaging |
| Frontend | Flutter 3.x, BLoC, GoRouter |
| UI | Material Design 3, flutter_animate |
| Deploy | Docker Compose, Nginx |
| Monitor | Prometheus + Grafana |

## API Endpoints chính

```
POST   /api/v1/auth/login
POST   /api/v1/auth/register
GET    /api/v1/auth/me

GET    /api/v1/question-banks
POST   /api/v1/question-banks/:id/import     # Upload Excel
POST   /api/v1/game-sessions                  # Tạo phòng game
WS     /game (Socket.IO)                      # Real-time game

GET    /api/v1/leaderboard?scope=class&period=weekly
POST   /api/v1/ai/analyze/:userId
GET    /api/v1/statistics/user/:userId/chart
```

## Target Production

- **10,000+** người dùng đồng thời
- **< 200ms** API response time
- **99.9%** uptime với 3 replicas + Redis cache
- WebSocket support cho game real-time

---

Built with ❤️ for Vietnamese K-12 Education
