import { registerAs } from '@nestjs/config';

export default registerAs('app', () => ({
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  jwtSecret: process.env.JWT_SECRET || 'super-secret-key-change-in-production',
  jwtExpiry: process.env.JWT_EXPIRY || '7d',
  jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'refresh-secret-key',
  jwtRefreshExpiry: process.env.JWT_REFRESH_EXPIRY || '30d',
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT, 10) || 6379,
    password: process.env.REDIS_PASSWORD || undefined,
  },
  storage: {
    endpoint: process.env.STORAGE_ENDPOINT || 'http://localhost:9000',
    accessKey: process.env.STORAGE_ACCESS_KEY || 'minioadmin',
    secretKey: process.env.STORAGE_SECRET_KEY || 'minioadmin',
    bucket: process.env.STORAGE_BUCKET || 'gamelearn',
    publicUrl: process.env.STORAGE_PUBLIC_URL || 'http://localhost:9000',
  },
  openai: {
    apiKey: process.env.OPENAI_API_KEY || '',
    model: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY || '',
  },
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
  },
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:8080',
}));
