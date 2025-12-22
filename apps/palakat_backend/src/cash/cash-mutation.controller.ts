import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import {
  CashMutationListQueryDto,
  CreateCashMutationDto,
  TransferCashDto,
} from './dto';
import { CashMutationService } from './cash-mutation.service';

@UseGuards(AuthGuard('jwt'))
@Controller('cash-mutation')
export class CashMutationController {
  constructor(private readonly cashMutationService: CashMutationService) {}

  @Get()
  async findAll(@Query() query: CashMutationListQueryDto, @Req() req: any) {
    return this.cashMutationService.findAll(query, req.user);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.cashMutationService.findOne(id, req.user);
  }

  @Post()
  async create(@Body() dto: CreateCashMutationDto, @Req() req: any) {
    return this.cashMutationService.create(dto, req.user);
  }

  @Post('transfer')
  async transfer(@Body() dto: TransferCashDto, @Req() req: any) {
    return this.cashMutationService.transfer(dto, req.user);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.cashMutationService.remove(id, req.user);
  }
}
