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
import { ExpenseService } from './expense.service';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { Prisma } from '@prisma/client';
import { ExpenseListQueryDto } from './dto/expense-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('expense')
export class ExpenseController {
  constructor(private readonly expenseService: ExpenseService) {}

  @Get()
  async findAll(@Query() query: ExpenseListQueryDto) {
    return this.expenseService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.expenseService.findOne(id);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.expenseService.remove(id);
  }

  @Post()
  async create(@Body() createExpenseDto: Prisma.ExpenseCreateInput) {
    return this.expenseService.create(createExpenseDto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateExpenseDto: Prisma.ExpenseUpdateInput,
  ) {
    return this.expenseService.update(id, updateExpenseDto);
  }
}
