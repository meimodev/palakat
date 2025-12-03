import { Controller, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport/dist/auth.guard';
import { ApproverService } from './approver.service';

@UseGuards(AuthGuard('jwt'))
@Controller('approver')
export class ApproverController {
  constructor(private readonly approverService: ApproverService) {}
}
