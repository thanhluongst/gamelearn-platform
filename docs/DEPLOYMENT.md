# HƯỚNG DẪN TRIỂN KHAI PRODUCTION

## YÊU CẦU HỆ THỐNG (10,000+ người dùng đồng thời)

### Server Requirements
```
CPU:    8 cores (16 cores khuyến nghị)
RAM:    16GB (32GB khuyến nghị)
Disk:   500GB SSD NVMe
OS:     Ubuntu 22.04 LTS
```

### Cloud (Khuyến nghị)
```
- AWS EC2 c5.2xlarge (8 CPU, 16GB RAM) x3 (API replicas)
- RDS PostgreSQL db.r6g.xlarge
- ElastiCache Redis cluster.r6g.large
- S3 hoặc MinIO (self-hosted)
- CloudFront CDN
```

---

## BƯỚC 1: SETUP SERVER

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker + Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo apt install docker-compose-plugin -y

# Install Nginx (optional if using Docker)
sudo apt install nginx certbot python3-certbot-nginx -y
```

---

## BƯỚC 2: CLONE VÀ CONFIGURE

```bash
git clone https://github.com/your-repo/gamelearn.git
cd gamelearn

# Copy và edit environment
cp backend/.env.example backend/.env
nano backend/.env  # Fill in all values

# Generate strong secrets
openssl rand -hex 32  # For JWT_SECRET
openssl rand -hex 32  # For JWT_REFRESH_SECRET
openssl rand -hex 16  # For REDIS_PASSWORD
```

---

## BƯỚC 3: SSL CERTIFICATE

```bash
# Get SSL certificate (replace yourdomain.com)
sudo certbot certonly --standalone -d yourdomain.com -d api.yourdomain.com

# Copy to nginx directory
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/
```

---

## BƯỚC 4: DATABASE SETUP

```bash
# Start only PostgreSQL first
docker compose up -d postgres

# Wait for it to be healthy
docker compose ps

# The schema.sql runs automatically on first start
# Verify:
docker compose exec postgres psql -U gamelearn -c "\dt"
```

---

## BƯỚC 5: BUILD AND START

```bash
# Build images
docker compose build

# Start all services
docker compose up -d

# Check logs
docker compose logs -f api

# Check health
curl https://yourdomain.com/api/health
```

---

## BƯỚC 6: MINÍO SETUP

```bash
# Access MinIO console at http://server-ip:9001
# Login with STORAGE_ACCESS_KEY / STORAGE_SECRET_KEY
# Create bucket: gamelearn
# Set bucket policy: public-read for /public/* prefix
```

---

## BƯỚC 7: MONITORING SETUP

```bash
# Grafana available at http://server-ip:3001
# Default: admin / admin123 (change immediately!)
# Import dashboard ID: 11835 (Node.js), 9628 (PostgreSQL)
```

---

## BƯỚC 8: FIREBASE SETUP

1. Tạo project tại https://console.firebase.google.com
2. Enable Cloud Messaging
3. Download service account JSON
4. Điền vào .env:
   ```
   FIREBASE_PROJECT_ID=xxx
   FIREBASE_PRIVATE_KEY="..."
   FIREBASE_CLIENT_EMAIL=...
   ```

---

## SCALE INSTRUCTIONS

### Tăng số lượng API replicas
```bash
docker compose up -d --scale api=5
```

### PostgreSQL Read Replica
```yaml
# Add to docker-compose.yml
postgres-replica:
  image: postgres:16-alpine
  environment:
    POSTGRES_USER: gamelearn
    POSTGRES_PASSWORD: ${DB_PASSWORD}
  command: |
    bash -c "
    until pg_basebackup -h postgres -D /var/lib/postgresql/data -U replication -P -Xs -R
    do sleep 1; done
    postgres
    "
```

### Redis Sentinel (High Availability)
```bash
# Deploy Redis Sentinel for auto-failover
docker compose -f docker-compose.redis-sentinel.yml up -d
```

---

## BACKUP

```bash
# Database backup (daily cron)
0 2 * * * docker compose exec -T postgres pg_dump -U gamelearn gamelearn | gzip > /backups/db_$(date +%Y%m%d).sql.gz

# Keep last 30 days
find /backups -name "db_*.sql.gz" -mtime +30 -delete

# MinIO backup
0 3 * * * mc mirror minio/gamelearn /backups/storage/
```

---

## PERFORMANCE TUNING

### PostgreSQL (postgresql.conf)
```ini
max_connections = 200
shared_buffers = 4GB            # 25% of RAM
effective_cache_size = 12GB     # 75% of RAM
work_mem = 16MB
maintenance_work_mem = 512MB
wal_buffers = 64MB
checkpoint_completion_target = 0.9
random_page_cost = 1.1          # For SSD
```

### Redis (redis.conf)
```ini
maxmemory 4gb
maxmemory-policy allkeys-lru
activerehashing yes
tcp-backlog 511
```

---

## HEALTH CHECKS & ALERTS

```bash
# API health
GET /api/health
Response: { status: "ok", uptime: 12345, database: "connected", redis: "connected" }

# Setup alerts via Grafana or UptimeRobot
# Recommended monitors:
# - API response time > 500ms
# - Database connection failures
# - Redis memory > 80%
# - Queue depth > 1000
```

---

## FLUTTER BUILD

### Web Build
```bash
cd frontend
flutter pub get
flutter build web --release --web-renderer canvaskit
# Deploy /build/web to S3/CloudFront or Nginx
```

### Android Build
```bash
flutter build apk --release
# Sign with your keystore
```

### iOS Build
```bash
flutter build ipa --release
# Requires Mac + Xcode
```

---

## ROLLBACK

```bash
# Tag releases
docker tag gamelearn-api:latest gamelearn-api:v1.2.0

# Rollback
docker compose down
docker tag gamelearn-api:v1.1.0 gamelearn-api:latest
docker compose up -d
```
