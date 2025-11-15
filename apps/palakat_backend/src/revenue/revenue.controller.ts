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
import { RevenueService } from './revenue.service';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { Prisma } from '@prisma/client';
import { RevenueListQueryDto } from './dto/revenue-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('revenue')
export class RevenueController {
  constructor(private readonly revenueService: RevenueService) {}

  @Get()
  async findAll(@Query() query: RevenueListQueryDto) {
    return this.revenueService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.revenueService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.revenueService.remove(id);
  }

  @Post()
  async create(@Body() createRevenueDto: Prisma.RevenueCreateInput) {
    return this.revenueService.create(createRevenueDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateRevenueDto: Prisma.RevenueUpdateInput,
  ) {
    return this.revenueService.update(id, updateRevenueDto);
  }
}
