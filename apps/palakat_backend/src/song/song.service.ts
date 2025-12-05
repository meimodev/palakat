import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { SongListQueryDto } from './dto/song-list.dto';
import { Prisma } from '@prisma/client';
@Injectable()
export class SongService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createSongDto: Prisma.SongCreateInput) {
    await this.prisma.song.create({
      data: createSongDto,
    });
    return {
      message: 'OK',
      data: createSongDto,
    };
  }

  async findAll(query: SongListQueryDto) {
    const {
      search,
      skip,
      take,
      sortBy = 'id',
      sortOrder = 'desc',
    } = query ?? ({} as any);

    const where: Prisma.SongWhereInput = {};

    if (search) {
      where.OR = [
        {
          title: {
            contains: search,
            mode: 'insensitive',
          },
        },
        {
          parts: {
            some: {
              content: {
                contains: search,
                mode: 'insensitive',
              },
            },
          },
        },
      ];
    }

    const [total, songs] = await this.prisma.$transaction([
      this.prisma.song.count({ where }),
      this.prisma.song.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          parts: true,
        },
      }),
    ]);

    return {
      message: 'OK',
      data: songs,
      total,
    } as any;
  }

  async findOne(id: number) {
    const song = await this.prisma.song.findUniqueOrThrow({
      where: { id: id },
      include: {
        parts: true,
      },
    });

    return {
      message: 'OK',
      data: song,
    };
  }

  async update(id: number, updateSongDto: Prisma.SongUpdateInput) {
    await this.prisma.song.update({
      where: { id: id },
      data: updateSongDto,
    });
    return {
      message: 'OK',
      data: updateSongDto,
    };
  }

  async delete(id: number) {
    await this.prisma.song.delete({
      where: { id: id },
    });
    return {
      message: 'OK',
    };
  }
}
