import { Module } from '@nestjs/common';
import { ColumnService } from './column.service';

@Module({
  providers: [ColumnService],
})
export class ColumnModule {}
