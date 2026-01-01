import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { randomBytes } from 'crypto';
import { PrismaService } from '../prisma.service';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AccountRole } from '../generated/prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  private async issueTokensWithRole(
    accountId: number,
    role: AccountRole,
    aud: string,
  ): Promise<{
    accessToken: string;
    refreshToken: string;
    refreshTokenExpiresAt: Date;
  }> {
    const accessToken = this.jwtService.sign(
      {
        sub: accountId,
        typ: 'user',
        role,
        aud,
      },
      {
        jwtid: randomBytes(16).toString('hex'),
      } as any,
    );
    const refreshToken = this.jwtService.sign(
      { sub: accountId, typ: 'refresh', jti: randomBytes(16).toString('hex') },
      { expiresIn: '7d' },
    );
    const refreshTokenExpiresAt = new Date(
      Date.now() + 7 * 24 * 60 * 60 * 1000,
    );
    return { accessToken, refreshToken, refreshTokenExpiresAt };
  }

  private normalizeIndonesianPhone(phone: string): string {
    let normalizedPhone = phone.trim();
    normalizedPhone = normalizedPhone.replace(/[\s\-()]/g, '');
    if (normalizedPhone.startsWith('+62')) {
      normalizedPhone = '0' + normalizedPhone.substring(3);
    } else if (
      normalizedPhone.startsWith('62') &&
      normalizedPhone.length > 11
    ) {
      normalizedPhone = '0' + normalizedPhone.substring(2);
    }
    return normalizedPhone;
  }

  async syncClaims(firebaseIdToken: string) {
    if (!firebaseIdToken || firebaseIdToken.trim().length === 0) {
      throw new BadRequestException('Firebase ID token is required');
    }

    const decoded = await this.firebaseAdmin
      .auth()
      .verifyIdToken(firebaseIdToken);
    const uid = decoded.uid;
    const phoneNumber = (decoded as any).phone_number as string | undefined;
    if (!phoneNumber) {
      throw new BadRequestException(
        'Firebase token does not contain phone_number',
      );
    }

    const normalizedPhone = this.normalizeIndonesianPhone(phoneNumber);
    const account: any = await this.prisma.account.findUnique({
      where: { phone: normalizedPhone },
      include: {
        membership: {
          select: { id: true, churchId: true },
        },
      },
    } as any);

    if (!account) {
      throw new UnauthorizedException('Account not found');
    }

    const membership = account.membership;
    if (!membership?.id || !membership?.churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    const claims = {
      accountId: account.id,
      membershipId: membership.id,
      churchId: membership.churchId,
    };

    await this.firebaseAdmin.auth().setCustomUserClaims(uid, claims);

    return {
      message: 'OK',
      data: {
        uid,
        claims,
      },
    };
  }

  async signInWithFirebaseIdToken(firebaseIdToken: string) {
    if (!firebaseIdToken || firebaseIdToken.trim().length === 0) {
      throw new BadRequestException('Firebase ID token is required');
    }

    const decoded = await this.firebaseAdmin
      .auth()
      .verifyIdToken(firebaseIdToken);
    const phoneNumber = (decoded as any).phone_number as string | undefined;
    if (!phoneNumber) {
      throw new BadRequestException(
        'Firebase token does not contain phone_number',
      );
    }

    const normalizedPhone = this.normalizeIndonesianPhone(phoneNumber);

    const account: any = await this.prisma.account.findUnique({
      where: { phone: normalizedPhone },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        gender: true,
        maritalStatus: true,
        dob: true,
        claimed: true,
        createdAt: true,
        updatedAt: true,
        role: true,
        isActive: true,
        membership: {
          include: {
            column: true,
            membershipPositions: true,
            church: {
              include: {
                location: true,
              },
            },
          },
        },
      },
    } as any);

    if (!account) {
      throw new NotFoundException('Account not found');
    }

    if (!account.isActive) {
      throw new ForbiddenException('Account is inactive');
    }

    const { accessToken, refreshToken, refreshTokenExpiresAt } =
      await this.issueTokensWithRole(account.id, account.role, 'user');

    const decodedRefresh: any = this.jwtService.decode(refreshToken);
    await this.prisma.account.update({
      where: { id: account.id },
      data: {
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decodedRefresh && typeof decodedRefresh === 'object'
            ? (decodedRefresh as any).jti
            : null,
      } as any,
    } as any);

    return {
      message: 'OK',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
        account,
      },
    };
  }

  async registerWithFirebaseIdToken(
    firebaseIdToken: string,
    dto: {
      name: string;
      email?: string | null;
      dob: string | Date;
      gender: any;
      maritalStatus: any;
      claimed?: boolean;
    },
  ) {
    if (!firebaseIdToken || firebaseIdToken.trim().length === 0) {
      throw new BadRequestException('Firebase ID token is required');
    }

    const decoded = await this.firebaseAdmin
      .auth()
      .verifyIdToken(firebaseIdToken);
    const phoneNumber = (decoded as any).phone_number as string | undefined;
    if (!phoneNumber) {
      throw new BadRequestException(
        'Firebase token does not contain phone_number',
      );
    }

    const normalizedPhone = this.normalizeIndonesianPhone(phoneNumber);

    const existing = await this.prisma.account.findUnique({
      where: { phone: normalizedPhone },
      select: { id: true },
    });
    if (existing?.id) {
      throw new ConflictException('Account already exists');
    }

    if (!dto?.name || dto.name.trim().length === 0) {
      throw new BadRequestException('name is required');
    }

    let dobValue: any = dto.dob;
    if (typeof dobValue === 'string' && !dobValue.endsWith('Z')) {
      dobValue = dobValue + 'Z';
    }
    const dob = dobValue ? new Date(dobValue) : null;
    if (!dob || isNaN(dob.getTime())) {
      throw new BadRequestException('dob is required');
    }

    const created: any = await this.prisma.account.create({
      data: {
        name: dto.name.trim(),
        phone: normalizedPhone,
        email:
          typeof dto.email === 'string' && dto.email.trim().length > 0
            ? dto.email.trim().toLowerCase()
            : null,
        gender: dto.gender,
        maritalStatus: dto.maritalStatus,
        dob,
        claimed: dto.claimed === true,
      } as any,
      include: {
        membership: {
          include: {
            column: true,
            membershipPositions: true,
            church: {
              include: {
                location: true,
              },
            },
          },
        },
      },
    } as any);

    const { accessToken, refreshToken, refreshTokenExpiresAt } =
      await this.issueTokensWithRole(
        created.id,
        created.role ?? AccountRole.USER,
        'user',
      );

    const decodedRefresh: any = this.jwtService.decode(refreshToken);
    await this.prisma.account.update({
      where: { id: created.id },
      data: {
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decodedRefresh && typeof decodedRefresh === 'object'
            ? (decodedRefresh as any).jti
            : null,
      } as any,
    } as any);

    return {
      message: 'OK',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
        account: created,
      },
    };
  }

  async generateClientToken(payload: { clientId: string }) {
    const token = this.jwtService.sign(payload);
    if (!token) {
      throw new Error('Token generation failed');
    }

    return {
      data: token,
      message: 'Client authenticated successfully',
    };
  }

  async validate(phone: string) {
    const account = await this.prisma.account.findUniqueOrThrow({
      where: { phone },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        gender: true,
        maritalStatus: true,
        dob: true,
        claimed: true,
        createdAt: true,
        updatedAt: true,
        role: true,
        membership: {
          include: {
            column: true,
            membershipPositions: true,
            church: {
              include: {
                location: true,
              },
            },
          },
        },
      },
    });

    // Generate both access and refresh tokens
    const { accessToken, refreshToken, refreshTokenExpiresAt } =
      await this.issueTokensWithRole(account.id, account.role, 'user');

    // Store refresh token in database
    const decoded: any = this.jwtService.decode(refreshToken);
    await this.prisma.account.update({
      where: { id: account.id },
      data: {
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decoded && typeof decoded === 'object' ? (decoded as any).jti : null,
      } as any,
    } as any);

    return {
      message: 'OK',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
        account,
      },
    };
  }

  async signIn(payload: { identifier: string; password: string }) {
    const { identifier, password } = payload;

    if (!identifier || identifier.trim().length === 0) {
      throw new BadRequestException('Identifier is required');
    }

    const trimmed = identifier.trim();
    const looksLikeEmail = /@/.test(trimmed);

    const account: any = await this.prisma.account.findFirst({
      where: looksLikeEmail
        ? { email: trimmed.toLowerCase() }
        : { phone: trimmed },
      include: {
        membership: {
          include: {
            membershipPositions: true,
            column: true,
            church: {
              include: {
                location: true,
              },
            },
          },
        },
      },
    } as any);

    if (!account) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!account.isActive) {
      throw new ForbiddenException('Account is inactive');
    }

    if (account.lockUntil && account.lockUntil > new Date()) {
      throw new ForbiddenException('Account is locked. Try again later');
    }

    if (!account.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatches = await bcrypt.compare(
      password,
      account.passwordHash,
    );

    const MAX_ATTEMPTS = 5;
    const LOCK_MINUTES = 5;

    if (!passwordMatches) {
      const newAttempts = (account.failedLoginAttempts ?? 0) + 1;
      const shouldLock = newAttempts >= MAX_ATTEMPTS;

      await this.prisma.account.update({
        where: { id: account.id },
        data: {
          failedLoginAttempts: shouldLock ? 0 : newAttempts,
          lockUntil: shouldLock
            ? new Date(Date.now() + LOCK_MINUTES * 60 * 1000)
            : null,
        } as any,
      } as any);

      throw new UnauthorizedException('Invalid credentials');
    }

    await this.prisma.account.update({
      where: { id: account.id },
      data: { failedLoginAttempts: 0, lockUntil: null } as any,
    } as any);

    const { accessToken, refreshToken, refreshTokenExpiresAt } =
      await this.issueTokensWithRole(
        account.id,
        account.role ?? AccountRole.USER,
        'user',
      );

    const decoded: any = this.jwtService.decode(refreshToken);
    await this.prisma.account.update({
      where: { id: account.id },
      data: {
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decoded && typeof decoded === 'object' ? (decoded as any).jti : null,
      } as any,
    } as any);

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, ...filteredAccount } = account;
    const sanitizedAccount = Object.keys(filteredAccount).reduce((acc, key) => {
      if (!key.toLowerCase().includes('token')) {
        acc[key] = filteredAccount[key];
      }
      return acc;
    }, {} as any);

    return {
      message: 'OK',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
        account: sanitizedAccount,
      },
    };
  }

  private async issueTokens(accountId: number): Promise<{
    accessToken: string;
    refreshToken: string;
    refreshTokenExpiresAt: Date;
  }> {
    const account = await this.prisma.account.findUnique({
      where: { id: accountId },
      select: { role: true },
    });
    return this.issueTokensWithRole(
      accountId,
      account?.role ?? AccountRole.USER,
      'user',
    );
  }

  async superAdminSignIn(payload: { phone: string; password: string }) {
    const { phone, password } = payload;

    if (!phone || phone.trim().length === 0) {
      throw new BadRequestException('Phone number is required');
    }
    if (!password || password.trim().length === 0) {
      throw new BadRequestException('Password is required');
    }

    const normalizedPhone = this.normalizeIndonesianPhone(phone);

    const account: any = await this.prisma.account.findFirst({
      where: { phone: normalizedPhone },
      select: {
        id: true,
        phone: true,
        passwordHash: true,
        isActive: true,
        lockUntil: true,
        role: true,
        failedLoginAttempts: true,
      } as any,
    } as any);

    if (!account) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (account.role !== AccountRole.SUPER_ADMIN) {
      throw new ForbiddenException('Super admin account required');
    }

    if (!account.isActive) {
      throw new ForbiddenException('Account is inactive');
    }

    if (account.lockUntil && account.lockUntil > new Date()) {
      throw new ForbiddenException('Account is locked. Try again later');
    }

    if (!account.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatches = await bcrypt.compare(
      password,
      account.passwordHash,
    );

    const MAX_ATTEMPTS = 5;
    const LOCK_MINUTES = 5;

    if (!passwordMatches) {
      const newAttempts = (account.failedLoginAttempts ?? 0) + 1;
      const shouldLock = newAttempts >= MAX_ATTEMPTS;

      await this.prisma.account.update({
        where: { id: account.id },
        data: {
          failedLoginAttempts: shouldLock ? 0 : newAttempts,
          lockUntil: shouldLock
            ? new Date(Date.now() + LOCK_MINUTES * 60 * 1000)
            : null,
        } as any,
      } as any);

      throw new UnauthorizedException('Invalid credentials');
    }

    await this.prisma.account.update({
      where: { id: account.id },
      data: { failedLoginAttempts: 0, lockUntil: null } as any,
    } as any);

    const { accessToken, refreshToken, refreshTokenExpiresAt } =
      await this.issueTokensWithRole(account.id, account.role, 'super-admin');

    const decoded: any = this.jwtService.decode(refreshToken);
    await this.prisma.account.update({
      where: { id: account.id },
      data: {
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decoded && typeof decoded === 'object' ? (decoded as any).jti : null,
      } as any,
    } as any);

    return {
      message: 'OK',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    };
  }

  async refreshToken(accountId: number, refreshToken: string) {
    const account: any = await this.prisma.account.findUnique({
      where: { id: accountId },
      select: {
        id: true,
        refreshTokenHash: true,
        refreshTokenExpiresAt: true,
        refreshTokenJti: true,
        isActive: true,
      } as any,
    } as any);

    if (!account || !account.isActive) {
      throw new UnauthorizedException('Invalid refresh');
    }
    if (!account.refreshTokenHash || !account.refreshTokenExpiresAt) {
      throw new UnauthorizedException('Invalid refresh');
    }
    if (account.refreshTokenExpiresAt < new Date()) {
      throw new UnauthorizedException('Refresh expired');
    }

    const decodedProvided: any = this.jwtService.decode(refreshToken);
    const providedJti =
      decodedProvided && typeof decodedProvided === 'object'
        ? (decodedProvided as any).jti
        : null;

    if (account.refreshTokenJti) {
      if (!providedJti || providedJti !== account.refreshTokenJti) {
        throw new UnauthorizedException('Invalid refresh');
      }
    }

    const valid = await bcrypt.compare(refreshToken, account.refreshTokenHash);
    if (!valid) {
      throw new UnauthorizedException('Invalid refresh');
    }

    const {
      accessToken,
      refreshToken: newRefreshToken,
      refreshTokenExpiresAt,
    } = await this.issueTokens(account.id);

    const decodedNew: any = this.jwtService.decode(newRefreshToken);
    await this.prisma.account.update({
      where: { id: account.id },
      data: {
        refreshTokenHash: await bcrypt.hash(newRefreshToken, 12),
        refreshTokenExpiresAt,
        refreshTokenJti:
          decodedNew && typeof decodedNew === 'object'
            ? (decodedNew as any).jti
            : null,
      } as any,
    } as any);

    return {
      message: 'OK',
      data: {
        accessToken,
        refreshToken: newRefreshToken,
      },
    };
  }

  async signOut(accountId: number) {
    await this.prisma.account.update({
      where: { id: accountId },
      data: {
        refreshTokenHash: null,
        refreshTokenExpiresAt: null,
        refreshTokenJti: null,
      } as any,
    } as any);

    return {
      message: 'Signed out',
      data: true,
    };
  }
}
