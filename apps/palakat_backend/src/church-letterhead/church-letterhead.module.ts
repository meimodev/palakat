import { Module } from '@nestjs/common';
import { ChurchLetterheadController } from './church-letterhead.controller';
import { ChurchLetterheadService } from './church-letterhead.service';

@Module({
  controllers: [ChurchLetterheadController],
  providers: [ChurchLetterheadService],
})
export class ChurchLetterheadModule {}
