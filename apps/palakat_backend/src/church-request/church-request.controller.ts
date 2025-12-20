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
  Request,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ChurchRequestService } from './church-request.service';
import { ChurchRequestListQueryDto } from './dto/church-request-list.dto';
import { CreateChurchRequestDto } from './dto/create-church-request.dto';
import { UpdateChurchRequestDto } from './dto/update-church-request.dto';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';

@UseGuards(AuthGuard('jwt'))
@Controller('church-request')
export class ChurchRequestController {
  constructor(private readonly churchRequestService: ChurchRequestService) {}

  @Post()
  create(@Request() req, @Body() createDto: CreateChurchRequestDto) {
    const requesterId = req.user.userId;
    return this.churchRequestService.createOrResubmit(requesterId, createDto);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  findAll(@Query() query: ChurchRequestListQueryDto) {
    return this.churchRequestService.findAll(query);
  }

  @Get('my-request')
  findMyRequest(@Request() req) {
    const requesterId = req.user.userId;
    return this.churchRequestService.findByRequester(requesterId);
  }

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.churchRequestService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateChurchRequestDto,
  ) {
    return this.churchRequestService.update(id, updateDto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('SUPER_ADMIN')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.churchRequestService.remove(id);
  }
}
