import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { FileListQueryDto } from './dto/file-list.dto';
import { FileFinalizeDto } from './dto/file-finalize.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';

@Injectable()
export class FileService {
  constructor(
    private prisma: PrismaService,
    private firebaseAdmin: FirebaseAdminService,
  ) {}

  async getFiles(query: FileListQueryDto) {
    const {
      search,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.FileManagerWhereInput = {};
    if (search && search.length >= 3) {
      (where as any).OR = [
        { path: { contains: search, mode: 'insensitive' } },
        { originalName: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [total, files] = await this.prisma.$transaction([
      this.prisma.fileManager.count({ where }),
      this.prisma.fileManager.findMany({
        where: where as any,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          report: true,
          document: true,
          activity: true,
          church: true,
        } as any,
      } as any),
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
        activity: true,
        church: true,
      } as any,
    });
    return {
      message: 'File fetched successfully',
      data: file,
    };
  }

  async finalize(dto: FileFinalizeDto, user?: any) {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { churchId: true },
    });

    if (!membership?.churchId || membership.churchId !== dto.churchId) {
      throw new BadRequestException('Invalid church context');
    }

    const effectiveBucket = dto.bucket ?? process.env.FIREBASE_STORAGE_BUCKET;
    if (!effectiveBucket) {
      throw new BadRequestException('Bucket is required');
    }

    const expectedPrefix = `churches/${dto.churchId}/`;
    if (!dto.path.startsWith(expectedPrefix)) {
      throw new BadRequestException('Invalid path');
    }

    const file = await this.prisma.fileManager.create({
      data: {
        provider: 'FIREBASE_STORAGE' as any,
        bucket: effectiveBucket,
        path: dto.path,
        sizeInKB: dto.sizeInKB,
        contentType: dto.contentType ?? null,
        originalName: dto.originalName ?? null,
        church: { connect: { id: dto.churchId } },
      },
      include: {
        church: true,
      } as any,
    } as any);

    return {
      message: 'File finalized',
      data: file,
    };
  }

  async resolveDownloadUrl(id: number, user?: any) {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { churchId: true },
    });

    if (!membership?.churchId) {
      throw new BadRequestException('User does not have a membership');
    }

    const file = await this.prisma.fileManager.findUnique({
      where: { id },
      select: { id: true, churchId: true, bucket: true, path: true } as any,
    });

    if (!file) {
      throw new NotFoundException('File not found');
    }

    if (file.churchId !== membership.churchId) {
      throw new BadRequestException('Invalid church context');
    }

    const bucket = this.firebaseAdmin.bucket(file.bucket);
    const object = bucket.file(file.path);
    const expiresInMinutes = 10;
    const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);
    const [url] = await object.getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: expiresAt,
    });

    return {
      message: 'OK',
      data: {
        url,
        expiresAt,
      },
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
}
