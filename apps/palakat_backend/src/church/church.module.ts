import { Module } from '@nestjs/common';
import { ChurchService } from './church.service';
import { HelperService } from '../../common/helper/helper.service';

@Module({
  providers: [ChurchService, HelperService],
})
export class ChurchModule {}
