import { Module } from '@nestjs/common';
import { SongPartController } from './song-part.controller';
import { SongPartService } from './song-part.service';

@Module({
  controllers: [SongPartController],
  providers: [SongPartService],
})
export class SongPartModule {}
