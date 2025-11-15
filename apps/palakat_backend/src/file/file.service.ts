import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from 'nestjs-prisma';
import { FileListQueryDto } from './dto/file-list.dto';

@Injectable()
export class FileService {
  constructor(private prisma: PrismaService) {}

  async getFiles(query: FileListQueryDto) {
    const { search, skip, take } = query;

    const where: Prisma.FileManagerWhereInput = {};
    if (search && search.length >= 3) {
      const keyword = search.toLowerCase();
      where.OR = [{ url: { contains: keyword, mode: 'insensitive' } }];
    }

    const [total, files] = await this.prisma.$transaction([
      this.prisma.fileManager.count({ where }),
      this.prisma.fileManager.findMany({
        where,
        take,
        skip,
        orderBy: { createdAt: 'desc' },
        include: {
          report: true,
          document: true,
        },
      }),
    ]);

    return {
      message: 'Files fetched successfully',
      data: files,
      total,
    };
  }

  async findOne(id: number) {
    const file = await this.prisma.fileManager.findUniqueOrThrow({
      where: { id },
      include: {
        report: true,
        document: true,
      },
    });
    return {
      message: 'File fetched successfully',
      data: file,
    };
  }

  async remove(id: number) {
    await this.prisma.fileManager.delete({
      where: { id },
    });
    return {
      message: 'File deleted successfully',
    };
  }

  async create(createFileDto: Prisma.FileManagerCreateInput) {
    const file = await this.prisma.fileManager.create({
      data: createFileDto,
    });
    return {
      message: 'File created successfully',
      data: file,
    };
  }

  async update(id: number, updateFileDto: Prisma.FileManagerUpdateInput) {
    const file = await this.prisma.fileManager.update({
      where: { id },
      data: updateFileDto,
      include: {
        report: true,
        document: true,
      },
    });
    return {
      message: 'File updated successfully',
      data: file,
    };
  }
}
