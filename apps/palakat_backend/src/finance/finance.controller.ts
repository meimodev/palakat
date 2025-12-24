import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { FinanceListQueryDto } from './dto/finance-list.dto';
import { FinanceService } from './finance.service';

@UseGuards(AuthGuard('jwt'))
@Controller('finance')
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  @Get()
  async findAll(@Query() query: FinanceListQueryDto, @Req() req: any) {
    return this.financeService.findAll(query, req.user);
  }

  @Get('overview')
  async overview(@Req() req: any) {
    return this.financeService.getOverview(req.user);
  }
}
