import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { SongPartListQueryDto } from './dto/song-part-list.dto';

@Injectable()
export class SongPartService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: Prisma.SongPartCreateInput) {
    const SongPart = await this.prisma.songPart.create({
      data: dto,
    });

    return {
      message: 'OK',
      data: SongPart,
    };
  }

  async findAll(query: SongPartListQueryDto) {
    const { songId, skip, take } = query ?? ({} as any);

    const where: Prisma.SongPartWhereInput = {};
    if (songId) {
      where.songId = songId;
    }

    const [total, parts] = await this.prisma.$transaction([
      this.prisma.songPart.count({ where }),
      this.prisma.songPart.findMany({
        where,
        take,
        skip,
        orderBy: { id: 'desc' },
      }),
    ]);
    return {
      message: 'OK',
      data: parts,
      total,
    } as any;
  }

  async findOne(id: number) {
    const Songpart = await this.prisma.songPart.findUniqueOrThrow({
      where: { id },
    });
    return {
      message: 'OK',
      data: Songpart,
    };
  }

  async update(id: number, updateSongPartDto: Prisma.SongPartUpdateInput) {
    await this.prisma.songPart.update({
      where: { id },
      data: updateSongPartDto,
    });
    return {
      message: 'OK',
      data: updateSongPartDto,
    };
  }

  async delete(id: number) {
    await this.prisma.songPart.delete({
      where: { id },
    });
    return {
      message: 'OK',
    };
  }
}
