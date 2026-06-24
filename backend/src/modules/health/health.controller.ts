import { Controller, Get } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Controller('health')
export class HealthController {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
  ) {}

  @Get()
  async check() {
    const dbOk = await this.dataSource.query('SELECT 1')
      .then(() => true)
      .catch(() => false);

    return {
      status: dbOk ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      services: { database: dbOk ? 'ok' : 'error' },
      version: process.env.npm_package_version || '1.0.0',
    };
  }
}
