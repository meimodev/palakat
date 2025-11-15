import { Module } from '@nestjs/common';
import { ActivitiesService } from './activity.service';
import { ActivitiesController } from './activity.controller';

@Module({
  controllers: [ActivitiesController],
  providers: [ActivitiesService],
})
export class ActivitiesModule {}
