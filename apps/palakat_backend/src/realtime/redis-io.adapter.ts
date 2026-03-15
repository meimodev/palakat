import { INestApplication, Logger } from '@nestjs/common';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import { ServerOptions } from 'socket.io';
import { HealthRuntimeStateService } from '../health/health-runtime-state.service';

export class RedisIoAdapter extends IoAdapter {
  private readonly logger = new Logger(RedisIoAdapter.name);
  private adapterConstructor?: ReturnType<typeof createAdapter>;

  constructor(
    app: INestApplication,
    private readonly runtimeState: HealthRuntimeStateService,
  ) {
    super(app);
  }

  async connectToRedis(): Promise<void> {
    const redisUrl = process.env.REDIS_URL;
    const redisHost = process.env.REDIS_HOST;
    const redisPort = process.env.REDIS_PORT;

    if (!redisUrl && (!redisHost || !redisPort)) {
      this.logger.warn(
        'Redis is not configured; using in-memory socket.io adapter',
      );
      this.runtimeState.setRedisStatus({
        configured: false,
        connected: false,
        mode: 'memory',
      });
      return;
    }

    try {
      const pubClient = createClient(
        redisUrl
          ? { url: redisUrl }
          : { socket: { host: redisHost!, port: parseInt(redisPort!, 10) } },
      );
      const subClient = pubClient.duplicate();

      await pubClient.connect();
      await subClient.connect();

      this.adapterConstructor = createAdapter(pubClient, subClient);
      this.runtimeState.setRedisStatus({
        configured: true,
        connected: true,
        mode: 'redis',
      });
      this.logger.log('Redis adapter configured');
    } catch (error) {
      this.runtimeState.setRedisStatus({
        configured: true,
        connected: false,
        mode: 'redis',
        error: error instanceof Error ? error.message : 'Redis connection failed',
      });
      throw error;
    }
  }

  createIOServer(port: number, options?: ServerOptions) {
    const server = super.createIOServer(port, {
      ...options,
      cors: {
        origin: true,
        credentials: true,
      },
      allowEIO3: true,
      maxHttpBufferSize: 1024 * 1024,
    } as ServerOptions);

    if (this.adapterConstructor) {
      server.adapter(this.adapterConstructor);
    }

    return server;
  }
}
