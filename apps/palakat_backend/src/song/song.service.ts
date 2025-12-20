import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { SongListQueryDto } from './dto/song-list.dto';
import { Prisma } from '../generated/prisma/client';
@Injectable()
export class SongService {
  constructor(private readonly prisma: PrismaService) {}

  private buildWhere(search?: string): Prisma.SongWhereInput {
    const where: Prisma.SongWhereInput = {};

    if (search && search.trim().length > 0) {
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

    return where;
  }

  async create(createSongDto: Prisma.SongCreateInput, _user?: any) {
    const created = await this.prisma.song.create({
      data: createSongDto,
      include: {
        parts: {
          orderBy: { index: 'asc' },
        },
      },
    });
    return {
      message: 'OK',
      data: created,
    };
  }

  async findAllPublic(query: SongListQueryDto) {
    const {
      search,
      skip,
      take,
      sortBy = 'id',
      sortOrder = 'desc',
    } = query ?? ({} as any);

    const where = this.buildWhere(search);

    const [total, songs] = await this.prisma.$transaction([
      this.prisma.song.count({ where }),
      this.prisma.song.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        select: {
          id: true,
          title: true,
          index: true,
          book: true,
          link: true,
        },
      }),
    ]);

    return {
      message: 'OK',
      data: songs,
      total,
    } as any;
  }

  async findAllAdmin(query: SongListQueryDto, _user?: any) {
    // For now keep admin list the same as public summary list
    return this.findAllPublic(query);
  }

  async findOnePublic(id: number) {
    const song = await this.prisma.song.findUniqueOrThrow({
      where: { id },
      include: {
        parts: {
          orderBy: { index: 'asc' },
        },
      },
    });

    return {
      message: 'OK',
      data: song,
    };
  }

  async findOneAdmin(id: number, _user?: any) {
    return this.findOnePublic(id);
  }

  async update(id: number, updateSongDto: Prisma.SongUpdateInput, _user?: any) {
    const updated = await this.prisma.song.update({
      where: { id: id },
      data: updateSongDto,
      include: {
        parts: {
          orderBy: { index: 'asc' },
        },
      },
    });
    return {
      message: 'OK',
      data: updated,
    };
  }

  async delete(id: number, _user?: any) {
    await this.prisma.song.delete({
      where: { id: id },
    });
    return {
      message: 'OK',
    };
  }
}
