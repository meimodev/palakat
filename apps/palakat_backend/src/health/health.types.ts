export type HealthStatus = 'healthy' | 'degraded' | 'down';

export type HealthLogLevel = 'log' | 'warn' | 'error' | 'debug' | 'verbose';

export interface HealthDetail {
  label: string;
  value: string;
}

export interface HealthCheck {
  key: string;
  label: string;
  status: HealthStatus;
  summary: string;
  critical: boolean;
  latencyMs?: number;
  details: HealthDetail[];
}

export interface HealthMetric {
  label: string;
  value: string;
  tone?: HealthStatus | 'neutral';
}

export interface HealthLogEntry {
  timestamp: string;
  level: HealthLogLevel;
  context?: string;
  message: string;
  trace?: string;
}

export interface HealthRuntimeSnapshot {
  environment: string;
  hostname: string;
  platform: string;
  nodeVersion: string;
  pid: number;
  startedAt: string;
  uptimeSeconds: number;
  rssMb: number;
  heapUsedMb: number;
  heapTotalMb: number;
  externalMb: number;
  arrayBuffersMb: number;
  loadAverage: [number, number, number];
}

export interface HealthSnapshot {
  generatedAt: string;
  overallStatus: HealthStatus;
  summary: string;
  runtime: HealthRuntimeSnapshot;
  highlights: HealthMetric[];
  endpoints: HealthMetric[];
  checks: HealthCheck[];
  recentLogs: HealthLogEntry[];
}
