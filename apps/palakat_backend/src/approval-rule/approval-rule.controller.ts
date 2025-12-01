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
import { AuthGuard } from '@nestjs/passport';
import { ApprovalRuleService } from './approval-rule.service';
import { ApprovalRuleListQueryDto } from './dto/approval-rule-list.dto';
import { CreateApprovalRuleDto } from './dto/create-approval-rule.dto';
import { UpdateApprovalRuleDto } from './dto/update-approval-rule.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('approval-rule')
export class ApprovalRuleController {
  constructor(private readonly approvalRuleService: ApprovalRuleService) {}

  @Get()
  async getApprovalRules(@Query() query: ApprovalRuleListQueryDto) {
    return this.approvalRuleService.getApprovalRules(query);
  }

  @Get(':id')
  async getApprovalRule(@Param('id', ParseIntPipe) id: number) {
    return this.approvalRuleService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.approvalRuleService.remove(id);
  }

  @Post()
  async create(@Body() createApprovalRuleDto: CreateApprovalRuleDto) {
    return this.approvalRuleService.create(createApprovalRuleDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateApprovalRuleDto: UpdateApprovalRuleDto,
  ) {
    return this.approvalRuleService.update(id, updateApprovalRuleDto);
  }
}
