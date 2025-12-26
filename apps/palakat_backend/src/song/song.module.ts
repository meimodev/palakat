import { Module } from '@nestjs/common';
import { SongService } from './song.service';

@Module({
  providers: [SongService],
})
export class SongModule {}
