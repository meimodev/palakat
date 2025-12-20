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
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Prisma } from '../generated/prisma/client';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ChurchService } from './church.service';
import { ChurchListQueryDto } from './dto/church-list.dto';

@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('SUPER_ADMIN')
@Controller('admin/churches')
export class ChurchAdminController {
  constructor(private readonly churchService: ChurchService) {}

  @Get()
  async getChurches(@Query() query: ChurchListQueryDto) {
    return this.churchService.getChurches(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.churchService.findOne(id);
  }

  @Post()
  async create(@Body() dto: Prisma.ChurchCreateInput, @Req() _req: any) {
    return this.churchService.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: Prisma.ChurchUpdateInput,
    @Req() _req: any,
  ) {
    return this.churchService.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() _req: any) {
    return this.churchService.remove(id);
  }
}
