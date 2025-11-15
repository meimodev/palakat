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
  UseGuards,
} from '@nestjs/common';
import { FileService } from './file.service';
import { Prisma } from '@prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { FileListQueryDto } from './dto/file-list.dto';

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

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.fileService.remove(id);
  }

  @Post()
  async create(@Body() createFileDto: Prisma.FileManagerCreateInput) {
    return this.fileService.create(createFileDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateFileDto: Prisma.FileManagerUpdateInput,
  ) {
    return this.fileService.update(id, updateFileDto);
  }
}
