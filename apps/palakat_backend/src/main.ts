import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { PrismaExceptionFilter } from './exception.filter';
import { PaginationInterceptor } from '../common/pagination/pagination.interceptor';
import { RequestMethod, ValidationPipe } from '@nestjs/common';
import { RedisIoAdapter } from './realtime/redis-io.adapter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1', {
    exclude: [{ path: 'verify/(.*)', method: RequestMethod.GET }],
  });

  const prismaExceptionFilter = app.get(PrismaExceptionFilter);

  app.enableCors({
    origin: true,
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  });

  app.useGlobalFilters(prismaExceptionFilter);
  app.useGlobalInterceptors(new PaginationInterceptor());
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: false,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const wsAdapter = new RedisIoAdapter(app);
  await wsAdapter.connectToRedis();
  app.useWebSocketAdapter(wsAdapter);

  await app.listen(process.env.PORT || 3000, '0.0.0.0');
}

bootstrap();
