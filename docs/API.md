# API DOCUMENTATION - GAMELEARN PLATFORM

Base URL: `https://api.yourdomain.com/api/v1`

All requests require `Authorization: Bearer <token>` except public endpoints.

Response format:
```json
{
  "success": true,
  "data": {},
  "meta": { "total": 100, "limit": 20, "offset": 0 }
}
```

---

## AUTH

### POST /auth/register
Đăng ký tài khoản mới.
```json
Request: { "username", "email", "password", "fullName", "role", "schoolId" }
Response: { "accessToken", "refreshToken", "user": {...} }
```

### POST /auth/login
Đăng nhập.
```json
Request: { "identifier" (email or username), "password" }
Response: { "accessToken", "refreshToken", "user": {...} }
```

### POST /auth/refresh
Làm mới access token.
```json
Request: { "refreshToken" }
Response: { "accessToken", "refreshToken", "user": {...} }
```

### POST /auth/logout
Đăng xuất (requires auth).

### GET /auth/me
Thông tin người dùng hiện tại.

---

## USERS

### GET /users/:id
Thông tin user.

### PATCH /users/:id
Cập nhật thông tin.

### GET /users/:id/statistics
Thống kê học tập chi tiết.

### GET /users/:id/achievements
Danh sách huy hiệu.

### GET /users/:id/inventory
Kho đồ của user.

---

## SCHOOLS (Admin only)

### GET /schools
Danh sách trường.

### POST /schools
Tạo trường mới.

### GET /schools/:id
Chi tiết trường.

### PATCH /schools/:id
Cập nhật trường.

---

## CLASSES (Teacher)

### GET /classes
Danh sách lớp của giáo viên.

### POST /classes
Tạo lớp mới.
```json
Request: { "name", "grade", "subject", "description" }
Response: { ...class, "code": "ABC123" }
```

### GET /classes/:id
Chi tiết lớp + danh sách học sinh.

### POST /classes/:id/join
Học sinh tham gia lớp.
```json
Request: { "code": "ABC123" }
```

### GET /classes/:id/analytics
Thống kê lớp học.
```json
Response: {
  "totalStudents", "activeStudents", "participationRate",
  "averageScore", "topStudents": [...], "weakStudents": [...],
  "questionHeatmap": { "easy": {...}, "medium": {...}, "hard": {...} }
}
```

---

## QUESTION BANKS (Teacher)

### GET /question-banks
Danh sách ngân hàng câu hỏi.

### POST /question-banks
Tạo ngân hàng mới.
```json
Request: { "name", "description", "subject", "grade", "isPublic" }
```

### GET /question-banks/:id
Chi tiết ngân hàng.

### GET /question-banks/:id/questions
Danh sách câu hỏi.
```json
Query: { type, difficulty, subject, topic, limit, offset, random }
```

### POST /question-banks/:id/import
Upload Excel file (multipart/form-data).
```
Field: file (xlsx/xls)
Response: {
  "batchId", "totalRows", "successRows", "errorRows",
  "errors": [{ "sheet", "row", "error" }]
}
```

### GET /import-batches/:id/status
Trạng thái xử lý import (polling).
```json
Response: {
  "status": "processing|completed|failed",
  "aiProcessingStatus": "pending|processing|completed",
  "successRows", "errorRows"
}
```

---

## GAME SESSIONS

### POST /game-sessions
Giáo viên tạo phòng game.
```json
Request: {
  "classId", "bankId", "gameType",
  "questionCount": 10, "timePerQuestion": 30,
  "difficulty", "randomizeQuestions": true
}
Response: { ...session, "joinCode": "ABCD12" }
```

### GET /game-sessions
Danh sách phòng.
```json
Query: { status, classId, teacherId }
```

### GET /game-sessions/:id
Chi tiết phòng + kết quả.

### GET /game-sessions/:id/results
Kết quả chi tiết của phòng.
```json
Response: {
  "players": [{ rank, score, correctCount, wrongCount, xpEarned }],
  "questionAnalysis": [{ questionId, correctRate, avgTime }]
}
```

---

## WebSocket Events (Socket.IO)

Namespace: `/game`

### Client → Server

| Event | Payload | Description |
|-------|---------|-------------|
| `session:join` | `{ sessionId?, joinCode?, nickname? }` | Tham gia phòng |
| `session:start` | `{ sessionId }` | Bắt đầu game (Teacher) |
| `game:answer` | `{ sessionId, questionId, answer, timeTaken }` | Gửi đáp án |
| `session:next_question` | `{ sessionId }` | Câu tiếp (Teacher) |
| `game:reaction` | `{ sessionId, emoji }` | Biểu cảm |

### Server → Client

| Event | Payload | Description |
|-------|---------|-------------|
| `session:joined` | `session` | Xác nhận tham gia |
| `session:players_update` | `players[]` | Danh sách người chơi |
| `game:started` | `{ sessionId, gameType, totalQuestions }` | Game bắt đầu |
| `game:question` | `{ index, question }` | Câu hỏi mới |
| `game:answer_result` | `{ isCorrect, correctAnswer, scoreEarned, xpEarned }` | Kết quả đáp án |
| `game:leaderboard_update` | `players[]` | Bảng xếp hạng real-time |
| `game:ended` | `{ players, avgScore }` | Game kết thúc |
| `player:disconnected` | `{ userId, username }` | Player ngắt kết nối |
| `error` | `{ message }` | Lỗi |

---

## STATISTICS

### GET /statistics/user/:userId
Thống kê tổng hợp của học sinh.

### GET /statistics/user/:userId/chart
Dữ liệu biểu đồ.
```json
Query: { period: daily|weekly|monthly }
Response: { dates[], correctAnswers[], gamesPlayed[], xpEarned[] }
```

### GET /statistics/user/:userId/subjects
Năng lực theo môn.
```json
Response: {
  "subjects": [{ name, correctRate, totalQuestions, topics: [...] }],
  "strengths": ["..."], "weaknesses": ["..."]
}
```

---

## LEADERBOARD

### GET /leaderboard
Bảng xếp hạng.
```json
Query: { scope: class|grade|school|global, scopeId?, period: daily|weekly|monthly|yearly }
Response: { rankings: [{ rank, user, score, xp }] }
```

---

## AI

### POST /ai/analyze/:userId
Phân tích năng lực học sinh bằng AI.
```json
Response: { strengths[], weaknesses[], recommendations[], summary }
```

### POST /ai/generate-similar/:questionId
Sinh câu hỏi tương tự.
```json
Request: { count: 3 }
Response: { questions: [...] }
```

### POST /ai/personalized-exercise/:userId
Gợi ý bài luyện cá nhân hóa.
```json
Response: { focusTopics[], recommendedDifficulty, questions[] }
```

---

## ACHIEVEMENTS

### GET /achievements
Danh sách tất cả huy hiệu.

### GET /users/:userId/achievements
Huy hiệu của user.

---

## MISSIONS

### GET /missions/daily
Nhiệm vụ hôm nay.

### GET /users/:userId/missions
Tiến độ nhiệm vụ của user.

---

## NOTIFICATIONS

### GET /notifications
Danh sách thông báo.

### PATCH /notifications/:id/read
Đánh dấu đã đọc.

### PATCH /notifications/read-all
Đánh dấu tất cả đã đọc.
