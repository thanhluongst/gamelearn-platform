import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { ScheduleModule } from '@nestjs/schedule';
import { BullModule } from '@nestjs/bull';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { SchoolsModule } from './modules/schools/schools.module';
import { ClassesModule } from './modules/classes/classes.module';
import { QuestionsModule } from './modules/questions/questions.module';
import { GamesModule } from './modules/games/games.module';
import { StatisticsModule } from './modules/statistics/statistics.module';
import { AiModule } from './modules/ai/ai.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { LeaderboardModule } from './modules/leaderboard/leaderboard.module';
import { AchievementsModule } from './modules/achievements/achievements.module';
import { MissionsModule } from './modules/missions/missions.module';
import { StorageModule } from './modules/storage/storage.module';
import { AdminModule } from './modules/admin/admin.module';
import databaseConfig from './config/database.config';
import appConfig from './config/app.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      load: [databaseConfig, appConfig],
    }),

    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('database.host'),
        port: config.get('database.port'),
        username: config.get('database.username'),
        password: config.get('database.password'),
        database: config.get('database.name'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/database/migrations/*{.ts,.js}'],
        synchronize: config.get('app.env') === 'development',
        logging: config.get('app.env') === 'development',
        ssl: config.get('database.ssl') ? { rejectUnauthorized: false } : false,
        extra: {
          max: 20,
          idleTimeoutMillis: 30000,
          connectionTimeoutMillis: 2000,
        },
      }),
    }),

    CacheModule.registerAsync({
      isGlobal: true,
      inject: [ConfigService],
      useFactory: async (config: ConfigService) => ({
        store: await redisStore({
          socket: {
            host: config.get('app.redis.host'),
            port: config.get('app.redis.port'),
          },
          password: config.get('app.redis.password'),
          ttl: 300,
        }),
      }),
    }),

    BullModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        redis: {
          host: config.get('app.redis.host'),
          port: config.get('app.redis.port'),
          password: config.get('app.redis.password'),
        },
      }),
    }),

    ThrottlerModule.forRoot([
      { name: 'short', ttl: 1000, limit: 20 },
      { name: 'medium', ttl: 10000, limit: 100 },
      { name: 'long', ttl: 60000, limit: 500 },
    ]),

    ScheduleModule.forRoot(),

    HealthModule,
    AuthModule,
    UsersModule,
    SchoolsModule,
    ClassesModule,
    QuestionsModule,
    GamesModule,
    StatisticsModule,
    AiModule,
    NotificationsModule,
    LeaderboardModule,
    AchievementsModule,
    MissionsModule,
    StorageModule,
    AdminModule,
  ],
})
export class AppModule {}
