import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ChurchRequestService } from './church-request.service';
import { ChurchRequestListQueryDto } from './dto/church-request-list.dto';
import { ApproveChurchRequestDto } from './dto/approve-church-request.dto';
import { RejectChurchRequestDto } from './dto/reject-church-request.dto';

@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('SUPER_ADMIN')
@Controller('admin/church-requests')
export class ChurchRequestAdminController {
  constructor(private readonly churchRequestService: ChurchRequestService) {}

  @Get()
  async findAll(@Query() query: ChurchRequestListQueryDto) {
    return this.churchRequestService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.churchRequestService.findOne(id);
  }

  @Post(':id/approve')
  async approve(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ApproveChurchRequestDto,
    @Req() req: any,
  ) {
    return this.churchRequestService.approve(id, req.user.userId, dto);
  }

  @Post(':id/reject')
  async reject(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: RejectChurchRequestDto,
    @Req() req: any,
  ) {
    return this.churchRequestService.reject(id, req.user.userId, dto);
  }
}
