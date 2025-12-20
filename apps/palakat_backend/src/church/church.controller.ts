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
import { ChurchService } from './church.service';
import { Prisma } from '../generated/prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { ChurchListQueryDto } from './dto/church-list.dto';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';

@UseGuards(AuthGuard('jwt'))
@Controller('church')
export class ChurchController {
  constructor(private readonly churchService: ChurchService) {}

  @Get()
  async getChurches(@Query() query: ChurchListQueryDto) {
    return this.churchService.getChurches(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.churchService.findOne(id);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.churchService.remove(id);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  async create(@Body() createchurchDto: Prisma.ChurchCreateInput) {
    return this.churchService.create(createchurchDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateChurchDto: Prisma.ChurchUpdateInput,
  ) {
    return this.churchService.update(id, updateChurchDto);
  }
}
