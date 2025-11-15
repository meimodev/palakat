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
import { Prisma } from '@prisma/client';
import { stripKeys, transformToSetFormat } from 'src/utils';
import { ApprovalRuleService } from './approval-rule.service';
import { ApprovalRuleListQueryDto } from './dto/approval-rule-list.dto';

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
  async create(@Body() createApprovalRule: Prisma.ApprovalRuleCreateInput) {
    const transformed = transformToSetFormat(
      createApprovalRule,
      ['positions'],
      'connect',
    );

    const cleaned = stripKeys(transformed, [
      'church',
      'createdAt',
      'updatedAt',
    ]);

    return this.approvalRuleService.create(cleaned);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateApprovalRule: Prisma.ApprovalRuleUpdateInput,
  ) {
    const transformed = transformToSetFormat(updateApprovalRule, ['positions']);

    const cleaned = stripKeys(transformed, [
      'church',
      'createdAt',
      'updatedAt',
    ]);

    return this.approvalRuleService.update(id, cleaned);
  }
}
