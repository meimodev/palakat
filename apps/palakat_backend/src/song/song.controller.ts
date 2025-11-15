import {
  Body,
  Post,
  Get,
  Query,
  Patch,
  Delete,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Controller, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { SongService } from './song.service';
import { SongListQueryDto } from './dto/song-list.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('song')
export class SongController {
  constructor(private readonly songService: SongService) {}

  @Post()
  async create(@Body() createSongDto: Prisma.SongCreateInput) {
    return this.songService.create(createSongDto);
  }

  @Get()
  async findAll(@Query() query: SongListQueryDto) {
    return this.songService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.songService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSongDto: Prisma.SongUpdateInput,
  ) {
    return this.songService.update(id, updateSongDto);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.songService.delete(id);
  }
}
