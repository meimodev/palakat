import {
  BadRequestException,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ArticleService } from './article.service';
import { ArticleListQueryDto } from './dto/article-list.dto';

@Controller('articles')
export class ArticleController {
  constructor(private readonly articleService: ArticleService) {}

  @Get()
  async findAll(@Query() query: ArticleListQueryDto) {
    return this.articleService.findAllPublic(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.articleService.findOnePublic(id);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post(':id/like')
  async like(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req?.user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }
    return this.articleService.like(id, userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id/like')
  async unlike(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req?.user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }
    return this.articleService.unlike(id, userId);
  }
}
