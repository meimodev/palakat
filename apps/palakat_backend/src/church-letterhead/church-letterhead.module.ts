import { Module } from '@nestjs/common';
import { ChurchLetterheadService } from './church-letterhead.service';

@Module({
  providers: [ChurchLetterheadService],
})
export class ChurchLetterheadModule {}
