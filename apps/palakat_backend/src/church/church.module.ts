import { Module } from '@nestjs/common';
import { ChurchService } from './church.service';
import { ChurchController } from './church.controller';
import { HelperService } from '../../common/helper/helper.service';

@Module({
  controllers: [ChurchController],
  providers: [ChurchService, HelperService],
})
export class ChurchModule {}
