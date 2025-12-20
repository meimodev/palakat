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
import { SongPartService } from './song-part.service';
import { SongPartListQueryDto } from './dto/song-part-list.dto';

@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('SUPER_ADMIN')
@Controller('admin/song-parts-legacy')
export class SongPartController {
  constructor(private readonly songPartService: SongPartService) {}

  @Post()
  async create(@Body() dto: Prisma.SongPartCreateInput, @Req() req: any) {
    return this.songPartService.create(dto, req.user);
  }

  @Get()
  async findAll(@Query() query: SongPartListQueryDto, @Req() req: any) {
    return this.songPartService.findAll(query, req.user);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.songPartService.findOne(id, req.user);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSongPartDto: Prisma.SongPartUpdateInput,
    @Req() req: any,
  ) {
    return this.songPartService.update(id, updateSongPartDto, req.user);
  }

  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.songPartService.delete(id, req.user);
  }
}
