import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { PrismaExceptionFilter } from './exception.filter';
import { PaginationInterceptor } from '../common/pagination/pagination.interceptor';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');

  const prismaExceptionFilter = app.get(PrismaExceptionFilter);

  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
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

  await app.listen(process.env.PORT || 3000);
}

bootstrap();
