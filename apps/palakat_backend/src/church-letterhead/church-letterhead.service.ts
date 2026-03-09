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
    await this.resolveRequesterChurchId(user);
    throw new BadRequestException('Letterhead customization is disabled');
  }

  async setLogoFile(logoFileId: number, user?: any) {
    await this.resolveRequesterChurchId(user);
    void logoFileId;
    throw new BadRequestException('Letterhead customization is disabled');
  }

  async updateMe(dto: UpdateChurchLetterheadDto, user?: any) {
    await this.resolveRequesterChurchId(user);
    void dto;
    throw new BadRequestException('Letterhead customization is disabled');
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
    await this.resolveRequesterChurchId(user);
    void file;
    throw new BadRequestException('Letterhead customization is disabled');
  }
}
