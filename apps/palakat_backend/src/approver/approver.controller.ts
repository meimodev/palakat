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
import { ApproverService } from './approver.service';
import { CreateApproverDto } from './dto/create-approver.dto';
import { UpdateApproverDto } from './dto/update-approver.dto';
import { ApproverListQueryDto } from './dto/approver-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('approver')
export class ApproverController {
  constructor(private readonly approverService: ApproverService) {}

  @Post()
  async create(@Body() createApproverDto: CreateApproverDto) {
    return this.approverService.create(createApproverDto);
  }

  @Get()
  async findAll(@Query() query: ApproverListQueryDto) {
    return this.approverService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.approverService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateApproverDto: UpdateApproverDto,
  ) {
    return this.approverService.update(id, updateApproverDto);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.approverService.remove(id);
  }
}
