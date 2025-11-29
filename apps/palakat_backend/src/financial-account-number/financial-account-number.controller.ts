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
