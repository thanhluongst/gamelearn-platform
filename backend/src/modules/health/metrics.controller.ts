import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';

// Simple Prometheus-compatible metrics without external library
@Controller('metrics')
export class MetricsController {
  private readonly startTime = Date.now();
  private requestCount = 0;

  @Get()
  getMetrics(@Res() res: Response) {
    const uptime = (Date.now() - this.startTime) / 1000;
    const memUsage = process.memoryUsage();

    const metrics = [
      '# HELP process_uptime_seconds Process uptime in seconds',
      '# TYPE process_uptime_seconds gauge',
      `process_uptime_seconds ${uptime}`,
      '',
      '# HELP nodejs_heap_size_used_bytes Heap memory used',
      '# TYPE nodejs_heap_size_used_bytes gauge',
      `nodejs_heap_size_used_bytes ${memUsage.heapUsed}`,
      '',
      '# HELP nodejs_heap_size_total_bytes Total heap memory',
      '# TYPE nodejs_heap_size_total_bytes gauge',
      `nodejs_heap_size_total_bytes ${memUsage.heapTotal}`,
      '',
      '# HELP nodejs_external_memory_bytes External memory',
      '# TYPE nodejs_external_memory_bytes gauge',
      `nodejs_external_memory_bytes ${memUsage.external}`,
    ].join('\n');

    res.set('Content-Type', 'text/plain; version=0.0.4');
    res.send(metrics);
  }
}
