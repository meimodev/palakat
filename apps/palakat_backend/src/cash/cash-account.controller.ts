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
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import {
  CashAccountListQueryDto,
  CreateCashAccountDto,
  UpdateCashAccountDto,
} from './dto';
import { CashAccountService } from './cash-account.service';

@UseGuards(AuthGuard('jwt'))
@Controller('cash-account')
export class CashAccountController {
  constructor(private readonly cashAccountService: CashAccountService) {}

  @Get()
  async findAll(@Query() query: CashAccountListQueryDto, @Req() req: any) {
    return this.cashAccountService.findAll(query, req.user);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.cashAccountService.findOne(id, req.user);
  }

  @Post()
  async create(@Body() dto: CreateCashAccountDto, @Req() req: any) {
    return this.cashAccountService.create(dto, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCashAccountDto,
    @Req() req: any,
  ) {
    return this.cashAccountService.update(id, dto, req.user);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.cashAccountService.remove(id, req.user);
  }
}
