import { Module } from '@nestjs/common';
import { SongService } from './song.service';
import { SongAdminController } from './song-admin.controller';
import { SongPublicController } from './song-public.controller';

@Module({
  controllers: [SongPublicController, SongAdminController],
  providers: [SongService],
})
export class SongModule {}
