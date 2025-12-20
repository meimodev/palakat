import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FileInterceptor } from '@nestjs/platform-express';
import { ArticleService } from './article.service';
import { AdminArticleListQueryDto } from './dto/admin-article-list.dto';
import { CreateArticleDto } from './dto/create-article.dto';
import { UpdateArticleDto } from './dto/update-article.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('admin/articles')
export class ArticleAdminController {
  constructor(private readonly articleService: ArticleService) {}

  @Get()
  async findAll(@Query() query: AdminArticleListQueryDto, @Req() req: any) {
    return this.articleService.findAllAdmin(query, req.user);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.articleService.findOneAdmin(id, req.user);
  }

  @Post()
  async create(@Body() dto: CreateArticleDto, @Req() req: any) {
    return this.articleService.create(dto, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateArticleDto,
    @Req() req: any,
  ) {
    return this.articleService.update(id, dto, req.user);
  }

  @Post(':id/publish')
  async publish(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.articleService.publish(id, req.user);
  }

  @Post(':id/unpublish')
  async unpublish(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.articleService.unpublish(id, req.user);
  }

  @Post(':id/cover')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadCover(
    @Param('id', ParseIntPipe) id: number,
    @UploadedFile() file: any,
    @Req() req: any,
  ) {
    return this.articleService.uploadCover(id, file, req.user);
  }

  @Delete(':id')
  async archive(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.articleService.archive(id, req.user);
  }
}
