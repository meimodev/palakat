import { Module } from '@nestjs/common';
import { ChurchService } from './church.service';
import { ChurchController } from './church.controller';
import { HelperService } from '../../common/helper/helper.service';
import { ChurchAdminController } from './church-admin.controller';

@Module({
  controllers: [ChurchController, ChurchAdminController],
  providers: [ChurchService, HelperService],
})
export class ChurchModule {}
