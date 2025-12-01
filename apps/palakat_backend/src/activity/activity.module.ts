import { Module } from '@nestjs/common';
import { ActivitiesService } from './activity.service';
import { ActivitiesController } from './activity.controller';
import { ApproverResolverService } from './approver-resolver.service';

@Module({
  controllers: [ActivitiesController],
  providers: [ActivitiesService, ApproverResolverService],
})
export class ActivitiesModule {}
