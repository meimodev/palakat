import { Module } from '@nestjs/common';
import { ChurchRequestController } from './church-request.controller';
import { ChurchRequestService } from './church-request.service';

@Module({
  controllers: [ChurchRequestController],
  providers: [ChurchRequestService],
})
export class ChurchRequestModule {}
