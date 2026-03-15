import { Module } from '@nestjs/common';
import { ReportModule } from '../report/report.module';
import { RealtimeModule } from '../realtime/realtime.module';
import { HealthController } from './health.controller';
import { HealthLogBufferService } from './health-log-buffer.service';
import { HealthLoggerService } from './health-logger.service';
import { HealthRuntimeStateService } from './health-runtime-state.service';
import { HealthSecretGuard } from './health-secret.guard';
import { HealthService } from './health.service';

@Module({
  imports: [RealtimeModule, ReportModule],
  controllers: [HealthController],
  providers: [
    HealthService,
    HealthSecretGuard,
    HealthRuntimeStateService,
    HealthLogBufferService,
    HealthLoggerService,
  ],
  exports: [HealthRuntimeStateService, HealthLogBufferService, HealthLoggerService],
})
export class HealthModule {}
