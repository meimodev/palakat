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
import { AuthGuard } from '@nestjs/passport';
import { MembershipPositionService } from './membership-position.service';
import { MembershipPositionListQueryDto } from './dto/membership-position-list.dto';
import {
  CreateMembershipPositionDto,
  UpdateMembershipPositionDto,
} from './dto/membership-position-write.dto';

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
  async create(@Body() dto: CreateMembershipPositionDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateMembershipPositionDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.service.delete(id);
  }
}
