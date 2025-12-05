import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { DocumentListQueryDto } from './dto/document-list.dto';

@Injectable()
export class DocumentService {
  constructor(private prisma: PrismaService) {}

  async getDocuments(query: DocumentListQueryDto) {
    const {
      search,
      churchId,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.DocumentWhereInput = {};

    if (search && search.length >= 3) {
      const keyword = search.toLowerCase();
      where.OR = [
        { accountNumber: { contains: keyword, mode: 'insensitive' } },
      ];
    }

    if (churchId) {
      where.churchId = churchId;
    }

    const [total, documents] = await this.prisma.$transaction([
      this.prisma.document.count({ where }),
      this.prisma.document.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          church: true,
          file: true,
        },
      }),
    ]);

    return {
      message: 'Documents fetched successfully',
      data: documents,
      total,
    };
  }

  async findOne(id: number) {
    const document = await this.prisma.document.findUniqueOrThrow({
      where: { id },
      include: {
        church: true,
        file: true,
      },
    });
    return {
      message: 'Document fetched successfully',
      data: document,
    };
  }

  async remove(id: number) {
    await this.prisma.document.delete({
      where: { id },
    });
    return {
      message: 'Document deleted successfully',
    };
  }

  async create(createDocumentDto: Prisma.DocumentCreateInput) {
    const document = await this.prisma.document.create({
      data: createDocumentDto,
    });
    return {
      message: 'Document created successfully',
      data: document,
    };
  }

  async update(id: number, updateDocumentDto: Prisma.DocumentUpdateInput) {
    const document = await this.prisma.document.update({
      where: { id },
      data: updateDocumentDto,
      include: {
        church: true,
        file: true,
      },
    });
    return {
      message: 'Document updated successfully',
      data: document,
    };
  }
}
