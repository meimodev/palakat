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
import { ReportService } from './report.service';
import { Prisma } from '@prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { ReportListQueryDto } from './dto/report-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('report')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  @Get()
  async getReports(@Query() query: ReportListQueryDto) {
    return this.reportService.getReports(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.reportService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.reportService.remove(id);
  }

  @Post()
  async create(@Body() createReportDto: Prisma.ReportCreateInput) {
    return this.reportService.create(createReportDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateReportDto: Prisma.ReportUpdateInput,
  ) {
    return this.reportService.update(id, updateReportDto);
  }
}
