import {
  Controller,
  Get,
  ParseIntPipe,
  Query,
  UseGuards,
  Param,
  Delete,
  Post,
  Body,
  Patch,
} from '@nestjs/common';
import { ActivitiesService } from './activity.service';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { Prisma } from '@prisma/client';
import { ActivityListQueryDto } from './dto/activity-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('activity')
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Get()
  async findAll(@Query() query: ActivityListQueryDto) {
    return this.activitiesService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.activitiesService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.activitiesService.remove(id);
  }

  @Post()
  async create(@Body() createActivityDto: Prisma.ActivityCreateInput) {
    return this.activitiesService.create(createActivityDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateActivityDto: Prisma.ActivityUpdateInput,
  ) {
    return this.activitiesService.update(id, updateActivityDto);
  }
}
