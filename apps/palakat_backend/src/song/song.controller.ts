import {
  Body,
  Post,
  Get,
  Query,
  Patch,
  Delete,
  Param,
  ParseIntPipe,
  Req,
} from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import { Controller, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { SongService } from './song.service';
import { SongListQueryDto } from './dto/song-list.dto';

@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('SUPER_ADMIN')
@Controller('admin/songs-legacy')
export class SongController {
  constructor(private readonly songService: SongService) {}

  @Post()
  async create(@Body() createSongDto: Prisma.SongCreateInput, @Req() req: any) {
    return this.songService.create(createSongDto, req.user);
  }

  @Get()
  async findAll(@Query() query: SongListQueryDto, @Req() req: any) {
    return this.songService.findAllAdmin(query, req.user);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.songService.findOneAdmin(id, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSongDto: Prisma.SongUpdateInput,
    @Req() req: any,
  ) {
    return this.songService.update(id, updateSongDto, req.user);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.songService.delete(id, req.user);
  }
}
