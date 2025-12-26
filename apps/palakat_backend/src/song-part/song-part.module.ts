import { Module } from '@nestjs/common';
import { SongPartService } from './song-part.service';

@Module({
  providers: [SongPartService],
})
export class SongPartModule {}
