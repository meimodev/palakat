import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import { FileService } from './file.service';
import { AuthGuard } from '@nestjs/passport';
import { FileListQueryDto } from './dto/file-list.dto';
import { FileFinalizeDto } from './dto/file-finalize.dto';
import { Request, Response } from 'express';

@UseGuards(AuthGuard('jwt'))
@Controller('file-manager')
export class FileController {
  constructor(private readonly fileService: FileService) {}

  @Get()
  async getFiles(@Query() query: FileListQueryDto) {
    return this.fileService.getFiles(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.fileService.findOne(id);
  }

  @Post('finalize')
  async finalize(@Body() dto: FileFinalizeDto, @Req() req: Request) {
    return this.fileService.finalize(dto, (req as any).user);
  }

  @Get(':id/resolve-download-url')
  async resolveDownloadUrl(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: Request,
  ) {
    return this.fileService.resolveDownloadUrl(id, (req as any).user);
  }

  @Get(':id/proxy')
  async proxyFile(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: Request,
    @Res() res: Response,
  ) {
    return this.fileService.proxyFile(id, (req as any).user, res);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.fileService.remove(id);
  }
}
