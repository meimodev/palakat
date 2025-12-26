import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { UpdateChurchLetterheadDto } from './dto/update-church-letterhead.dto';

@Injectable()
export class ChurchLetterheadService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { churchId: true },
    });

    if (!membership?.churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return membership.churchId;
  }

  async getMe(user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const letterhead = await this.prisma.churchLetterhead.findUnique({
      where: { churchId },
      include: { logoFile: true },
    });

    return {
      message: 'OK',
      data: letterhead,
    };
  }

  async setLogoFile(logoFileId: number, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    if (typeof logoFileId !== 'number') {
      throw new BadRequestException('logoFileId is required');
    }

    const file = await (this.prisma as any).fileManager.findUnique({
      where: { id: logoFileId },
      select: { id: true, churchId: true, contentType: true } as any,
    });

    if (!file) {
      throw new BadRequestException('File not found');
    }

    if (file.churchId !== churchId) {
      throw new BadRequestException('Invalid church context');
    }

    if (!file.contentType || !file.contentType.startsWith('image/')) {
      throw new BadRequestException('Only image uploads are supported');
    }

    const letterhead = await this.prisma.churchLetterhead.upsert({
      where: { churchId },
      create: {
        church: { connect: { id: churchId } },
        logoFile: { connect: { id: logoFileId } },
      } as any,
      update: {
        logoFile: { connect: { id: logoFileId } },
      } as any,
      include: { logoFile: true },
    });

    return {
      message: 'OK',
      data: letterhead,
    };
  }

  async updateMe(dto: UpdateChurchLetterheadDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const data = {
      ...(dto.title !== undefined ? { title: dto.title } : {}),
      ...(dto.line1 !== undefined ? { line1: dto.line1 } : {}),
      ...(dto.line2 !== undefined ? { line2: dto.line2 } : {}),
      ...(dto.line3 !== undefined ? { line3: dto.line3 } : {}),
    };

    const letterhead = await this.prisma.churchLetterhead.upsert({
      where: { churchId },
      create: {
        church: { connect: { id: churchId } },
        ...(data as any),
      } as any,
      update: data as any,
      include: { logoFile: true },
    });

    return {
      message: 'OK',
      data: letterhead,
    };
  }

  async uploadLogo(
    file: {
      buffer?: Buffer;
      mimetype?: string;
      originalname?: string;
      size?: number;
    },
    user?: any,
  ) {
    const churchId = await this.resolveRequesterChurchId(user);

    if (!file?.buffer?.length) {
      throw new BadRequestException('file is required');
    }

    if (!file.mimetype?.startsWith('image/')) {
      throw new BadRequestException('Only image uploads are supported');
    }

    const maxBytes = 5 * 1024 * 1024;
    if ((file.size ?? 0) > maxBytes) {
      throw new BadRequestException('File is too large (max 5MB)');
    }

    // Get existing letterhead to check for existing logo
    const existingLetterhead = await this.prisma.churchLetterhead.findUnique({
      where: { churchId },
      include: { logoFile: true },
    });

    const existingLogoFile = existingLetterhead?.logoFile;
    const bucket = this.firebaseAdmin.bucket();

    // Determine file extension
    const original = file.originalname ?? '';
    const extFromName = original.includes('.')
      ? original.split('.').pop()?.toLowerCase()
      : undefined;
    const extFromMime =
      file.mimetype === 'image/jpeg'
        ? 'jpg'
        : file.mimetype === 'image/png'
          ? 'png'
          : file.mimetype === 'image/webp'
            ? 'webp'
            : undefined;
    const ext = extFromName || extFromMime || 'png';

    let path: string;
    let fileManagerId: number;

    if (existingLogoFile?.path) {
      // Replace existing file in storage
      path = existingLogoFile.path;
      fileManagerId = existingLogoFile.id;

      // Delete old file from storage (ignore errors if file doesn't exist)
      try {
        await bucket.file(path).delete();
      } catch {
        // File might not exist, continue
      }

      // Upload new file to same path
      await bucket.file(path).save(file.buffer, {
        resumable: false,
        contentType: file.mimetype,
        metadata: {
          metadata: {
            churchId: String(churchId),
            purpose: 'CHURCH_LETTERHEAD_LOGO',
          },
        },
      });

      const sizeInKB = Number((file.buffer.length / 1024).toFixed(2));

      // Update existing file manager record
      await (this.prisma as any).fileManager.update({
        where: { id: fileManagerId },
        data: {
          sizeInKB,
          contentType: file.mimetype,
          originalName: file.originalname ?? path.split('/').pop(),
          updatedAt: new Date(),
        },
      });
    } else {
      // Create new file
      const now = new Date();
      const stamp = now.toISOString().replace(/[-:]/g, '').replace(/\..+$/, '');
      const objectName = `letterhead_logo_${stamp}.${ext}`;
      path = `churches/${churchId}/letterhead/${objectName}`;

      await bucket.file(path).save(file.buffer, {
        resumable: false,
        contentType: file.mimetype,
        metadata: {
          metadata: {
            churchId: String(churchId),
            purpose: 'CHURCH_LETTERHEAD_LOGO',
          },
        },
      });

      const sizeInKB = Number((file.buffer.length / 1024).toFixed(2));

      const createdFile = await (this.prisma as any).fileManager.create({
        data: {
          provider: 'FIREBASE_STORAGE',
          bucket: bucket.name as string,
          path,
          sizeInKB,
          contentType: file.mimetype,
          originalName: file.originalname ?? objectName,
          churchId,
        },
      });

      fileManagerId = createdFile.id;
    }

    const letterhead = await this.prisma.churchLetterhead.upsert({
      where: { churchId },
      create: {
        church: { connect: { id: churchId } },
        logoFile: { connect: { id: fileManagerId } },
      } as any,
      update: {
        logoFile: { connect: { id: fileManagerId } },
      } as any,
      include: { logoFile: true },
    });

    return {
      message: 'OK',
      data: letterhead,
    };
  }
}
