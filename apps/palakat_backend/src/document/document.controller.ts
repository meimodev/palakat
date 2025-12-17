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
import { DocumentService } from './document.service';
import { Prisma } from '../generated/prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { DocumentListQueryDto } from './dto/document-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('document')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Get()
  async getDocuments(@Query() query: DocumentListQueryDto) {
    return this.documentService.getDocuments(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.documentService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.documentService.remove(id);
  }

  @Post()
  async create(@Body() createDocumentDto: Prisma.DocumentCreateInput) {
    return this.documentService.create(createDocumentDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDocumentDto: Prisma.DocumentUpdateInput,
  ) {
    return this.documentService.update(id, updateDocumentDto);
  }
}
