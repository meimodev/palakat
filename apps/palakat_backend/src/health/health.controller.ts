import { Controller, Get, Header, UseGuards } from '@nestjs/common';
import { HealthSecretGuard } from './health-secret.guard';
import { HealthService } from './health.service';

@Controller()
@UseGuards(HealthSecretGuard)
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get('health')
  @Header('Cache-Control', 'no-store')
  async getHealth() {
    return this.healthService.getSnapshot();
  }

  @Get('health.json')
  @Header('Cache-Control', 'no-store')
  async getHealthJson() {
    return this.healthService.getSnapshot();
  }
}
