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
import { Prisma } from '@prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { MembershipPositionService } from './membership-position.service';
import { MembershipPositionListQueryDto } from './dto/membership-position-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('membership-position')
export class MembershipPositionController {
  constructor(private readonly service: MembershipPositionService) {}

  @Get()
  async findAll(@Query() query: MembershipPositionListQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Post()
  async create(@Body() dto: Prisma.MembershipPositionCreateInput) {
    return this.service.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: Prisma.MembershipPositionUpdateInput,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.service.delete(id);
  }
}
