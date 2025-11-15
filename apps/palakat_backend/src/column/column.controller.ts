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
import { ColumnService } from './column.service';
import { Prisma } from '@prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { ColumnListQueryDto } from './dto/column-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('column')
export class ColumnController {
  constructor(private readonly columnService: ColumnService) {}

  @Get()
  async getColumns(@Query() query: ColumnListQueryDto) {
    return this.columnService.getColumns(query);
  }

  @Get(':id')
  async getColumn(@Param('id', ParseIntPipe) id: number) {
    return this.columnService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.columnService.remove(id);
  }

  @Post()
  async create(@Body() createColumn: Prisma.ColumnCreateInput) {
    return this.columnService.create(createColumn);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateColumn: Prisma.ColumnUpdateInput,
  ) {
    return this.columnService.update(id, updateColumn);
  }
}
