# KIẾN TRÚC HỆ THỐNG - GAME-BASED LEARNING PLATFORM

## 1. TỔNG QUAN HỆ THỐNG

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
│  │  Flutter │  │  Flutter │  │  Flutter │  │  Flutter Web │   │
│  │  Android │  │   iOS    │  │   Web    │  │  Admin Panel │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘   │
└───────┼─────────────┼─────────────┼────────────────┼───────────┘
        │             │             │                │
        └─────────────┴─────────────┴────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │   API Gateway /    │
                    │   Nginx + SSL      │
                    └─────────┬──────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐  ┌────────▼────────┐  ┌─────────▼───────┐
│  NestJS API    │  │  WebSocket      │  │  AI Service     │
│  REST API      │  │  Gateway        │  │  (OpenAI/Gemini) │
│  :3000         │  │  Socket.IO      │  │  :3002          │
│                │  │  :3001          │  │                 │
└───────┬────────┘  └────────┬────────┘  └─────────┬───────┘
        │                    │                      │
        └────────────────────┴──────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
    ┌─────────▼─────┐  ┌────▼────┐  ┌─────▼──────┐
    │  PostgreSQL   │  │  Redis  │  │ MinIO/S3   │
    │  Primary DB   │  │  Cache  │  │  Storage   │
    │               │  │  Queue  │  │            │
    └───────────────┘  └─────────┘  └────────────┘
```

## 2. CÔNG NGHỆ SỬ DỤNG

### Frontend
- **Flutter** 3.x (Web + Android + iOS)
- **Material Design 3**
- **BLoC/Cubit** State Management
- **Dio** HTTP Client
- **Socket.IO** Client
- **Firebase Messaging** Push Notifications
- **Hive** Local Storage

### Backend
- **NestJS** 10.x
- **TypeScript** 5.x
- **TypeORM** ORM
- **JWT** Authentication
- **Socket.IO** WebSocket
- **Bull** Queue (Redis)
- **Multer** File Upload
- **ExcelJS** Excel Parser

### Database
- **PostgreSQL** 16 (Primary)
- **Redis** 7 (Cache + Session + Queue)
- **MinIO** (Self-hosted S3 compatible)

### AI / External Services
- **OpenAI GPT-4** hoặc **Google Gemini Pro**
- **Firebase Cloud Messaging**

## 3. CLEAN ARCHITECTURE

```
backend/
├── src/
│   ├── core/                    # Domain Layer
│   │   ├── entities/            # Business Entities
│   │   ├── repositories/        # Repository Interfaces
│   │   ├── use-cases/           # Business Logic
│   │   └── value-objects/       # Value Objects
│   │
│   ├── infrastructure/          # Infrastructure Layer
│   │   ├── database/            # TypeORM Entities, Migrations
│   │   ├── repositories/        # Repository Implementations
│   │   ├── services/            # External Services
│   │   └── config/              # Configuration
│   │
│   ├── application/             # Application Layer
│   │   ├── auth/                # Authentication Module
│   │   ├── users/               # Users Module
│   │   ├── schools/             # Schools Module
│   │   ├── classes/             # Classes Module
│   │   ├── questions/           # Questions Module
│   │   ├── games/               # Games Module
│   │   ├── statistics/          # Statistics Module
│   │   ├── ai/                  # AI Module
│   │   └── notifications/       # Notifications Module
│   │
│   └── presentation/            # API Layer
│       ├── controllers/         # REST Controllers
│       ├── gateways/            # WebSocket Gateways
│       ├── dto/                 # Data Transfer Objects
│       └── middleware/          # Guards, Interceptors
```

## 4. DATA FLOW

### Luồng Upload Excel:
```
Teacher → Upload Excel → API Gateway → Parse Sheet
→ Validate Data → AI Classify (Topic/Difficulty)
→ Save to DB → Notify Teacher → Ready to Use
```

### Luồng Game:
```
Teacher Create Game → Student Join (Code/Link)
→ WebSocket Connect → Game Engine Start
→ Questions Push → Student Answer
→ Real-time Score Update → Leaderboard
→ Game End → Results Save → AI Analysis
```

### Luồng AI:
```
Question Uploaded → AI Process
→ Classify Subject → Classify Topic
→ Rate Difficulty → Generate Similar
→ Store Metadata → Available for Recommendations
```

## 5. DEPLOYMENT (PRODUCTION)

### Docker Compose Stack:
- NestJS API (x3 replicas)
- PostgreSQL (Primary + Replica)
- Redis Cluster
- MinIO
- Nginx Load Balancer
- Prometheus + Grafana (Monitoring)

### Targets:
- 10,000+ concurrent users
- <200ms API response
- 99.9% uptime
- Auto-scaling
