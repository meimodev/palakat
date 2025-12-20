import { Module } from '@nestjs/common';
import { SongPartController } from './song-part.controller';
import { SongPartAdminController } from './song-part-admin.controller';
import { SongPartService } from './song-part.service';

@Module({
  controllers: [SongPartController, SongPartAdminController],
  providers: [SongPartService],
})
export class SongPartModule {}
