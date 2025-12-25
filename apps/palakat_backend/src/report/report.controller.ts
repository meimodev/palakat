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
import { ReportQueueService } from './report-queue.service';
import { Prisma } from '../generated/prisma/client';
import { AuthGuard } from '@nestjs/passport';
import { ReportListQueryDto } from './dto/report-list.dto';
import { ReportGenerateDto } from './dto/report-generate.dto';
import { ReportJobListQueryDto } from './dto/report-job-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('report')
export class ReportController {
  constructor(
    private readonly reportService: ReportService,
    private readonly reportQueueService: ReportQueueService,
  ) {}

  @Get()
  async getReports(@Query() query: ReportListQueryDto, @Req() req: any) {
    return this.reportService.getReports(query, req.user);
  }

  @Get('jobs')
  async getMyJobs(@Query() query: ReportJobListQueryDto, @Req() req: any) {
    return this.reportQueueService.getMyJobs(query, req.user);
  }

  @Get('jobs/:id')
  async getJobStatus(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.reportQueueService.getJobStatus(id, req.user);
  }

  @Delete('jobs/:id')
  async cancelJob(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.reportQueueService.cancelJob(id, req.user);
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
    return this.reportQueueService.createJob(dto, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateReportDto: Prisma.ReportUpdateInput,
  ) {
    return this.reportService.update(id, updateReportDto);
  }
}
