import { Injectable } from '@nestjs/common';

@Injectable()
export class HealthRuntimeStateService {
  private readonly startedAt = new Date();
  private redisStatus: {
    configured: boolean;
    connected: boolean;
    mode: 'memory' | 'redis';
    updatedAt: string;
    error?: string;
  } = {
    configured: false,
    connected: false,
    mode: 'memory',
    updatedAt: new Date().toISOString(),
  };

  getStartedAt(): Date {
    return this.startedAt;
  }

  getRedisStatus() {
    return this.redisStatus;
  }

  setRedisStatus(status: {
    configured: boolean;
    connected: boolean;
    mode: 'memory' | 'redis';
    error?: string;
  }) {
    this.redisStatus = {
      ...status,
      updatedAt: new Date().toISOString(),
    };
  }
}
