import { Injectable } from '@nestjs/common';
import * as os from 'os';
import { PrismaService } from '../prisma.service';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';
import { ReportQueueService } from '../report/report-queue.service';
import { HealthLogBufferService } from './health-log-buffer.service';
import { HealthRuntimeStateService } from './health-runtime-state.service';
import { HealthCheck, HealthSnapshot, HealthStatus } from './health.types';

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
    private readonly realtimeGateway: RealtimeGateway,
    private readonly reportQueue: ReportQueueService,
    private readonly logBuffer: HealthLogBufferService,
    private readonly runtimeState: HealthRuntimeStateService,
  ) {}

  async getSnapshot(): Promise<HealthSnapshot> {
    const recentLogs = this.logBuffer.getRecent(30);
    const runtime = this.buildRuntimeSnapshot();
    const [databaseCheck, queueState] = await Promise.all([
      this.buildDatabaseCheck(),
      this.reportQueue.getHealthSnapshot(),
    ]);
    const redisCheck = this.buildRedisCheck();
    const realtimeCheck = this.buildRealtimeCheck();
    const firebaseCheck = this.buildFirebaseCheck();
    const httpCheck = this.buildHttpCheck();
    const queueCheck = this.buildQueueCheck(queueState);
    const checks = [
      httpCheck,
      databaseCheck,
      redisCheck,
      realtimeCheck,
      firebaseCheck,
      queueCheck,
    ];
    const overallStatus = this.computeOverallStatus(checks);
    const summary = this.buildSummary(overallStatus, checks);
    const activeSockets = this.resolveActiveSockets();
    const recentErrors = recentLogs.filter(
      (entry) => entry.level === 'error',
    ).length;

    return {
      generatedAt: new Date().toISOString(),
      overallStatus,
      summary,
      runtime,
      highlights: [
        {
          label: 'Database latency',
          value:
            typeof databaseCheck.latencyMs === 'number'
              ? `${databaseCheck.latencyMs} ms`
              : 'Unavailable',
          tone: databaseCheck.status,
        },
        {
          label: 'Active sockets',
          value: String(activeSockets),
          tone: realtimeCheck.status,
        },
        {
          label: 'Queue depth',
          value: String(queueState.pending + queueState.processing),
          tone: queueCheck.status,
        },
        {
          label: 'RSS memory',
          value: `${runtime.rssMb} MB`,
          tone: runtime.rssMb > 700 ? 'degraded' : 'neutral',
        },
        {
          label: 'Recent errors',
          value: String(recentErrors),
          tone: recentErrors > 0 ? 'degraded' : 'healthy',
        },
      ],
      endpoints: [
        {
          label: 'HTTP',
          value: `${this.resolvePublicBaseUrl()}/health`,
          tone: httpCheck.status,
        },
        {
          label: 'WebSocket',
          value: `${this.resolvePublicBaseUrl().replace(/^http/i, 'ws')}/ws`,
          tone: realtimeCheck.status,
        },
        {
          label: 'PostgreSQL',
          value: this.resolvePostgresTarget(),
          tone: databaseCheck.status,
        },
        {
          label: 'Redis',
          value: this.resolveRedisTarget(),
          tone: redisCheck.status,
        },
        {
          label: 'Storage bucket',
          value: process.env.FIREBASE_STORAGE_BUCKET || 'Not configured',
          tone: firebaseCheck.status,
        },
      ],
      checks,
      recentLogs,
    };
  }

  private buildRuntimeSnapshot() {
    const memory = process.memoryUsage();

    return {
      environment: process.env.NODE_ENV || 'development',
      hostname: os.hostname(),
      platform: `${process.platform}/${process.arch}`,
      nodeVersion: process.version,
      pid: process.pid,
      startedAt: this.runtimeState.getStartedAt().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
      rssMb: this.toMb(memory.rss),
      heapUsedMb: this.toMb(memory.heapUsed),
      heapTotalMb: this.toMb(memory.heapTotal),
      externalMb: this.toMb(memory.external),
      arrayBuffersMb: this.toMb(memory.arrayBuffers),
      loadAverage: os.loadavg().map((value) => Number(value.toFixed(2))) as [
        number,
        number,
        number,
      ],
    };
  }

  private buildHttpCheck(): HealthCheck {
    const port = String(process.env.PORT || '3000');

    return {
      key: 'http',
      label: 'HTTP listener',
      status: 'healthy',
      summary: `Health page served on port ${port}.`,
      critical: true,
      details: [
        { label: 'Port', value: port },
        { label: 'Base URL', value: this.resolvePublicBaseUrl() },
        { label: 'Health path', value: '/health' },
      ],
    };
  }

  private async buildDatabaseCheck(): Promise<HealthCheck> {
    const startedAt = Date.now();

    try {
      await this.prisma.$queryRawUnsafe('SELECT 1');
      const latencyMs = Date.now() - startedAt;

      return {
        key: 'database',
        label: 'PostgreSQL',
        status: latencyMs > 500 ? 'degraded' : 'healthy',
        summary:
          latencyMs > 500
            ? `Database reachable but slow at ${latencyMs} ms.`
            : `Database reachable in ${latencyMs} ms.`,
        critical: true,
        latencyMs,
        details: [
          { label: 'Target', value: this.resolvePostgresTarget() },
          { label: 'Connection', value: 'Prisma adapter reachable' },
        ],
      };
    } catch (error) {
      return {
        key: 'database',
        label: 'PostgreSQL',
        status: 'down',
        summary: this.resolveErrorSummary(error, 'Database query failed.'),
        critical: true,
        details: [
          { label: 'Target', value: this.resolvePostgresTarget() },
          { label: 'Connection', value: 'Prisma query failed' },
        ],
      };
    }
  }

  private buildRedisCheck(): HealthCheck {
    const redisStatus = this.runtimeState.getRedisStatus();
    const status: HealthStatus = !redisStatus.configured
      ? 'degraded'
      : redisStatus.connected
        ? 'healthy'
        : 'down';
    const summary = !redisStatus.configured
      ? 'Redis not configured; realtime is using the in-memory adapter.'
      : redisStatus.connected
        ? 'Redis adapter connected for distributed realtime.'
        : redisStatus.error || 'Redis adapter is configured but not connected.';

    return {
      key: 'redis',
      label: 'Redis adapter',
      status,
      summary,
      critical: true,
      details: [
        { label: 'Mode', value: redisStatus.mode },
        { label: 'Target', value: this.resolveRedisTarget() },
        {
          label: 'Updated',
          value: this.formatTimestamp(redisStatus.updatedAt),
        },
      ],
    };
  }

  private buildRealtimeCheck(): HealthCheck {
    const serverReady = Boolean(this.realtimeGateway.server);
    const activeSockets = this.resolveActiveSockets();

    return {
      key: 'realtime',
      label: 'WebSocket gateway',
      status: serverReady ? 'healthy' : 'down',
      summary: serverReady
        ? `Socket server ready with ${activeSockets} active connection${activeSockets === 1 ? '' : 's'}.`
        : 'Socket server is not ready.',
      critical: true,
      details: [
        { label: 'Path', value: '/ws' },
        { label: 'Server ready', value: serverReady ? 'Yes' : 'No' },
        { label: 'Active sockets', value: String(activeSockets) },
      ],
    };
  }

  private buildFirebaseCheck(): HealthCheck {
    const configured = this.firebaseAdmin.isConfigured();
    const bucket = process.env.FIREBASE_STORAGE_BUCKET;
    const hasBucket = typeof bucket === 'string' && bucket.trim().length > 0;
    const status: HealthStatus =
      configured && hasBucket ? 'healthy' : 'degraded';

    return {
      key: 'firebase',
      label: 'Firebase storage',
      status,
      summary:
        configured && hasBucket
          ? 'Firebase Admin and storage bucket are configured.'
          : 'Firebase Admin or storage bucket is not fully configured.',
      critical: false,
      details: [
        {
          label: 'Admin SDK',
          value: configured ? 'Configured' : 'Not configured',
        },
        { label: 'Bucket', value: bucket || 'Not configured' },
        {
          label: 'Project',
          value: process.env.FIREBASE_PROJECT_ID || 'Not configured',
        },
      ],
    };
  }

  private buildQueueCheck(
    queueState: Awaited<ReturnType<ReportQueueService['getHealthSnapshot']>>,
  ): HealthCheck {
    const pendingLoad = queueState.pending + queueState.processing;
    const status: HealthStatus =
      queueState.failed > 0
        ? 'degraded'
        : pendingLoad > 25
          ? 'degraded'
          : 'healthy';
    const oldestPending = queueState.oldestPendingAt
      ? this.formatTimestamp(queueState.oldestPendingAt)
      : 'None';

    return {
      key: 'queue',
      label: 'Report queue',
      status,
      summary:
        queueState.failed > 0
          ? `${queueState.failed} failed job${queueState.failed === 1 ? '' : 's'} need attention.`
          : pendingLoad > 25
            ? `Queue depth is elevated at ${pendingLoad} jobs.`
            : 'Report queue is within normal range.',
      critical: false,
      details: [
        { label: 'Pending', value: String(queueState.pending) },
        { label: 'Processing', value: String(queueState.processing) },
        { label: 'Failed', value: String(queueState.failed) },
        {
          label: 'Worker active',
          value: queueState.isProcessing ? 'Yes' : 'No',
        },
        {
          label: 'Last attempt',
          value: queueState.lastAttemptedAt
            ? this.formatTimestamp(queueState.lastAttemptedAt)
            : 'None',
        },
        {
          label: 'Last completed',
          value: queueState.lastCompletedAt
            ? this.formatTimestamp(queueState.lastCompletedAt)
            : 'None',
        },
        { label: 'Oldest pending', value: oldestPending },
      ],
    };
  }

  private buildSummary(
    overallStatus: HealthStatus,
    checks: HealthCheck[],
  ): string {
    const unhealthy = checks.filter((check) => check.status !== 'healthy');
    if (overallStatus === 'healthy') {
      return 'All critical services are responding normally, and the backend is operating within expected bounds.';
    }

    if (overallStatus === 'down') {
      return `At least one critical dependency is down: ${unhealthy.map((check) => check.label).join(', ')}.`;
    }

    return `The backend is serving traffic, but ${unhealthy.map((check) => check.label).join(', ')} require attention.`;
  }

  private computeOverallStatus(checks: HealthCheck[]): HealthStatus {
    if (checks.some((check) => check.critical && check.status === 'down')) {
      return 'down';
    }

    if (checks.some((check) => check.status !== 'healthy')) {
      return 'degraded';
    }

    return 'healthy';
  }

  private resolveActiveSockets(): number {
    const server = this.realtimeGateway.server;
    if (!server) {
      return 0;
    }

    const engineCount = (server.engine as any)?.clientsCount;
    if (typeof engineCount === 'number') {
      return engineCount;
    }

    const socketMap = (server.sockets as any)?.sockets;
    if (socketMap?.size && typeof socketMap.size === 'number') {
      return socketMap.size;
    }

    return 0;
  }

  private resolvePublicBaseUrl(): string {
    const base = process.env.PUBLIC_BASE_URL;
    if (base && base.trim().length > 0) {
      return base.trim().replace(/\/$/, '');
    }

    return `http://localhost:${process.env.PORT || '3000'}`;
  }

  private resolvePostgresTarget(): string {
    if (process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('${')) {
      return this.sanitizeUrlTarget(process.env.DATABASE_URL);
    }

    const host = process.env.POSTGRES_HOST || 'localhost';
    const port = process.env.POSTGRES_PORT || '5432';
    const database = process.env.POSTGRES_DB || 'database';
    return `${host}:${port}/${database}`;
  }

  private resolveRedisTarget(): string {
    if (process.env.REDIS_URL) {
      return this.sanitizeUrlTarget(process.env.REDIS_URL);
    }

    if (process.env.REDIS_HOST || process.env.REDIS_PORT) {
      return `${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || '6379'}`;
    }

    return 'Not configured';
  }

  private sanitizeUrlTarget(value: string): string {
    try {
      const url = new URL(value);
      const pathname = url.pathname && url.pathname !== '/' ? url.pathname : '';
      return `${url.hostname}${url.port ? `:${url.port}` : ''}${pathname}`;
    } catch (_) {
      return value.replace(/:\/\/.*@/, '://');
    }
  }

  private resolveErrorSummary(error: unknown, fallback: string): string {
    if (error instanceof Error && error.message) {
      return error.message;
    }

    return fallback;
  }

  private formatTimestamp(value: string): string {
    return new Date(value).toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false,
    });
  }

  private toMb(value: number): number {
    return Number((value / 1024 / 1024).toFixed(1));
  }
}
