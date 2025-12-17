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
import { ReportService } from './report.service';
import { Prisma } from '../generated/prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { ReportListQueryDto } from './dto/report-list.dto';
import { ReportGenerateDto } from './dto/report-generate.dto';

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

  @Post('generate')
  async generate(@Body() dto: ReportGenerateDto, @Req() req: any) {
    return this.reportService.generate(dto, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateReportDto: Prisma.ReportUpdateInput,
  ) {
    return this.reportService.update(id, updateReportDto);
  }
}
