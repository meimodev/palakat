import {
  Body,
  Post,
  Get,
  Query,
  Patch,
  Delete,
  Param,
  ParseIntPipe,
  Controller,
  UseGuards,
} from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { LocationService } from './location.service';
import { LocationListQueryDto } from './dto/location-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('location')
export class LocationController {
  constructor(private readonly locationService: LocationService) {}

  @Post()
  async create(@Body() dto: Prisma.LocationCreateInput) {
    return this.locationService.create(dto);
  }

  @Get()
  async findAll(@Query() query: LocationListQueryDto) {
    return this.locationService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.locationService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: Prisma.LocationUpdateInput,
  ) {
    return this.locationService.update(id, dto);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.locationService.delete(id);
  }
}
