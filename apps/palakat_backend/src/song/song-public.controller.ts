import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { SongService } from './song.service';
import { SongListQueryDto } from './dto/song-list.dto';

@Controller('public/songs')
export class SongPublicController {
  constructor(private readonly songService: SongService) {}

  @Get()
  async findAll(@Query() query: SongListQueryDto) {
    return this.songService.findAllPublic(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.songService.findOnePublic(id);
  }
}
