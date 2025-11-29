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
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { CreateRevenueDto } from './dto/create-revenue.dto';
import { RevenueListQueryDto } from './dto/revenue-list.dto';
import { UpdateRevenueDto } from './dto/update-revenue.dto';
import { RevenueService } from './revenue.service';

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
  async create(@Body() createRevenueDto: CreateRevenueDto) {
    return this.revenueService.create(createRevenueDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateRevenueDto: UpdateRevenueDto,
  ) {
    return this.revenueService.update(id, updateRevenueDto);
  }
}
