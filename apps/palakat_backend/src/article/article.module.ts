import { Module } from '@nestjs/common';
import { ArticleService } from './article.service';
import { ArticleController } from './article.controller';
import { ArticleAdminController } from './article-admin.controller';

@Module({
  controllers: [ArticleController, ArticleAdminController],
  providers: [ArticleService],
})
export class ArticleModule {}
