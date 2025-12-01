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
import {
  CreateFinancialAccountNumberDto,
  FindAllFinancialAccountNumberDto,
  FindAvailableFinancialAccountNumberDto,
  UpdateFinancialAccountNumberDto,
} from './dto';
import { FinancialAccountNumberService } from './financial-account-number.service';

@UseGuards(AuthGuard('jwt'))
@Controller('financial-account-number')
export class FinancialAccountNumberController {
  constructor(
    private readonly financialAccountNumberService: FinancialAccountNumberService,
  ) {}

  @Get()
  async findAll(
    @Query() query: FindAllFinancialAccountNumberDto,
    @Query('churchId', ParseIntPipe) churchId: number,
  ) {
    return this.financialAccountNumberService.findAll(query, churchId);
  }

  /**
   * Get available financial accounts that are not linked to any approval rule.
   * Useful for populating dropdowns when creating/editing approval rules.
   *
   * @param churchId - The church ID to filter accounts
   * @param query - Query parameters including optional financeType and currentRuleId
   * @returns List of available financial accounts
   */
  @Get('available')
  async getAvailableAccounts(
    @Query('churchId', ParseIntPipe) churchId: number,
    @Query() query: FindAvailableFinancialAccountNumberDto,
  ) {
    return this.financialAccountNumberService.getAvailableAccounts(
      churchId,
      query,
    );
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.financialAccountNumberService.findOne(id);
  }

  @Post()
  async create(
    @Body() dto: CreateFinancialAccountNumberDto,
    @Query('churchId', ParseIntPipe) churchId: number,
  ) {
    return this.financialAccountNumberService.create(dto, churchId);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateFinancialAccountNumberDto,
  ) {
    return this.financialAccountNumberService.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.financialAccountNumberService.remove(id);
  }
}
