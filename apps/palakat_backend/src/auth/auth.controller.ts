import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Headers,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { RefreshDto } from './dto/refresh.dto';
import { SignInDto } from './dto/sign-in.dto';
import { SuperAdminSignInDto } from './dto/super-admin-sign-in.dto';
import { ValidatedClient } from './strategies/client.strategy';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly jwtService: JwtService,
  ) {}

  @Post('sync-claims')
  async syncClaims(@Headers('authorization') authorization?: string) {
    const token = authorization?.startsWith('Bearer ')
      ? authorization.substring('Bearer '.length)
      : undefined;
    if (!token) {
      throw new BadRequestException('Firebase ID token is required');
    }
    return this.authService.syncClaims(token);
  }

  @Get('signing')
  @UseGuards(AuthGuard('client-signing'))
  async signingClient(@Req() req: Request) {
    return this.authService.generateClientToken(req.user as ValidatedClient);
  }

  @Get('validate')
  async validate(@Query('phone') phone?: string) {
    if (!phone) {
      throw new BadRequestException('Phone number is required');
    }

    // Normalize phone number to Indonesian format (0XXXXXXXXXX)
    let normalizedPhone = phone.trim();

    // Remove all spaces, dashes, and other non-digit characters except +
    normalizedPhone = normalizedPhone.replace(/[\s\-()]/g, '');

    // Handle different formats:
    // +6281234567890 -> 081234567890
    // 6281234567890 -> 081234567890
    // 081234567890 -> 081234567890
    if (normalizedPhone.startsWith('+62')) {
      normalizedPhone = '0' + normalizedPhone.substring(3);
    } else if (
      normalizedPhone.startsWith('62') &&
      normalizedPhone.length > 11
    ) {
      // Only convert if it's clearly a phone number (62 followed by 10+ digits)
      normalizedPhone = '0' + normalizedPhone.substring(2);
    }

    return this.authService.validate(normalizedPhone);
  }

  @Post('sign-in')
  async signIn(@Body() dto: SignInDto) {
    return this.authService.signIn(dto);
  }

  @Post('super-admin/sign-in')
  async superAdminSignIn(@Body() dto: SuperAdminSignInDto) {
    return this.authService.superAdminSignIn(dto);
  }

  @Post('refresh')
  async refresh(@Body() body: RefreshDto) {
    try {
      const decoded: any = this.jwtService.verify(body.refreshToken);
      if (!decoded?.sub) {
        throw new BadRequestException('Invalid refresh token');
      }
      return this.authService.refreshToken(decoded.sub, body.refreshToken);
    } catch {
      throw new BadRequestException('Invalid refresh token');
    }
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('sign-out')
  async signOut(@Req() req: Request) {
    const user: any = req.user;
    if (!user?.userId) {
      throw new BadRequestException('Invalid user');
    }
    return this.authService.signOut(user.userId);
  }
}
