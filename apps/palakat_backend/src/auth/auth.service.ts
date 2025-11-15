import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { randomBytes } from 'crypto';
import { PrismaService } from 'nestjs-prisma';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

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
      await this.issueTokens(account.id);

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
      await this.issueTokens(account.id);

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
    const accessToken = this.jwtService.sign({ sub: accountId, typ: 'user' });
    const refreshToken = this.jwtService.sign(
      { sub: accountId, typ: 'refresh', jti: randomBytes(16).toString('hex') },
      { expiresIn: '7d' },
    );
    const refreshTokenExpiresAt = new Date(
      Date.now() + 7 * 24 * 60 * 60 * 1000,
    );
    return { accessToken, refreshToken, refreshTokenExpiresAt };
  }

  async refreshToken(accountId: number, refreshToken: string) {
    const account: any = await this.prisma.account.findUnique({
      where: { id: accountId },
      select: {
        id: true,
        refreshTokenHash: true,
        refreshTokenExpiresAt: true,
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
